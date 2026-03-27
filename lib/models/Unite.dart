class Unite {
  final int? idUnite;
  final String? codeUnite;
  final String? libelle;
  final String? sigle;
  final String? description;
  final String? dateAjout;
  final String? dateModif;

  Unite({
     this.idUnite,
    this.codeUnite,
    this.libelle,
    this.sigle,
    this.description,
    this.dateAjout,
    this.dateModif,
  });

  factory Unite.fromJson(Map<String, dynamic> json) {
    return Unite(
      idUnite: json['idUnite'],
      codeUnite: json['codeUnite'],
      libelle: json['libelle'],
      sigle: json['sigle'],
      description: json['description'],
      dateAjout: json['dateAjout'],
      dateModif: json['dateModif'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idUnite': idUnite,
      'libelle': libelle,
      'sigle': sigle,
      'description': description,
      'dateAjout': dateAjout,
      'dateModif': dateModif
    };
  }
}