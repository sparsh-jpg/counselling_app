import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/connection_provider.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/mentor_dashboard/mentor_dashboard_screen.dart';
import 'screens/chat/chat_screen.dart';
import 'screens/video_call/video_call_screen.dart';
import 'screens/mentors/models/connection_model.dart';
import 'screens/role_selection_screen.dart'; // Re-added your role selection screen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
    
    // 1. Wait for SharedPreferences to load from the device (Persistent login fix)
    if (!auth.isInitialized) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A0A1A),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF00E5CC)),
        ),
      );
    }

    // 2. Once loaded, if logged in, route to the correct Dashboard
    if (auth.isLoggedIn) {
      return auth.isMentor
          ? const MentorDashboardScreen()
          : const DashboardScreen();
    }
    
    // 3. Not logged in -> Go to your Role Selection Screen (Restores your UI!)
    return const RoleSelectionScreen(); 
  }
}