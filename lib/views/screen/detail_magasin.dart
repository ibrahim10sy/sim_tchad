import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:sim_tchad/core/constants/app_colors.dart';
import 'package:sim_tchad/models/EnqueteMagasin.dart';
import 'package:sim_tchad/models/Enqueteur.dart';
import 'package:sim_tchad/models/prixMagasin.dart';
import 'package:sim_tchad/services/auth_service.dart';
import 'package:sim_tchad/utils/database_service.dart';
import 'package:sim_tchad/utils/server_service.dart';
import 'package:sim_tchad/views/screen/AddProduitMagasin.dart';
import 'package:sim_tchad/views/widgets/PrixMagasinCard.dart';
import 'package:sim_tchad/views/widgets/ProduitCollecteCard.dart';

class DetailMagasin extends StatefulWidget {
  EnqueteMagasin? enqueteMagasin;
  DetailMagasin({super.key, this.enqueteMagasin});

  @override
  State<DetailMagasin> createState() => _DetailMagasinState();
}

class _DetailMagasinState extends State<DetailMagasin> {
  bool isLoading = false;
  Enqueteur? enqueteur;
  List<PrixMagasin> allFiches = []; // Liste originale
  List<PrixMagasin> filteredFiches = []; // Liste pour l'affichage
  String searchQuery = "";
  bool isLoad = false;

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
      final magasinsData = await DatabaseService.getPrixMagasinByNum(
          widget.enqueteMagasin!.numFiche);
      setState(() {
        allFiches = magasinsData;
        _applyFilter(searchQuery); // Ré-appliquer le filtre après recharge
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> handleSync() async {
    setState(() => isLoad = true);
    try {
      await syncDataMagasinByFicheServer(
          widget.enqueteMagasin!.enqueteur!, widget.enqueteMagasin!.numFiche);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Synchronisation réussie !"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur : ${e.toString()}"),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isLoad = false);
      await _fetchDataLocal();
    }
  }

  Future<void> _getResultFromNextScreens(
      BuildContext context, EnqueteMagasin en, PrixMagasin p) async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => AddProduitMagasin(
                isEdit: true, enqueteMagasin: en, prixMagasin: p)));
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
      "PrixMagasin",
      "idPrixMagasin",
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
      body: Stack(
        children: [
          Column(
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
                                      .enqueteMagasin!
                                      .commune!
                                      .nom,
                                  onEdit: () => _getResultFromNextScreens(
                                      context,
                                      widget.enqueteMagasin!,
                                      filteredFiches[index]),
                                  onDelete: () => _showDeleteConfirm(
                                      filteredFiches[index].idPrixMagasin!),
                                );
                              },
                            ),
                          ),
              ),
            ],
          ),
          if (isLoad)
            Container(
              color: Colors.black.withOpacity(
                  0.5), // Un peu plus sombre pour faire ressortir le message
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // S'adapte au contenu
                    children: [
                      const Text(
                        "Synchronisation en cours...",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Barre de progression linéaire
                      LinearProgressIndicator(
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.institutionalGreen),
                        minHeight: 6, // Un peu plus épaisse pour la visibilité
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Veuillez patienter",
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
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
    final e = widget.enqueteMagasin;
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
                Text(e?.magasin.nomMagasin ?? "Magasin inconnu",
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                onChanged: _applyFilter,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: "Rechercher un produit...",
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    size: 20,
                    color: AppColors.institutionalGreen,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Material(
            color: AppColors.institutionalGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
            child: InkWell(
              onTap: _showSyncConfirm, // Appel de la confirmation ici
              borderRadius: BorderRadius.circular(15),
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Icon(
                  Icons.cloud_sync_rounded,
                  color: AppColors.institutionalGreen,
                  size: 26,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showSyncConfirm() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            "Confirmation",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            "Voulez-vous lancer la synchronisation des données avec le serveur ?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child:
                  const Text("ANNULER", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Ferme le dialogue
                handleSync(); // Lance la sync
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.institutionalGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("SYNCHRONISER",
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
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
