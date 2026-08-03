import '../config/supabase_config.dart';
import '../models/admin_user.dart';
import '../models/category.dart';
import '../models/complaint.dart';
import '../models/coupon.dart';
import '../models/paid_order.dart';
import '../models/trainer_application.dart';
import '../models/training_package.dart';
import '../models/training_program.dart';

/// Single repository for the whole admin portal. Unlike the main Yalla Fit
/// app (one interface + mock/Supabase pair per domain, since it also ships
/// an offline-friendly mock mode), this is a small single-purpose internal
/// tool that always talks to the real backend, so one class per concern
/// isn't worth the ceremony — everything lives here, grouped by section.
class AdminRepository {
  // ---------------------------------------------------------------------
  // Auth
  // ---------------------------------------------------------------------
  Future<AdminUser> login(String email, String password) async {
    final res = await SupabaseConfig.client.auth.signInWithPassword(email: email.trim(), password: password);
    final user = res.user;
    if (user == null) throw Exception('Invalid credentials');
    return _fetchAdminUser(user.id, user.email ?? email);
  }

  Future<void> logout() => SupabaseConfig.client.auth.signOut();

  Future<AdminUser?> currentUser() async {
    final user = SupabaseConfig.client.auth.currentUser;
    if (user == null) return null;
    return _fetchAdminUser(user.id, user.email ?? '');
  }

  Future<AdminUser> _fetchAdminUser(String id, String email) async {
    final row = await SupabaseConfig.client.from('profiles').select().eq('id', id).maybeSingle();
    return AdminUser(
      id: id,
      firstName: row?['first_name'] as String? ?? '',
      lastName: row?['last_name'] as String? ?? '',
      email: row?['email'] as String? ?? email,
      isAdmin: row?['is_admin'] as bool? ?? false,
    );
  }

  // ---------------------------------------------------------------------
  // Dashboard stats
  // ---------------------------------------------------------------------
  Future<Map<String, int>> getUserRoleCounts() async {
    final rows = await SupabaseConfig.client.from('profiles').select('role');
    var clients = 0, trainers = 0;
    for (final r in rows as List) {
      if ((r as Map)['role'] == 'trainer') {
        trainers++;
      } else {
        clients++;
      }
    }
    return {'client': clients, 'trainer': trainers};
  }

  /// Cumulative signups per role for each of the last 6 calendar months
  /// (including the current one), for the dashboard's growth chart.
  Future<List<Map<String, int>>> getUserGrowthByMonth() async {
    final rows = await SupabaseConfig.client.from('profiles').select('role, created_at');
    final now = DateTime.now();
    final months = List.generate(6, (i) => DateTime(now.year, now.month - (5 - i), 1));

    final parsed = (rows as List).map((r) {
      final m = r as Map;
      return (
        role: m['role'] as String? ?? 'client',
        createdAt: DateTime.tryParse(m['created_at'] as String? ?? '') ?? now,
      );
    }).toList();

    return months.map((monthStart) {
      final cutoff = DateTime(monthStart.year, monthStart.month + 1, 1);
      var clients = 0, trainers = 0;
      for (final p in parsed) {
        if (p.createdAt.isBefore(cutoff)) {
          if (p.role == 'trainer') {
            trainers++;
          } else {
            clients++;
          }
        }
      }
      return {'month': monthStart.month, 'client': clients, 'trainer': trainers};
    }).toList();
  }

  Future<Map<String, int>> getApplicationStatusCounts() async {
    final rows = await SupabaseConfig.client.from('trainer_applications').select('verification_status');
    var pending = 0, approved = 0, rejected = 0;
    for (final r in rows as List) {
      switch ((r as Map)['verification_status']) {
        case 'approved':
          approved++;
        case 'rejected':
          rejected++;
        default:
          pending++;
      }
    }
    return {'pending': pending, 'approved': approved, 'rejected': rejected};
  }

  // ---------------------------------------------------------------------
  // Orders / trainer allocation
  // ---------------------------------------------------------------------
  Future<List<PaidOrder>> getPaidOrders({bool onlyUnassigned = false}) async {
    // orders.user_id and profiles.id both reference auth.users(id) but
    // there's no direct FK between orders and profiles, so PostgREST can't
    // auto-embed profiles here — fetched separately and merged below.
    var builder = SupabaseConfig.client
        .from('orders')
        .select('id, total, created_at, trainer_id, user_id, addresses(city), '
            'trainers(name), order_items(training_packages(name))')
        .eq('payment_status', 'paid');
    if (onlyUnassigned) builder = builder.filter('trainer_id', 'is', null);
    final rows = await builder.order('created_at', ascending: false) as List;

    final userIds = rows.map((r) => (r as Map)['user_id'] as String).toSet().toList();
    final names = <String, String>{};
    if (userIds.isNotEmpty) {
      final profileRows = await SupabaseConfig.client
          .from('profiles')
          .select('id, first_name, last_name')
          .inFilter('id', userIds);
      for (final p in profileRows as List) {
        final row = p as Map<String, dynamic>;
        names[row['id'] as String] = '${row['first_name'] ?? ''} ${row['last_name'] ?? ''}'.trim();
      }
    }

    return rows
        .map((r) => PaidOrder.fromRow(r as Map<String, dynamic>, clientName: names[r['user_id']] ?? ''))
        .toList();
  }

