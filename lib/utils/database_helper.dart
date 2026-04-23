import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

const dbName = "database.db";

// Future<Database?> openDatabaseConnection() async {
//   try {
//     print("Tentative d'ouverture de la base de données...");

//     final databasePath = await getDatabasesPath();
//     final path = join(databasePath, dbName);

//     final db = await openDatabase(path);

//     if (db == null) {
//       throw Exception("Impossible d'ouvrir la base de données.");
//     }

//     print("Base de données ouverte avec succès !");
//     return db;
//   } catch (error) {
//     print("Erreur lors de l'ouverture de la base de données : $error");
//     return null;
//   }
// }

Future<Database> openDatabaseConnection() async {
  final databasePath = await getDatabasesPath();
  final path = join(databasePath, dbName);

  return await openDatabase(path, version: 2, onCreate: (db, version) async {
    print("Création des tables...");

    /// PRIX MARCHE
    await db.execute('''
  CREATE TABLE IF NOT EXISTS PrixMarche (
    idPrixMarche INTEGER PRIMARY KEY AUTOINCREMENT,
    variete TEXT,
    image TEXT,
    age TEXT,
    prixUnite1 TEXT,
    prixUnite2 TEXT,
    prixUnite3 TEXT,
    prixTransport TEXT,
    fournisseur TEXT,
    latitude TEXT,
    longitude TEXT,
    qualiteProduit TEXT,
    clientPrincipal TEXT,
    uniteTransport TEXT,
    moyenTransport TEXT,
    etatRoute TEXT,
    origineProduit TEXT,
    observation TEXT,
    dateAjout TEXT,
    uniteMesure1 TEXT,
    uniteMesure2 TEXT,
    uniteMesure3 TEXT,
    commercant TEXT,
    produit TEXT,
    niveau TEXT,
    marche TEXT,
    enqueteCollecte TEXT
  )
  ''');

    await db.execute('''
  CREATE TABLE IF NOT EXISTS PrixMarches (
    idPrixMarche INTEGER PRIMARY KEY,
        codePrix TEXT NOT NULL,
        image TEXT,
        variete TEXT,
        age TEXT,
        prixUnite1 TEXT,
        prixUnite2 TEXT,
        prixUnite3 TEXT,
        prixTransport TEXT,
        fournisseur TEXT,
        qualiteProduit TEXT,
        clientPrincipal TEXT,
        uniteTransport TEXT,
        moyenTransport TEXT,
        etatRoute TEXT,
        origineProduit TEXT,
        observation TEXT,
        dateAjout TEXT,
        dateModif TEXT,
        uniteMesure1 TEXT,
        uniteMesure2 TEXT,
        uniteMesure3 TEXT,
        produit TEXT,
        commercant TEXT,
        niveau TEXT,
        marche TEXT,
        enqueteur TEXT,
        enqueteCollecte TEXT,
        donneesSpecifiques TEXT
  )
  ''');

    await db.execute('''
  CREATE TABLE IF NOT EXISTS DonneeSpecifique (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    caracteristiqueId INTEGER,
    idPrixMarche INTEGER,
    valeur TEXT
  )
  ''');

    /// PRIX MAGASIN
    await db.execute('''
  CREATE TABLE IF NOT EXISTS PrixMagasin (
    idPrixMagasin INTEGER PRIMARY KEY AUTOINCREMENT,
    variete TEXT,
    uniteMesure TEXT,
    age TEXT,
    image TEXT,
    prixBordChamp TEXT,
    stockDisponible TEXT,
    prixTransport TEXT,
    uniteTransport TEXT,
    moyenTransport TEXT,
    latitude TEXT,
    longitude TEXT,
    prixVente TEXT,
    observation TEXT,
    dateAjout TEXT,
    qualiteProduit TEXT,
    bassinProduction TEXT,
    magasin TEXT,
    produit TEXT,
    niveau TEXT,
    enqueteMagasin TEXT
  )
  ''');
    await db.execute('''
  CREATE TABLE IF NOT EXISTS PrixMagasins (
     idPrixMagasin INTEGER PRIMARY KEY,
        codePrix TEXT,
        variete TEXT,
        uniteMesure TEXT,
        age TEXT,
        image TEXT,
        prixBordChamp TEXT NOT NULL,
        stockDisponible TEXT NOT NULL,
        prixTransport TEXT NOT NULL,
        uniteTransport TEXT,
        moyenTransport TEXT,
        prixVente TEXT NOT NULL,
        observation TEXT NOT NULL,
        dateAjout TEXT,
        qualiteProduit TEXT,
        bassinProduction TEXT,
        magasin TEXT,
        produit TEXT,
        niveau TEXT,
        enqueteur TEXT,
        enqueteMagasin TEXT
  )
  ''');

    /// ENQUETE COLLECTE
    await db.execute('''
  CREATE TABLE IF NOT EXISTS EnqueteCollecte (
    idEnquete INTEGER PRIMARY KEY AUTOINCREMENT,
    numFiche TEXT,
    dateEnquete TEXT,
    reference TEXT,
    enqueteur TEXT,
    marche TEXT,
    dateEnregistrement TEXT,
    dateModif TEXT,
    commune TEXT
  )
  ''');

    /// ENQUETE MAGASIN
    await db.execute('''
  CREATE TABLE IF NOT EXISTS EnqueteMagasin (
    idEnquete INTEGER PRIMARY KEY AUTOINCREMENT,
    numFiche TEXT,
    dateEnquete TEXT,
    reference TEXT,
    enqueteur TEXT,
    magasin TEXT,
    dateEnregistrement TEXT,
    dateModif TEXT,
    commune TEXT
  )
  ''');

    await db.execute('''
  CREATE TABLE IF NOT EXISTS EnqueteCollecte (
    idEnquete INTEGER PRIMARY KEY AUTOINCREMENT,
    numFiche TEXT,
    dateEnquete TEXT,
    reference TEXT,
    enqueteur TEXT,
    marche TEXT,
    dateEnregistrement TEXT,
    dateModif TEXT,
    commune TEXT
  )
  ''');

    /// ENQUETE CAMPAGNE
    await db.execute('''
  CREATE TABLE IF NOT EXISTS EnqueteCampagne (
    idEnquete INTEGER PRIMARY KEY AUTOINCREMENT,
    numFiche TEXT,
    dateEnquete TEXT,
    enqueteur TEXT,
    reference TEXT,
    dateEnregistrement TEXT,
    dateModif TEXT,
    commune TEXT
  )
  ''');

    /// ENQUETE SUIVI
    await db.execute('''
  CREATE TABLE IF NOT EXISTS EnqueteSuivi (
    idEnquete INTEGER PRIMARY KEY AUTOINCREMENT,
    numFiche TEXT,
    dateEnquete TEXT,
    enqueteur TEXT,
    reference TEXT,
    dateEnregistrement TEXT,
    dateModif TEXT,
    commune TEXT
  )
  ''');

    /// MAGASIN
    await db.execute('''
  CREATE TABLE IF NOT EXISTS Magasin (
    idMagasin INTEGER PRIMARY KEY,
    codeMagasin TEXT,
    nomMagasin TEXT,
    localite TEXT,
    commune TEXT
  )
  ''');

    /// MARCHE
    await db.execute('''
  CREATE TABLE IF NOT EXISTS Marche (
    idMarche INTEGER PRIMARY KEY,
    codeMarche TEXT,
    nomMarche TEXT,
    localite TEXT,
    acteur TEXT,
    commune TEXT
  )
  ''');

    /// PRODUIT
    await db.execute('''
  CREATE TABLE IF NOT EXISTS Produit (
    idProduit INTEGER PRIMARY KEY,
    codeProduit TEXT,
    nomProduit TEXT,
    image TEXT,
    description TEXT,
    dateAjout TEXT,
    categorieProduit TEXT,
    formeProduit TEXT
  )
  ''');

    //caracteristique
    await db.execute('''
  CREATE TABLE IF NOT EXISTS CaracteristiqueProduit (
    id INTEGER PRIMARY KEY,
    nom TEXT,
    type TEXT,
    idProduit INTEGER,
    codeProduit TEXT,
    nomProduit TEXT
  )
  ''');

    /// VARIETE
    await db.execute('''
  CREATE TABLE IF NOT EXISTS Variete (
    idVariete INTEGER PRIMARY KEY,
    codeVariete TEXT,
    libelle TEXT,
    observation TEXT,
    dateAjout TEXT,
    filiere TEXT
  )
  ''');

    /// ACTEUR
    await db.execute('''
  CREATE TABLE IF NOT EXISTS Acteur (
    idActeur INTEGER PRIMARY KEY,
    codeActeur TEXT,
    nomActeur TEXT,
    adresse TEXT,
    localite TEXT,
    telephone TEXT,
    whatsApp TEXT,
    typeActeur TEXT
  )
  ''');

    /// COMMUNE
    await db.execute('''
  CREATE TABLE IF NOT EXISTS Commune (
    idCommune INTEGER PRIMARY KEY,
    codeCommune TEXT,
    nom TEXT,
    description TEXT
  )
  ''');

    /// UNITE
    await db.execute('''
  CREATE TABLE IF NOT EXISTS UniteConventionnelle(
    idUnite INTEGER PRIMARY KEY,
    libelle TEXT,
    sigle TEXT,
    conversion TEXT,
    uniteStock INTEGER
  )
  ''');

    await db.execute('''
  CREATE TABLE IF NOT EXISTS EquivalenceUnite(
    id INTEGER PRIMARY KEY,
    equivalenceUnite REAL,
    uniteConventionnelle TEXT,
    produit TEXT,
    commune TEXT
  )
  ''');

    await db.execute('''
  CREATE TABLE IF NOT EXISTS SuiviFlux (
    idSuivi INTEGER PRIMARY KEY AUTOINCREMENT,
          observation TEXT,
          fluxEntrantTonne REAL,
          fluxSortantTonne REAL,
          disponibilite TEXT NOT NULL,
          difficulte TEXT NOT NULL,
          dateCollecte TEXT NOT NULL,
          dateAjout,
          produit TEXT,
          uniteMesure TEXT,
          niveau TEXT,
          enqueteur TEXT,
          enqueteSuivi TEXT,
          commune TEXT
  )
  ''');

    await db.execute('''
  CREATE TABLE IF NOT EXISTS SuiviFluxs (
      idSuivi  INTEGER PRIMARY KEY,
          codeSuivi TEXT,
          observation TEXT,
          fluxEntrantTonne REAL,
          fluxSortantTonne REAL,
          disponibilite TEXT NOT NULL,
          difficulte TEXT NOT NULL,
          dateCollecte TEXT NOT NULL,
          dateAjout,
          produit TEXT,
          uniteMesure TEXT,
          niveau TEXT,
          enqueteur TEXT,
          enqueteSuivi TEXT,
          commune TEXT
  )
  ''');

    await db.execute('''
  CREATE TABLE IF NOT EXISTS SuiviCampagne (
   idSuiviCampagne INTEGER PRIMARY KEY AUTOINCREMENT,
          commentaire TEXT,
          dateSemi TEXT,
          dateAjout TEXT,
          superficieHa REAL,
          quantiteProduit REAL,
          latitude TEXT,
          longitude TEXT,
          uniteMesure TEXT,
          bassinProduction TEXT,
          campagne TEXT,
          commune TEXT,
          acteur TEXT,
          variete TEXT,
          produit TEXT,
          enqueteur TEXT,
          enqueteCampagne TEXT
  )
  ''');

    await db.execute('''
  CREATE TABLE IF NOT EXISTS SuiviCampagnes (
  idSuiviCampagne INTEGER PRIMARY KEY,
          codeSuiviCampagne TEXT,
          commentaire TEXT,
          dateSemi TEXT,
          dateAjout TEXT,
          superficieHa REAL,
          quantiteProduit REAL,
          bassinProduction TEXT,
          uniteMesure TEXT,
          campagne TEXT,
          commune TEXT,
          acteur TEXT,
          variete TEXT,
          produit TEXT,
          enqueteCampagne TEXT
  )
  ''');

    await db.execute('''
  CREATE TABLE IF NOT EXISTS NiveauApprovisionnement (
    idNiveauApprovisionnement INTEGER PRIMARY KEY,
          codeNiveau TEXT,
          libelle TEXT
  )
  ''');

    await db.execute('''
  CREATE TABLE IF NOT EXISTS  CategorieProduit(
    idCategorieProduit INTEGER PRIMARY KEY,
          codeCategorie TEXT,
          libelle TEXT,
          filiere TEXT
  )
  ''');

    await db.execute('''
  CREATE TABLE IF NOT EXISTS  Campagne(
          idCampagne INTEGER PRIMARY KEY,
          codeCampagne TEXT,
          commentaire TEXT,
          ficheRapport TEXT,
          dateAjout TEXT,
          anneeDebut TEXT,
          anneeFin TEXT,
          dateModif TEXT
  )
  ''');

    await db.execute('''
  CREATE TABLE IF NOT EXISTS  Variete (
          idVariete INTEGER PRIMARY KEY,
          codeVariete TEXT,
          libelle TEXT,
          observation TEXT,
          dateAjout TEXT,
          filiere
  )
  ''');

    await db.execute('''
  CREATE TABLE IF NOT EXISTS  Equivalence (
          id INTEGER PRIMARY KEY,
          unite TEXT,
          produit TEXT,
          commune TEXT
            )
  ''');

    await db.execute('''
  CREATE TABLE IF NOT EXISTS  Produit (
          idProduit INTEGER PRIMARY KEY,
          codeProduit TEXT,
          nomProduit TEXT,
          image TEXT,
          description TEXT,
          dateAjout TEXT,
          categorieProduit TEXT,
          formeProduit TEXT
  )
  ''');

    await db.execute('''
  CREATE TABLE IF NOT EXISTS BassinProduction (
          idBassin INTEGER PRIMARY KEY,
          codeBassin TEXT,
          libelle TEXT
  )
  ''');

    print("Toutes les tables ont été créées avec succès.");
  });
}
