import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/firebase_options.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;
  bool _initialized = false;
  bool _loggedIn = false;
  String _currentUser = '';

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDark') ?? false;
    final logged = prefs.getBool('isLoggedIn') ?? false;
    final user = prefs.getString('currentUser') ?? '';
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      _loggedIn = logged;
      _currentUser = user;
      _initialized = true;
    });
  }

  Future<void> _setTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDark', isDark);
    setState(() => _themeMode = isDark ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> _setLogin(bool logged, {String username = ''}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', logged);
    if (logged) {
      await prefs.setString('currentUser', username);
    } else {
      await prefs.remove('currentUser');
    }
    setState(() {
      _loggedIn = logged;
      _currentUser = logged ? username : '';
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'English Learner',
      theme: ThemeData(brightness: Brightness.light, primarySwatch: Colors.blue),
      darkTheme: ThemeData(brightness: Brightness.dark, primarySwatch: Colors.deepPurple),
      themeMode: _themeMode,
      home: _loggedIn
          ? HomePage(
              currentUsername: _currentUser,
              isDark: _themeMode == ThemeMode.dark,
              onToggleTheme: _setTheme,
              onLogout: () => _setLogin(false),
            )
          : LoginPage(
              isDark: _themeMode == ThemeMode.dark,
              onToggleTheme: _setTheme,
              onLogin: (username) => _setLogin(true, username: username),
            ),
    );
    
  }
}
