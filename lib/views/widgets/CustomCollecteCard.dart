import 'package:flutter/material.dart';
import 'package:sim_tchad/core/constants/app_colors.dart';

class CustomCollecteCard extends StatelessWidget {
  final String type; // "Marché" ou "Magasin"
  final String label1; // "Localité"
  final String value1;
  final String label2; // "Point" ou "Magasin"
  final String value2;
  final VoidCallback onTap;
  final Color accentColor;

  const CustomCollecteCard({
    super.key,
    required this.type,
    required this.label1,
    required this.value1,
    required this.label2,
    required this.value2,
    required this.onTap,
    this.accentColor = AppColors.institutionalGreen,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          // Une ombre très légère pour décoller la carte du fond gris
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: IntrinsicHeight(
            child: Row(
              children: [
                // Barre latérale colorée (comme sur ton image)
                Container(
                  width: 5,
                  color: accentColor,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // En-tête avec l'icône #
                        Row(
                          children: [
                            Text(
                              "#",
                              style: TextStyle(
                                color: accentColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              type,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkGrey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(height: 1, color: AppColors.lightGrey),
                        const SizedBox(height: 12),

                        // Infos
                        _buildInfoRow(label1, value1),
                        const SizedBox(height: 8),
                        _buildInfoRow(label2, value2),

                        const SizedBox(height: 16),

                        // Bouton "Commencer" / "Start"
                        SizedBox(
                          width: double.infinity,
                          height: 40,
                          child: ElevatedButton(
                            onPressed: onTap,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accentColor,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              "Commencer",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          "$label : ",
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.darkGrey,
              fontSize: 14,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
