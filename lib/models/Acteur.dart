import 'package:sim_tchad/models/TypeActeur.dart';

class Acteur {
  final int idActeur;
  final String codeActeur;
  final String nomActeur;
  final String? email;
  final String? lien;
  final String? logo;
  final String? adresse;
  final String? localite;
  final String? telephone;
  final String? whatsApp;
  final String? password;
  final String? dateAjout;
  final String? dateModif;
  final bool statutActeur;

  Acteur({
    required this.idActeur,
    required this.codeActeur,
    required this.nomActeur,
    this.email,
    this.lien,
    this.logo,
    this.adresse,
    this.localite,
    this.telephone,
    this.whatsApp,
    this.password,
    this.dateAjout,
    this.dateModif,
    required this.statutActeur,
  });

  factory Acteur.fromJson(Map<String, dynamic> json) {
    return Acteur(
      idActeur: json['idActeur'] ?? 0,
      codeActeur: json['codeActeur'] ?? '',
      nomActeur: json['nomActeur'] ?? '',
      email: json['email'],
      lien: json['lien'],
      logo: json['logo'],
      adresse: json['adresse'],
      localite: json['localite'],
      telephone: json['telephone'],
      whatsApp: json['whatsApp'],
      password: json['password'],
      dateAjout: json['dateAjout'],
      dateModif: json['dateModif'],
      statutActeur: json['statutActeur'] ?? false,
      
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idActeur': idActeur,
      'codeActeur': codeActeur,
      'nomActeur': nomActeur,
      'email': email,
      'lien': lien,
      'logo': logo,
      'adresse': adresse,
      'localite': localite,
      'telephone': telephone,
      'whatsApp': whatsApp,
      'password': password,
      'dateAjout': dateAjout,
      'dateModif': dateModif,
      'statutActeur': statutActeur,
    };
  }
}