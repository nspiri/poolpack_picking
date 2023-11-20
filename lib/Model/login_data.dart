class LoginData {
  final String username;
  final String password;

  LoginData({required this.username, required this.password});
}

class Utente {
  int? id;
  String? nome;

  Utente({this.id, this.nome});

  Utente.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    nome = json['Utente'];
  }
}
