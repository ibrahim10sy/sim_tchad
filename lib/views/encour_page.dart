import 'package:flutter/material.dart';

class EncourPage extends StatefulWidget {
  const EncourPage({super.key});

  @override
  State<EncourPage> createState() => _EncourPageState();
}

class _EncourPageState extends State<EncourPage> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "Fiches en cours",
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}