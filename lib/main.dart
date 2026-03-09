import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'config/theme/app_theme.dart';
import 'config/routes/app_router.dart';
import 'data/models/reflection_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(ReflectionModelAdapter());
  await Hive.openBox<ReflectionModel>('reflections');
  await Hive.openBox<String>('session_state');

  runApp(
    const ProviderScope(
      child: HushApp(),
    ),
  );
}

class HushApp extends ConsumerWidget {
  const HushApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'Hush',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routerConfig: goRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
