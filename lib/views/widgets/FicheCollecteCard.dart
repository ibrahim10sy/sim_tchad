import 'package:flutter/material.dart';
import 'package:sim_tchad/core/constants/app_colors.dart';

class FicheCollecteCard extends StatelessWidget {
  final String numFiche;
  final String date;
  final VoidCallback? onDetail;
  VoidCallback? onAddProduct;
  VoidCallback? onDelete;
  VoidCallback? onSync; // Nouvelle action pour la synchronisation

  FicheCollecteCard({
    super.key,
    required this.numFiche,
    required this.date,
    required this.onDetail,
    this.onAddProduct,
    this.onDelete,
    this.onSync,
  });

  PopupMenuItem<String> _buildMenuItem({
    required String value,
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return PopupMenuItem<String>(
      value: value,
      height: 40, // Hauteur contrôlée
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black.withOpacity(0.04),
        //     blurRadius: 10,
        //     offset: const Offset(0, 4),
        //   ),
        // ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Barre latérale (Indicateur visuel)
            Container(
              width: 5,
              decoration: const BoxDecoration(
                color: AppColors.institutionalGreen,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "FICHE N° $numFiche",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppColors.darkGrey,
                          ),
                        ),
                        // Remplacement de l'IconButton par le PopupMenuButton
                        // On vérifie si au moins une des deux fonctions est fournie
                        if (onSync != null || onDelete != null)
                          PopupMenuButton<String>(
                            icon:
                                const Icon(Icons.more_vert, color: Colors.grey),
                            padding: EdgeInsets.zero,
                            color: Colors.white,
                            surfaceTintColor: Colors
                                .white, // Empêche la teinte violette de Material 3
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  12), // Bords arrondis plus modernes
                            ),
                            constraints: const BoxConstraints(
                              minWidth:
                                  180, // Largeur minimale pour éviter que le menu soit trop étroit
                            ),
                            onSelected: (value) {
                              switch (value) {
                                case 'sync':
                                  onSync?.call();
                                  break;
                                case 'delete':
                                  onDelete?.call();
                                  break;
                              }
                            },
                            itemBuilder: (BuildContext context) => [
                              if (onSync != null)
                                _buildMenuItem(
                                  value: 'sync',
                                  icon: Icons.sync_rounded,
                                  text: "Envoyer les données",
                                  color: Colors.black87,
                                ),
                              if (onSync != null && onDelete != null)
                                const PopupMenuDivider(
                                    height:
                                        1), // Séparateur subtil entre les actions
                              if (onDelete != null)
                                _buildMenuItem(
                                  value: 'delete',
                                  icon: Icons.delete_outline_rounded,
                                  text: "Supprimer la fiche et ses données",
                                  color: Colors.redAccent,
                                ),
                            ],
                          )
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Date d'enquête : $date",
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(height: 1),
                    ),
                    Row(
                      children: [
                        // Le bouton Détails est toujours présent
                        Expanded(
                          child: OutlinedButton(
                            onPressed: onDetail,
                            child: const Text("voir les produits"),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.darkGrey,
                              side: BorderSide(color: Colors.grey[300]!),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),

                        // On affiche le bouton Produit et l'espace SEULEMENT si la fonction est fournie
                        if (onAddProduct != null) ...[
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: onAddProduct,
                              // icon:
                              //     const Icon(Icons.add_shopping_cart, size: 18),
                              child: const Text("Produit"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.institutionalGreen,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ),
                        ],
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
