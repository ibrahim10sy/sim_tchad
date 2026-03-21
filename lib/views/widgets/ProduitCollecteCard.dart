import 'package:flutter/material.dart';
import 'package:sim_tchad/core/constants/app_colors.dart';
import 'package:sim_tchad/models/prixMagasin.dart';

class ProduitCollecteCard extends StatelessWidget {
  final String libelle;
  final String localite;

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProduitCollecteCard({
    super.key,
    required this.libelle,
    required this.localite,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Barre latérale dynamique selon la qualité (par exemple)
            Container(
              width: 5,
              decoration: const BoxDecoration(
                color: AppColors.primaryGreen,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            libelle.toUpperCase() ?? "N/A",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppColors.darkGrey,
                            ),
                          ),
                        ),
                        Text(
                          localite ?? "N/A",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryGreen,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(height: 1, thickness: 0.5),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: onEdit,
                            icon: const Icon(
                              Icons.edit_outlined,
                              size: 16,
                              color: AppColors.primaryGreen,
                            ),
                            label: const Text("Modifier"),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primaryGreen,
                              side: BorderSide(color: Colors.green[100]!),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: onDelete,
                            icon: Icon(Icons.delete_outline,
                                size: 16, color: Colors.red[700]),
                            label: const Text("Supprimer"),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red[700],
                              side: BorderSide(color: Colors.red[100]!),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
