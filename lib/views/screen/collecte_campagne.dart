import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sim_tchad/core/constants/app_colors.dart';
import 'package:sim_tchad/models/EnqueteCampagne.dart';
import 'package:sim_tchad/models/Enqueteur.dart';
import 'package:sim_tchad/services/auth_service.dart';
import 'package:sim_tchad/utils/database_service.dart';
import 'package:sim_tchad/utils/server_service.dart';
import 'package:sim_tchad/views/screen/add_campagne.dart';
import 'package:sim_tchad/views/screen/detail_campagne.dart';
import 'package:sim_tchad/views/widgets/FicheCollecteCard.dart';

class CollecteCampagne extends StatefulWidget {
  Enqueteur? enqueteur;
  CollecteCampagne({super.key, this.enqueteur});

  @override
  State<CollecteCampagne> createState() => _CollecteCampagneState();
}
 
class _CollecteCampagneState extends State<CollecteCampagne> {
  bool isLoading = false;
  List<EnqueteCampagne> fiches = [];
  String dateEnquete = DateFormat('dd/MM/yyyy').format(DateTime.now());
  DateTime selectedDate = DateTime.now();
  String numFiche = '';
  Enqueteur? enq;
  bool isLoad = false;

  @override
  void initState() {
    super.initState();
    _initialize();
    loadUser();
  }

  Future<void> loadUser() async {
    final user = await AuthService.getLocalUser();
    if (user != null) {
      setState(() => enq = Enqueteur.fromJson(user));
    }
    print("commune ${enq!.commune!.nom}");
  }

  Future<void> _initialize() async {
    await _fetchDataLocal();
    _checkOrCreateFiche();
  }

  Future<void> _fetchDataLocal() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      final data = await DatabaseService.getFicheByCampagne(
          widget.enqueteur!.commune!.nom);
      if (!mounted) return;
      setState(() {
        fiches = data.map((e) => EnqueteCampagne.fromJson(e)).toList();
      });
    } finally {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  void _checkOrCreateFiche() async {
    final exist = await DatabaseService.getFicheSuiviByDateAndSuivi(
        dateEnquete, widget.enqueteur!.commune!.nom);
    if (exist == null && fiches.isEmpty) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _openCreateFicheBottomSheet());
    }
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
                        child: SafeArea(
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

  Future<void> handleSave() async {
    if (numFiche.isEmpty || dateEnquete.isEmpty) return;

    final exist = await DatabaseService.getFicheSuiviByDateAndSuivi(
        dateEnquete, widget.enqueteur!.commune!.nom);

    if (exist != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Une fiche existe déjà pour cette date"),
        ),
      );

      return;
    }

    final newFiche = EnqueteCampagne(
      numFiche: numFiche,
      dateEnquete: dateEnquete,
      reference: widget.enqueteur?.commune!.nom,
      enqueteur: enq!,
      commune: enq?.commune,
    );

    await DatabaseService.insert(
      "EnqueteCampagne",
      newFiche.toJson(),
    );

    await _fetchDataLocal();
  }

  Future<void> handleDelete(int id) async {
    await DatabaseService.delete(
      "EnqueteCampagne",
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

  Future<void> _getResultFromNextScreens(
      BuildContext context, EnqueteCampagne en) async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => DetailCampagne(
                  enqueteCampagne: en,
                )));
    log(result.toString());
    if (result == true) {
      print("Rafraichissement en cours");

      if (!mounted) return;
      await _fetchDataLocal();
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
      await syncDataSuiviCampagneByFicheServer(widget.enqueteur!, numFiche);

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
      body: Column(
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
    );
  }

  Widget _buildHeader() {
    return Container(
      // On réduit drastiquement le padding
      padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 10,
          bottom: 15,
          left: 10,
          right: 15),
      decoration: const BoxDecoration(
        color: AppColors.institutionalGreen,
        // On retire les gros arrondis et l'ombre portée pour gagner de l'espace visuel
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // Bouton retour plus compact
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded,
                    color: Colors.white, size: 24),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 5),
              // Titre et Sous-titre sur la même colonne mais très serrés
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Suivi des campagnes",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18, // Taille réduite
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Zone : ${widget.enqueteur!.commune!.nom}",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Petit badge discret
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "${fiches.length} fiches",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600),
                ),
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
          onDetail: () => _getResultFromNextScreens(context, fiche),
          onAddProduct: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => AddCampagne(
                          commune: fiche.commune!,
                          enqueteCampagne: fiche,
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
          const Text("Aucune fiche pour ce trouvé",
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
              DatabaseService.delete("EnqueteCampagne", "idEnquete", id);
              _fetchDataLocal();
              Navigator.pop(ctx);
            },
            child: const Text("Supprimer", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

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
