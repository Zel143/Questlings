import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/home/home_screen.dart';
import '../features/inventory/inventory_screen.dart';
import '../features/party/party_screen.dart';
import '../features/shop/shop_screen.dart';
import '../features/auth/auth_screen.dart';
import '../features/auth/username_screen.dart';
import '../features/auth/setup_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show ConsumerWidget, WidgetRef;
import 'dart:async';
import 'theme.dart';
import '../features/home/evolution_screen.dart';

class MainLayout extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const MainLayout({super.key, required this.navigationShell});

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = index == navigationShell.currentIndex;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected ? QuestlingsTheme.lightGreen : Colors.transparent,
            border: isSelected ? Border.all(color: QuestlingsTheme.shadow, width: 2) : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: QuestlingsTheme.shadow),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  color: QuestlingsTheme.shadow,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.w900)),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await Supabase.instance.client.auth.signOut();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QUESTLINGS', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 4.0)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
            onPressed: () => _confirmSignOut(context),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Container(
            color: QuestlingsTheme.shadow,
            height: 4.0,
          ),
        ),
      ),
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: QuestlingsTheme.background,
          border: Border(
            top: BorderSide(color: QuestlingsTheme.shadow, width: 4),
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 70,
            child: Row(
              children: [
                _buildNavItem(Icons.home_outlined, 'Home', 0),
                _buildNavItem(Icons.inventory_2_outlined, 'Inventory', 1),
                _buildNavItem(Icons.group_outlined, 'Party', 2),
                _buildNavItem(Icons.storefront_outlined, 'Shop', 3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  refreshListenable: GoRouterRefreshStream(Supabase.instance.client.auth.onAuthStateChange),
  redirect: (context, state) {
    final session = Supabase.instance.client.auth.currentSession;

    // Not logged in -> login screen
    if (session == null && state.matchedLocation != '/login') {
      return '/login';
    }

    // Logged in but on login screen -> send to home
    if (session != null && state.matchedLocation == '/login') {
      return '/';
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const AuthScreen(),
    ),
    GoRoute(
      path: '/username',
      builder: (context, state) => const UsernameScreen(),
    ),
    GoRoute(
      path: '/setup',
      builder: (context, state) => const SetupScreen(),
    ),
    GoRoute(
      path: '/evolution',
      builder: (context, state) {
        final gifPath = state.extra as String? ?? 'assets/sprites/Sports-ling/Animation_Starter1.gif';
        return EvolutionScreen(gifPath: gifPath);
      },
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainLayout(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/inventory',
              builder: (context, state) => const InventoryScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/party',
              builder: (context, state) => const PartyScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/shop',
              builder: (context, state) => const ShopScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);