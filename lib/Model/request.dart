class Request {
  late String cmd;
  late String codiceApp;
  late String nomeCollage;
  late String etichettaCollage;
  late dynamic dati;

  Request(
      {required this.cmd,
      required this.codiceApp,
      required this.nomeCollage,
      required this.etichettaCollage,
      required this.dati});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['cmd'] = cmd;
    data['codice_app'] = codiceApp;
    data['nome_collage'] = nomeCollage;
    data['etichetta_collage'] = etichettaCollage;
    data['dati'] = dati;

    return data;
  }
}
