// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:poolpack_picking/Model/magazzino.dart';
import 'package:poolpack_picking/Model/ordini_fornitori.dart';
import 'package:poolpack_picking/Model/request.dart';
import 'package:poolpack_picking/Model/vendite.dart';
import 'package:poolpack_picking/env.dart';
import 'package:poolpack_picking/utils/global.dart';
import 'package:poolpack_picking/utils/utils.dart';
import '../Model/login_data.dart';
import '../env.dart' as env;

class Http {
  Duration get loginTime => const Duration(milliseconds: 0);

  Future<List<String>> getUtenti(BuildContext context) async {
    try {
      await setIp();
      if (base_url != "") {
        final Request request = Request(
            cmd: 'esec_collage_server_remoto',
            codiceApp: '415944GESTMAGAZ',
            nomeCollage: 'colsrute',
            etichettaCollage: 'UTENTI',
            dati: {});

        final response = await http
            .post(Uri.parse('$base_url/webapi/servizi'),
                headers: env.passHeaders, body: jsonEncode(request))
            .timeout(const Duration(seconds: 10));
        if (response.statusCode == 200) {
          Map<String, dynamic> res = jsonDecode(response.body);
          List<dynamic> parsedListJson = res["result"];
          List<String> listaUtenti = [];
          for (int c = 0; c < parsedListJson.length; c++) {
            listaUtenti.add(parsedListJson[c]["Utente"]);
          }
          return listaUtenti;
        } else {
          return [];
        }
      } else {
        showErrorMessage(context, "Configura un url");
        return [];
      }
    } on TimeoutException {
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<String?> doLogin(LoginData data) async {
    try {
      final Request request = Request(
          cmd: 'esec_collage_server_remoto',
          codiceApp: '415944GESTMAGAZ',
          nomeCollage: 'colsrute',
          etichettaCollage: 'LOGIN',
          dati: {"Utente": data.username, "Password": data.password});
      final response = await http
          .post(Uri.parse('${env.base_url}/webapi/servizi'),
              headers: env.passHeaders, body: jsonEncode(request))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        Map<String, dynamic> res = jsonDecode(response.body);
        utente_selezionato = Utente.fromJson(res["result"][0]);
        return "200";
      } else {
        return '${response.statusCode}';
      }
    } on TimeoutException {
      return "404";
    } catch (e) {
      return e.toString();
    }
  }

  Future<List<DocumentoOF>> getOrdini(String data) async {
    try {
      final Request request = Request(
          cmd: 'esec_collage_server_remoto',
          codiceApp: '415944GESTMAGAZ',
          nomeCollage: 'colsrpic',
          etichettaCollage: 'ENTRATA',
          dati: {"Scadenza": data});
      final response = await http
          .post(Uri.parse('${env.base_url}/webapi/servizi'),
              headers: env.passHeaders, body: jsonEncode(request))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        Map<String, dynamic> res = jsonDecode(response.body);
        List<dynamic>? parsedListJson = res["result"];
        List<DocumentoOF> ordini = [];
        if (parsedListJson != null) {
          ordini = List<DocumentoOF>.from(
              parsedListJson.map((i) => DocumentoOF.fromJson(i)));
        }
        return ordini;
      } else {
        return [];
      }
    } on TimeoutException {
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<Magazzino>> getMagazzini() async {
    try {
      final Request request = Request(
          cmd: 'esec_collage_server_remoto',
          codiceApp: '415944GESTMAGAZ',
          nomeCollage: 'colsrmag',
          etichettaCollage: 'MAGAZZINI',
          dati: {});
      final response = await http
          .post(Uri.parse('${env.base_url}/webapi/servizi'),
              headers: env.passHeaders, body: jsonEncode(request))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        Map<String, dynamic> res = jsonDecode(response.body);
        List<Magazzino> magazzini = [];
        List<dynamic>? parsedListJson =
            res["result"]; //jsonDecode(response.body);
        if (parsedListJson != null) {
          magazzini = List<Magazzino>.from(
              parsedListJson.map((i) => Magazzino.fromJson(i)));
        }
        return magazzini;
      } else {
        return [];
      }
    } on TimeoutException {
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<Ubicazione>> getUbicazioni() async {
    try {
      final Request request = Request(
          cmd: 'esec_collage_server_remoto',
          codiceApp: '415944GESTMAGAZ',
          nomeCollage: 'colsrmag',
          etichettaCollage: 'UBICAZIONI',
          dati: {"IdMagazzino": 1});

      final response = await http
          .post(Uri.parse('${env.base_url}/webapi/servizi'),
              headers: env.passHeaders, body: jsonEncode(request))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        Map<String, dynamic> res = jsonDecode(response.body);
        List<Ubicazione> ubicazioni = [];
        List<dynamic>? parsedListJson = res["result"];
        if (parsedListJson != null) {
          ubicazioni = List<Ubicazione>.from(
              parsedListJson.map((i) => Ubicazione.fromJson(i)));
        }
        return ubicazioni;
      } else {
        return [];
      }
    } on TimeoutException {
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<ArticoloLista>> getArticoli() async {
    try {
      final Request request = Request(
          cmd: 'esec_collage_server_remoto',
          codiceApp: '415944GESTMAGAZ',
          nomeCollage: 'colsrmag',
          etichettaCollage: 'ANAG_ARTICOLI',
          dati: {"IdMagazzino": 1});

      final response = await http
          .post(Uri.parse('${env.base_url}/webapi/servizi'),
              headers: env.passHeaders, body: jsonEncode(request))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        Map<String, dynamic> res = jsonDecode(response.body);
        List<ArticoloLista> ubicazioni = [];
        List<dynamic>? parsedListJson = res["result"];
        if (parsedListJson != null) {
          ubicazioni = List<ArticoloLista>.from(
              parsedListJson.map((i) => ArticoloLista.fromJson(i)));
        }
        return ubicazioni;
      } else {
        return [];
      }
    } on TimeoutException {
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<Picking?> setPickingOrdini(Picking data, BuildContext context) async {
    try {
      final Request request = Request(
          cmd: 'esec_collage_server_remoto',
          codiceApp: '415944GESTMAGAZ',
          nomeCollage: 'colsrpic',
          etichettaCollage: 'SET_PICKING',
          dati: data);
      final response = await http
          .post(Uri.parse('${env.base_url}/webapi/servizi'),
              headers: env.passHeaders, body: jsonEncode(request))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        Picking picking;
        Map<String, dynamic> res = jsonDecode(response.body);
        picking = Picking.fromJson(res["result"][0]);
        showSuccessMessage(context, "Picking aggiornato");
        return picking;
      } else {
        return null;
      }
    } on TimeoutException {
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> associaAlias(
      String alias, String codArt, int prgTaglia, double quantita) async {
    try {
      final Request request = Request(
          cmd: 'esec_collage_server_remoto',
          codiceApp: '415944GESTMAGAZ',
          nomeCollage: 'colsrmag',
          etichettaCollage: 'ASSOCIA_ALIAS',
          dati: {
            "CodiceArticolo": codArt,
            "CodiceAlias": alias,
            "PrgTaglia": prgTaglia,
            "Quantita": quantita
          });
      final response = await http
          .post(Uri.parse('${env.base_url}/webapi/servizi'),
              headers: env.passHeaders, body: jsonEncode(request))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        Map<String, dynamic> res = jsonDecode(response.body);
        List<dynamic>? result = res["result"];
        List<dynamic>? error = res["error"];
        if (error!.isNotEmpty) {
          return false;
        }
        return true;
      } else {
        return false;
      }
    } on TimeoutException {
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> creaEAN(String codArt, BuildContext context) async {
    try {
      final Request request = Request(
          cmd: 'esec_collage_server_remoto',
          codiceApp: '415944GESTMAGAZ',
          nomeCollage: 'colsrmag',
          etichettaCollage: 'CREA_EAN',
          dati: {"CodiceArticolo": codArt});
      final response = await http
          .post(Uri.parse('${env.base_url}/webapi/servizi'),
              headers: env.passHeaders, body: jsonEncode(request))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        Map<String, dynamic> res = jsonDecode(response.body);
        List<dynamic>? result = res["result"];
        List<dynamic>? error = res["error"];
        if (error!.isNotEmpty) {
          showErrorMessage(context, error[0]["response-message"]);
          return false;
        }
        showSuccessMessage(context, "Codice EAN generato");
        return true;
      } else {
        showErrorMessage(context, "Si è verificato un errore del server");
        return false;
      }
    } on TimeoutException {
      showErrorMessage(context, "Timeout Exception");
      return false;
    } catch (e) {
      showErrorMessage(context, "Si è verificato un errore interno");
      return false;
    }
  }

  Future<bool> stampaEtichetta(String codArt, BuildContext context) async {
    try {
      final Request request = Request(
          cmd: 'esec_collage_server_remoto',
          codiceApp: '415944GESTMAGAZ',
          nomeCollage: 'colsrmag',
          etichettaCollage: 'STAMPA_ETICHETTA',
          dati: {
            "CodiceArticolo": codArt,
            "Copie": 1,
            "Stampante": numeroStampante
          });
      final response = await http
          .post(Uri.parse('${env.base_url}/webapi/servizi'),
              headers: env.passHeaders, body: jsonEncode(request))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        Map<String, dynamic> res = jsonDecode(response.body);
        List<dynamic>? result = res["result"];
        List<dynamic>? error = res["error"];
        if (error!.isNotEmpty) {
          showErrorMessage(context, error[0]["response-message"]);
          return false;
        }
        showSuccessMessage(context, "Stampa etichetta inviata");
        return true;
      } else {
        showErrorMessage(context, "Si è verificato un errore del server");
        return false;
      }
    } on TimeoutException {
      showErrorMessage(context, "Timeout Exception");
      return false;
    } catch (e) {
      showErrorMessage(context, "Si è verificato un errore interno");
      return false;
    }
  }

  Future<bool> associaUbicazione(int codUb, String codArt) async {
    try {
      final Request request = Request(
          cmd: 'esec_collage_server_remoto',
          codiceApp: '415944GESTMAGAZ',
          nomeCollage: 'colsrmag',
          etichettaCollage: 'ASSOCIA_UBICAZIONE',
          dati: {"CodiceArticolo": codArt, "IdUbicazione": codUb});
      final response = await http
          .post(Uri.parse('${env.base_url}/webapi/servizi'),
              headers: env.passHeaders, body: jsonEncode(request))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        Map<String, dynamic> res = jsonDecode(response.body);
        List<dynamic>? result = res["result"];
        List<dynamic>? error = res["error"];
        if (error!.isNotEmpty) {
          return false;
        }
        return true;
      } else {
        return false;
      }
    } on TimeoutException {
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<List<Articolo>> getArticoliArt(String codArt, int prTaglia) async {
    try {
      final Request request = Request(
          cmd: 'esec_collage_server_remoto',
          codiceApp: '415944GESTMAGAZ',
          nomeCollage: 'colsrmag',
          etichettaCollage: 'ARTICOLO',
          dati: {"IdMagazzino": 1, "Codice": codArt});
      final response = await http
          .post(Uri.parse('${env.base_url}/webapi/servizi'),
              headers: env.passHeaders, body: jsonEncode(request))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        Map<String, dynamic> res = jsonDecode(response.body);
        List<dynamic>? parsedListJson = res["result"];
        List<Articolo> articoli = [];
        if (parsedListJson != null) {
          articoli = List<Articolo>.from(
              parsedListJson.map((i) => Articolo.fromJson(i)));
        }
        if (prTaglia != 0) {
          if (articoli.length > 1) {
            for (var c = 0; c < articoli.length; c++) {
              if (articoli[c].prgTaglia == prTaglia) {
                return [articoli[c]];
              }
            }
          }
        }
        return articoli;
      } else {
        return [];
      }
    } on TimeoutException {
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<Articolo>> getArticoliUbi(int codUb) async {
    try {
      final Request request = Request(
          cmd: 'esec_collage_server_remoto',
          codiceApp: '415944GESTMAGAZ',
          nomeCollage: 'colsrmag',
          etichettaCollage: 'UBICAZIONE',
          dati: {"IdMagazzino": 1, "IdUbicazione": codUb});
      final response = await http
          .post(Uri.parse('${env.base_url}/webapi/servizi'),
              headers: env.passHeaders, body: jsonEncode(request))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        Map<String, dynamic> res = jsonDecode(response.body);
        List<dynamic>? parsedListJson = res["result"];
        List<Articolo> ordini = [];
        if (parsedListJson != null) {
          ordini = List<Articolo>.from(
              parsedListJson.map((i) => Articolo.fromJson(i)));
        }
        return ordini;
      } else {
        return [];
      }
    } on TimeoutException {
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<Zona>> getZone() async {
    try {
      final Request request = Request(
          cmd: 'esec_collage_server_remoto',
          codiceApp: '415944GESTMAGAZ',
          nomeCollage: 'colsrpic',
          etichettaCollage: 'USCITAZONE',
          dati: {});
      final response = await http
          .post(Uri.parse('${env.base_url}/webapi/servizi'),
              headers: env.passHeaders, body: jsonEncode(request))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        Map<String, dynamic> res = jsonDecode(response.body);
        List<dynamic>? parsedListJson = res["result"];
        List<Zona> zone = [];
        if (parsedListJson != null) {
          zone = List<Zona>.from(parsedListJson.map((i) => Zona.fromJson(i)));
        }
        return zone;
      } else {
        return [];
      }
    } on TimeoutException {
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<DocumentoOF>> getVendite(int zona) async {
    try {
      final Request request = Request(
          cmd: 'esec_collage_server_remoto',
          codiceApp: '415944GESTMAGAZ',
          nomeCollage: 'colsrpic',
          etichettaCollage: 'USCITA',
          dati: {"IdZona": zona});
      final response = await http
          .post(Uri.parse('${env.base_url}/webapi/servizi'),
              headers: env.passHeaders, body: jsonEncode(request))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        Map<String, dynamic> res = jsonDecode(response.body);
        List<dynamic>? parsedListJson = res["result"];
        List<DocumentoOF> ordini = [];
        if (parsedListJson != null) {
          ordini = List<DocumentoOF>.from(
              parsedListJson.map((i) => DocumentoOF.fromJson(i)));
        }
        return ordini;
      } else {
        return [];
      }
    } on TimeoutException {
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> evadiDocumenti(
      List<EvadiDocumento> dati, BuildContext context) async {
    try {
      final Request request = Request(
          cmd: 'esec_collage_server_remoto',
          codiceApp: '415944GESTMAGAZ',
          nomeCollage: 'colsrdoc',
          etichettaCollage: 'EVADI',
          dati: {
            "Utente": utente_selezionato!.nome,
            "IdUbicazione": getUbicazioneFromCode(idUbicazioneScarico)?.id,
            "Documenti": dati
          });
      final response = await http
          .post(Uri.parse('${env.base_url}/webapi/servizi'),
              headers: env.passHeaders, body: jsonEncode(request))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        Map<String, dynamic> res = jsonDecode(response.body);
        List<dynamic>? result = res["result"];
        List<dynamic>? error = res["error"];
        if (error!.isNotEmpty) {
          showErrorMessage(context, error[0]["response-message"]);
          return false;
        }
        return true;
      } else {
        showErrorMessage(context, "Si è verificato un errore del server");
        return false;
      }
    } on TimeoutException {
      showErrorMessage(context, "Timeout exception");
      return false;
    } catch (e) {
      showErrorMessage(context, "Errore:${e.toString()}");
      return false;
    }
  }

  Future<Documento?> movimento(String movimento,
      List<ArticoloMovimento> articoli, BuildContext context) async {
    try {
      final Request request = Request(
          cmd: 'esec_collage_server_remoto',
          codiceApp: '415944GESTMAGAZ',
          nomeCollage: 'colsrdoc',
          etichettaCollage: 'MOVIMENTO',
          dati: {
            "Movimento": movimento,
            "Utente": utente_selezionato!.nome,
            "Articoli": articoli
          });
      final response = await http
          .post(Uri.parse('${env.base_url}/webapi/servizi'),
              headers: env.passHeaders, body: jsonEncode(request))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        Documento doc;
        Map<String, dynamic> res = jsonDecode(response.body);
        List<dynamic>? error = res["error"];
        if (error!.isNotEmpty) {
          showErrorMessage(context, error[0]["response-message"]);
          return null;
        }
        doc = Documento.fromJson(res["result"][0]);
        return doc;
      } else {
        showErrorMessage(context, "Si è verificato un errore del server");
        return null;
      }
    } on TimeoutException {
      showErrorMessage(context, "Timeout exception");
      return null;
    } catch (e) {
      showErrorMessage(context, "Errore:${e.toString()}");
      return null;
    }
  }

  Future<Documento?> rettifica(int idMagazzino, Articolo art,
      List<Esistenza> dati, BuildContext context) async {
    try {
      final Request request = Request(
          cmd: 'esec_collage_server_remoto',
          codiceApp: '415944GESTMAGAZ',
          nomeCollage: 'colsrdoc',
          etichettaCollage: 'RETTIFICA',
          dati: {
            "CodiceArticolo": art.codiceArticolo,
            "PrgTaglia": art.prgTaglia,
            "IdMagazzino": idMagazzino,
            "Utente": utente_selezionato!.nome,
            "Esistenza": dati
          });
      var b = jsonEncode(request);
      final response = await http
          .post(Uri.parse('${env.base_url}/webapi/servizi'),
              headers: env.passHeaders, body: jsonEncode(request))
          .timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        Documento doc;
        Map<String, dynamic> res = jsonDecode(response.body);
        List<dynamic>? error = res["error"];
        if (error!.isNotEmpty) {
          showErrorMessage(context, error[0]["response-message"]);
          return null;
        }
        doc = Documento.fromJson(res["result"][0]);
        return doc;
      } else {
        showErrorMessage(context, "Si è verificato un errore del server");
        return null;
      }
    } on TimeoutException {
      showErrorMessage(context, "Timeout exception");
      return null;
    } catch (e) {
      showErrorMessage(context, "Errore:${e.toString()}");
      return null;
    }
  }
}
