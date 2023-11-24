import 'package:flutter/material.dart';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:intl/intl.dart';
import 'package:poolpack_picking/Model/ordini_fornitori.dart';
import 'package:poolpack_picking/pages/home.dart';
import 'package:poolpack_picking/pages/login.dart';
import 'package:poolpack_picking/pages/ordini/componenti/lista_articoli.dart';
import 'package:poolpack_picking/utils/http.dart';
import 'package:poolpack_picking/utils/global.dart';
import 'package:poolpack_picking/utils/utils.dart';

class PaginaListaArticoli extends StatefulWidget {
  static const route = "/listaArticoli";
  final PassaggioDatiOrdini ordine;
  const PaginaListaArticoli({super.key, required this.ordine});

  @override
  ListaArticoliState createState() => ListaArticoliState();
}

class ListaArticoliState extends State<PaginaListaArticoli> {
  bool isLoading = false;
  Http http = Http();
  final List<bool> ordineUbicazioneSelezionato = <bool>[true, false];
  bool visualizzaListaOrdini = false;

  bool isShowing = false;

  @override
  void initState() {
    //BackButtonInterceptor.add(myInterceptor);
    super.initState();
  }

  controlloOrdineCompleto(DocumentoOF documento) {
    int numeroArticoliCompleti = 0;

    for (int c = 0; c < documento.articoli!.length; c++) {
      Articolo art = documento.articoli![c];
      if (art.picking != null) {
        if (art.picking!.stato != " ") {
          if (art.picking!.stato == "<" || art.picking!.stato == ">") {
          } else {
            numeroArticoliCompleti += 1;
          }
        }
      }
    }

    if (numeroArticoliCompleti == documento.articoli?.length) {
      return true;
    }
    return false;
  }

  controlloOrdiniCompletati() {
    for (int c = 0; c < widget.ordine.ordini.length; c++) {
      if (controlloOrdineCompleto(widget.ordine.ordini[c]) == false) {
        return false;
      }
    }
    return true;
  }

  setOrdine(DocumentoOF doc) {
    widget.ordine.ordine = doc;
    setState(() {});
  }

  setLoading(bool val) {
    isLoading = val;
    setState(() {});
  }

  apriDialogConferma() {
    showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Ordine completato.'),
        content: const Text("Vuoi passare all'ordine successivo?"),
        actions: [
          TextButton(
            child: const Text('No'),
            onPressed: () {
              isShowing = false;
              Navigator.pop(c, false);
            },
          ),
          TextButton(
            child: const Text('Si'),
            onPressed: () {
              setState(() {
                widget.ordine.ordine =
                    widget.ordine.ordini[trovaOrdineSuccessivo()];
                Navigator.pop(c, false);
              });
            },
          ),
        ],
      ),
    );
  }

  apriDialogOrdiniCompletati() {
    showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Ordini completati.'),
        content: const Text("Tutti gli ordini sono stati completati."),
        actions: [
          TextButton(
            child: const Text('Ok'),
            onPressed: () {
              isShowing = false;
              Navigator.pop(c, false);
            },
          ),
        ],
      ),
    );
  }

  trovaOrdineSuccessivo() {
    for (int c = 0; c < widget.ordine.ordini.length; c++) {
      if (widget.ordine.ordini[c].serie == widget.ordine.ordine.serie &&
          widget.ordine.ordini[c].numero == widget.ordine.ordine.numero) {
        if (!(c + 1 >= widget.ordine.ordini.length)) {
          var num = c + 1;
          for (var i = num; i < widget.ordine.ordini.length; i++) {
            if (!controlloOrdineCompleto(widget.ordine.ordini[num])) {
              return i;
            }
          }
        }
      }
    }
    return 0;
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    if (!isShowing) {
      isShowing = true;
      showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text('Attenzione'),
          content: const Text("Vuoi veramente uscire dall'applicazione?"),
          actions: [
            TextButton(
              child: const Text('Si'),
              onPressed: () {
                utente_selezionato = null;
                Navigator.pushNamed(context, Login.route);
              },
            ),
            TextButton(
              child: const Text('No'),
              onPressed: () {
                isShowing = false;
                Navigator.pop(c, false);
              },
            ),
          ],
        ),
      );
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return scaffold(ordine: widget.ordine.ordine);
  }

  refresh() {
    setState(() {});
  }

  evadiOrdine(
      DocumentoOF documento, String dataDocumento, String numeroDocumento) {
    EvadiDocumento doc = EvadiDocumento(
      dataTras: DateFormat("yyyyMMdd")
          .format(DateFormat("dd-MM-yyyy").parse(dataDocumento)),
      documento: "OF",
      documentoTras: "BF",
      serie: documento.serie,
      numero: documento.numero,
      numeroTras: int.parse(numeroDocumento),
    );
    List<EvadiDocumento> dati = [doc];
    isLoading = true;
    setState(() {});
    http.evadiDocumenti(dati, context).then((value) {
      if (value) {
        showSuccessMessage(context, "Documento creato");
        Navigator.pop(context);
      }
      isLoading = false;
      setState(() {});
      widget.ordine.aggiornaDocumenti();
    });
  }

  Widget scaffold({required DocumentoOF ordine}) {
    return Scaffold(
      appBar: AppBar(
        title: RichText(
          textAlign: TextAlign.start,
          text: TextSpan(
              text: '${ordine.documento} ${ordine.serie}/${ordine.numero}',
              style: const TextStyle(fontSize: 20),
              children: const <TextSpan>[]),
        ),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pushNamed(context, HomePage.route);
              },
              icon: const Icon(Icons.home)),
          Visibility(
            visible: widget.ordine.isOF,
            child: IconButton(
                onPressed: () {
                  if (controlloOrdineCompleto(ordine)) {
                    apriDialogDatiBF(ordine, context, evadiOrdine);
                  } else {
                    showErrorMessage(
                        context, "Completa l'ordine prima di poterlo inviare");
                  }
                },
                icon: const Icon(Icons.send)),
          )
        ],
      ),
      body: Stack(
        children: [
          ListaArticoli(
            articoli: ordine.articoli,
            visualizzaDatiOrdine: false,
            documento: widget.ordine.ordine,
            listaDocumenti: widget.ordine.ordini,
            controlloOrdineCompleto: () {
              if (controlloOrdineCompleto(ordine)) {
                if (!controlloOrdiniCompletati()) {
                  apriDialogConferma();
                } else {
                  apriDialogOrdiniCompletati();
                }
              }
            },
            setDocumento: setOrdine,
            isOF: widget.ordine.isOF,
            setLoading: setLoading,
          ),
          loading()
        ],
      ),
    );
  }

  Widget loading() {
    return Visibility(
      visible: isLoading,
      child: Container(
        decoration: BoxDecoration(color: Colors.grey.withOpacity(0.5)),
        child: const Center(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }

  Widget errore() {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Ordini"),
        ),
        body: const Text("Si è verificato un errore"));
  }
}
