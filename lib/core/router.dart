import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/home/home_screen.dart';
import '../features/inventory/inventory_screen.dart';
import '../features/party/party_screen.dart';
import '../features/shop/shop_screen.dart';
import '../features/auth/auth_screen.dart';
import '../features/auth/username_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'theme.dart';

class MainLayout extends StatelessWidget {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QUESTLINGS', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 4.0)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
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

/// Tracks whether the current user still needs to set up their profile.
/// Set to false once the user record exists in public.users.
bool needsUsernameSetup = true;

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) {
        // Reset the flag when auth state changes (e.g. sign out)
        final session = Supabase.instance.client.auth.currentSession;
        if (session == null) {
          needsUsernameSetup = true;
        }
        notifyListeners();
      },
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
    final isLoggingIn = state.matchedLocation == '/login';
    final isSettingUsername = state.matchedLocation == '/username';

    // Not logged in -> login screen
    if (session == null && !isLoggingIn && !isSettingUsername) {
      return '/login';
    }

    // Logged in but on auth screen -> redirect away
    if (session != null && isLoggingIn) {
      // Check immediately whether to go to username or home
      return needsUsernameSetup ? '/username' : '/';
    }

    // Logged in but hasn't set username yet -> redirect to username screen
    if (session != null && needsUsernameSetup && !isSettingUsername) {
      return '/username';
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