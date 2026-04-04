import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sim_tchad/core/constants/app_colors.dart';
import 'package:sim_tchad/services/auth_service.dart';
import 'package:sim_tchad/views/login_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
  
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    
    _controller.forward();
    _initializeApp();
  }

    /// 🔹 Vérifie la session
  Future<void> checkSession() async {
    // petit délai pour afficher le Splash
    await Future.delayed(const Duration(seconds: 2));

    final prefs = await SharedPreferences.getInstance();
    final hasUser = prefs.containsKey("userLogin");
    final isValid = await AuthService.isSessionValid();

    if (hasUser && isValid) {
      // Session valide → HOME
      if (mounted) {
        Navigator.pushReplacementNamed(context, "/home");
      }
    } else {
      // Pas de session ou expirée → LOGIN
      if (mounted) {
        Navigator.pushReplacementNamed(context, "/login");
      }
    }
  }

  // --- Logique de redirection automatique ---
  Future<void> _initializeApp() async {
    // On attend 3 secondes pour laisser le temps à l'utilisateur de voir le logo
    await Future.delayed(const Duration(seconds: 3));
    
    if (!mounted) return;
    
    // Redirection vers la page de connexion
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const LoginPage(), // Remplace par ton widget LoginPage
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryGreen,
      body: FadeTransition(
        opacity: _opacityAnimation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo avec bordure circulaire
              Container(
                padding: const EdgeInsets.all(5), // Espace pour l'effet de bordure
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Image.asset(
                    "assets/images/logo.jpeg",
                    width: 160,
                    height: 160,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "e-AgriSouk",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Collecte de données",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}