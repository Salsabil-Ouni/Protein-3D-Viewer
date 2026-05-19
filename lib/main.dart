import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'core/network/router.dart';
import 'core/providers/theme_provider.dart';
import 'features/protein/data/models/protein_hive_model.dart';
import 'firebase_options.dart';

// True only when firebase_options.dart has real credentials AND init succeeds.
bool firebaseReady = false;

bool get _isFirebaseConfigured =>
    DefaultFirebaseOptions.currentPlatform.projectId != 'YOUR_PROJECT_ID';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (_isFirebaseConfigured) {
    try {
      await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform);
      firebaseReady = true;
      await _seedFirebaseDemo();
    } catch (e) {
      debugPrint('⚠️ Firebase init failed: $e');
    }
  }

  await Hive.initFlutter();
  Hive.registerAdapter(ProteinHiveModelAdapter());
  await Hive.openBox<String>('history');

  if (!firebaseReady) await _seedLocalDemo();

  runApp(const ProviderScope(child: Protein3DApp()));
}

Future<void> _seedFirebaseDemo() async {
  try {
    await fb.FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: 'demo@protein3d.app',
      password: 'demo1234',
    );
    await fb.FirebaseAuth.instance.currentUser?.updateDisplayName('Demo');
    await fb.FirebaseAuth.instance.signOut();
    debugPrint('✅ Firebase demo account created');
  } on fb.FirebaseAuthException catch (e) {
    if (e.code == 'email-already-in-use') {
      debugPrint('ℹ️ Firebase demo account already exists');
    } else {
      debugPrint('⚠️ Could not seed Firebase demo: ${e.code}');
    }
  }
}

Future<void> _seedLocalDemo() async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString('registered_users');
  final users = raw != null
      ? Map<String, dynamic>.from(jsonDecode(raw) as Map)
      : <String, dynamic>{};
  final demoKey = 'demo@protein3d.app'.toLowerCase().trim();
  if (!users.containsKey(demoKey)) {
    users[demoKey] = {
      'id': 1,
      'password': 'demo1234',
      'first_name': 'Demo',
      'last_name': 'User',
    };
    await prefs.setString('registered_users', jsonEncode(users));
  }
}

class Protein3DApp extends ConsumerWidget {
  const Protein3DApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeProvider);
    return MaterialApp.router(
      title: 'Protein3D Viewer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
