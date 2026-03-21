import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:sim_tchad/core/constants/app_colors.dart';
import 'package:sim_tchad/models/Commune.dart';
import 'package:sim_tchad/models/EnqueteSuivi.dart';
import 'package:sim_tchad/models/Enqueteur.dart';
import 'package:sim_tchad/models/SuiviFlux.dart';
import 'package:sim_tchad/services/auth_service.dart';
import 'package:sim_tchad/utils/database_service.dart';
import 'package:sim_tchad/views/screen/add_suivi.dart';
import 'package:sim_tchad/views/widgets/ProduitCollecteCard.dart';

class DetailSuivi extends StatefulWidget {
  EnqueteSuivi? enqueteSuivi;
  DetailSuivi({super.key, this.enqueteSuivi});

  @override
  State<DetailSuivi> createState() => _DetailSuiviState();
}

class _DetailSuiviState extends State<DetailSuivi> {
  bool isLoading = false;
  Enqueteur? enqueteur;
  List<SuiviFlux> allFiches = []; // Liste originale
  List<SuiviFlux> filteredFiches = []; // Liste pour l'affichage
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await loadUser();
    await _fetchDataLocal();
  }

  Future<void> loadUser() async {
    final user = await AuthService.getLocalUser();
    if (user != null) {
      setState(() => enqueteur = Enqueteur.fromJson(user));
    }
  }

  Future<void> _fetchDataLocal() async {
    if (enqueteur == null) return;
    setState(() => isLoading = true);
    try {
      final suiviData = await DatabaseService.getSuiviByNum(
          widget.enqueteSuivi!.numFiche);
      setState(() {
        allFiches = suiviData;
        _applyFilter(searchQuery); // Ré-appliquer le filtre après recharge
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _getResultFromNextScreens(
      BuildContext context, EnqueteSuivi en, SuiviFlux p) async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => AddSuivi(
                isEdit: true, enqueteSuivi: en, suivi: p)));
    log(result.toString());
    if (result == true) {
      print("Rafraichissement en cours");

      if (!mounted) return;
      await _fetchDataLocal();
    }
  }

  void _applyFilter(String query) {
    setState(() {
      searchQuery = query;
      filteredFiches = allFiches
          .where((f) => (f.produit!.nomProduit ?? "")
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> handleDelete(int id) async {
    await DatabaseService.delete(
      "SuiviFlux",
      "idSuivi",
      id,
    );
    _fetchDataLocal();
  }

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        title: const Text("Détails de la collecte",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: AppColors.institutionalGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildInfoEnqueteHeader(), // En-tête avec infos EnqueteMagasin
          _buildSearchBar(), // Champ de recherche
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primaryGreen))
                : filteredFiches.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _fetchDataLocal,
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 80),
                          itemCount: filteredFiches.length,
                          itemBuilder: (context, index) {
                            return ProduitCollecteCard(
                              libelle:
                                  filteredFiches[index].produit!.nomProduit,
                              localite: filteredFiches[index]
                                  .enqueteSuivi!
                                  .commune!
                                  .nom,
                              onEdit: () => _getResultFromNextScreens(
                                  context,
                                  widget.enqueteSuivi!,
                                  filteredFiches[index]),
                              onDelete: () => _showDeleteConfirm(
                                  filteredFiches[index].idSuivi!),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: () => _navigateToAdd(),
      //   backgroundColor: AppColors.institutionalGreen,
      //   icon: const Icon(Icons.add),
      //   label: const Text("AJOUTER UN PRODUIT"),
      // ),
    );
  }

  // --- Widget En-tête Informations ---
  Widget _buildInfoEnqueteHeader() {
    final e = widget.enqueteSuivi;
    return Container(
      width: double.infinity,
      color: AppColors.institutionalGreen,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.store, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Text("Suivi des fluxs",
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _headerInfoItem(Icons.tag, "Fiche: ${e?.numFiche}"),
                _headerInfoItem(
                    Icons.calendar_today, "Date: ${e?.dateEnquete}"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 14),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text("Aucun produit collecté pour le moment",
              style: TextStyle(color: Colors.grey[600], fontSize: 16)),
        ],
      ),
    );
  }

  // --- Widget Barre de recherche ---
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        onChanged: _applyFilter,
        decoration: InputDecoration(
          hintText: "Rechercher un ...",
          prefixIcon: const Icon(Icons.search, color: AppColors.primaryGreen),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  void _showDeleteConfirm(int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Supprimer la fiche ?"),
        content: const Text("Cette action est irréversible."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Annuler")),
          TextButton(
            onPressed: () {
              handleDelete(id);
              _fetchDataLocal();
              Navigator.pop(ctx);
            },
            child: const Text("Supprimer", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
