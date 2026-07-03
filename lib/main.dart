import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_router.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://bzckanmfgkcljvsroamr.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ6Y2thbm1mZ2tjbGp2c3JvYW1yIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODMwMjgxMzIsImV4cCI6MjA5ODYwNDEzMn0.ynKAmkCD2sTr4N62uhuB-r_OND0nnQJokSCbVWUqXpE',
  );
  
  runApp(const ProviderScope(child: AarogyaPlusApp()));
}

class AarogyaPlusApp extends ConsumerWidget {
  const AarogyaPlusApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'AarogyaPlus',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
