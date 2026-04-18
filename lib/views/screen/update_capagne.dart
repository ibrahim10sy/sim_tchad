import 'package:flutter/material.dart';
import 'package:sim_tchad/core/constants/app_colors.dart';
import 'package:sim_tchad/models/BassinProduction.dart';
import 'package:sim_tchad/models/Campagne.dart';
import 'package:sim_tchad/models/CategorieProduit.dart';
import 'package:sim_tchad/models/Commune.dart';
import 'package:sim_tchad/models/EnqueteCampagne.dart';
import 'package:sim_tchad/models/EnqueteSuivi.dart';
import 'package:sim_tchad/models/Enqueteur.dart';
import 'package:sim_tchad/models/NiveauApprovisionnement.dart';
import 'package:sim_tchad/models/Produit.dart';
import 'package:sim_tchad/models/SuiviCampagne.dart';
import 'package:sim_tchad/models/SuiviFlux.dart';
import 'package:sim_tchad/models/UniteConventionnelle.dart';
import 'package:sim_tchad/models/Variete.dart';
import 'package:sim_tchad/services/auth_service.dart';
import 'package:sim_tchad/utils/database_service.dart';
import 'package:sim_tchad/views/widgets/buildSelectField.dart';
import 'package:sim_tchad/views/widgets/showCustomSelector.dart';

class UpdateCampagne extends StatefulWidget {
  Commune? commune;
  EnqueteCampagne? enqueteCampagne;
  SuiviCampagne? suivi;
  UpdateCampagne(
      {super.key, this.commune, required this.enqueteCampagne, this.suivi});

  @override
  State<UpdateCampagne> createState() => _UpdateCampagneState();
}

class _UpdateCampagneState extends State<UpdateCampagne> {
  final TextEditingController uniteMesureController = TextEditingController();
  final TextEditingController varieteController = TextEditingController();
  final TextEditingController dateSemiController = TextEditingController();
  final TextEditingController commentaireController = TextEditingController();
  final TextEditingController superficieController = TextEditingController();
  final TextEditingController quantiteController = TextEditingController();

  String? selectedQualite;
  UniteConventionnelle? selectedUnite;
  Variete? selectedVariete;
  NiveauApprovisionnement? selectedNiveau;
  bool isLoading = false;
  List<NiveauApprovisionnement> niveaux = [];
  List<Produit> produit = [];
  Produit? selectedProduit;
  List<CategorieProduit> categorieProduit = [];
  List<UniteConventionnelle> unites = [];
  List<Campagne> campagne = [];
  List<BassinProduction> bassinProductions = [];
  List<Variete> variete = [];
  SuiviCampagne? p;
  CategorieProduit? selectedCategorie;
  Campagne? selectedCampagne;
  BassinProduction? selectedBassin;
  Enqueteur? enqueteur;
  String? selectedUniteMesure;

  // Getter pour obtenir uniquement les produits de la catégorie sélectionnée
  List<Produit> get filteredProduits {
    if (selectedCategorie == null) return produit;
    return produit
        .where((p) =>
            p!.categorieProduit?.idCategorieProduit ==
            selectedCategorie!.idCategorieProduit)
        .toList();
  }

  @override
  void initState() {
    super.initState();
    loadUser();
    if (widget.suivi != null) {
      p = widget.suivi!;

      selectedBassin = p!.bassinProduction;
      selectedProduit = p!.produit;
      selectedCategorie = p!.produit?.categorieProduit;
      selectedCampagne = p!.campagne;

      uniteMesureController.text = p!.uniteMesure ?? "";
      selectedUniteMesure = p!.uniteMesure;
      varieteController.text = p!.variete ?? "";
      dateSemiController.text = p!.dateSemi ?? "";
      commentaireController.text = p!.commentaire ?? "";
      superficieController.text = p!.superficieHa.toString() ?? "";
      quantiteController.text = p!.quantiteProduit.toString() ?? "";
      commentaireController.text = p!.commentaire ?? "";
    }

    _fetchDataLocal();
  }

  Future<void> loadUser() async {
    final user = await AuthService.getLocalUser();
    if (user != null) {
      setState(() => enqueteur = Enqueteur.fromJson(user));
    }
    print("commune ${enqueteur!.commune!.nom}");
  }

