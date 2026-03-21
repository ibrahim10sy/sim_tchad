class TypeActeur {
  final int idTypeActeur;
  final String libelle;
  final String codeTypeActeur;
  final String? descriptionTypeActeur;
  final String? dateAjout;
  final String? dateModif;

  TypeActeur({
    required this.idTypeActeur,
    required this.libelle,
    required this.codeTypeActeur,
    this.descriptionTypeActeur,
    this.dateAjout,
    this.dateModif,
  });

  factory TypeActeur.fromJson(Map<String, dynamic> json) {
    return TypeActeur(
      idTypeActeur: json['idTypeActeur'],
      libelle: json['libelle'],
      codeTypeActeur: json['codeTypeActeur'],
      descriptionTypeActeur: json['descriptionTypeActeur'],
      dateAjout: json['dateAjout'],
      dateModif: json['dateModif'],
    );
  }

  Map<String, dynamic> toJson() => {
        'idTypeActeur': idTypeActeur,
        'libelle': libelle,
        'codeTypeActeur': codeTypeActeur,
        'descriptionTypeActeur': descriptionTypeActeur,
        'dateAjout': dateAjout,
        'dateModif': dateModif,
      };
}