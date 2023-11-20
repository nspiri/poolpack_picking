class Zona {
  int? id;
  String? descrizione;
  int? documenti;

  Zona({this.id, this.descrizione, this.documenti});

  Zona.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    descrizione = json['Descrizione'];
    documenti = json['Documenti'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Id'] = id;
    data['Descrizione'] = descrizione;
    data['Documenti'] = documenti;
    return data;
  }
}
