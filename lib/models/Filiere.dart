class Filiere {
  final int idFiliere;
  final String codeFiliere;
  final String libelle;
  final String? description;
  final String? dateAjout;
  final String? dateModif;

  Filiere({
    required this.idFiliere,
    required this.codeFiliere,
    required this.libelle,
    this.description,
    this.dateAjout,
    this.dateModif,
  });

  factory Filiere.fromJson(Map<String, dynamic> json) {
    return Filiere(
      idFiliere: json['idFiliere'],
      codeFiliere: json['codeFiliere'],
      libelle: json['libelle'],
      description: json['description'],
      dateAjout: json['dateAjout'],
      dateModif: json['dateModif'],
    );
  }

  Map<String, dynamic> toJson() => {
        'idFiliere': idFiliere,
        'codeFiliere': codeFiliere,
        'libelle': libelle,
        'description': description,
        'dateAjout': dateAjout,
        'dateModif': dateModif,
      };
}