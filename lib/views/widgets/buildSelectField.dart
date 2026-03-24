import 'package:flutter/material.dart';
import 'package:sim_tchad/core/constants/app_colors.dart';

class SelectField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;
  final bool isHighlight;
  final bool isRequired; // Nouveau paramètre

  const SelectField({
    Key? key,
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
    this.isHighlight = false,
    this.isRequired = false, // Par défaut à false
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
        decoration: BoxDecoration(
          color: isHighlight
              ? AppColors.primaryGreen.withOpacity(0.1)
              : AppColors.lightGrey.withOpacity(0.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryGreen, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Utilisation de RichText pour l'astérisque rouge
                  RichText(
                    text: TextSpan(
                      text: label,
                      style: const TextStyle(
                          color: AppColors.darkGrey, fontSize: 10),
                      children: [
                        if (isRequired)
                          const TextSpan(
                            text: ' *',
                            style: TextStyle(
                                color: Colors.red, fontWeight: FontWeight.bold),
                          ),
                      ],
                    ),
                  ),
                  Text(
                    value.isEmpty ? "Sélectionner..." : value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: value.isEmpty
                            ? FontWeight.normal
                            : FontWeight.bold),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
