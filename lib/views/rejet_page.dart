import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:sim_tchad/core/constants/app_colors.dart';
import 'package:sim_tchad/models/EnqueteCollecte.dart';
import 'package:sim_tchad/models/EnqueteMagasin.dart';
import 'package:sim_tchad/models/EnqueteSuivi.dart';
import 'package:sim_tchad/models/PrixMarche.dart';
import 'package:sim_tchad/models/SuiviFlux.dart';
import 'package:sim_tchad/models/prixMagasin.dart';
import 'package:sim_tchad/utils/database_service.dart';
import 'package:sim_tchad/utils/server_service.dart';
import 'package:sim_tchad/views/screen/AddProduitMagasin.dart';
import 'package:sim_tchad/views/screen/add_produit_marche.dart';
import 'package:sim_tchad/views/screen/add_suivi.dart';
import 'package:sim_tchad/views/screen/update_prix_magasin.dart';
import 'package:sim_tchad/views/screen/update_prix_marche.dart';
import 'package:sim_tchad/views/screen/update_suivi.dart';
import 'package:sim_tchad/views/widgets/ProduitCollecteCard.dart';

class RejetPage extends StatefulWidget {
  const RejetPage({super.key});

  @override
  State<RejetPage> createState() => _RejetPageState();
}

class _RejetPageState extends State<RejetPage> {
  bool isLoading = false;
  List<PrixMarche> fiches = [];
  List<PrixMagasin> fichesMagasin = [];
  List<SuiviFlux> fichesSuivi = [];
  String syncStatus = "idle";
  bool isSyncing = false;

  void setSyncStatus(String status) {
    setState(() {
      syncStatus = status;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchDataLocal();
  }

  Future<void> _fetchDataLocal() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      final dataMarche = await DatabaseService.getAllPrixMarches();
      final dataMagasin = await DatabaseService.getAllPrixMagasins();
      final dataSuivi = await DatabaseService.getAllSuivi();
      print(dataMagasin.toList());

      if (!mounted) return;
      setState(() {
        fiches = dataMarche;
        fichesMagasin = dataMagasin;
        fichesSuivi = dataSuivi;
      });
    } catch (e) {
      debugPrint("Erreur : $e");
    } finally {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  Future<void> _getResultFromNextScreensMagasin(
      BuildContext context, EnqueteMagasin en, PrixMagasin p) async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) =>
                UpdatePrixMagasin(enqueteMagasin: en, prixMagasin: p)));
    log(result.toString());
    if (result == true) {
      print("Rafraichissement en cours");

      if (!mounted) return;
      await _fetchDataLocal();
    }
  }

  Future<void> _getResultFromNextScreensSuivi(
      BuildContext context, EnqueteSuivi en, SuiviFlux p) async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => UpdateSuivi(enqueteSuivi: en, suivi: p)));
    log(result.toString());
    if (result == true) {
      print("Rafraichissement en cours");

      if (!mounted) return;
      await _fetchDataLocal();
    }
  }

  Future<void> _getResultFromNextScreens(
      BuildContext context, EnqueteCollecte en, PrixMarche p) async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) =>
                UpdatePrixMarche(enqueteCollecte: en, prixMarche: p)));
    log(result.toString());
    if (result == true) {
      print("Rafraichissement en cours");

      if (!mounted) return;
      await _fetchDataLocal();
    }
  }

  Future<void> syncData({
    required String label,
    required List<dynamic> data,
    required Future<bool> Function() syncFunction,
    required BuildContext context,
    required Function(String) setSyncStatus,
  }) async {
    if (data.isEmpty) {
      print("Aucune donnée locale $label à envoyer.");
      return;
    }

    try {
      setSyncStatus("loading");
      print("Synchronisation des données locales $label en cours...");

      final success = await syncFunction();

      if (success) {
        setSyncStatus("success");

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Données $label synchronisées")),
        );
      } else {
        throw Exception("Échec de la synchronisation $label");
      }
    } catch (error) {
      print("Erreur lors de la synchronisation $label : $error");

      setSyncStatus("error");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de la synchronisation ($label)")),
      );
    }
  }

  Future<void> handleSyncData(BuildContext context) async {
    setState(() => isSyncing = true);

    try {
      // On lance les 3 processus simultanément
      await Future.wait([
        syncData(
          label: "Marché",
          data: fiches,
          syncFunction: syncDataUpdateServer,
          context: context,
          setSyncStatus: setSyncStatus,
        ),
        syncData(
          label: "Magasin",
          data: fichesMagasin,
          syncFunction: syncDataMagasinUpdateServer,
          context: context,
          setSyncStatus: setSyncStatus,
        ),
        syncData(
          label: "Suivi",
          data: fichesSuivi,
          syncFunction: syncDataAgentUpdateServer,
          context: context,
          setSyncStatus: setSyncStatus,
        ),
      ]);

      // Une fois que tout est fini, on rafraîchit le local une seule fois
      await _fetchDataLocal();
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("🚀 Synchronisation globale réussie !"),
            backgroundColor: AppColors.institutionalGreen,
          ),
        );
    } catch (error) {
      print("Erreur globale de synchronisation : $error");
      // if (mounted)
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(
      //         content: Text("Échec de la synchronisation : $error"),
      //         backgroundColor: Colors.red),
      //   );
    } finally {
      setState(() => isSyncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool toutEstVide =
        fiches.isEmpty && fichesMagasin.isEmpty && fichesSuivi.isEmpty;

    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: false,
        title: _buildAppBarTitle(),
        actions: [
          // Bouton Sync désactivé si en cours ou si vide
          if (!toutEstVide)
            isSyncing
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.only(right: 16.0),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.institutionalGreen),
                      ),
                    ),
                  )
                : IconButton(
                    onPressed: _showSyncConfirm,
                    icon: const Icon(Icons.cloud_upload_rounded,
                        color: AppColors.institutionalGreen),
                  ),
          IconButton(
            onPressed: isSyncing ? null : _fetchDataLocal,
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey[200], height: 1.0),
        ),
      ),
      body: Stack(
        children: [
          // 1. Contenu Principal
          isLoading
              ? _buildLoadingState()
              : toutEstVide
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _fetchDataLocal,
                      color: AppColors.institutionalGreen,
                      child: ListView(
                        padding: const EdgeInsets.all(10),
                        physics: const BouncingScrollPhysics(),
                        children: [
                          if (fiches.isNotEmpty) ...[
                            _buildSectionTitle(
                                "Collectes de Marché", fiches.length),
                            ...fiches.map((f) => _buildMarcheItem(f)),
                            const SizedBox(height: 10),
                          ],
                          if (fichesMagasin.isNotEmpty) ...[
                            _buildSectionTitle(
                                "Enquêtes Magasin", fichesMagasin.length),
                            ...fichesMagasin.map((f) => _buildMagasinItem(f)),
                            const SizedBox(height: 10),
                          ],
                          if (fichesSuivi.isNotEmpty) ...[
                            _buildSectionTitle(
                                "Suivis de Prix", fichesSuivi.length),
                            ...fichesSuivi.map((f) => _buildSuiviItem(f)),
                          ],
                        ],
                      ),
                    ),

          // 2. Overlay de Synchronisation (Bloque l'écran proprement)
          if (isSyncing) _buildSyncOverlay(),
        ],
      ),
    );
  }

  // --- Widgets de composants ---

  Widget _buildAppBarTitle() {
    int total = fiches.length + fichesMagasin.length + fichesSuivi.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Fiches rejetées",
            style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                letterSpacing: -0.5)),
        Text("$total fiches au total",
            style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
                fontWeight: FontWeight.w400)),
      ],
    );
  }

  Widget _buildSyncOverlay() {
    return Container(
      color: Colors.black45,
      child: Center(
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                    color: AppColors.institutionalGreen),
                const SizedBox(height: 20),
                const Text("Synchronisation en cours...",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.institutionalGreen),
                ),
                const SizedBox(height: 10),
                const Text("Veuillez patienter",
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ),
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
                handleSyncData(context); // Lance la sync
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

  // Titre de section stylisé
  Widget _buildSectionTitle(String title, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title.toUpperCase(),
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
                color: AppColors.institutionalGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10)),
            child: Text("$count",
                style: const TextStyle(
                    color: AppColors.institutionalGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 12)),
          ),
        ],
      ),
    );
  }

