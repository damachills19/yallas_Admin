import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/supabase_config.dart';
import 'theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/locale_provider.dart';
import 'screens/login_screen.dart';
import 'screens/shell_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.init();
  runApp(const ProviderScope(child: YallaFitAdminApp()));
}

class YallaFitAdminApp extends ConsumerWidget {
  const YallaFitAdminApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(adminLocaleProvider);
    return Directionality(
      textDirection: locale == AppLocale.ar ? TextDirection.rtl : TextDirection.ltr,
      child: MaterialApp(
        title: 'Yalla Fit Admin',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const _RootGate(),
      ),
    );
  }
}

/// Restores any existing Supabase session on load, then routes to the
/// login screen or the admin shell depending on whether that session
/// belongs to an admin account.
class _RootGate extends ConsumerStatefulWidget {
  const _RootGate();

  @override
  ConsumerState<_RootGate> createState() => _RootGateState();
}

class _RootGateState extends ConsumerState<_RootGate> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(adminAuthProvider.notifier).restoreSession());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminAuthProvider);
    if (!state.checked) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (state.user != null && state.user!.isAdmin) {
      return const ShellScreen();
    }
    return const LoginScreen();
  }
}
