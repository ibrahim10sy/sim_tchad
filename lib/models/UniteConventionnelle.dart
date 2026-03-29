class UniteConventionnelle {
  final int? idUnite;
  final String? libelle;
  final String? sigle;
  final String? image;
  final String? imageUrl;
  final String? conversion;
  final String? description;
  final String? dateAjout;
  final String? dateModif;
  final bool uniteStock;
  final bool statut;

  UniteConventionnelle({
    this.idUnite,
    this.libelle,
    this.sigle,
    this.image,
    this.imageUrl,
    this.conversion,
    this.description,
    this.dateAjout,
    this.dateModif,
    this.uniteStock = true,
    this.statut = true,
  });

  // 🔹 Convertir JSON → Objet
  factory UniteConventionnelle.fromJson(Map<String, dynamic> json) {
    return UniteConventionnelle(
      idUnite: json['idUnite'],
      libelle: json['libelle'],
      sigle: json['sigle'],
      image: json['image'],
      imageUrl: json['imageUrl'],
      conversion: json['conversion'],
      description: json['description'],
      dateAjout: json['dateAjout'],
      dateModif: json['dateModif'],
      uniteStock: json['uniteStock'] == true || json['uniteStock'] == 1,
      statut: json['statut'] == true || json['statut'] == 1,
    );
  }

  // 🔹 Convertir Objet → JSON / DB
  Map<String, dynamic> toJson() {
    return {
      'idUnite': idUnite,
      'libelle': libelle,
      'sigle': sigle,
      'image': image,
      'imageUrl': imageUrl,
      'conversion': conversion,
      'description': description,
      'dateAjout': dateAjout,
      'dateModif': dateModif,
      'uniteStock': uniteStock ? 1 : 0, // SQLite
      'statut': statut ? 1 : 0,
    };
  }
}