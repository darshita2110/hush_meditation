import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hush/features/ambience/screens/ambience_list_screen.dart';
import 'package:hush/features/ambience/screens/ambience_detail_screen.dart';
import 'package:hush/features/player/screens/session_player_screen.dart';
import 'package:hush/features/journal/screens/reflection_screen.dart';
import 'package:hush/features/history/screens/journal_history_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const AmbienceListScreen(),
      ),
      GoRoute(
        path: '/detail/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return AmbienceDetailScreen(ambienceId: id);
        },
      ),
      GoRoute(
        path: '/player/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return SessionPlayerScreen(ambienceId: id);
        },
      ),
      GoRoute(
        path: '/reflection/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ReflectionScreen(ambienceId: id);
        },
      ),
      GoRoute(
        path: '/history',
        builder: (context, state) => const JournalHistoryScreen(),
      ),
    ],
  );
});