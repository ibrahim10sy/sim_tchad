class NiveauApprovisionnement {
  final int idNiveauApprovisionnement;
  final String codeNiveau;
  final String libelle;
  final String? description;

  NiveauApprovisionnement({
    required this.idNiveauApprovisionnement,
    required this.codeNiveau,
    required this.libelle,
    this.description,
  });

  factory NiveauApprovisionnement.fromJson(Map<String, dynamic> json) {
    return NiveauApprovisionnement(
      idNiveauApprovisionnement: json['idNiveauApprovisionnement'],
      codeNiveau: json['codeNiveau'],
      libelle: json['libelle'],
      description: json['description'] ?? '',
    );
  }

   Map<String, dynamic> toJson() {
    return {
      'idNiveauApprovisionnement': idNiveauApprovisionnement,
      'codeNiveau': codeNiveau,
      'libelle': libelle,
      'description': description
    };
  }
}