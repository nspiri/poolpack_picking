// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:poolpack_picking/Model/magazzino.dart';
import 'package:poolpack_picking/pages/articolo/anagrafica_articolo.dart';
import 'package:poolpack_picking/utils/global.dart';
import 'package:poolpack_picking/utils/http.dart';
import 'package:poolpack_picking/Model/ordini_fornitori.dart';
import 'package:poolpack_picking/utils/utils.dart';

class ListaArticoli extends StatefulWidget {
  final List<Articolo>? articoli;
  final bool visualizzaDatiOrdine;
  final DocumentoOF? documento;
  final List<DocumentoOF> listaDocumenti;
  final bool isOF;
  final Function() controlloOrdineCompleto;
  final Function(DocumentoOF doc) setDocumento;
  const ListaArticoli(
      {super.key,
      required this.articoli,
      required this.visualizzaDatiOrdine,
      required this.controlloOrdineCompleto,
      required this.documento,
      required this.listaDocumenti,
      required this.setDocumento,
      required this.isOF});

  @override
  ListaArticoliState createState() => ListaArticoliState();
}

class ListaArticoliState extends State<ListaArticoli> {
  Http http = Http();
  bool isLoading = false;
  bool isShowing = false;

  refresh() {
    widget.controlloOrdineCompleto();
    setState(() {});
  }

  setDocumento(DocumentoOF doc) {
    widget.setDocumento(doc);
  }

  chiediConfermaResiduoSospeso(Articolo articolo, int index) {
    if (articolo.picking != null) {
      if (articolo.picking!.stato != "#") {
        if (articolo.colli != 0) {
          if (articolo.picking!.colli! < articolo.colli! ||
              articolo.picking!.colli! > articolo.colli!) {
            apriConfermaArticoloSospeso(articolo, index);
          }
        } else {
          if (articolo.picking!.quantita! < articolo.quantita! ||
              articolo.picking!.quantita! > articolo.quantita!) {
            apriConfermaArticoloSospeso(articolo, index);
          }
        }
      }
    } else {
      apriConfermaArticoloSospeso(articolo, index);
    }
  }

