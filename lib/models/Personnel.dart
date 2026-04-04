class Personnel {
  final int? idPersonnel;
  final String codePersonnel;
  final String nomPersonnel;
  final String role;
  final String? email;
  final String adresse;
  final String localite;
  final String telephone;
  final String? whatsApp;
  final String? password;
  final String? dateAjout;
  final String? dateModif;
  final bool statutPersonnel;

  Personnel({
    this.idPersonnel,
    required this.codePersonnel,
    required this.nomPersonnel,
    required this.role,
    this.email,
    required this.adresse,
    required this.localite,
    required this.telephone,
    this.whatsApp,
    this.password,
    this.dateAjout,
    this.dateModif,
    this.statutPersonnel = true,
  });

  factory Personnel.fromJson(Map<String, dynamic> json) {
    return Personnel(
      idPersonnel: json['idPersonnel'],
      codePersonnel: json['codePersonnel'],
      nomPersonnel: json['nomPersonnel'],
      role: json['role'],
      email: json['email'],
      adresse: json['adresse'],
      localite: json['localite'],
      telephone: json['telephone'],
      whatsApp: json['whatsApp'],
      dateAjout: json['dateAjout'],
      dateModif: json['dateModif'],
      statutPersonnel: json['statutPersonnel'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "idPersonnel": idPersonnel,
      "codePersonnel": codePersonnel,
      "nomPersonnel": nomPersonnel,
      "role": role,
      "email": email,
      "adresse": adresse,
      "localite": localite,
      "telephone": telephone,
      "whatsApp": whatsApp,
      "password": password,
      "dateAjout": dateAjout,
      "dateModif": dateModif,
      "statutPersonnel": statutPersonnel,
    };
  }
}