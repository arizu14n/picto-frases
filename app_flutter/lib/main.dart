
import 'package:app_flutter/screens/auth_screen.dart';
import 'package:app_flutter/screens/home_screen.dart';
import 'package:app_flutter/services/phrase_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// TODO: Replace with your Supabase project details.
// You can get these from your Supabase project settings.
// If you are running Supabase locally, you can get these by running `supabase status`.
const String supabaseUrl = 'http://127.0.0.1:54321';
const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0';

Future<void> main() async {
  // Initialize Flutter binding.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase.
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(const MyApp());
}

// Get a reference to the Supabase client.
final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PhraseProvider(),
      child: MaterialApp(
        title: 'PictoFrases',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const AuthStateChangeHandler(),
      ),
    );
  }
}

class AuthStateChangeHandler extends StatelessWidget {
  const AuthStateChangeHandler({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData && snapshot.data!.session != null) {
          return HomeScreen();
        } else {
          return const AuthScreen();
        }
      },
    );
  }
}
