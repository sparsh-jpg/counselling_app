import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/connection_provider.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/mentor_dashboard/mentor_dashboard_screen.dart';
import 'screens/chat/chat_screen.dart';
import 'screens/video_call/video_call_screen.dart';
import 'screens/mentors/models/connection_model.dart';
import 'screens/role_selection_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..init()),
        ChangeNotifierProvider(create: (_) => ConnectionProvider()),
      ],
      child: MaterialApp(
        title: 'JEE Guide',
        debugShowCheckedModeBanner: false,
        home: const _AppEntry(),
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/video-call':
              final args = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                builder: (_) => VideoCallScreen(
                  channelName: args['channelName'],
                  otherName: args['otherName'],
                ),
              );
            case '/chat':
              final args = settings.arguments as Map<String, dynamic>;
              final conn = args['connection'] as ConnectionRequest;
              return MaterialPageRoute(
                builder: (ctx) => ChatScreen(
                  connection: conn,
                  currentUserId: ctx.read<AuthProvider>().currentUser!.id,
                  currentUserName: ctx.read<AuthProvider>().currentUser!.name,
                  otherName: args['otherName'],
                ),
              );
            default:
              return null;
          }
        },
      ),
    );
  }
}

class _AppEntry extends StatelessWidget {
  const _AppEntry();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!auth.isInitialized) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A0A1A),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF00E5CC)),
        ),
      );
    }

    if (auth.isLoggedIn) {
      return auth.isMentor
          ? const MentorDashboardScreen()
          : const DashboardScreen();
    }

    return const RoleSelectionScreen();
  }
}