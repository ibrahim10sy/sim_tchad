import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:sim_tchad/core/constants/app_colors.dart';
import 'package:sim_tchad/models/BassinProduction.dart';
import 'package:sim_tchad/models/CategorieProduit.dart';
import 'package:sim_tchad/models/EnqueteMagasin.dart';
import 'package:sim_tchad/models/Enqueteur.dart';
import 'package:sim_tchad/models/Magasin.dart';
import 'package:sim_tchad/models/NiveauApprovisionnement.dart';
import 'package:sim_tchad/models/Produit.dart';
import 'package:sim_tchad/models/UniteConventionnelle.dart';
import 'package:sim_tchad/models/Variete.dart';
import 'package:sim_tchad/models/prixMagasin.dart';
import 'package:sim_tchad/utils/database_service.dart';
import 'package:sim_tchad/views/widgets/buildSelectField.dart';
import 'package:sim_tchad/views/widgets/showCustomSelector.dart';
import 'package:image_picker/image_picker.dart';

class UpdatePrixMagasin extends StatefulWidget {
  Magasin? magasin;
  Enqueteur? enqueteur;
  EnqueteMagasin? enqueteMagasin;
  PrixMagasin? prixMagasin;
  UpdatePrixMagasin({
    super.key,
    this.enqueteur,
    this.magasin,
    this.enqueteMagasin,
    this.prixMagasin,
  });

  @override
  State<UpdatePrixMagasin> createState() => _UpdatePrixMagasinState();
}

class _UpdatePrixMagasinState extends State<UpdatePrixMagasin> {
  final TextEditingController prixVenteController = TextEditingController();
  final TextEditingController prixTransportController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController moyenController = TextEditingController();
  final TextEditingController qualiteController = TextEditingController();
  final TextEditingController prixBordChampController = TextEditingController();
  final TextEditingController stockController = TextEditingController();
  final TextEditingController observationController = TextEditingController();

  File? _imageFile; // Pour la nouvelle photo capturée
  String? existingImage; // Pour le chemin de l'image venant de la DB
  String? pathImageToSave;

  String? selectedQualite;
  String? selectedUniteTransport;
  String? selectedMoyenTransport;
  Produit? selectedProduit;
  UniteConventionnelle? selectedUnite;
  String? selectedUniteMesure;
  Variete? selectedVariete;
  NiveauApprovisionnement? selectedNiveau;
  BassinProduction? selectedBassin;
  PrixMagasin? p;
  bool isLoading = false;
  List<NiveauApprovisionnement> niveaux = [];
  List<Produit> produit = [];
  List<CategorieProduit> categorieProduit = [];
  List<BassinProduction> bassins = [];
  List<Magasin> magasins = [];
  List<UniteConventionnelle> unites = [];
  List<Variete> variete = [];
  List<String> moyenTransport = ["Moto", "Tricycle", "Camion", "Pick-up"];
  List<String> uniteTransport = ["Sac", "Carton", "Caisse", "Panier", "Bac"];
  List<String> qualites = ["Bon", "Très bon", "Moyen", "Mauvais"];
  CategorieProduit? selectedCategorie;

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

  @override
  void initState() {
    super.initState();

    if (widget.prixMagasin != null) {
      p = widget.prixMagasin!;
      // print("donnee recu ${widget.prixMagasin!.image! ?? "aucun chemin"}");

      prixVenteController.text = p!.prixVente ?? "";
      prixTransportController.text = p!.prixTransport ?? "";
      ageController.text = p!.age ?? "";
      prixBordChampController.text = p!.prixBordChamp ?? "";
      stockController.text = p!.stockDisponible ?? "";
      observationController.text = p!.observation ?? "";

      selectedQualite = p!.qualiteProduit;
      selectedUniteTransport = p!.uniteTransport;
      selectedMoyenTransport = p!.moyenTransport;
      selectedProduit = p!.produit;
      selectedNiveau = p!.niveau;
      selectedBassin = p!.bassinProduction;
      selectedCategorie = p!.produit?.categorieProduit;
      selectedUniteMesure = p!.uniteMesure;

      // 🔥 si le fichier existe vraiment
      if (p!.image != null &&
          p!.image!.isNotEmpty &&
          File(p!.image!).existsSync()) {
        existingImage = p!.image!;
        pathImageToSave = p!.image; // chemin permanent à réutiliser
      }
    }

    _fetchDataLocal();
  }

