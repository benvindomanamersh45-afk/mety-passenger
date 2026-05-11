import 'package:flutter/material.dart';
import 'package:metty_pro/core/constants/theme/app_theme.dart';
import 'package:metty_pro/core/theme/app_colors.dart';
import 'package:metty_pro/core/theme/app_theme.dart';
import 'package:metty_pro/features/auth/passenger/presentation/screens/home_screen.dart';
import 'package:metty_pro/features/auth/passenger/presentation/screens/rate_trip_screen.dart';
import 'package:metty_pro/features/auth/passenger/presentation/screens/splash_screen.dart';
import 'package:metty_pro/features/auth/passenger/presentation/screens/profile_screen.dart';
import 'package:metty_pro/features/auth/passenger/presentation/screens/history_screen.dart';
import 'package:metty_pro/features/auth/passenger/presentation/screens/trip_details_screen.dart';
import 'package:metty_pro/features/auth/presentation/screens/home_screen.dart';
import 'package:metty_pro/features/auth/presentation/screens/login_screen.dart';
import 'package:metty_pro/features/auth/presentation/screens/register_screen.dart';
import 'package:metty_pro/features/passenger/presentation/screens/ride_request_map_screen.dart';
import 'package:metty_pro/features/passenger/presentation/screens/trip_details_screen.dart';
import 'package:metty_pro/features/passenger/presentation/screens/rate_trip_screen.dart';
import 'package:metty_pro/core/api/api_client.dart';
import 'package:metty_pro/core/models/trip_model.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'METY Pro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        // Rota para solicitar viagem com mapa (destino digitado)
        '/ride-request': (context) => const RideRequestMapScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/history': (context) => const HistoryScreen(),
        '/trip-details': (context) => TripDetailsScreen(
          trip: ModalRoute.of(context)!.settings.arguments as Trip,
        ),
        '/rate-trip': (context) => RateTripScreen(
          trip: ModalRoute.of(context)!.settings.arguments as Trip,
        ),
        // Rota de teste (opcional)
        
      },
    );
  }
}

// SplashScreen
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 2));
    
    final isLoggedIn = await ApiClient.isLoggedIn();
    
    if (mounted) {
      if (isLoggedIn) {
        try {
          await ApiClient.refreshToken();
        } catch (e) {
          await ApiClient.logout();
        }
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.metyBlue, AppColors.metyBlueLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Center(
                child: Icon(
                  Icons.directions_car_rounded,
                  color: Colors.white,
                  size: 60,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'METY Pro',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              color: AppColors.metyBlue,
            ),
          ],
        ),
      ),
    );
  }
}