  /// Trainers with their current allocated (paid, still-active) client
  /// count, so an admin can pick the least-loaded trainer.
  Future<List<TrainerRosterEntry>> getTrainerRoster() async {
    final trainers = await SupabaseConfig.client.from('trainers').select('id, name').not('user_id', 'is', null);
    final orders = await SupabaseConfig.client.from('orders').select('trainer_id').eq('payment_status', 'paid');
    final counts = <String, int>{};
    for (final o in orders as List) {
      final tid = (o as Map)['trainer_id'] as String?;
      if (tid != null) counts[tid] = (counts[tid] ?? 0) + 1;
    }
    return (trainers as List)
        .map((t) => TrainerRosterEntry(
              id: (t as Map)['id'] as String,
              name: t['name'] as String? ?? 'Trainer',
              activeClientCount: counts[t['id']] ?? 0,
            ))
        .toList()
      ..sort((a, b) => a.activeClientCount.compareTo(b.activeClientCount));
  }

  Future<void> assignTrainer(String orderId, String trainerId) => SupabaseConfig.client.from('orders').update({
        'trainer_id': trainerId,
        'assigned_at': DateTime.now().toIso8601String(),
      }).eq('id', orderId);

  /// Cash-on-delivery orders: there's no online gateway confirmation for
  /// these, so they sit at payment_status='unpaid' forever unless an admin
  /// manually marks them paid (e.g. once cash is actually collected) —
  /// otherwise they never appear anywhere for trainer allocation.
  Future<List<PaidOrder>> getUnpaidCashOrders() async {
    final rows = await SupabaseConfig.client
        .from('orders')
        .select('id, total, created_at, trainer_id, user_id, addresses(city), '
            'trainers(name), order_items(training_packages(name))')
        .eq('payment_status', 'unpaid')
        .eq('bank_transfer_status', 'none')
        .order('created_at', ascending: false) as List;

    final userIds = rows.map((r) => (r as Map)['user_id'] as String).toSet().toList();
    final names = <String, String>{};
    if (userIds.isNotEmpty) {
      final profileRows =
          await SupabaseConfig.client.from('profiles').select('id, first_name, last_name').inFilter('id', userIds);
      for (final p in profileRows as List) {
        final row = p as Map<String, dynamic>;
        names[row['id'] as String] = '${row['first_name'] ?? ''} ${row['last_name'] ?? ''}'.trim();
      }
    }

    return rows
        .map((r) => PaidOrder.fromRow(r as Map<String, dynamic>, clientName: names[r['user_id']] ?? ''))
        .toList();
  }

  Future<void> markOrderPaidCash(String orderId) => SupabaseConfig.client.from('orders').update({
        'payment_status': 'paid',
        'payment_method': 'cash',
        'status': 'confirmed',
      }).eq('id', orderId);

  // ---------------------------------------------------------------------
  // Bank transfer review (manual payment method — no automated gateway)
  // ---------------------------------------------------------------------
  Future<List<PendingBankTransfer>> getPendingBankTransfers() async {
    final rows = await SupabaseConfig.client
        .from('orders')
        .select('id, total, created_at, user_id, bank_transfer_slip_path')
        .eq('bank_transfer_status', 'pending')
        .order('created_at', ascending: false) as List;

    final userIds = rows.map((r) => (r as Map)['user_id'] as String).toSet().toList();
    final names = <String, String>{};
    if (userIds.isNotEmpty) {
      final profileRows =
          await SupabaseConfig.client.from('profiles').select('id, first_name, last_name').inFilter('id', userIds);
      for (final p in profileRows as List) {
        final row = p as Map<String, dynamic>;
        names[row['id'] as String] = '${row['first_name'] ?? ''} ${row['last_name'] ?? ''}'.trim();
      }
    }

    return rows
        .map((r) => PendingBankTransfer.fromRow(r as Map<String, dynamic>, clientName: names[r['user_id']] ?? ''))
        .toList();
  }

  Future<String> getSlipUrl(String path) async {
    return SupabaseConfig.client.storage.from('payment-slips').createSignedUrl(path, 60 * 10);
  }

  Future<void> approveBankTransfer(String orderId) => SupabaseConfig.client.from('orders').update({
        'bank_transfer_status': 'approved',
        'payment_status': 'paid',
        'payment_method': 'bank_transfer',
        'status': 'confirmed',
      }).eq('id', orderId);

  Future<void> rejectBankTransfer(String orderId) =>
      SupabaseConfig.client.from('orders').update({'bank_transfer_status': 'rejected'}).eq('id', orderId);

