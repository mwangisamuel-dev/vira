import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/vira_theme.dart';
import 'core/router/vira_router.dart';
import 'core/services/location_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await LocationService.instance.init();

  runApp(const ProviderScope(child: ViraApp()));
}

/// Router is built once per app lifetime via this provider rather than
/// inline in build() — GoRouter holds internal navigation state that
/// must not be discarded on every widget rebuild. It still re-evaluates
/// `redirect` reactively because the redirect closure reads authProvider
/// fresh via `ref.read` each time GoRouter invokes it, and we feed
/// `refreshListenable` so a sign-in/sign-out actually triggers that
/// re-evaluation.
final _routerProvider = Provider<GoRouter>((ref) {
  return ViraRouter.build(ref);
});

/// Root widget. One MaterialApp, one theme, one router — role determines
/// which subtree of screens a session can reach (see ViraRouter), not a
/// separate app shell per role.
class ViraApp extends ConsumerWidget {
  const ViraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(_routerProvider);

    return MaterialApp.router(
      title: 'VIRA',
      debugShowCheckedModeBanner: false,
      theme: ViraTheme.dark,
      darkTheme: ViraTheme.dark,
      themeMode: ThemeMode.dark,
      routerConfig: router,
    );
  }
}