  apriConfermaArticoloSospeso(Articolo articolo, int index) {
    showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Attenzione'),
        content: const Text("Confermi quantità diversa dall'ordine?"),
        actions: [
          TextButton(
            child: const Text('No'),
            onPressed: () {
              Navigator.pop(c, false);
            },
          ),
          TextButton(
            child: const Text('Si'),
            onPressed: () {
              if (articolo.picking != null) {
                setPicking(articolo, articolo.picking!.colli!,
                    articolo.picking!.quantita!.toString(), "#", index);
              } else {
                setPicking(articolo, 0, "0", "#", index);
              }
              Navigator.pop(c, false);
            },
          ),
        ],
      ),
    );
    return true;
  }

  DocumentoOF? cercaDocumento(Articolo articolo) {
    DocumentoOF? d;
    for (var c = 0; c < widget.listaDocumenti!.length; c++) {
      var doc = widget.listaDocumenti![c];
      if (articolo.documento == "${doc.documento} ${doc.serie}/${doc.numero}") {
        d = doc;
      }
    }
    return d;
  }

  int? idDocumento(Articolo articolo) {
    for (var c = 0; c < widget.listaDocumenti.length; c++) {
      var doc = widget.listaDocumenti[c];
      if (articolo.documento == "${doc.documento} ${doc.serie}/${doc.numero}") {
        return c;
      }
    }
    return null;
  }

  setPicking(
      Articolo articolo, int colli, String? quantita, String stato, int index) {
    isLoading = true;
    setState(() {});

    Picking payload = Picking(
        documento:
            widget.documento?.documento ?? cercaDocumento(articolo)?.documento,
        serie: widget.documento?.serie ?? cercaDocumento(articolo)?.serie,
        numero: widget.documento?.numero ?? cercaDocumento(articolo)?.numero,
        rigo: articolo.rigo,
        prgTaglia: articolo.prgTaglia,
        colli: colli,
        quantita: articolo.colli == 0
            ? double.parse(quantita == "" ? "0" : quantita!)
            : articolo.quantita,
        idMagazzino: articolo.idMagazzino,
        idUbicazione: articolo.idUbicazione,
        stato: stato,
        idUtente: utente_selezionato!.nome.toString());

    http.setPickingOrdini(payload, context).then((value) {
      isLoading = false;

      if (value != null) {
        if (widget.documento != null) {
          widget.documento?.articoli?[index].picking = value;
        } else {
          widget.listaDocumenti[idDocumento(articolo)!].articoli?[index]
              .picking = value;
        }
        widget.controlloOrdineCompleto();
      } else {
        showErrorMessage(context, "Si è verificato un errore");
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.articoli?.length,
      itemBuilder: (context, index) {
        return cardArticolo(widget.articoli![index], index);
      },
    );
  }

  Widget cardArticolo(Articolo articolo, int index) {
    return Padding(
      padding: const EdgeInsets.only(top: 5, right: 5, left: 5),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(
                    context,
                    AnagraficaArticolo
                        .route, //PAGINA LISTA ARTICOLI DA DOCUMENTI
                    arguments: PassaggioDatiArticolo(
                        articolo: articolo,
                        modalita: widget.isOF ? "OF" : "OC",
                        documentoOF: widget.documento,
                        index: index,
                        controlloOrdineCompleto: widget.controlloOrdineCompleto,
                        listaDocumenti: widget.listaDocumenti,
                        setDocumento: setDocumento))
                .then((value) => refresh());
          },
          onLongPress: () {
            chiediConfermaResiduoSospeso(articolo, index);
          },
          child: ClipPath(
            clipper: ShapeBorderClipper(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                      color: controlloArticoloCompleto(articolo), width: 12),
                ),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.only(left: 6, top: 4, bottom: 4, right: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: dettaglioCard(articolo),
                    ),
                    /*Padding(
                      padding: const EdgeInsets.only(right: 10, left: 10),
                      child: modificaQuantita(articolo, index),
                    ),*/
                    Visibility(
                      visible: articolo.taglia != "",
                      child: Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("TG"),
                            const SizedBox(
                              height: 5,
                            ),
                            Text('${articolo.taglia}',
                                maxLines: 1,
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black))
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget dettaglioCard(Articolo articolo) {
    double qtaPrelevata = 0;
    double qtaRichiesta = 0;
    if (articolo.colli != 0) {
      qtaRichiesta = articolo.colli! * articolo.quantita!;
    } else {
      qtaRichiesta = articolo.quantita!;
    }
    if (articolo.picking != null) {
      if (articolo.colli != 0) {
        qtaPrelevata = (articolo.picking!.colli! * articolo.picking!.quantita!);
      } else {
        qtaPrelevata = articolo.picking!.quantita!;
      }
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '${articolo.descrizione}',
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        const SizedBox(
          height: 5,
        ),
        Row(
          children: [
            const Text(
              'Documento: ',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: Colors.black),
            ),
            Text(
              widget.documento == null
                  ? '${articolo.documento}'
                  : '${widget.documento?.documento} ${widget.documento?.serie}/${widget.documento?.numero}',
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
          ],
        ),
        const SizedBox(
          height: 5,
        ),
        Row(
          children: [
            const Text(
              'Codice: ',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: Colors.black),
            ),
            Text(
              '${articolo.codiceArticolo}',
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            )
          ],
        ),
        const SizedBox(
          height: 5,
        ),
        Row(
          children: [
            const Text(
              'Ubicazione: ',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: Colors.black),
            ),
            Text(
              '${articolo.ubicazione}',
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            )
          ],
        ),
        const SizedBox(
          height: 5,
        ),
        Text(
          articolo.colli != 0
              ? '${articolo.um.toString().toUpperCase()} ${articolo.colli} * ${formatStringDecimal(articolo.quantita, articolo.decimali!)} (${formatStringDecimal(qtaRichiesta, articolo.decimali!)})'
              : '${articolo.um.toString().toUpperCase()} ${formatStringDecimal(articolo.quantita, articolo.decimali!)}',
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        const SizedBox(
          height: 5,
        ),
        Visibility(
          visible: articolo.picking != null,
          child: Text(
            articolo.colli != 0
                ? "${articolo.um.toString().toUpperCase()} ${articolo.picking?.colli} * ${formatStringDecimal(articolo.picking?.quantita, articolo.decimali!)} (${formatStringDecimal(qtaPrelevata, articolo.decimali!)})"
                : '${articolo.um.toString().toUpperCase()} ${formatStringDecimal(articolo.picking?.quantita, articolo.decimali!)}',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: controlloArticoloCompleto(articolo)),
          ),
        ),
      ],
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
}
