import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/protein/presentation/screens/home_screen.dart';
import '../../features/protein/presentation/screens/search_screen.dart';
import '../../features/protein/presentation/screens/protein_detail_screen.dart';
import '../../features/protein/presentation/screens/favorites_screen.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: authState.isAuthenticated ? '/home' : '/login',
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (!isAuthenticated && !isAuthRoute) return '/login';
      if (isAuthenticated && isAuthRoute) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (c, s) => const LoginScreen()),
      GoRoute(path: '/register', builder: (c, s) => const RegisterScreen()),
      GoRoute(
        path: '/home',
        builder: (c, s) => const HomeScreen(),
        routes: [
          GoRoute(path: 'search', builder: (c, s) => const SearchScreen()),
          GoRoute(
            path: 'detail/:pdbId',
            builder: (c, s) => ProteinDetailScreen(pdbId: s.pathParameters['pdbId']!),
          ),
          GoRoute(path: 'favorites', builder: (c, s) => const FavoritesScreen()),
        ],
      ),
    ],
  );
});