  void _deleteOldImageFile(String? path) {
    if (path != null && File(path).existsSync()) {
      File(path).deleteSync();
    }
  }

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

  Future<void> _fetchDataLocal() async {
    setState(() => isLoading = true);

    try {
      final magasinsData = await DatabaseService.getAll("Magasin");
      final niveauxData =
          await DatabaseService.getAll("NiveauApprovisionnement");
      final produitData = await DatabaseService.getAll("Produit");
      final bassinData = await DatabaseService.getAll("BassinProduction");
      final uniteData = await DatabaseService.getAll("UniteConventionnelle");
      final varieteData = await DatabaseService.getAll("Variete");
      final catData = await DatabaseService.getAll("CategorieProduit");

      setState(() {
        magasins = magasinsData.map((m) => Magasin.fromJson(m)).toList();
        niveaux = niveauxData
            .map((m) => NiveauApprovisionnement.fromJson(m))
            .toList();
        bassins = bassinData.map((m) => BassinProduction.fromJson(m)).toList();
        print("${bassins.length}");
        produit = produitData.map((m) => Produit.fromJson(m)).toList();
        unites = uniteData
            .map((m) => UniteConventionnelle.fromJson(m))
            .where((u) => !(u.uniteStock))
            .toList();
        variete = varieteData.map((m) => Variete.fromJson(m)).toList();
        categorieProduit =
            catData.map((m) => CategorieProduit.fromJson(m)).toList();
      });

      // 🔥 IMPORTANT : RECONSTRUCTION DES SELECTED
      if (p != null) {
        setState(() {
          // ✅ Variété
          if (p!.variete != null) {
            selectedVariete = variete.firstWhere(
              (v) => v.libelle == p!.variete,
              orElse: () => Variete(libelle: p!.variete),
            );
          }

          // ✅ Unité
          if (p!.uniteMesure != null) {
            selectedUnite = unites.firstWhere(
              (u) => u.libelle == p!.uniteMesure,
              orElse: () => UniteConventionnelle(libelle: p!.uniteMesure),
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

  String? safeText(TextEditingController c) {
    final text = c.text.trim();
    return text.isEmpty ? null : text;
  }

  Future<void> handleSubmit() async {
    if (selectedUniteMesure == null ||
        selectedProduit == null ||
        selectedBassin == null ||
        stockController == null ||
        prixVenteController == null ||
        prixBordChampController == null ||
        prixBordChampController == null) {
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
      final data = PrixMagasin(
          uniteMesure: selectedUniteMesure!,
          prixBordChamp: safeText(prixBordChampController)!,
          stockDisponible: safeText(stockController)!,
          variete: selectedVariete?.libelle ?? "",
          age: safeText(ageController) ?? "",
          prixTransport: safeText(prixTransportController) ?? "",
          prixVente: safeText(prixVenteController)!,
          observation: safeText(observationController) ?? "",
          bassinProduction: selectedBassin,
          magasin: widget.magasin,
          produit: selectedProduit,
          niveau: selectedNiveau ?? null,
          qualiteProduit: selectedQualite ?? "",
          uniteTransport: selectedUniteTransport ?? "",
          moyenTransport: selectedMoyenTransport ?? "",
          enqueteMagasin: widget.enqueteMagasin,
          dateAjout: DateTime.now().toString(),
          image: pathImageToSave);

      await DatabaseService.update(
        "PrixMagasins",
        data.toJson(),
        "idPrixMagasin",
        p!.idPrixMagasin,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Produit modifié avec succès"),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      debugPrint("Erreur: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Une erreur est survenue")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        title: Text("Modification",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                  _buildFicheHeader(),

                  _buildSectionTitle("INFORMATIONS PRODUIT"),
                  _buildProductSection(), // Appel propre de la section

                  _buildSectionTitle("PRIX & DISPONIBILITÉ"),
                  _buildPriceSection(),

                  _buildSectionTitle("LOGISTIQUE & ORIGINE"),
                  _buildLogisticsSection(),

                  _buildSectionTitle("PHOTO"),
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

// Section 4 : Observation
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

// Widget pour les titres de section
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

  // Section 1 : Produit & Filtre
  Widget _buildProductSection() {
    return _buildCardWrapper([
      SelectField(
        label: "Filtrer par Catégorie",
        icon: Icons.filter_list,
        value: selectedCategorie?.libelle ?? "Toutes les catégories",
        isHighlight: selectedCategorie != null,
        isRequired: true,
        onTap: () => SelectorBottomSheet.show<CategorieProduit>(
          // <-- Correction ici
          context: context, // Très important : passer le context
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
        label: "Produit",
        isRequired: true,
        icon: Icons.shopping_basket_outlined,
        value: selectedProduit?.nomProduit ?? "",
        onTap: () => SelectorBottomSheet.show<Produit>(
          // <-- Correction ici
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
      SelectField(
        label: "Etat de produit",
        icon: Icons.star_outline,
        value: selectedQualite ?? "Sélectionner",
        onTap: () {
          if (qualites.isEmpty) return;

          SelectorBottomSheet.show<String>(
            context: context,
            title: "Etat",
            items: qualites,
            itemLabel: (q) => q,
            selectedItem: selectedQualite,
            onSelected: (q) {
              setState(() => selectedQualite = q);
            },
          );
        },
      ),
      _buildTextField(
          controller: ageController,
          label: "Âge (jours)",
          icon: Icons.history,
          isNumber: true),
    ]);
  }

  // Section 2 : Prix & Stock
  Widget _buildPriceSection() {
    return _buildCardWrapper([
      SelectField(
        label: "Unité de mesure",
        isRequired: true,
        icon: Icons.straighten,
        value: selectedUnite?.libelle ?? "Sélectionner",
        onTap: () => SelectorBottomSheet.show<UniteConventionnelle>(
          context: context,
          title: "Unités",
          items: unites,
          itemLabel: (u) => u.libelle ?? "",
          selectedItem: selectedUnite,
          onSelected: (u) {
            setState(() {
              selectedUnite = u;
              selectedUniteMesure = u.libelle;
            });
          },
        ),
      ),
      _buildTextField(
        controller: prixVenteController,
        label: "Prix de vente",
        isRequired: true,
        icon: Icons.payments_outlined,
        isNumber: true,
        suffix: "FCFA",
      ),
      _buildTextField(
        controller: prixBordChampController,
        label: "Prix bord champ",
        isRequired: true,
        icon: Icons.agriculture,
        isNumber: true,
        suffix: "FCFA",
      ),
      _buildTextField(
        controller: stockController,
        label: "Stock disponible",
        isRequired: true,
        icon: Icons.inventory_2_outlined,
        isNumber: true,
      ),
    ]);
  }

  // Section 3 : Logistique
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
        label: "Bassin de Production",
        icon: Icons.map_outlined,
        isRequired: true,
        value: selectedBassin?.libelle ?? "",
        onTap: () => SelectorBottomSheet.show<BassinProduction>(
          context: context,
          title: "Bassins de production",
          items: bassins,
          itemLabel: (b) => b.libelle ?? "",
          selectedItem: selectedBassin,
          onSelected: (b) => setState(() => selectedBassin = b),
        ),
      ),
      SelectField(
        label: "Moyen de transport",
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
        icon: Icons.local_shipping_outlined,
        isNumber: true,
        suffix: "FCFA",
      ),
    ]);
  }
  // --- COMPOSANTS DE STYLE REUTILISABLES ---

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
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12),
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
            "Modifier",
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
                "Fiche n° ${widget.enqueteMagasin?.numFiche ?? '---'}",
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Text(
                "Date d'enquête : ${widget.enqueteMagasin?.dateEnquete ?? '---'}",
                style: TextStyle(color: Colors.grey[700], fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
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

// ----------------------- BUILD IMAGE CONTENT -----------------------
  Widget _buildImageContent() {
    // 🟢 Nouvelle image sélectionnée
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

    // 🟡 Image existante (update)
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

    // 🔴 Aucune image
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

// ----------------------- REMOVE BUTTON -----------------------
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
}
