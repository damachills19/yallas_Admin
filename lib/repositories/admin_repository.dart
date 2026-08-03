import '../config/supabase_config.dart';
import '../models/admin_user.dart';
import '../models/category.dart';
import '../models/complaint.dart';
import '../models/coupon.dart';
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
