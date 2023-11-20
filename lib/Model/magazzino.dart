import 'package:poolpack_picking/Model/ordini_fornitori.dart';

class Magazzino {
  int? id;
  String? descrizione;

  Magazzino({this.id, this.descrizione});

  Magazzino.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    descrizione = json['Descrizione'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Id'] = id;
    data['Descrizione'] = descrizione;
    return data;
  }
}

class Ubicazione {
  int? id;
  int? idMagazzino;
  String? codice;
  String? descrizione;
  String? area;
  int? percorso;

  Ubicazione(
      {this.id,
      this.idMagazzino,
      this.codice,
      this.descrizione,
      this.area,
      this.percorso});

  Ubicazione.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    idMagazzino = json['IdMagazzino'];
    codice = json['Codice'];
    descrizione = json['Descrizione'];
    area = json['Area'];
    percorso = json['Percorso'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Id'] = id;
    data['IdMagazzino'] = idMagazzino;
    data['Codice'] = codice;
    data['Descrizione'] = descrizione;
    data['Area'] = area;
    data['Percorso'] = percorso;
    return data;
  }
}

class PassaggioDatiArticolo {
  Articolo articolo;
  DocumentoOF? documentoOF;
  List<DocumentoOF>? listaDocumenti;
  String modalita;
  int? index;
  final Function()? controlloOrdineCompleto;
  final Function(DocumentoOF doc)? setDocumento;

  PassaggioDatiArticolo(
      {required this.articolo,
      required this.modalita,
      required this.documentoOF,
      required this.index,
      required this.controlloOrdineCompleto,
      required this.listaDocumenti,
      required this.setDocumento});
}

class ArticoloLista {
  String? codiceArticolo;
  String? descrizione;

  ArticoloLista({this.codiceArticolo, this.descrizione});

  ArticoloLista.fromJson(Map<String, dynamic> json) {
    codiceArticolo = json['CodiceArticolo'];
    descrizione = json['Descrizione'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['CodiceArticolo'] = codiceArticolo;
    data['Descrizione'] = descrizione;
    return data;
  }
}
