class DocumentoOF {
  String? documento;
  int? serie;
  int? numero;
  String? data;
  String? intestatario;
  int? giro;
  String? scadenza;
  List<Articolo>? articoli;

  DocumentoOF(
      {this.documento,
      this.serie,
      this.numero,
      this.data,
      this.intestatario,
      this.giro,
      this.scadenza,
      this.articoli});

  DocumentoOF.fromJson(Map<String, dynamic> json) {
    documento = json['Documento'];
    serie = json['Serie'];
    numero = json['Numero'];
    data = json['Data'];
    intestatario = json['Intestatario'];
    giro = json['Giro'];
    scadenza = json['Scadenza'];
    if (json['Articoli'] != null) {
      articoli = <Articolo>[];
      json['Articoli'].forEach((v) {
        articoli!.add(Articolo.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Documento'] = documento;
    data['Serie'] = serie;
    data['Numero'] = numero;
    data['Data'] = this.data;
    data['Intestatario'] = intestatario;
    data['Giro'] = giro;
    data['Scadenza'] = scadenza;
    if (articoli != null) {
      data['Articoli'] = articoli!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Articolo {
  int? rigo;
  int? prgTaglia;
  String? codiceArticolo;
  String? descrizione;
  String? um;
  String? taglia;
  int? colli;
  double? quantita;
  String? um1;
  double? quantitaTotaleUm1;
  double? confezione;
  int? decimali;
  int? idMagazzino;
  int? idUbicazione;
  String? ubicazione;
  double? percorso;
  bool? gestioneLotto;
  Picking? picking;
  List<Esistenza>? esistenza;
  Alias? alias;
  double? esistenzaTotale;
  double? esistenzaUbicazione;
  String? documento;

  Articolo(
      {this.rigo,
      this.prgTaglia,
      this.codiceArticolo,
      this.descrizione,
      this.um,
      this.taglia,
      this.colli,
      this.quantita,
      this.um1,
      this.quantitaTotaleUm1,
      this.decimali,
      this.idMagazzino,
      this.idUbicazione,
      this.ubicazione,
      this.confezione,
      this.percorso,
      this.gestioneLotto,
      this.picking,
      this.esistenza,
      this.alias,
      this.esistenzaTotale,
      this.esistenzaUbicazione,
      this.documento});

  Articolo.fromJson(Map<String, dynamic> json) {
    rigo = json['Rigo'];
    prgTaglia = json['PrgTaglia'];
    codiceArticolo = json['CodiceArticolo'];
    descrizione = json['Descrizione'];
    um = json['Um'];
    taglia = json['Taglia'];
    colli = json['Colli'];
    quantita = json['Quantita'];
    um1 = json['Um1'];
    confezione = json['Confezione'];
    quantitaTotaleUm1 = json['QuantitaTotaleUm1'];
    decimali = json['Decimali'];
    idMagazzino = json['IdMagazzino'];
    idUbicazione = json['IdUbicazione'];
    ubicazione = json['Ubicazione'];
    percorso = json['Percorso'];
    gestioneLotto = json['GestioneLotto'];
    picking =
        json['Picking'] != null ? Picking.fromJson(json['Picking']) : null;
    if (json['Esistenza'] != null) {
      esistenza = <Esistenza>[];
      json['Esistenza'].forEach((v) {
        esistenza!.add(Esistenza.fromJson(v));
      });
    }
    alias = json['Alias'] != null ? Alias.fromJson(json['Alias']) : null;
    esistenzaTotale = json['EsistenzaTotale'];
    esistenzaUbicazione = json['EsistenzaUbicazione'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Rigo'] = rigo;
    data['PrgTaglia'] = prgTaglia;
    data['CodiceArticolo'] = codiceArticolo;
    data['Descrizione'] = descrizione;
    data['Um'] = um;
    data['Taglia'] = taglia;
    data['Colli'] = colli;
    data['Quantita'] = quantita;
    data['Um1'] = um1;
    data['Confezione'] = confezione;
    data['QuantitaTotaleUm1'] = quantitaTotaleUm1;
    data['Decimali'] = decimali;
    data['IdMagazzino'] = idMagazzino;
    data['IdUbicazione'] = idUbicazione;
    data['Ubicazione'] = ubicazione;
    data['Percorso'] = percorso;
    data['GestioneLotto'] = gestioneLotto;
    if (picking != null) {
      data['Picking'] = picking!.toJson();
    }
    if (esistenza != null) {
      data['Esistenza'] = esistenza!.map((v) => v.toJson()).toList();
    }
    if (alias != null) {
      data['Alias'] = alias!.toJson();
    }
    data['EsistenzaTotale'] = esistenzaTotale;
    data['EsistenzaUbicazione'] = esistenzaUbicazione;
    return data;
  }
}

class Picking {
  String? documento;
  int? serie;
  int? numero;
  int? rigo;
  int? prgTaglia;
  String? codiceArticolo;
  int? colli;
  double? quantita;
  int? idMagazzino;
  int? idUbicazione;
  String? stato;
  String? idUtente;
  String? inserimento;
  String? ultimaModifica;

  Picking(
      {this.documento,
      this.serie,
      this.numero,
      this.rigo,
      this.prgTaglia,
      this.codiceArticolo,
      this.colli,
      this.quantita,
      this.idMagazzino,
      this.idUbicazione,
      this.stato,
      this.idUtente,
      this.inserimento,
      this.ultimaModifica});

  Picking.fromJson(Map<String, dynamic> json) {
    documento = json['Documento'];
    serie = json['Serie'];
    numero = json['Numero'];
    rigo = json['Rigo'];
    prgTaglia = json['PrgTaglia'];
    codiceArticolo = json['CodiceArticolo'];
    colli = json['Colli'];
    quantita = json['Quantita'];
    idMagazzino = json['IdMagazzino'];
    idUbicazione = json['IdUbicazione'];
    stato = json['Stato'];
    idUtente = json['Utente'];
    inserimento = json['Inserimento'];
    ultimaModifica = json['UltimaModifica'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Documento'] = documento;
    data['Serie'] = serie;
    data['Numero'] = numero;
    data['Rigo'] = rigo;
    data['PrgTaglia'] = prgTaglia;
    data['CodiceArticolo'] = codiceArticolo;
    data['Colli'] = colli;
    data['Quantita'] = quantita;
    data['IdMagazzino'] = idMagazzino;
    data['IdUbicazione'] = idUbicazione;
    data['Stato'] = stato;
    data['Utente'] = idUtente;
    data['Inserimento'] = inserimento;
    data['UltimaModifica'] = ultimaModifica;
    return data;
  }
}

class Esistenza {
  String? scadenzaLotto;
  int? idLotto;
  bool? ubicazionePredefinita;
  int? idUbicazione;
  double? quantita;
  String? codiceLotto;

  Esistenza(
      {this.scadenzaLotto,
      this.idLotto,
      this.ubicazionePredefinita,
      this.idUbicazione,
      this.quantita,
      this.codiceLotto});

  Esistenza.fromJson(Map<String, dynamic> json) {
    scadenzaLotto = json['ScadenzaLotto'];
    idLotto = json['IdLotto'];
    ubicazionePredefinita = json['UbicazionePredefinita'];
    idUbicazione = json['IdUbicazione'];
    quantita = json['Quantita'];
    codiceLotto = json['CodiceLotto'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ScadenzaLotto'] = scadenzaLotto;
    data['IdLotto'] = idLotto;
    data['UbicazionePredefinita'] = ubicazionePredefinita;
    data['IdUbicazione'] = idUbicazione;
    data['Quantita'] = quantita;
    data['CodiceLotto'] = codiceLotto;
    return data;
  }
}

class PassaggioDatiOrdini {
  DocumentoOF ordine;
  bool isOF;
  List<DocumentoOF> ordini;
  Function() aggiornaDocumenti;

  PassaggioDatiOrdini(
      {required this.ordine,
      required this.ordini,
      required this.isOF,
      required this.aggiornaDocumenti});
}

class Alias {
  int? id;
  String? codice;
  String? descrizione;
  int? colli;
  double? quantita;
  String? um;

  Alias(
      {this.id,
      this.codice,
      this.descrizione,
      this.colli,
      this.quantita,
      this.um});

  Alias.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    codice = json['Codice'];
    descrizione = json['Descrizione'];
    colli = json['Colli'];
    quantita = json['Quantita'];
    um = json['Um'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Id'] = id;
    data['Codice'] = codice;
    data['Descrizione'] = descrizione;
    data['Colli'] = colli;
    data['Quantita'] = quantita;
    data['Um'] = um;
    return data;
  }
}

class EvadiDocumento {
  String? documento;
  int? serie;
  int? numero;
  String? documentoTras;
  int? numeroTras;
  String? dataTras;

  EvadiDocumento({
    this.documento,
    this.serie,
    this.numero,
    this.documentoTras,
    this.numeroTras,
    this.dataTras,
  });

  EvadiDocumento.fromJson(Map<String, dynamic> json) {
    documento = json['Documento'];
    serie = json['Serie'];
    numero = json['Numero'];
    documentoTras = json['DocumentoTras'];
    numeroTras = json['NumeroTras'];
    dataTras = json['DataTras'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Documento'] = documento;
    data['Serie'] = serie;
    data['Numero'] = numero;
    data['DocumentoTras'] = documentoTras;
    data['NumeroTras'] = numeroTras;
    data['DataTras'] = dataTras;
    return data;
  }
}

class ArticoloMovimento {
  String? codiceArticolo;
  int? prgTaglia;
  double? quantita;
  int? idLotto;
  int? idMagazzino;
  int? idUbicazione;
  int? idMagazzinoA;
  int? idUbicazioneA;
  String? nota;

  ArticoloMovimento(
      {this.codiceArticolo,
      this.prgTaglia,
      this.quantita,
      this.idLotto,
      this.idMagazzino,
      this.idUbicazione,
      this.idMagazzinoA,
      this.idUbicazioneA,
      this.nota});

  ArticoloMovimento.fromJson(Map<String, dynamic> json) {
    codiceArticolo = json['CodiceArticolo'];
    prgTaglia = json['PrgTaglia'];
    quantita = json['Quantita'];
    idLotto = json['IdLotto'];
    idMagazzino = json['IdMagazzino'];
    idUbicazione = json['IdUbicazione'];
    idMagazzinoA = json['IdMagazzinoA'];
    idUbicazioneA = json['IdUbicazioneA'];
    nota = json['Nota'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['CodiceArticolo'] = codiceArticolo;
    data['PrgTaglia'] = prgTaglia;
    data['Quantita'] = quantita;
    data['IdLotto'] = idLotto;
    data['IdMagazzino'] = idMagazzino;
    data['IdUbicazione'] = idUbicazione;
    data['IdMagazzinoA'] = idMagazzinoA;
    data['IdUbicazioneA'] = idUbicazioneA;
    data['Nota'] = nota;
    return data;
  }
}

class Documento {
  int? serie;
  String? documento;
  int? numero;
  String? data;

  Documento({this.serie, this.documento, this.numero, this.data});

  Documento.fromJson(Map<String, dynamic> json) {
    serie = json['Serie'];
    documento = json['Documento'];
    numero = json['Numero'];
    data = json['Data'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Serie'] = serie;
    data['Documento'] = documento;
    data['Numero'] = numero;
    data['Data'] = data;
    return data;
  }
}
