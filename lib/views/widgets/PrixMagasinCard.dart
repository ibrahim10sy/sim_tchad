import 'package:flutter/material.dart';
import 'package:sim_tchad/core/constants/app_colors.dart';
import 'package:sim_tchad/models/prixMagasin.dart';

class PrixMagasinCard extends StatelessWidget {
  final PrixMagasin fiche;
  final Function(PrixMagasin) onEdit;
  final Function(PrixMagasin) onDelete;

  const PrixMagasinCard({
    super.key,
    required this.fiche,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 2,
      child: Column(
        children: [
          ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
              child: const Icon(Icons.shopping_basket,
                  color: AppColors.primaryGreen),
            ),
            title: Text(
              fiche.produit!.nomProduit ?? "N/A",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text(
              "${fiche.uniteMesure} • ${fiche.variete ?? '"N/A"'}",
              style: TextStyle(color: Colors.grey[600]),
            ),
            trailing: Text(
              "${fiche.prixVente} FCFA",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryGreen,
                fontSize: 16,
              ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _ActionButton(
                  label: "Modifier",
                  icon: Icons.edit_outlined,
                  color: Colors.blue[700]!,
                  onTap: () => onEdit(fiche),
                ),
                const SizedBox(width: 8),
                _ActionButton(
                  label: "Supprimer",
                  icon: Icons.delete_outline,
                  color: Colors.red[700]!,
                  onTap: () => onDelete(fiche),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// Petit composant interne pour éviter la répétition des styles de boutons
class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: TextButton.styleFrom(foregroundColor: color),
    );
  }
}
