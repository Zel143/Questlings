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

<<<<<<< Updated upstream
=======
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

>>>>>>> Stashed changes
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
        return ScaffoldWithNavBar(navigationShell: navigationShell);
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

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

const _navItems = [
  _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home'),
  _NavItem(icon: Icons.backpack_outlined, activeIcon: Icons.backpack, label: 'Inventory'),
  _NavItem(icon: Icons.people_outline, activeIcon: Icons.people, label: 'Party'),
  _NavItem(icon: Icons.store_outlined, activeIcon: Icons.store, label: 'Shop'),
];

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({
    required this.navigationShell,
    Key? key,
  }) : super(key: key ?? const ValueKey<String>('ScaffoldWithNavBar'));

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: QuestlingsTheme.backgroundGradient,
        ),
        child: navigationShell,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: QuestlingsTheme.surfaceDark,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_navItems.length, (index) {
                final isSelected = navigationShell.currentIndex == index;
                final item = _navItems[index];
                return _NavBarItem(
                  icon: isSelected ? item.activeIcon : item.icon,
                  label: item.label,
                  isSelected: isSelected,
                  onTap: () => _onTap(context, index),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  void _onTap(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? QuestlingsTheme.primaryLight.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? QuestlingsTheme.primaryLight
                  : QuestlingsTheme.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? QuestlingsTheme.primaryLight
                    : QuestlingsTheme.textSecondary,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}