import 'package:flutter/material.dart';
import 'package:sim_tchad/models/Commune.dart';
import 'package:sim_tchad/models/EnqueteCampagne.dart';

class AddCampagne extends StatefulWidget {
  final Commune commune;
  final EnqueteCampagne enqueteCampagne;
  bool? isEdit;
  AddCampagne({super.key, required this.commune, this.isEdit, required this.enqueteCampagne});

  @override
  State<AddCampagne> createState() => _AddCampagneState();
}

class _AddCampagneState extends State<AddCampagne> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
