import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sim_tchad/core/constants/app_colors.dart';
import 'package:sim_tchad/models/Enqueteur.dart';
import 'package:sim_tchad/services/auth_service.dart';
import 'package:sim_tchad/utils/fecth_data.dart';
import 'package:sim_tchad/views/acheve_page.dart';
import 'package:sim_tchad/views/affect_page.dart';
import 'package:sim_tchad/views/encour_page.dart';
import 'package:sim_tchad/views/rejet_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String userName = "Enqueteur";
  Enqueteur? enqueteur;
  bool isLoadData = false;
  int syncProgress = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    loadUser();
  }

  Future<void> handleFetchData(
    String codeEnqueteur,
    String codeActeur,
    int idCommune,
    Function(int progress)? onProgress,
  ) async {
    print("Synchronisation en cours...");

    int progress = 0;

    // Map des tables avec leurs colonnes autorisées
    final Map<String, List<String>> allowedColumns = {
      "PrixMarches": [
        'idPrixMarche',
        'codePrix',
        'image',
        'variete',
        'age',
        'prixUnite1',
        'prixUnite2',
        'prixUnite3',
        'prixTransport',
        'fournisseur',
        'qualiteProduit',
        'clientPrincipal',
        'uniteTransport',
        'moyenTransport',
        'etatRoute',
        'origineProduit',
        'observation',
        'dateAjout',
        'dateModif',
        'uniteMesure2',
        'uniteMesure3',
        'produit',
        'commercant',
        'niveau',
        'marche',
        'enqueteCollecte'
      ],
      "PrixMagasins": [
        'idPrixMagasin',
        'codePrix',
        'variete',
        'uniteMesure',
        'age',
        'image',
        'prixBordChamp',
        'stockDisponible',
        'prixTransport',
        'uniteTransport',
        'moyenTransport',
        'prixVente',
        'observation',
        'dateAjout',
        'qualiteProduit',
        'bassinProduction',
        'magasin',
        'produit',
        'niveau',
        'enqueteMagasin'
      ],
      "SuiviFluxs": [
        'idSuivi',
        'codeSuivi',
        'observation',
        'fluxEntrantTonne',
        'fluxSortantTonne',
        'disponibilite',
        'difficulte',
        'prixBordChamp',
        'stockDisponible',
        'dateCollecte',
        'dateAjout',
        'produit',
        'uniteMesure',
        'niveau',
        'enqueteSuivi',
        'commune'
      ],
      "Produit": [
        'idProduit',
        'codeProduit',
        'nomProduit',
        'description',
        'dateAjout',
        'categorieProduit',
        'formeProduit'
      ],
      "BassinProduction": [
        'idBassin',
        'codeBassin',
        'nomBassin',
        'description'
      ],
      "EquivalenceUnite": [
        'id',
        'equivalenceUnite',
        'uniteConventionnelle',
        'produit',
        'commune'
      ],
      "Variete": [
        'idVariete',
        'codeVariete',
        'libelle',
        'observation',
        'dateAjout',
        'filiere'
      ],
      "UniteConventionnelle": [
        'idUnite',
        'libelle',
        'sigle',
        'conversion',
        'uniteStock'
      ],
      "Campagne": [
        'idCampagne',
        'codeCampagne',
        'commentaire',
        'ficheRapport',
        'dateAjout',
        'anneeDebut',
        'anneeFin',
        'dateModif'
      ],
      "Acteur": [
        'idActeur',
        'codeActeur',
        'nomActeur',
        'adresse',
        'localite',
        'telephone',
        'whatsApp',
        'typeActeur'
      ],
      "Commune": ['idCommune', 'codeCommune', 'nom', 'description'],
      "NiveauApprovisionnement": [
        'idNiveauApprovisionnement',
        'codeNiveau',
        'libelle'
      ],
      "Marche": [
        'idMarche',
        'codeMarche',
        'nomMarche',
        'acteur',
        'localite',
        'commune'
      ],
      "Magasin": [
        'idMagasin',
        'codeMagasin',
        'nomMagasin',
        'localite',
        'commune'
      ],
      "CategorieProduit": [
        'idCategorieProduit',
        'codeCategorie',
        'libelle',
        'filiere'
      ]
    };

    // Liste des ressources à synchroniser
    final resources = [
      ["produits", "Produit", "Produits"],
      ["bassins", "BassinProduction", "Bassins"],
      ["varietes", "Variete", "Variétés"],
      ["unites", "UniteConventionnelle", "UniteConventionnelle"],
      ["campagnes", "Campagne", "Campagnes"],
      ["acteurs/libelle", "Acteur", "Acteurs"],
      ["communes/enqueteur/$codeEnqueteur", "Commune", "Communes"],
      ["niveaux", "NiveauApprovisionnement", "Niveaux"],
      ["marches/enqueteur/$codeEnqueteur", "Marche", "Marchés"],
      ["magasins/acteur/$codeActeur/commune/$idCommune", "Magasin", "Magasins"],
      ["categories", "CategorieProduit", "Categories"],
      [
        "prix-marches/enqueteur/$codeEnqueteur/not-validated",
        "PrixMarches",
        "PrixMarches"
      ],
      [
        "prix-magasins/enqueteur/$codeEnqueteur/not-validated",
        "PrixMagasins",
        "PrixMagasins"
      ],
      ["suivis/enqueteur/$codeEnqueteur/pending", "SuiviFluxs", "SuiviFlux"],
      [
        "equivalences/commune/$idCommune",
        "EquivalenceUnite",
        "EquivalenceUnite"
      ]
    ];

    for (var r in resources) {
      final table = r[1];
      final allowedCols = allowedColumns[table] ?? [];

      await fetchDataResource(
        r[0], // endpoint
        table, // table
        r[2], // resource
        allowedCols, // colonnes filtrées
      );

      progress++;
      if (onProgress != null) {
        int percent = ((progress / resources.length) * 100).toInt();
        onProgress(percent);
      }
    }

    print("Synchronisation terminée");
  }

  Future<void> _fetchData() async {
    if (enqueteur == null) return;

    setState(() {
      isLoadData = true;
      syncProgress = 0;
    });

    try {
      await handleFetchData(
        enqueteur!.codeEnqueteur!,
        enqueteur!.acteur!.codeActeur,
        enqueteur!.commune!.idCommune,
        (progress) {
          setState(() {
            syncProgress = progress;
          });
        },
      );
    } catch (e) {
      print("Erreur sync $e");
    } finally {
      setState(() {
        isLoadData = false;
      });
    }
  }

  /// Récupère l'utilisateur connecté en local
  Future<void> loadUser() async {
    final user = await AuthService.getLocalUser();

    if (user != null) {
      setState(() {
        enqueteur = Enqueteur.fromJson(user);
      });

      print("Utilisateur local trouvé: ${enqueteur!.nomEnqueteur}");
    } else {
      print("Aucun utilisateur local trouvé");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.institutionalGreen,
        elevation: 0,
        toolbarHeight: 0,
      ),
      body: Column(
        children: [
          _buildHeader(),

          // La barre de progression s'affiche ici, juste sous le header
          // Barre de progression intégrée
          if (isLoadData)
            LinearProgressIndicator(
              value: syncProgress > 0 ? syncProgress / 100 : null,
              backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
              minHeight: 3,
            )
          else
            // Une fine ligne de séparation grise quand on ne charge pas
            Divider(height: 1, color: Colors.grey[200]),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                AffectPage(),
                // EncourPage(),
                AchevePage(),
                RejetPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }

// Dans _buildActionButtons, n'oublie pas d'appeler la fonction avec ()
  Widget _buildActionButtons() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.sync, color: Colors.white, size: 18),
          onPressed:
              _fetchData, // Correction ici : On passe la référence de la fonction
        ),
        IconButton(
          icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 18),
          onPressed: () => _showLogoutDialog(),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.institutionalGreen,
        // Optionnel : ajouter un très léger arrondi en bas
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(0),
          bottomRight: Radius.circular(0),
        ),
      ),
      child: SafeArea(
        // Assure que le contenu ne touche pas l'encoche (notch)
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: Row(
                children: [
                  // Avatar ou Initiale pour un look plus pro

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Bonjour, ${enqueteur?.nomEnqueteur ?? userName} 👋",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // Text(
                        //   "e-AgriSouk • Collecte de données",
                        //   style: TextStyle(
                        //     color: Colors.white.withOpacity(0.7),
                        //     fontSize: 12,
                        //     letterSpacing: 0.5,
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                  _buildActionButtons(),
                ],
              ),
            ),
            _buildTabBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      isScrollable: true,
      tabAlignment: TabAlignment.center,
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white.withOpacity(0.5),
      indicatorColor: Colors.white,
      indicatorWeight: 3, // Un peu plus fin pour plus d'élégance

      labelPadding: const EdgeInsets.only(left: 20, right: 10),

      indicatorSize: TabBarIndicatorSize.label,
      dividerColor: Colors.transparent,
      labelStyle: const TextStyle(
        fontWeight: FontWeight.w800,
        fontSize: 14,
        letterSpacing: 0.3,
      ),
      unselectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
      tabs: const [
        Tab(text: "Affectées"),
        // Tab(text: "En cours"),
        Tab(text: "Achevées"),
        Tab(text: "Rejetées"),
      ],
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text("Déconnexion",
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
          "Voulez-vous vraiment quitter l'application ? Notez que toute déconnexion entraînera la suppression de toutes les données.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => AuthService.logout(context),
            child: const Text("Déconnexion",
                style: TextStyle(
                    color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