// Items de liste spécifiques
  Widget _buildMarcheItem(PrixMarche fiche) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 3),
        child: ProduitCollecteCard(
          libelle: fiche.produit?.nomProduit ?? "N/A",
          localite: fiche.enqueteCollecte?.commune?.nom ?? "N/A",
          onEdit: () =>
              _getResultFromNextScreens(context, fiche.enqueteCollecte!, fiche),
          onDelete: () => _showDeleteConfirmMarche(fiche.idPrixMarche!),
        ));
  }

  Widget _buildMagasinItem(PrixMagasin fiche) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 3),
        child: ProduitCollecteCard(
          libelle: fiche.produit?.nomProduit ?? "N/A",
          localite: fiche.enqueteMagasin?.commune?.nom ?? "N/A",
          onEdit: () => _getResultFromNextScreensMagasin(
              context, fiche.enqueteMagasin!, fiche),
          onDelete: () => _showDeleteConfirm(fiche.idPrixMagasin!),
        ));
  }

  Widget _buildSuiviItem(SuiviFlux fiche) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 3),
        child: ProduitCollecteCard(
          libelle: "Suivi flux",
         localite: fiche.enqueteur?.commune?.nom ?? "N/A",
          onEdit: () => _getResultFromNextScreensSuivi(
              context, fiche.enqueteSuivi!, fiche),
          onDelete: () => _showDeleteConfirmSuivi(fiche.idSuivi!),
        ));
  }

  Future<void> handleDeleteMagasin(int id) async {
    await DatabaseService.delete(
      "PrixMagasins",
      "idPrixMagasin",
      id,
    );
    _fetchDataLocal();
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
              handleDeleteMagasin(id);
              _fetchDataLocal();
              Navigator.pop(ctx);
            },
            child: const Text("Supprimer", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> handleDeleteMarche(int id) async {
    await DatabaseService.delete(
      "PrixMarches",
      "idPrixMarche",
      id,
    );
    _fetchDataLocal();
  }

  void _showDeleteConfirmMarche(int id) {
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
              handleDeleteMarche(id);
              _fetchDataLocal();
              Navigator.pop(ctx);
            },
            child: const Text("Supprimer", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> handleDeleteSuivi(int id) async {
    await DatabaseService.delete(
      "SuiviFluxs",
      "idSuiviFlux",
      id,
    );
    _fetchDataLocal();
  }

  void _showDeleteConfirmSuivi(int id) {
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
              handleDeleteSuivi(id);
              _fetchDataLocal();
              Navigator.pop(ctx);
            },
            child: const Text("Supprimer", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  // Répétez la même logique de Padding pour _buildFicheMagasinList et _buildFicheSuiviList...

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.institutionalGreen),
          SizedBox(height: 15),
          Text("Chargement des données...",
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_turned_in_outlined,
              size: 70, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text("Aucune fiche rejetée trouvée",
              style: TextStyle(color: Colors.grey, fontSize: 15)),
        ],
      ),
    );
  }
}
