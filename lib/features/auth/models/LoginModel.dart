class LoginModel {
  String codeEnqueteur;
  String passWord;

  LoginModel({
    required this.codeEnqueteur,
    required this.passWord,
  });

  Map<String, dynamic> toJson() {
    return {
      "codeEnqueteur": codeEnqueteur,
      "password": passWord,
    };
  }
}