  // ---------------------------------------------------------------------
  // Trainer applications
  // ---------------------------------------------------------------------
  Future<List<TrainerApplication>> getApplications({VerificationStatus? filterStatus}) async {
    var builder = SupabaseConfig.client.from('trainer_applications').select();
    if (filterStatus != null) {
      final s = filterStatus == VerificationStatus.approved
          ? 'approved'
          : filterStatus == VerificationStatus.rejected
              ? 'rejected'
              : 'pending';
      builder = builder.eq('verification_status', s);
    }
    final rows = await builder.order('submitted_at', ascending: false);
    return (rows as List).map((r) => TrainerApplication.fromRow(r as Map<String, dynamic>)).toList();
  }

  Future<void> respondToApplication(String trainerUserId, {required bool approve}) async {
    await SupabaseConfig.client
        .from('trainer_applications')
        .update({'verification_status': approve ? 'approved' : 'rejected'})
        .eq('trainer_user_id', trainerUserId);
  }

  Future<String> getDocumentUrl(String path) async {
    return SupabaseConfig.client.storage.from('trainer-documents').createSignedUrl(path, 60 * 10);
  }

  // ---------------------------------------------------------------------
  // Categories
  // ---------------------------------------------------------------------
  Future<List<TrainingCategory>> getCategories() async {
    final rows = await SupabaseConfig.client.from('categories').select();
    return (rows as List).map((r) => TrainingCategory.fromRow(r as Map<String, dynamic>)).toList();
  }

  Future<void> createCategory(TrainingCategory c) =>
      SupabaseConfig.client.from('categories').insert({'name': c.name, 'icon_seed': c.iconSeed});

  Future<void> updateCategory(TrainingCategory c) => SupabaseConfig.client
      .from('categories')
      .update({'name': c.name, 'icon_seed': c.iconSeed}).eq('id', c.id);

  Future<void> deleteCategory(String id) => SupabaseConfig.client.from('categories').delete().eq('id', id);

  // ---------------------------------------------------------------------
  // Packages
  // ---------------------------------------------------------------------
  Future<List<TrainingPackage>> getPackages() async {
    final rows = await SupabaseConfig.client.from('training_packages').select();
    return (rows as List).map((r) => TrainingPackage.fromRow(r as Map<String, dynamic>)).toList();
  }

  Future<void> createPackage(TrainingPackage p) =>
      SupabaseConfig.client.from('training_packages').insert(p.toRow());

  Future<void> updatePackage(TrainingPackage p) =>
      SupabaseConfig.client.from('training_packages').update(p.toRow()).eq('id', p.id);

  Future<void> deletePackage(String id) => SupabaseConfig.client.from('training_packages').delete().eq('id', id);

  // ---------------------------------------------------------------------
  // Programs
  // ---------------------------------------------------------------------
  Future<List<TrainingProgram>> getPrograms() async {
    final rows = await SupabaseConfig.client.from('training_programs').select();
    return (rows as List).map((r) => TrainingProgram.fromRow(r as Map<String, dynamic>)).toList();
  }

  Future<void> createProgram(TrainingProgram p) =>
      SupabaseConfig.client.from('training_programs').insert(p.toRow());

  Future<void> updateProgram(TrainingProgram p) =>
      SupabaseConfig.client.from('training_programs').update(p.toRow()).eq('id', p.id);

  Future<void> deleteProgram(String id) => SupabaseConfig.client.from('training_programs').delete().eq('id', id);

  // ---------------------------------------------------------------------
  // Coupons
  // ---------------------------------------------------------------------
  Future<List<Coupon>> getCoupons() async {
    final rows = await SupabaseConfig.client.from('coupons').select();
    return (rows as List).map((r) => Coupon.fromRow(r as Map<String, dynamic>)).toList();
  }

  Future<void> createCoupon(Coupon c) => SupabaseConfig.client.from('coupons').insert({
        'code': c.code,
        'discount_percent': c.discountPercent,
        'is_active': c.isActive,
      });

  Future<void> updateCoupon(Coupon c) => SupabaseConfig.client
      .from('coupons')
      .update({'discount_percent': c.discountPercent, 'is_active': c.isActive}).eq('code', c.code);

  Future<void> deleteCoupon(String code) => SupabaseConfig.client.from('coupons').delete().eq('code', code);

  // ---------------------------------------------------------------------
  // Complaints
  // ---------------------------------------------------------------------
  Future<List<Complaint>> getComplaints({String? filterStatus}) async {
    var builder = SupabaseConfig.client.from('complaints').select();
    if (filterStatus != null) builder = builder.eq('status', filterStatus);
    final rows = await builder.order('created_at', ascending: false);
    return (rows as List).map((r) => Complaint.fromRow(r as Map<String, dynamic>)).toList();
  }

  Future<void> respondToComplaint(String id, {ComplaintStatus? status, String? adminResponse}) async {
    final update = <String, dynamic>{'updated_at': DateTime.now().toIso8601String()};
    if (status != null) update['status'] = complaintStatusToString(status);
    if (adminResponse != null) update['admin_response'] = adminResponse;
    await SupabaseConfig.client.from('complaints').update(update).eq('id', id);
  }
}
