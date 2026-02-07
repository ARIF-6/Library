import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/book_list_screen.dart';
import 'screens/add_book_screen.dart';
import 'screens/edit_book_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/user_dashboard_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/book_details_screen.dart';
import 'screens/user_reservations_screen.dart';
import 'screens/admin_reservations_screen.dart';
import 'screens/user_loans_screen.dart';
import 'screens/admin_loans_screen.dart';
import 'screens/fines_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/admin_home_screen.dart';
import 'screens/user_home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoggedIn = false;
  bool _isLoading = true;
  String? _role;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final role = prefs.getString('role');

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoggedIn = token != null;
      _role = role;
      _isLoading = false;
    });
  }

  Widget _resolveHomeScreen() {
    if (!_isLoggedIn) {
      return const LoginScreen();
    }

    if (_role == 'admin') {
      return const AdminHomeScreen();
    }

    return const UserHomeScreen();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    // Modern color palette
    const primaryColor = Color(0xFF006B7D); // Deep Teal
    const secondaryColor = Color(0xFFF59E0B); // Amber
    const backgroundColor = Color(0xFFF8FAFC); // Light Gray
    const surfaceColor = Colors.white;
    const textPrimary = Color(0xFF1E293B); // Dark Gray
    const textSecondary = Color(0xFF64748B); // Medium Gray

    final homeScreen = _resolveHomeScreen();

    return MaterialApp(
      title: 'E-Library',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          primary: primaryColor,
          secondary: secondaryColor,
          background: backgroundColor,
          surface: surfaceColor,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: backgroundColor,
        useMaterial3: true,

        // Modern Typography with Google Fonts
        textTheme: GoogleFonts.poppinsTextTheme().copyWith(
          displayLarge: GoogleFonts.poppins(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
          displayMedium: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
          displaySmall: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
          headlineMedium: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
          titleLarge: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
          titleMedium: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: textPrimary,
          ),
          bodyLarge: GoogleFonts.poppins(
            fontSize: 16,
            color: textPrimary,
          ),
          bodyMedium: GoogleFonts.poppins(
            fontSize: 14,
            color: textPrimary,
          ),
          bodySmall: GoogleFonts.poppins(
            fontSize: 12,
            color: textSecondary,
          ),
        ),

        // Modern AppBar Theme
        appBarTheme: AppBarTheme(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),

        // // Enhanced Card Theme
        // cardTheme: CardTheme(
        //   color: surfaceColor,
        //   elevation: 3,

        //   shape: RoundedRectangleBorder(
        //     borderRadius: BorderRadius.circular(16),
        //   ),
        //   margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        // ),

        // Modern Input Decoration
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surfaceColor,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: textSecondary.withOpacity(0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: textSecondary.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primaryColor, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          labelStyle: GoogleFonts.poppins(color: textSecondary),
          hintStyle: GoogleFonts.poppins(color: textSecondary.withOpacity(0.6)),
        ),

        // Modern Elevated Button Theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            elevation: 2,
            shadowColor: primaryColor.withOpacity(0.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // Modern Text Button Theme
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: primaryColor,
            textStyle: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // Floating Action Button Theme
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: secondaryColor,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),

        // Bottom Navigation Bar Theme
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: surfaceColor,
          selectedItemColor: primaryColor,
          unselectedItemColor: textSecondary,
          selectedLabelStyle: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
      ),
      home: homeScreen,
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/admin_dashboard': (context) => const AdminDashboardScreen(),
        '/user_dashboard': (context) => const UserDashboardScreen(),
        '/admin_home': (context) => const AdminHomeScreen(),
        '/user_home': (context) => const UserHomeScreen(),
        '/books': (context) => const BookListScreen(),
        '/add_book': (context) => const AddBookScreen(),
        '/edit_book': (context) => const EditBookScreen(),
        '/book_details': (context) => const BookDetailsScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/my_reservations': (context) => const UserReservationsScreen(),
        '/admin_reservations': (context) => const AdminReservationsScreen(),
        '/my_loans': (context) => const UserLoansScreen(),
        '/admin_loans': (context) => const AdminLoansScreen(),
        '/fines': (context) => const FinesScreen(),
        '/reports': (context) => const ReportsScreen(),
        '/splash': (context) => const SplashScreen(),
      },
    );
  }
}
