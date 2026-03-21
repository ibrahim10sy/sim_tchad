import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sim_tchad/core/constants/app_colors.dart';
import 'package:sim_tchad/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController codeController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool loading = false;
  bool showPassword = false;
  bool isFirstLogin = false;

  String errorMessage = "";

  static const String firstLoginMessage =
      "C'est le premier démarrage de cet appareil. Veuillez vous identifier avec vos informations de connexion. "
      "Une connexion Internet est requise pour cette première authentification";

  @override
  void initState() {
    super.initState();
    checkFirstLogin();
    loadSavedUser();
  }

  /// Charger le code enregistré localement
  Future<void> loadSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final storedLogin = prefs.getString("userLogin");

    if (storedLogin != null) {
      final data = jsonDecode(storedLogin);

      setState(() {
        codeController.text = data["codeEnqueteur"];
      });
    }
  }

  /// Vérifie si c'est la première connexion
  Future<void> checkFirstLogin() async {
    bool result = await AuthService.isFirstLogin();

    setState(() {
      isFirstLogin = result;
    });
  }

  /// Fonction login
  Future<void> login() async {
  print("login>>>> start");
  setState(() {
    loading = true;
    errorMessage = "";
  });

  try {
    String code = codeController.text.trim();
    String password = passwordController.text.trim();

    if (code.isEmpty || password.isEmpty) {
      setState(() {
        errorMessage = "Veuillez remplir tous les champs";
      });
      return;
    }

    // Login offline
    bool localLogin = await AuthService.checkLocalLogin(code, password);
    print("Local login result: $localLogin");

    if (localLogin) {
      if (!mounted) return;
      print("Offline login success");
      Navigator.pushReplacementNamed(context, "/home");
      return;
    }

    // Login online
    bool onlineLogin = await AuthService.login(code, password);
    print("Online login result: $onlineLogin");

    if (onlineLogin) {
      if (!mounted) return;
      print("Online login success");
      Navigator.pushReplacementNamed(context, "/home");
    }
  } catch (e, st) {
    print("Login error: $e\n$st");
    setState(() {
      errorMessage = "Échec de connexion. Vérifiez vos identifiants.";
    });
  } finally {
    setState(() {
      loading = false;
    });
  }
}

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFF8FAFB), // Un gris très clair/bleuté pour le fond
    body: SafeArea(
      child: Center( // Centre le contenu verticalement si l'écran est grand
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),

              /// LOGO AVEC OMBRE DOUCE
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
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

              const SizedBox(height: 40),

              /// TITRE ET SOUS-TITRE
              Text(
                "Connexion",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.normal,
                  color: AppColors.darkGrey,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Accédez à votre espace de collecte",
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.darkGrey.withOpacity(0.6),
                ),
              ),

              const SizedBox(height: 40),

              /// FORMULAIRE
              _buildTextField(
                controller: codeController,
                label: "Code enquêteur",
                icon: Icons.badge_outlined,
                readOnly: !isFirstLogin,
              ),

              const SizedBox(height: 20),

              _buildTextField(
                controller: passwordController,
                label: "Mot de passe",
                icon: Icons.lock_outline,
                isPassword: true,
                showPassword: showPassword,
                onToggleVisibility: () {
                  setState(() => showPassword = !showPassword);
                },
              ),

              /// ERREUR
              if (errorMessage.isNotEmpty) ...[
                const SizedBox(height: 15),
                Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        errorMessage,
                        style: const TextStyle(color: Colors.red, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 20),

              /// MESSAGE PREMIERE CONNEXION (Style Info Card)
              if (isFirstLogin)
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: AppColors.primaryGreen.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.primaryGreen),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          "Ceci est votre première connexion. Veuillez définir vos accès.",
                          style: TextStyle(fontSize: 13, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 35),

              /// BOUTON LOGIN MODERNE
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: AppColors.primaryGreen.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: loading ? null : login,
                  child: loading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Text(
                          "Se connecter",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Widget helper pour des champs uniformes
Widget _buildTextField({
  required TextEditingController controller,
  required String label,
  required IconData icon,
  bool isPassword = false,
  bool? showPassword,
  VoidCallback? onToggleVisibility,
  bool readOnly = false,
}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.03),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: TextField(
      controller: controller,
      readOnly: readOnly,
      obscureText: isPassword && !(showPassword ?? false),
      style: TextStyle(color: readOnly ? Colors.grey : AppColors.darkGrey),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primaryGreen.withOpacity(0.7)),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  showPassword! ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: onToggleVisibility,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.transparent,
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
      ),
    ),
  );
}
}