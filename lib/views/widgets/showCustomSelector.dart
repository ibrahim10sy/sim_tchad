import 'package:flutter/material.dart';
import 'package:sim_tchad/core/constants/app_colors.dart';

class SelectorBottomSheet<T> extends StatefulWidget {
  final String title;
  final List<T> items;
  final String Function(T) itemLabel;
  final T? selectedItem;
  final Function(T) onSelected;

  const SelectorBottomSheet({
    super.key,
    required this.title,
    required this.items,
    required this.itemLabel,
    required this.selectedItem,
    required this.onSelected,
  });

  @override
  State<SelectorBottomSheet<T>> createState() => _SelectorBottomSheetState<T>();

  static void show<T>({
    required BuildContext context,
    required String title,
    required List<T> items,
    required String Function(T) itemLabel,
    required T? selectedItem,
    required Function(T) onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Pour voir les bords arrondis
      builder: (_) => SelectorBottomSheet(
        title: title,
        items: items,
        itemLabel: itemLabel,
        selectedItem: selectedItem,
        onSelected: onSelected,
      ),
    );
  }
}

class _SelectorBottomSheetState<T> extends State<SelectorBottomSheet<T>> {
  late List<T> _filteredItems;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
  }

  void _filterList(String query) {
    setState(() {
      _filteredItems = widget.items
          .where((item) => widget
              .itemLabel(item)
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7, // Plus haut par défaut pour faciliter la saisie
      maxChildSize: 0.95,
      minChildSize: 0.4,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            children: [
              // Indicateur de drag
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 45,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              
              // Titre
              Text(
                widget.title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),

              // Barre de recherche
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchController,
                  onChanged: _filterList,
                  decoration: InputDecoration(
                    hintText: "Rechercher...",
                    prefixIcon: const Icon(Icons.search, color: AppColors.primaryGreen),
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Divider(),

              // Liste
              Expanded(
                child: _filteredItems.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        itemCount: _filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = _filteredItems[index];
                          final isSelected = item == widget.selectedItem;
                          
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primaryGreen.withOpacity(0.05) : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              title: Text(
                                widget.itemLabel(item),
                                style: TextStyle(
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: isSelected ? AppColors.primaryGreen : Colors.black87,
                                ),
                              ),
                              trailing: isSelected
                                  ? const Icon(Icons.check_circle, color: AppColors.primaryGreen)
                                  : null,
                              onTap: () {
                                widget.onSelected(item);
                                Navigator.pop(context);
                              },
                            ),
                          );
                        },
                      ),
              ),
              // Padding dynamique pour le clavier
              Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 10),
          Text(
            "Aucun résultat trouvé",
            style: TextStyle(color: Colors.grey[500], fontSize: 16),
          ),
        ],
      ),
    );
  }
}