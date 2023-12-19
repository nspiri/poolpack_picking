class LoginData {
  final String username;
  final String password;

  LoginData({required this.username, required this.password});
}

class Utente {
  int? id;
  String? nome;
  bool? rettifica;

  Utente({this.id, this.nome, this.rettifica});

  Utente.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    nome = json['Utente'];
    rettifica = json['Rettifica'];
  }
}
