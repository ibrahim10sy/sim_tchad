import 'package:flutter/material.dart';
import 'package:sim_tchad/core/constants/app_colors.dart';
import 'package:sim_tchad/models/CategorieProduit.dart';
import 'package:sim_tchad/models/Commune.dart';
import 'package:sim_tchad/models/EnqueteSuivi.dart';
import 'package:sim_tchad/models/Enqueteur.dart';
import 'package:sim_tchad/models/NiveauApprovisionnement.dart';
import 'package:sim_tchad/models/Produit.dart';
import 'package:sim_tchad/models/SuiviFlux.dart';
import 'package:sim_tchad/services/auth_service.dart';
import 'package:sim_tchad/utils/database_service.dart';
import 'package:sim_tchad/views/widgets/buildSelectField.dart';
import 'package:sim_tchad/views/widgets/showCustomSelector.dart';

class AddSuivi extends StatefulWidget {
  Commune? commune;
  bool? isEdit;
  EnqueteSuivi? enqueteSuivi;
  SuiviFlux? suivi;
  AddSuivi(
      {super.key, this.commune, this.isEdit, this.enqueteSuivi, this.suivi});

  @override
  State<AddSuivi> createState() => _AddSuiviState();
}

class _AddSuiviState extends State<AddSuivi> {
  bool isLoading = false;
  final TextEditingController fluxEntrantTonneCont = TextEditingController();
  final TextEditingController fluxSortantTonneCont = TextEditingController();
  final TextEditingController dateCollecte = TextEditingController();
  final TextEditingController observationController = TextEditingController();

