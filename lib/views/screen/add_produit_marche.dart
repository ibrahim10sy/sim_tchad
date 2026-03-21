import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sim_tchad/core/constants/app_colors.dart';
import 'package:sim_tchad/models/Acteur.dart';
import 'package:sim_tchad/models/CategorieProduit.dart';
import 'package:sim_tchad/models/EnqueteCollecte.dart';
import 'package:sim_tchad/models/Enqueteur.dart';
import 'package:sim_tchad/models/Marche.dart';
import 'package:sim_tchad/models/NiveauApprovisionnement.dart';
import 'package:sim_tchad/models/PrixMarche.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sim_tchad/models/Produit.dart';
import 'package:sim_tchad/models/Unite.dart';
import 'package:sim_tchad/models/Variete.dart';
import 'package:sim_tchad/utils/database_service.dart';
import 'package:sim_tchad/views/widgets/buildSelectField.dart';
import 'package:sim_tchad/views/widgets/showCustomSelector.dart';

class AddProduitMarche extends StatefulWidget {
  final bool? isEdit;
  final Marche? marche;
  final Enqueteur? enqueteur;
  final EnqueteCollecte? enqueteCollecte;
  final PrixMarche? prixMarche;

  AddProduitMarche({
    super.key,
    this.enqueteCollecte,
    this.enqueteur,
    this.isEdit = false,
    this.marche,
    this.prixMarche,
  });

  @override
  State<AddProduitMarche> createState() => _AddProduitMarcheState();
}

class _AddProduitMarcheState extends State<AddProduitMarche> {
  final _formKey = GlobalKey<FormState>();

  // Contrôleurs pour les champs de texte
  final TextEditingController _prix1Controller = TextEditingController();
  final TextEditingController _prix2Controller = TextEditingController();
  final TextEditingController _prix3Controller = TextEditingController();
  final TextEditingController _origineController = TextEditingController();
  final TextEditingController observationController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController prixTransportController = TextEditingController();
  // Valeurs par défaut pour les Dropdowns
  String? selectedEtatRoute;
  String? selectedFournisseur;
  String? selectedClient;
  String? selectedQualite;
  String? selectedUniteTransport;
  String? selectedMoyenTransport;
  Produit? selectedProduit;
  Unite? selectedUnite1;
  Acteur? selectedActeur;
  Unite? selectedUnite2;
  String? selectedUniteMesure;
  String? selectedUniteMesure2;
  Variete? selectedVariete;
  NiveauApprovisionnement? selectedNiveau;
  bool isLoading = false;
  List<NiveauApprovisionnement> niveaux = [];
  List<Produit> produit = [];
  List<Acteur> acteur = [];
  List<CategorieProduit> categorieProduit = [];
  List<Unite> unites = [];
  List<Variete> variete = [];
  PrixMarche? p;
  CategorieProduit? selectedCategorie;
  File? _imageFile; // Pour la nouvelle photo capturée
  String? existingImage; // Pour le chemin de l'image venant de la DB
  String? pathImageToSave;

  // Listes de constantes (provenant de ton code)
  List<String> moyenTransport = ["Moto", "Tricycle", "Camion", "Pick-up"];
  List<String> uniteTransport = ["Sac", "Carton", "Caisse", "Panier", "Bac"];
  List<String> qualites = ["Bon", "Très bon", "Moyen", "Mauvais"];
  List<String> etatsRoutes = [
    "Bon",
    "Passable",
    "Mauvais",
    "Très mauvais",
    "Autre"
  ];
  final List<String> fournisseurs = [
    "Collecteur",
    "Grossiste",
    "Importateur",
    "Producteur",
    "Autre"
  ];
  final List<String> clients = [
    "Grossiste",
    "Semi-grossiste",
    "Exportateur",
    "Détaillant",
    "Autre"
  ];

