import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sim_tchad/core/constants/app_colors.dart';
import 'package:sim_tchad/models/Enqueteur.dart';
import 'package:sim_tchad/models/Magasin.dart';
import 'package:sim_tchad/models/Marche.dart';
import 'package:sim_tchad/services/auth_service.dart';
import 'package:sim_tchad/utils/database_service.dart';
import 'package:sim_tchad/utils/fecth_data.dart';
import 'package:sim_tchad/views/screen/collecte_magasin.dart';
import 'package:sim_tchad/views/screen/collecte_marche.dart';
import 'package:sim_tchad/views/screen/collecte_suivi.dart';
import 'package:sim_tchad/views/widgets/CustomCollecteCard.dart';

class AffectPage extends StatefulWidget {
  const AffectPage({super.key});

  @override
  State<AffectPage> createState() => _AffectPageState();
}

class _AffectPageState extends State<AffectPage> {
  bool isLoading = false;
  bool isLoadData = false;
  int syncProgress = 0;
  Enqueteur? enqueteur;
  List<Marche> marches = [];
  List<Magasin> magasins = [];

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await loadUser();
    // Logique de vérification du mot de passe
    if (enqueteur != null) {
      final prefs = await SharedPreferences.getInstance();
      bool firstLoginDone = prefs.getBool("firstLoginDone") ?? false;

      // Si le serveur dit que le mot de passe doit être reset (resetPassword == false)
      // et que nous n'avons pas encore marqué localement que c'est fait.
      if (enqueteur!.resetPassword == false && !firstLoginDone) {
        // Attendre la fin du build pour afficher le modal
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showResetPasswordModal(context, enqueteur!.codeEnqueteur!);
        });
      }
    }
    await _fetchDataLocal();
  }

  Future<void> loadUser() async {
    final user = await AuthService.getLocalUser();
    if (user != null) {
      setState(() => enqueteur = Enqueteur.fromJson(user));
    }
  }

  Future<void> _fetchDataLocal() async {
    print(">>> _fetchDataLocal appelé"); // <-- vérification
    if (enqueteur == null) return;

    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      final magasinsData = await DatabaseService.getAll("Magasin");
      final marchesData = await DatabaseService.getAll("Marche");

      if (!mounted) return;
      setState(() {
        magasins = magasinsData.map((m) => Magasin.fromJson(m)).toList();
        marches = marchesData.map((m) => Marche.fromJson(m)).toList();
      });
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
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
      "Produit": [
        'idProduit',
        'codeProduit',
        'nomProduit',
        'description',
        'dateAjout',
        'categorieProduit',
        'formeProduit'
      ],
      "BassinProduction": ['idBassin', 'codeBassin', 'libelle', 'description'],
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
      "EquivalenceUnite": [
        'id',
        'equivalenceUnite',
        'uniteConventionnelle',
        'produit',
        'commune'
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
      ],
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
        (progress) => setState(() => syncProgress = progress),
      );
      await _fetchDataLocal();

      // Message de succès
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Données synchronisées avec succès !"),
            backgroundColor: AppColors.institutionalGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint("Erreur sync $e");
      // Message d'erreur
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text("Échec de la synchronisation. Vérifiez votre connexion."),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isLoadData = false);
    }
  }

  void _showResetPasswordModal(BuildContext context, String codeEnqueteur) {
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();
    bool isResetting = false;
    bool obscureNew = true;
    bool obscureConfirm = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              contentPadding: const EdgeInsets.all(20),
              title: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: AppColors.institutionalGreen.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.lock_reset_rounded,
                        color: AppColors.institutionalGreen, size: 40),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    "Sécurité du compte",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "C'est votre première connexion. Par mesure de sécurité, veuillez définir un nouveau mot de passe.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 25),
                  // Nouveau Mot de Passe
                  TextField(
                    controller: newPasswordController,
                    obscureText: obscureNew,
                    decoration: InputDecoration(
                      labelText: "Nouveau mot de passe",
                      prefixIcon: const Icon(Icons.vpn_key_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(obscureNew
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () =>
                            setModalState(() => obscureNew = !obscureNew),
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Confirmation
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: obscureConfirm,
                    decoration: InputDecoration(
                      labelText: "Confirmer le mot de passe",
                      prefixIcon: const Icon(Icons.check_circle_outline),
                      suffixIcon: IconButton(
                        icon: Icon(obscureConfirm
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () => setModalState(
                            () => obscureConfirm = !obscureConfirm),
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10, left: 5, right: 5),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.institutionalGreen,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: isResetting
                          ? null
                          : () async {
                              if (newPasswordController.text.length < 4) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            "Le mot de passe est trop court")));
                                return;
                              }

                              if (newPasswordController.text !=
                                  confirmPasswordController.text) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            "Les mots de passe ne correspondent pas")));
                                return;
                              }

                              setModalState(() => isResetting = true);

                              bool success = await AuthService.resetPassword(
                                  codeEnqueteur, newPasswordController.text);

                              if (success) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: Text(
                                      "Mot de passe mis à jour avec succès !"),
                                  backgroundColor: Colors.green,
                                  behavior: SnackBarBehavior.floating,
                                ));
                              } else {
                                setModalState(() => isResetting = false);
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            "Erreur serveur, réessayez plus tard")));
                              }
                            },
                      child: isResetting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Text("METTRE À JOUR",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1)),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Si chargement
    if (isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primaryGreen));
    }

    return Stack(
      children: [
        _buildContent(),
        if (isLoadData)
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                  sigmaX: 5, sigmaY: 5), // Effet de flou élégant
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.cloud_download_rounded,
                            color: AppColors.primaryGreen, size: 40),
                        const SizedBox(height: 16),
                        const Text(
                          "Synchronisation en cours",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 20),
                        // Barre de progression fluide
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: syncProgress / 100,
                            minHeight: 8,
                            backgroundColor: Colors.grey[200],
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.primaryGreen),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "$syncProgress %",
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryGreen,
                            fontSize: 18,
                          ),
                        ),
                        const Text(
                          "Veuillez ne pas fermer l'application",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildContent() {
    // Si vide
    if (marches.isEmpty && magasins.isEmpty) {
      return _buildEmptyState();
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        if (marches.isNotEmpty) _buildSectionTitle("Marchés affectés"),
        ...marches.map((m) => CustomCollecteCard(
              type: 'Marché',
              label1: 'Localité',
              value1: m.localite,
              label2: 'Point de collecte',
              value2: m.nomMarche,
              accentColor:
                  AppColors.institutionalGreen, // Vert clair pour les marchés
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          CollecteMarche(marche: m, enqueteur: enqueteur))),
            )),
        const SizedBox(height: 16),
        if (enqueteur!.isAnader) _buildSectionTitle("Suivi des fluxs"),
        if (enqueteur!.isAnader)
          CustomCollecteCard(
            type: 'Suivi des flux',
            label1: 'Localité',
            value1: enqueteur!.commune!.nom,
            label2: 'Point de collecte',
            value2: enqueteur!.commune!.nom,
            accentColor:
                AppColors.institutionalGreen, // Vert clair pour les marchés
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => CollectSuivi(enqueteur: enqueteur))),
          ),
        const SizedBox(height: 16),
        if (magasins.isNotEmpty) _buildSectionTitle("Magasins affectés"),
        ...magasins.map((m) => CustomCollecteCard(
            type: 'Magasin',
            label1: 'Localité',
            value1: m.localite ?? "N/A",
            label2: 'Nom Magasin',
            value2: m.nomMagasin,
            accentColor:
                AppColors.institutionalGreen, // Vert foncé pour les magasins
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => CollecteMagasin(
                          magasin: m,
                          enqueteur: enqueteur,
                        ))))),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.darkGrey,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration ou Icône stylisée
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.cloud_sync_rounded,
                  size: 60, color: AppColors.institutionalGreen),
            ),
            const SizedBox(height: 24),
            const Text(
              "Bienvenue !",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              "C'est votre première connexion. Synchronisez vos données pour accéder à vos affectations et commencer la collecte.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 13, height: 1),
            ),
            const SizedBox(height: 32),
            // Bouton d'action principal plus visible
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                icon: const Icon(
                  Icons.sync_rounded,
                  color: Colors.white,
                ),
                label: Text(
                  "DÉMARRER LA SYNCHRONISATION",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13),
                ),
                onPressed: _fetchData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.institutionalGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
