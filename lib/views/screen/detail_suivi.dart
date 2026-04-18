import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:sim_tchad/core/constants/app_colors.dart';
import 'package:sim_tchad/models/Commune.dart';
import 'package:sim_tchad/models/EnqueteSuivi.dart';
import 'package:sim_tchad/models/Enqueteur.dart';
import 'package:sim_tchad/models/SuiviFlux.dart';
import 'package:sim_tchad/services/auth_service.dart';
import 'package:sim_tchad/utils/database_service.dart';
import 'package:sim_tchad/utils/server_service.dart';
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
  List<SuiviFlux> allFiches = [];
  List<SuiviFlux> filteredFiches = [];
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
      final suiviData =
          await DatabaseService.getSuiviByNum(widget.enqueteSuivi!.numFiche);
      setState(() {
        allFiches = suiviData;
        _applyFilter(searchQuery); // Ré-appliquer le filtre après recharge
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> handleSync() async {
    setState(() => isLoad = true);
    try {
      await syncDataSuiviByFicheServer(
          widget.enqueteSuivi!.enqueteur!, widget.enqueteSuivi!.numFiche);

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
            content: Text("Erreur de synchroniation. Veuillez réessayer"),
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
      BuildContext context, EnqueteSuivi en, SuiviFlux p) async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) =>
                AddSuivi(isEdit: true, enqueteSuivi: en, suivi: p)));
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
                              onEdit: () => _getResultFromNextScreens(context,
                                  widget.enqueteSuivi!, filteredFiches[index]),
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

  Future<void> _showSyncConfirm() async {
    return showDialog<void>(
      context: context,
      // BarrierDismissible à false si l'action est critique
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                28), // Bords plus arrondis (Material 3 style)
          ),
          // On ajoute une icône pour le feedback visuel
          title: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.institutionalGreen.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cloud_upload_outlined,
                  color: AppColors.institutionalGreen,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Synchronisation",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: const Text(
            "Voulez-vous lancer la synchronisation des données avec le serveur ?",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black54,
              fontSize: 16,
            ),
          ),
          actionsPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          actionsAlignment:
              MainAxisAlignment.center, // Aligner les boutons au centre
          actions: [
            // Bouton Annuler plus discret
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Text(
                "Plus tard",
                style: TextStyle(
                    color: Colors.grey[600], fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 8),
            // Bouton Action principal plus imposant
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                handleSync();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.institutionalGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                 "Envoyer les données",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
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
