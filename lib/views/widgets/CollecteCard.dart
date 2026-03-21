
import 'package:flutter/material.dart';
import 'package:sim_tchad/views/widgets/AppCard.dart';
import 'package:sim_tchad/views/widgets/AppRow.dart';

class CollecteCard extends StatelessWidget {
  final String titre;
  final String localite;
  final String marche;
  final VoidCallback onTap;

  const CollecteCard({
    super.key,
    required this.titre,
    required this.localite,
    required this.marche,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      title: titre,
      onPressed: onTap,
      children: [
        AppRow(label: "Localité", value: localite),
        const Divider(),
        AppRow(label: "Point", value: marche),
      ],
    );
  }
}