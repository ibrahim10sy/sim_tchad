import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sim_tchad/core/state_management/provider_helpers.dart';
import 'package:sim_tchad/views/login_page.dart';
import 'package:sim_tchad/views/screen/splash_page.dart';
import 'core/state_management/counter_provider.dart';
import 'views/home_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
        ),
        initialRoute: "/",
        routes: {
          "/": (context) => const SplashPage(),
          "/login": (context) => const LoginPage(),
          "/home": (context) => const HomePage(),
        });
  }
}
