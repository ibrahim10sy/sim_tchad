import 'package:flutter/material.dart';
import 'package:sim_tchad/core/constants/app_colors.dart';
import 'package:sim_tchad/models/EnqueteCollecte.dart';
import 'package:sim_tchad/models/EnqueteMagasin.dart';
import 'package:sim_tchad/models/EnqueteSuivi.dart';
import 'package:sim_tchad/utils/database_service.dart';
import 'package:sim_tchad/views/screen/detail_magasin.dart';
import 'package:sim_tchad/views/screen/detail_marche.dart';
import 'package:sim_tchad/views/screen/detail_suivi.dart';
import 'package:sim_tchad/views/widgets/FicheCollecteCard.dart';

class AchevePage extends StatefulWidget {
  const AchevePage({super.key});

  @override
  State<AchevePage> createState() => _AchevePageState();
}

class _AchevePageState extends State<AchevePage> {
  bool isLoading = false;
  List<EnqueteCollecte> fiches = [];
  List<EnqueteMagasin> fichesMagasin = [];
  List<EnqueteSuivi> fichesSuivi = [];

  @override
  void initState() {
    super.initState();
    _fetchDataLocal();
  }

  Future<void> _fetchDataLocal() async {
    setState(() => isLoading = true);
    try {
      final dataMarche = await DatabaseService.getAllFicheMarche();
      final dataMagasin = await DatabaseService.getAllFicheMagasin();
      final dataSuivi = await DatabaseService.getAllFicheSuivi();

      setState(() {
        fiches = dataMarche.map((e) => EnqueteCollecte.fromJson(e)).toList();
        fichesMagasin =
            dataMagasin.map((e) => EnqueteMagasin.fromJson(e)).toList();
        fichesSuivi = dataSuivi.map((e) => EnqueteSuivi.fromJson(e)).toList();
      });
    } catch (e) {
      debugPrint("Erreur : $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // On vérifie si tout est vide pour afficher l'état vide global
    bool toutEstVide =
        fiches.isEmpty && fichesMagasin.isEmpty && fichesSuivi.isEmpty;

    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Fiches Achevées",
              style: TextStyle(
                fontWeight: FontWeight.w800, // Plus épais pour un look moderne
                fontSize: 20,
                letterSpacing: -0.5,
              ),
            ),
            // Petit sous-titre dynamique
            Text(
              "${fiches.length + fichesMagasin.length + fichesSuivi.length} fiches au total",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0, // On enlève l'ombre par défaut
        centerTitle: false,
        actions: [
          // Bouton de rafraîchissement manuel discret
          IconButton(
            onPressed: _fetchDataLocal,
            icon: const Icon(Icons.refresh_rounded,
                color: AppColors.institutionalGreen),
          ),
          const SizedBox(width: 8),
        ],
        // Ajout d'une fine bordure en bas au lieu d'une ombre grossière
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey[200],
            height: 1.0,
          ),
        ),
      ),
      body: isLoading
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
                        const SizedBox(height: 10),
                      ],
                    ],
                  ),
                ),
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
  Widget _buildMarcheItem(EnqueteCollecte fiche) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: FicheCollecteCard(
        numFiche: fiche.numFiche ?? "N/A",
        date: fiche.dateEnquete ?? "N/A",
        onDetail: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => DetailMarche(enqueteCollecte: fiche))),
      ),
    );
  }

  Widget _buildMagasinItem(EnqueteMagasin fiche) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: FicheCollecteCard(
        numFiche: fiche.numFiche ?? "N/A",
        date: fiche.dateEnquete ?? "N/A",
        onDetail: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => DetailMagasin(enqueteMagasin: fiche))),
      ),
    );
  }

  Widget _buildSuiviItem(EnqueteSuivi fiche) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: FicheCollecteCard(
        numFiche: fiche.numFiche ?? "N/A",
        date: fiche.dateEnquete ?? "N/A",
        onDetail: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => DetailSuivi(enqueteSuivi: fiche))),
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
          const Text("Aucune fiche achevée trouvée",
              style: TextStyle(color: Colors.grey, fontSize: 15)),
        ],
      ),
    );
  }
}
