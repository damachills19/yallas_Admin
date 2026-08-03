import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/admin_repository.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) => AdminRepository());