  List<String> diff = [
    "Niveau élevé des taxes",
    "Concurrence des produits importés",
    "Intempéries",
    "Mauvais conditionnement",
    "Autres",
  ];
  List<String> dispo = [
    "Très abondant",
    "Abondant",
    "Moyen",
    "Faible",
    "Très faible"
  ];
  SuiviFlux? p;
  List<NiveauApprovisionnement> niveaux = [];
  List<Produit> produit = [];
  List<CategorieProduit> categorieProduit = [];
  CategorieProduit? selectedCategorie;
  Produit? selectedProduit;
  NiveauApprovisionnement? selectedNiveau;
  String? disponibilte;
  String? difficulte;
  Enqueteur? enqueteur;
  // String? selectedDiff;
  // String? selectedDispo;

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
    print("enquetesuivi ${widget.enqueteSuivi}");
    // print("commune ${widget.commune!.toJson()}");
    if (widget.isEdit == true && widget.suivi != null) {
      p = widget.suivi!;
      // print("donnee recu ${widget.prixMagasin!.image! ?? "aucun chemin"}");
      fluxEntrantTonneCont.text = p!.fluxEntrantTonne.toString() ?? "";
      fluxSortantTonneCont.text = p!.fluxSortantTonne.toString() ?? "";
      observationController.text = p!.observation ?? "";

      selectedProduit = p!.produit;
      selectedNiveau = p!.niveau;
      selectedCategorie = p!.produit?.categorieProduit;
      disponibilte = p!.disponibilite;
      difficulte = p!.difficulte;
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
      final magasinsData = await DatabaseService.getAll("Magasin");
      final niveauxData =
          await DatabaseService.getAll("NiveauApprovisionnement");
      final produitData = await DatabaseService.getAll("Produit");

      final catData = await DatabaseService.getAll("CategorieProduit");

      setState(() {
        niveaux = niveauxData
            .map((m) => NiveauApprovisionnement.fromJson(m))
            .toList();
        produit = produitData.map((m) => Produit.fromJson(m)).toList();
        categorieProduit =
            catData.map((m) => CategorieProduit.fromJson(m)).toList();
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  String? safeText(TextEditingController c) {
    final text = c.text.trim();
    return text.isEmpty ? null : text;
  }

  Future<void> handleSubmit() async {
    if (selectedProduit == null ||
        enqueteur!.commune == null ||
        fluxEntrantTonneCont == null ||
        fluxSortantTonneCont == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Veuillez renseigné tout les champs obligatoire")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final data = SuiviFlux(
        produit: selectedProduit!,
        fluxEntrantTonne: double.tryParse(fluxEntrantTonneCont.text)!,
        fluxSortantTonne: double.tryParse(fluxSortantTonneCont.text)!,
        observation: safeText(observationController) ?? "",
        commune: enqueteur!.commune ?? null,
        niveau: selectedNiveau ?? null,
        difficulte: difficulte ?? "",
        disponibilite: disponibilte ?? "",
        enqueteSuivi: widget.enqueteSuivi ?? null,
        enqueteur: enqueteur,
        dateAjout: DateTime.now().toString(),
        dateCollecte: DateTime.now().toString(),
      );
      print(data.toJson());
      if (widget.isEdit == true) {
        await DatabaseService.update(
          "SuiviFlux",
          data.toJson(),
          "idSuivi",
          p!.idSuivi,
        );
      } else {
        await DatabaseService.insert("SuiviFlux", data.toJson());
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.isEdit!
              ? "Suivi modifié avec succès"
              : "Suivi enregistré avec succès"),
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
        title: widget.isEdit == true
            ? Text("Modification",
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))
            : Text("Suivi des fluxs",
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                  _buildSupplySection(), // fusion des 2 sections

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
                "Fiche n° ${widget.enqueteSuivi?.numFiche ?? '---'}",
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              Text(
                "Date d'enquête : ${widget.enqueteSuivi?.dateEnquete ?? '---'}",
                style: TextStyle(color: Colors.grey[700], fontSize: 12),
              ),
            ],
          ),
        ],
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
    ]);
  }

  Widget _buildSupplySection() {
    return _buildCardWrapper([
      /// Niveau d'approvisionnement
      SelectField(
        label: "Niveau d'Approvisionnement",
        icon: Icons.trending_up,
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

      const SizedBox(height: 10),

      /// Flux
      _buildTextField(
        controller: fluxEntrantTonneCont,
        isRequired: true,
        label: "Flux entrant (tonne)",
        icon: Icons.call_received,
        isNumber: true,
        suffix: "T",
      ),

      _buildTextField(
        controller: fluxSortantTonneCont,
        label: "Flux sortant (tonne)",
        isRequired: true,
        icon: Icons.call_made,
        isNumber: true,
        suffix: "T",
      ),

      const SizedBox(height: 10),

      /// Disponibilité & difficulté
      Row(
        children: [
          Expanded(
            child: _buildDisponibiliteField(),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildDifficulteField(),
          ),
        ],
      ),
    ]);
  }

  Widget _buildDisponibiliteField() {
    return SelectField(
      label: "Disponibilité",
      icon: Icons.star_outline,
      value: disponibilte ?? "Sélectionner",
      onTap: () {
        if (dispo.isEmpty) return;

        SelectorBottomSheet.show<String>(
          context: context,
          title: "Disponibilité",
          items: dispo,
          itemLabel: (q) => q,
          selectedItem: disponibilte,
          onSelected: (q) => setState(() => disponibilte = q),
        );
      },
    );
  }

  Widget _buildDifficulteField() {
    return SelectField(
      label: "Difficulté",
      icon: Icons.star_outline,
      value: difficulte ?? "Sélectionner",
      onTap: () {
        if (diff.isEmpty) return;

        SelectorBottomSheet.show<String>(
          context: context,
          title: "Difficulté",
          items: diff,
          itemLabel: (q) => q,
          selectedItem: difficulte,
          onSelected: (q) => setState(() => difficulte = q),
        );
      },
    );
  }

  Widget _buildObservationSection() {
    return _buildCardWrapper([
      _buildTextField(
        controller: observationController,
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
}
