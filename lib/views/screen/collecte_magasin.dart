import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sim_tchad/core/constants/app_colors.dart';
import 'package:sim_tchad/models/EnqueteMagasin.dart';
import 'package:sim_tchad/models/Enqueteur.dart';
import 'package:sim_tchad/models/Magasin.dart';
import 'package:sim_tchad/utils/database_service.dart';
import 'package:sim_tchad/utils/server_service.dart';
import 'package:sim_tchad/views/screen/AddProduitMagasin.dart';
import 'package:sim_tchad/views/screen/detail_magasin.dart';
import 'package:sim_tchad/views/widgets/FicheCollecteCard.dart';

class CollecteMagasin extends StatefulWidget {
  final Magasin? magasin;
  final Enqueteur? enqueteur;

  const CollecteMagasin({super.key, this.magasin, this.enqueteur});

  @override
  State<CollecteMagasin> createState() => _CollecteMagasinState();
}

class _CollecteMagasinState extends State<CollecteMagasin> {
  bool isLoading = false;
  List<EnqueteMagasin> fiches = [];
  String dateEnquete = DateFormat('dd/MM/yyyy').format(DateTime.now());
  DateTime selectedDate = DateTime.now();
  String numFiche = '';
   bool isLoad = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _fetchDataLocal();
    _checkOrCreateFiche();
  }

  Future<void> _fetchDataLocal() async {
    setState(() => isLoading = true);
    try {
      final data =
          await DatabaseService.getFicheByMagasin(widget.magasin!.nomMagasin);
      setState(() {
        fiches = data.map((e) => EnqueteMagasin.fromJson(e)).toList();
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _checkOrCreateFiche() async {
    final exist = await DatabaseService.getFicheMagasinByDateAndMagasin(
        dateEnquete, widget.magasin!.nomMagasin!);
    if (exist == null && fiches.isEmpty) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _openCreateFicheBottomSheet());
    }
  }

  Future<void> selectDate({Function(void Function())? setInternalState}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      // Personnalisation du thème pour coller à la charte
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.institutionalGreen, // Entête
              onPrimary: Colors.white, // Texte entête
              onSurface: AppColors.darkGrey, // Texte des jours
            ),
            textButtonTheme: TextButtonThemeData(
              style:
                  TextButton.styleFrom(foregroundColor: AppColors.primaryGreen),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      // 1. Mise à jour de l'état principal de la page
      setState(() {
        selectedDate = picked;
        dateEnquete = DateFormat('dd/MM/yyyy').format(picked);
      });

      // 2. Mise à jour de l'état interne du Bottom Sheet si fourni
      if (setInternalState != null) {
        setInternalState(() {});
      }
    }
  }

Future<void> handleSync(String numFiche) async {
  setState(() => isLoad = true);
  try {
     await syncDataMagasinByFicheServer(widget.enqueteur!, numFiche);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Synchronisation réussie !"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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

  Future<void> handleSave() async {
    if (numFiche.isEmpty || dateEnquete.isEmpty) return;

    final exist = await DatabaseService.getFicheMagasinByDateAndMagasin(
        dateEnquete, widget.magasin!.nomMagasin!);

    if (exist != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Une fiche existe déjà pour cette date"),
        ),
      );

      return;
    }

    final newFiche = EnqueteMagasin(
      numFiche: numFiche,
      dateEnquete: dateEnquete,
      reference: widget.magasin!.nomMagasin,
      enqueteur: widget!.enqueteur!,
      magasin: widget.magasin!,
      commune: widget.magasin?.commune,
    );

    await DatabaseService.insert(
      "EnqueteMagasin",
      newFiche.toJson(),
    );

    await _fetchDataLocal();
  }

  Future<void> handleDelete(int id) async {
    await DatabaseService.delete(
      "EnqueteMagasin",
      "idEnquete",
      id,
    );
    _fetchDataLocal();
  }

  String generateNumFiche() {
    final timestamp =
        DateTime.now().millisecondsSinceEpoch.toString().substring(7);

    final random = (100 + (900 * (DateTime.now().millisecond / 999)).toInt());

    return "$timestamp$random-${widget.enqueteur?.idEnqueteur}";
  }

  void _openCreateFicheBottomSheet() {
    numFiche = generateNumFiche();

    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // Permet au contenu de s'adapter si on ajoute un clavier
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          // Important pour mettre à jour la date dans le bottom sheet
          builder: (context, setInternalState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                top: 20,
                left: 20,
                right: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Barre de saisie/poignée
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Nouvelle Fiche d'Enquête",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.institutionalGreen,
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Affichage du numéro de fiche (Non modifiable)
                  _buildInfoTile(
                    label: "Numéro de fiche",
                    value: numFiche,
                    icon: Icons.tag,
                  ),
                  const SizedBox(height: 15),

                  // Sélection de la Date
                  InkWell(
                    onTap: () async {
                      await selectDate();
                      setInternalState(
                          () {}); // Rafraîchit le texte dans le bottom sheet
                    },
                    child: _buildInfoTile(
                      label: "Date de l'enquête",
                      value: dateEnquete,
                      icon: Icons.calendar_today_rounded,
                      isAction: true,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Boutons d'action
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          child: const Text("Annuler",
                              style: TextStyle(color: Colors.grey)),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            await handleSave();
                            if (context.mounted) Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.institutionalGreen,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text("Créer la fiche",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.institutionalGreen,
        onPressed: _openCreateFicheBottomSheet,
        elevation: 4,
        icon: const Icon(Icons.add_task_rounded, color: Colors.white),
        label: const Text("Nouvelle Fiche",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              _buildHeader(),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: isLoading
                      ? _buildLoadingState()
                      : fiches.isEmpty
                          ? _buildEmptyState()
                          : _buildFicheList(),
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
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 50, bottom: 25, left: 20, right: 20),
      decoration: const BoxDecoration(
        color: AppColors.institutionalGreen,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 15,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 20),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
              ),
              // Badge du nombre de fiches
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${fiches.length} Fiches",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            widget.magasin?.nomMagasin ?? "Détails Magasin",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              const Icon(Icons.location_on_rounded,
                  color: AppColors.lightGreen, size: 16),
              const SizedBox(width: 5),
              Text(
                "Zone de collecte : ${widget.magasin!.commune!.nom}", // Exemple dynamique
                style: TextStyle(
                    color: Colors.white.withOpacity(0.8), fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFicheList() {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 15, bottom: 100),
      physics: const BouncingScrollPhysics(),
      itemCount: fiches.length,
      itemBuilder: (context, index) {
        final fiche = fiches[index];
        // On peut ajouter une petite animation d'entrée ici
        return FicheCollecteCard(
          numFiche: fiche.numFiche ?? "N/A",
          date: fiche.dateEnquete ?? "N/A",
          onDetail: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => DetailMagasin(
                          enqueteMagasin: fiche,
                        )));
          },
          onAddProduct: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => AddProduitMagasin(
                          magasin: widget.magasin,
                          enqueteur: widget.enqueteur,
                          enqueteMagasin: fiche,
                          isEdit: false,
                        )));
          },
          onSync: () => handleSync(fiche.numFiche),
          onDelete: () => _showDeleteConfirm(fiche.idEnquete!),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColors.primaryGreen,
            strokeWidth: 3,
          ),
          SizedBox(height: 10),
          Text("Chargement des fiches...",
              style: TextStyle(color: AppColors.darkGrey)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text("Aucune fiche pour ce magasin",
              style: TextStyle(color: Colors.grey)),
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
              DatabaseService.delete("EnqueteMagasin", "idEnquete", id);
              _fetchDataLocal();
              Navigator.pop(ctx);
            },
            child: const Text("Supprimer", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Widget utilitaire pour les lignes d'information
  Widget _buildInfoTile(
      {required String label,
      required String value,
      required IconData icon,
      bool isAction = false}) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(12),
        border: isAction
            ? Border.all(color: AppColors.primaryGreen.withOpacity(0.3))
            : null,
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.institutionalGreen),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Text(value,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold)),
            ],
          ),
          if (isAction) ...[
            const Spacer(),
            const Icon(Icons.edit_calendar_rounded,
                size: 18, color: AppColors.primaryGreen),
          ]
        ],
      ),
    );
  }
}
