import 'package:flutter/material.dart';

class AppRow extends StatelessWidget {
  final String label;
  final String value;

  const AppRow({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text("$label : ",
              style: const TextStyle(
                  fontWeight: FontWeight.w500)),
          Expanded(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}