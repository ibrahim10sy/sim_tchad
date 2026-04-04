
class Campagne {
  int? idCampagne;
  String? codeCampagne;
  String? commentaire;
  String? ficheRapport;
  String? ficheRapportUrl;
  String? dateAjout;
  String? anneeDebut;
  String? anneeFin;
  String? dateModif;
  bool? statut;

  Campagne({
    this.idCampagne,
    this.codeCampagne,
    this.commentaire,
    this.ficheRapport,
    this.ficheRapportUrl,
    this.dateAjout,
    this.anneeDebut,
    this.anneeFin,
    this.dateModif,
    this.statut
  });

  factory Campagne.fromJson(Map<String, dynamic> json) {
    return Campagne(
      idCampagne: json['idCampagne'],
      codeCampagne: json['codeCampagne'],
      commentaire: json['commentaire'],
      ficheRapport: json['ficheRapport'],
      ficheRapportUrl: json['ficheRapportUrl'],
      dateAjout: json['dateAjout'],
      anneeDebut: json['anneeDebut'],
      anneeFin: json['anneeFin'],
      dateModif: json['dateModif'],
      statut: json['statut']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idCampagne': idCampagne,
      'codeCampagne': codeCampagne,
      'commentaire': commentaire,
      'ficheRapport': ficheRapport,
      'ficheRapportUrl': ficheRapportUrl,
      'dateAjout': dateAjout,
      'anneeDebut': anneeDebut,
      'anneeFin': anneeFin,
      'dateModif': dateModif,
      'statut': statut
    };
  }
}