  Future<void> _fetchDataLocal() async {
    setState(() => isLoading = true);

    try {
      final niveauxData =
          await DatabaseService.getAll("NiveauApprovisionnement");
      final produitData = await DatabaseService.getAll("Produit");
      final bassinData = await DatabaseService.getAll("BassinProduction");
      final uniteData = await DatabaseService.getAll("UniteConventionnelle");
      final varieteData = await DatabaseService.getAll("Variete");
      final catData = await DatabaseService.getAll("CategorieProduit");
      final campagnes = await DatabaseService.getAll("Campagne");

      setState(() {
        niveaux = niveauxData
            .map((m) => NiveauApprovisionnement.fromJson(m))
            .toList();

        bassinProductions =
            bassinData.map((m) => BassinProduction.fromJson(m)).toList();
        print("${bassinProductions.length}");

        produit = produitData.map((m) => Produit.fromJson(m)).toList();
        unites = uniteData
            .map((m) => UniteConventionnelle.fromJson(m))
            .where((u) => !(u.uniteStock))
            .toList();
        print(unites);

        variete = varieteData.map((m) => Variete.fromJson(m)).toList();

        campagne = campagnes.map((m) => Campagne.fromJson(m)).toList();

        categorieProduit =
            catData.map((m) => CategorieProduit.fromJson(m)).toList();
      });

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
    setState(() => isLoading = true);

    try {
      final data = SuiviCampagne(
        commentaire: safeText(commentaireController) ?? "",
        dateSemi: safeText(dateSemiController) ?? "",
        superficieHa: double.tryParse(superficieController.text),
        quantiteProduit: double.tryParse(quantiteController.text),
        variete: selectedVariete?.libelle ?? "",
        uniteMesure: selectedUnite?.libelle ?? "",
        produit: selectedProduit,
        bassinProduction: selectedBassin ?? null,
        campagne: selectedCampagne,
        commune: enqueteur!.commune,
        dateModif: DateTime.now().toString(),
        enqueteCampagne: widget.enqueteCampagne,
      );

      print(data.toJson());

      await DatabaseService.update(
        "SuiviCampagnes",
        data.toJson(),
        "idSuiviCampagne",
        p!.idSuiviCampagne,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Suivi campagne modifié avec succès"),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      debugPrint("Erreur: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Veuillez renseigné tout les champs obligatoire")),
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
                  _buildProductSection(),
                  _buildSectionTitle("STOCK & DISPONIBILITÉ"),
                  _buildSupplySection(),
                  _buildSectionTitle("CONTEXTE AGRICOLE"),
                  _buildContextSection(),
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

  Widget _buildProductSection() {
    return _buildCardWrapper([
      SelectField(
        label: "Catégorie",
        icon: Icons.filter_list,
        value: selectedCategorie?.libelle ?? "Toutes les catégories",
        isHighlight: selectedCategorie != null,
        isRequired: true,
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
        label: "Produit",
        icon: Icons.shopping_basket_outlined,
        isRequired: true,
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
    ]);
  }

  /// ---------------- STOCK ----------------
  Widget _buildSupplySection() {
    return _buildCardWrapper([
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
      const SizedBox(height: 10),
      SelectField(
        label: "Unité de mesure",
        icon: Icons.straighten,
        isRequired: true,
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
    ]);
  }

  /// ---------------- CONTEXTE AGRICOLE ----------------
  Widget _buildContextSection() {
    return _buildCardWrapper([
      SelectField(
        label: "Bassin de production",
        icon: Icons.map_outlined,
        isRequired: true,
        value: selectedBassin?.libelle ?? "",
        onTap: () => SelectorBottomSheet.show<BassinProduction>(
          context: context,
          title: "Bassins de production",
          items: bassinProductions,
          itemLabel: (b) => b.libelle ?? "",
          selectedItem: selectedBassin,
          onSelected: (b) => setState(() => selectedBassin = b),
        ),
      ),
      const SizedBox(height: 10),
      SelectField(
        label: "Campagne agricole",
        icon: Icons.calendar_today,
        isRequired: true,
        value: selectedCampagne != null
            ? "${selectedCampagne!.anneeDebut} - ${selectedCampagne!.anneeFin}"
            : "",
        onTap: () => SelectorBottomSheet.show<Campagne>(
          context: context,
          title: "Campagnes agricoles",
          items: campagne,
          itemLabel: (c) => "${c.anneeDebut} - ${c.anneeFin}",
          selectedItem: selectedCampagne,
          onSelected: (c) => setState(() => selectedCampagne = c),
        ),
      ),
    ]);
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

  Widget _buildObservationSection() {
    return _buildCardWrapper([
      _buildTextField(
        controller: commentaireController,
        label: "Observations",
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
                "Fiche n° ${widget.enqueteCampagne?.numFiche ?? '---'}",
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Text(
                "Date d'enquête : ${widget.enqueteCampagne?.dateEnquete ?? '---'}",
                style: TextStyle(color: Colors.grey[700], fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