  // Getter pour obtenir uniquement les produits de la catégorie sélectionnée
  List<Produit> get filteredProduits {
    if (selectedCategorie == null) return produit;
    return produit
        .where((p) =>
            p!.categorieProduit?.idCategorieProduit ==
            selectedCategorie!.idCategorieProduit)
        .toList();
  }

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
    );

    if (pickedFile != null) {
      // 1. Obtenir le dossier permanent de stockage
      final Directory dir = await getApplicationDocumentsDirectory();

      // 2. Créer un nom unique
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String fileName = "product_$timestamp.jpg";
      final String fullPath = '${dir.path}/$fileName';

      // 3. Copier le fichier sélectionné dans le stockage permanent
      final File savedImage = await File(pickedFile.path).copy(fullPath);

      // 4. Supprimer l'ancienne image si elle existe
      _deleteOldImageFile(existingImage);

      setState(() {
        _imageFile = savedImage;
        pathImageToSave = savedImage.path; // <-- chemin permanent à sauvegarder
        existingImage = null;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchDataLocal();
    if (widget.isEdit == true && widget.prixMarche != null) {
      _initData();
    }
  }

  void _initData() {
    p = widget.prixMarche!;
    _prix1Controller.text = p!.prixUnite1 ?? "";
    _prix2Controller.text = p!.prixUnite2 ?? "";
    _prix3Controller.text = p!.prixUnite3 ?? "";
    prixTransportController.text = p!.prixTransport ?? "";
    observationController.text = p!.observation ?? "";
    ageController.text = p!.age ?? "";
    _origineController.text = p!.origineProduit ?? "";
    selectedEtatRoute = p!.etatRoute;
    selectedFournisseur = p!.fournisseur;
    selectedClient = p!.clientPrincipal;
    selectedQualite = p!.qualiteProduit;
    selectedUniteTransport = p!.uniteTransport ?? "";
    selectedMoyenTransport = p!.moyenTransport ?? "";
    selectedProduit = p!.produit;
    selectedActeur = p!.acteur;
    selectedNiveau = p!.niveau;
    selectedUniteMesure = p!.uniteMesure2 ?? "";
    selectedUniteMesure2 = p!.uniteMesure3 ?? "";

    // --- Récupérer l'image existante ---
    if (p!.image != null &&
        p!.image!.isNotEmpty &&
        File(p!.image!).existsSync()) {
      existingImage = p!.image!;
      pathImageToSave = p!.image; // chemin permanent à réutiliser
    }
  }

  void _deleteOldImageFile(String? path) {
    if (path != null && File(path).existsSync()) {
      File(path).deleteSync();
    }
  }

  Future<void> _fetchDataLocal() async {
    setState(() => isLoading = true);

    try {
      final magasinsData = await DatabaseService.getAll("Marche");
      final niveauxData =
          await DatabaseService.getAll("NiveauApprovisionnement");
      final produitData = await DatabaseService.getAll("Produit");
      final uniteData = await DatabaseService.getAll("Unite");
      final varieteData = await DatabaseService.getAll("Variete");
      final catData = await DatabaseService.getAll("CategorieProduit");
      final acteurs = await DatabaseService.getAll("Acteur");

      setState(() {
        niveaux = niveauxData
            .map((m) => NiveauApprovisionnement.fromJson(m))
            .toList();
        produit = produitData.map((m) => Produit.fromJson(m)).toList();
        unites = uniteData.map((m) => Unite.fromJson(m)).toList();
        acteur = acteurs.map((m) => Acteur.fromJson(m)).toList();
        variete = varieteData.map((m) => Variete.fromJson(m)).toList();
        categorieProduit =
            catData.map((m) => CategorieProduit.fromJson(m)).toList();
      });

      // 🔥 IMPORTANT : RECONSTRUCTION DES SELECTED
      if (widget.isEdit == true && p != null) {
        setState(() {
          // ✅ Variété
          if (p!.variete != null) {
            selectedVariete = variete.firstWhere(
              (v) => v.libelle == p!.variete,
              orElse: () => Variete(libelle: p!.variete),
            );
          }

          // ✅ Unité
          if (p!.uniteMesure2 != null) {
            selectedUnite1 = unites.firstWhere(
              (u) => u.libelle == p!.uniteMesure2,
              orElse: () => Unite(libelle: p!.uniteMesure2),
            );
          }
          if (p!.uniteMesure3 != null) {
            selectedUnite2 = unites.firstWhere(
              (u) => u.libelle == p!.uniteMesure3,
              orElse: () => Unite(libelle: p!.uniteMesure3),
            );
          }

          // ✅ Qualité
          selectedQualite = p!.qualiteProduit;

          // ✅ Transport
          selectedUniteTransport = p!.uniteTransport;

          // ✅ Image
          // if (p!.image != null && p!.image!.isNotEmpty) {
          //   _imageFile = File(p!.image!);
          // }
        });
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        title: widget.isEdit == true
            ? Text("Modification",
                style: const TextStyle(fontWeight: FontWeight.bold))
            : Text(widget.marche!.nomMarche,
                style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.institutionalGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  _buildFicheHeader(), // Toujours en haut (Contexte)

                  // BLOC 1 : IDENTIFICATION DU PRODUIT
                  _buildSectionTitle("INFORMATIONS PRODUIT"),
                  _buildProductSection(),

                  // BLOC 2 : DONNÉES CHIFFRÉES (Le cœur de l'enquête)
                  _buildSectionTitle("PRIX ET UNITÉS"),
                  _buildPriceSection(),

                  // BLOC 3 : FLUX ET LOGISTIQUE
                  _buildSectionTitle("LOGISTIQUE & FLUX"),
                  _buildLogisticsSection(),
                  _buildMarketDetails(), // Intégré ici car lié aux flux

                  // BLOC 4 : INFORMATIONS COMPLÉMENTAIRES
                  _buildSectionTitle("PHOTOS"),
                  _buildImageSection(),

                  _buildSectionTitle("AUTRES"),
                  _buildObservationSection(),

                  const SizedBox(height: 40),
                  _buildSubmitButton(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 10, bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.darkGrey,
            letterSpacing: 1.1,
          ),
        ),
      ),
    );
  }

  // --- SECTION PRODUIT ---
  Widget _buildProductSection() {
    return _buildCardWrapper([
      SelectField(
        label: "Filtrer par Catégorie",
        isRequired: true,
        icon: Icons.filter_list,
        value: selectedCategorie?.libelle ?? "Toutes les catégories",
        isHighlight: selectedCategorie != null,
        onTap: () => SelectorBottomSheet.show<CategorieProduit>(
          context: context,
          title: "Catégories",
          items: categorieProduit,
          itemLabel: (c) => c.libelle ?? "",
          selectedItem: selectedCategorie,
          onSelected: (c) => setState(() {
            selectedCategorie = c;
            selectedProduit = null;
          }),
        ),
      ),
      const SizedBox(height: 10),
      SelectField(
        label: "Commerçant référant",
        isRequired: true,
        icon: Icons.person_2_outlined,
        value: selectedActeur?.nomActeur ?? "",
        onTap: () => SelectorBottomSheet.show<Acteur>(
          context: context,
          title: "Acteur",
          items: acteur,
          itemLabel: (p) => p!.nomActeur ?? "",
          selectedItem: selectedActeur,
          onSelected: (p) => setState(() => selectedActeur = p),
        ),
      ),
      SelectField(
        label: "Produit",
        isRequired: true,
        icon: Icons.shopping_basket_outlined,
        value: selectedProduit?.nomProduit ?? "",
        onTap: () => SelectorBottomSheet.show<Produit>(
          context: context,
          title: "Produits",
          items: filteredProduits,
          itemLabel: (p) => p!.nomProduit ?? "",
          selectedItem: selectedProduit,
          onSelected: (p) => setState(() => selectedProduit = p),
        ),
      ),
      SelectField(
        label: "Variété",
        isRequired: true,
        icon: Icons.category_outlined,
        value: selectedVariete?.libelle ?? "Sélectionner",
        onTap: () {
          if (variete.isEmpty) return;
          SelectorBottomSheet.show<Variete>(
            context: context,
            title: "Variétés",
            items: variete,
            itemLabel: (v) => v.libelle ?? "",
            selectedItem: selectedVariete,
            onSelected: (v) {
              setState(() => selectedVariete = v);
            },
          );
        },
      ),
      Row(
        children: [
          Expanded(
            child: SelectField(
              label: "Qualité",
              icon: Icons.star_outline,
              value: selectedQualite ?? "Sélectionner",
              onTap: () {
                if (qualites.isEmpty) return;
                SelectorBottomSheet.show<String>(
                  context: context,
                  title: "Qualité",
                  items: qualites,
                  itemLabel: (q) => q,
                  selectedItem: selectedQualite,
                  onSelected: (q) {
                    setState(() => selectedQualite = q);
                  },
                );
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildTextField(
                controller: ageController,
                label: "Âge (jours)",
                icon: Icons.history,
                isNumber: true),
          ),
        ],
      ),
    ]);
  }

  // --- SECTION PRIX ---
  Widget _buildPriceSection() {
    return _buildCardWrapper([
      _buildTextField(
        controller: _prix1Controller,
        isRequired: true,
        label: "Prix en kg",
        icon: Icons.payments_outlined,
        isNumber: true,
        suffix: "FCFA",
      ),
      Row(
        children: [
          Expanded(
            child: SelectField(
              label: "Unité de mesure 1",
              isRequired: true,
              icon: Icons.straighten,
              value: selectedUnite1?.libelle ?? "Sélectionner",
              onTap: () => SelectorBottomSheet.show<Unite>(
                context: context,
                title: "Unités",
                items: unites,
                itemLabel: (u) => u.libelle ?? "",
                selectedItem: selectedUnite1,
                onSelected: (u) {
                  setState(() {
                    selectedUnite1 = u;
                    selectedUniteMesure = u.libelle;
                  });
                },
              ),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: _buildTextField(
              controller: _prix2Controller,
              isRequired: true,
              label: "Prix unite 1",
              icon: Icons.agriculture,
              isNumber: true,
              suffix: "FCFA",
            ),
          ),
        ],
      ),
      Row(
        children: [
          Expanded(
            child: SelectField(
              label: "Unité de mesure 2",
              icon: Icons.straighten,
              value: selectedUnite2?.libelle ?? "Sélectionner",
              onTap: () => SelectorBottomSheet.show<Unite>(
                context: context,
                title: "Unités",
                items: unites,
                itemLabel: (u) => u.libelle ?? "",
                selectedItem: selectedUnite2,
                onSelected: (u) {
                  setState(() {
                    selectedUnite2 = u;
                    selectedUniteMesure2 = u.libelle;
                  });
                },
              ),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: _buildTextField(
              controller: _prix3Controller,
              label: "Prix unite 2",
              icon: Icons.agriculture,
              isNumber: true,
              suffix: "FCFA",
            ),
          ),
        ],
      ),
    ]);
  }

  // --- SECTION LOGISTIQUE ---
  Widget _buildLogisticsSection() {
    return _buildCardWrapper([
      SelectField(
        label: "Niveau d'Approvisionnement",
        icon: Icons.trending_up,
        isRequired: true,
        value: selectedNiveau?.libelle ?? "",
        onTap: () => SelectorBottomSheet.show<NiveauApprovisionnement>(
          context: context,
          title: "Niveau d'Appro.",
          items: niveaux,
          itemLabel: (n) => n.libelle ?? "",
          selectedItem: selectedNiveau,
          onSelected: (n) => setState(() => selectedNiveau = n),
        ),
      ),
      SelectField(
        label: "Moyen de transport",
        isRequired: true,
        icon: Icons.local_shipping_outlined,
        value: selectedMoyenTransport ?? "Sélectionner",
        onTap: () {
          if (moyenTransport.isEmpty) return;
          SelectorBottomSheet.show<String>(
            context: context,
            title: "Moyen de transport",
            items: moyenTransport,
            itemLabel: (q) => q,
            selectedItem: selectedMoyenTransport,
            onSelected: (q) {
              setState(() => selectedMoyenTransport = q);
            },
          );
        },
      ),
      SelectField(
        label: "Unité de transport",
        isRequired: true,
        icon: Icons.local_shipping_outlined,
        value: selectedUniteTransport ?? "Sélectionner",
        onTap: () {
          if (uniteTransport.isEmpty) return;
          SelectorBottomSheet.show<String>(
            context: context,
            title: "Unité de transport",
            items: uniteTransport,
            itemLabel: (q) => q,
            selectedItem: selectedUniteTransport,
            onSelected: (q) {
              setState(() => selectedUniteTransport = q);
            },
          );
        },
      ),
      _buildTextField(
        controller: prixTransportController,
        label: "Prix transport",
        isRequired: true,
        icon: Icons.local_shipping_outlined,
        isNumber: true,
        suffix: "FCFA",
      ),
      SelectField(
        label: "Etat de la route",
        icon: Icons.local_shipping_outlined,
        value: selectedEtatRoute ?? "Sélectionner",
        onTap: () {
          if (etatsRoutes.isEmpty) return;
          SelectorBottomSheet.show<String>(
            context: context,
            title: "Etat de la route",
            items: etatsRoutes,
            itemLabel: (q) => q,
            selectedItem: selectedEtatRoute,
            onSelected: (q) {
              setState(() => selectedEtatRoute = q);
            },
          );
        },
      ),
    ]);
  }

  Widget _buildMarketDetails() {
    return _buildCardWrapper([
      // Utilise le wrapper pour la cohérence
      SelectField(
        label: "Fournisseur principal",
        isRequired: true,
        icon: Icons.local_shipping_outlined,
        value: selectedFournisseur ?? "Sélectionner",
        onTap: () {
          if (fournisseurs.isEmpty) return;
          SelectorBottomSheet.show<String>(
            context: context,
            title: "Fournisseur principal",
            items: fournisseurs,
            itemLabel: (q) => q,
            selectedItem: selectedFournisseur,
            onSelected: (q) {
              setState(() => selectedFournisseur = q);
            },
          );
        },
      ),
      SelectField(
        label: "Client principal",
        isRequired: true,
        icon: Icons.local_shipping_outlined,
        value: selectedClient ?? "Sélectionner",
        onTap: () {
          if (clients.isEmpty) return;
          SelectorBottomSheet.show<String>(
            context: context,
            title: "Fournisseur principal",
            items: clients,
            itemLabel: (q) => q,
            selectedItem: selectedClient,
            onSelected: (q) {
              setState(() => selectedClient = q);
            },
          );
        },
      ),
    ]);
  }

  Widget _buildImageSection() {
    return _buildCardWrapper([
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Photo du produit (Facultatif)",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGrey,
            ),
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: _pickImage,
            child: Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                color: AppColors.lightGrey.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
              ),
              child: _buildImageContent(),
            ),
          ),
        ],
      ),
    ]);
  }

  Widget _buildImageContent() {
    if (_imageFile != null && _imageFile!.existsSync()) {
      return Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.file(_imageFile!, fit: BoxFit.cover),
          ),
          _buildRemoveButton(() {
            setState(() {
              _imageFile = null;
            });
          }),
        ],
      );
    }

    if (existingImage != null &&
        existingImage!.isNotEmpty &&
        File(existingImage!).existsSync()) {
      return Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.file(File(existingImage!), fit: BoxFit.cover),
          ),
          _buildRemoveButton(() {
            setState(() {
              existingImage = null;
            });
          }),
        ],
      );
    }

    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.camera_alt_outlined,
            size: 40, color: AppColors.primaryGreen),
        Text(
          "Cliquez pour prendre une photo",
          style: TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildRemoveButton(VoidCallback onTap) {
    return Positioned(
      right: 8,
      top: 8,
      child: CircleAvatar(
        backgroundColor: Colors.red,
        radius: 15,
        child: IconButton(
          icon: const Icon(Icons.close, size: 15, color: Colors.white),
          onPressed: onTap,
        ),
      ),
    );
  }

  Widget _buildObservationSection() {
    return _buildCardWrapper([
      _buildTextField(
        controller: observationController,
        label: "Observations éventuelles",
        icon: Icons.chat_bubble_outline,
        maxLines: 3,
      ),
    ]);
  }

  Widget _buildCardWrapper(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
              color: const Color.fromARGB(255, 225, 211, 211).withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
          children:
              children.expand((w) => [w, const SizedBox(height: 12)]).toList()
                ..removeLast()),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isNumber = false,
    bool isRequired = false, // Nouveau paramètre
    String? suffix,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      decoration: InputDecoration(
        // On crée le label avec l'astérisque si nécessaire
        label: RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(color: AppColors.darkGrey),
            children: [
              if (isRequired)
                const TextSpan(
                  text: ' *',
                  style:
                      TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
            ],
          ),
        ),
        prefixIcon: Icon(icon, color: AppColors.primaryGreen, size: 20),
        suffixText: suffix,
        filled: true,
        fillColor: AppColors.lightGrey.withOpacity(0.5),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required IconData icon,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 5),
        prefixIcon: Icon(icon, color: AppColors.primaryGreen, size: 20),
        filled: true,
        fillColor: AppColors.lightGrey.withOpacity(0.5),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isLoading ? null : handleSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryGreen,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: Text(
            widget.isEdit! ? "Modifier" : "Enregistrer",
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildFicheHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryGreen.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.assignment_turned_in_outlined,
              color: AppColors.primaryGreen),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Fiche n° ${widget.enqueteCollecte?.numFiche ?? '---'}",
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Text(
                "Date d'enquête : ${widget.enqueteCollecte?.dateEnquete ?? '---'}",
                style: TextStyle(color: Colors.grey[700], fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String? safeText(TextEditingController c) {
    final text = c.text.trim();
    return text.isEmpty ? null : text;
  }

  Future<void> handleSubmit() async {
    if (selectedUniteMesure == null ||
        selectedProduit == null ||
        selectedNiveau == null ||
        selectedClient == null ||
        selectedActeur == null ||
        selectedFournisseur == null ||
        selectedUnite1 == null ||
        selectedMoyenTransport == null ||
        widget.enqueteCollecte == null ||
        _prix1Controller.text.isEmpty ||
        _prix2Controller.text.isEmpty) {
      print("${selectedUniteMesure}");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Veuillez renseigné tout les champs obligatoire")),
      );
      return;
    }

    setState(() => isLoading = true);

    // --- LOGIQUE DE DETERMINATION DU CHEMIN ---
    if (_imageFile != null) {
      pathImageToSave = _imageFile!.path; // Priorité à la nouvelle capture
    } else if (existingImage != null) {
      pathImageToSave = existingImage; // Garder l'ancienne si pas de nouvelle
    } else {
      pathImageToSave = null; // L'utilisateur a tout supprimé
    }

    try {
      final data = PrixMarche(
        variete: selectedVariete!.libelle ?? "",
        prixUnite1: safeText(_prix1Controller)!,
        prixUnite2: safeText(_prix2Controller)!,
        prixUnite3: safeText(_prix3Controller) ?? "",
        uniteMesure2: selectedUniteMesure ?? "",
        uniteMesure3: selectedUniteMesure2 ?? "",
        qualiteProduit: selectedQualite ?? "",
        etatRoute: selectedEtatRoute ?? "",
        produit: selectedProduit,
        marche: widget.marche,
        enqueteCollecte: widget.enqueteCollecte,
        dateAjout: DateTime.now().toString(),
        origineProduit: safeText(_origineController) ?? "",
        prixTransport: safeText(prixTransportController)!,
        moyenTransport: selectedMoyenTransport ?? "",
        uniteTransport: selectedUniteTransport,
        fournisseur: selectedFournisseur!,
        clientPrincipal: selectedClient!,
        niveau: selectedNiveau,
        age: safeText(ageController) ?? "",
        acteur: selectedActeur,
        observation: safeText(observationController) ?? "",
        image: pathImageToSave,
      );

      if (widget.isEdit == true) {
        await DatabaseService.update(
          "PrixMarche",
          data.toJson(),
          "idPrixMarche",
          p!.idPrixMarche,
        );
      } else {
        await DatabaseService.insert("PrixMarche", data.toJson());
        print("data ${data.toJson()}");
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.isEdit!
              ? "Produit modifié avec succès"
              : "Produit enregistré avec succès"),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      debugPrint("Erreur: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Une erreur est survenue")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }
}
