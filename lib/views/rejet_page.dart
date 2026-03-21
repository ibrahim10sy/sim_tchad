import 'package:flutter/material.dart';

class RejetPage extends StatefulWidget {
  const RejetPage({super.key});

  @override
  State<RejetPage> createState() => _RejetPageState();
}

class _RejetPageState extends State<RejetPage> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "Fiches rejetées",
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}