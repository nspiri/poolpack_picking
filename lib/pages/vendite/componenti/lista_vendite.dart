// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:poolpack_picking/Model/ordini_fornitori.dart';
import 'package:poolpack_picking/pages/login.dart';
import 'package:poolpack_picking/pages/ordini/lista_ART.dart';
import 'package:poolpack_picking/utils/utils.dart';

class ListaVendite extends StatefulWidget {
  final List<DocumentoOF> documenti;
  final Function() getDocumenti;
  final Function(bool value) setLoading;
  const ListaVendite({
    super.key,
    required this.documenti,
    required this.getDocumenti,
    required this.setLoading,
  });

  @override
  ListaVenditeState createState() => ListaVenditeState();
}

class ListaVenditeState extends State<ListaVendite> {
  refresh() {
    setState(() {});
  }

  controlloOrdineCompleto(DocumentoOF ordine) {
    int numeroArticoliCompleti = 0;
    int numeroArticoliDaPrelevare = 0;
    int numeroArticoliQtaErrata = 0;

    var rosso = Colors.red;
    var grigio = Colors.grey;
    var verde = Colors.green;
    var giallo = Colors.yellow[700];

    DocumentoOF ord = trovaOrdineCompleto(ordine);

    if (ord.articoli != null) {
      for (int c = 0; c < ord.articoli!.length; c++) {
        Articolo art = ord.articoli![c];
        if (art.picking != null) {
          if (art.picking!.stato != " ") {
            if (art.picking!.stato == "<" || art.picking!.stato == ">") {
              numeroArticoliQtaErrata += 1;
            } else {
              numeroArticoliCompleti += 1;
            }
          } else {
            numeroArticoliDaPrelevare += 1;
          }
        } else {
          numeroArticoliDaPrelevare += 1;
        }
      }

      if (numeroArticoliDaPrelevare > 0) {
        if (numeroArticoliQtaErrata > 0) {
          return rosso;
        } else {
          if (numeroArticoliDaPrelevare < ord.articoli!.length) {
            return giallo;
          } else {
            return grigio;
          }
        }
      }
      if (numeroArticoliQtaErrata > 0) {
        return rosso;
      }
      if (numeroArticoliCompleti == ord.articoli?.length) {
        return verde;
      } else {
        return giallo;
      }
    } else {
      return grigio;
    }

    //return true;
  }

  trovaOrdineCompleto(DocumentoOF ord) {
    for (var c = 0; c < widget.documenti.length; c++) {
      if (ord.serie == widget.documenti[c].serie &&
          ord.numero == widget.documenti[c].numero) {
        return widget.documenti[c];
      }
    }
    return {};
  }

  evadiOrdine(DocumentoOF documento) {
    List<EvadiDocumento> dati = [];
    EvadiDocumento doc = EvadiDocumento(
      dataTras: DateFormat("yyyyMMdd").format(DateTime.now()),
      documento: "OC",
      documentoTras: "",
      serie: documento.serie,
      numero: documento.numero,
      numeroTras: 0,
    );
    dati.add(doc);

    widget.setLoading(true);
    setState(() {});
    http.evadiDocumenti(dati, context).then((value) {
      widget.setLoading(false);
      if (value) {
        showSuccessMessage(context, "Ordini cliente evasi");
      }
      widget.getDocumenti();
    });
  }

  controlloOrdineCompletoa(DocumentoOF documento) {
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

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.documenti.length,
      itemBuilder: (context, index) {
        return cardOrdine(widget.documenti[index], context);
      },
    );
  }

  String formatDate(String input) {
    DateTime date = DateTime.parse(input);
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  Widget cardOrdine(DocumentoOF documento, context) {
    return Padding(
        padding: const EdgeInsets.only(top: 5, left: 5, right: 5),
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: InkWell(
            onLongPress: () {
              if (controlloOrdineCompletoa(documento)) {
                //TODO chiedi evasione
              }
            },
            onTap: () {
              Navigator.pushNamed(
                      context,
                      PaginaListaArticoli
                          .route, //PAGINA LISTA ARTICOLI DA DOCUMENTI
                      arguments: PassaggioDatiOrdini(
                          ordine: documento,
                          ordini: widget.documenti,
                          isOF: false,
                          aggiornaDocumenti: widget.getDocumenti))
                  .then((value) => refresh());
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
                        color: controlloOrdineCompleto(documento), width: 12),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 12, top: 8, bottom: 8, right: 12),
                  child: dettaglioCard(documento),
                ),
              ),
            ),
          ),
        ));
  }

  Widget dettaglioCard(DocumentoOF? ordine) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '${ordine?.intestatario}',
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        const SizedBox(
          height: 5,
        ),
        Text(
          'Documento: ${ordine?.documento} ${ordine?.serie}/${ordine?.numero}',
          style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.normal, color: Colors.black),
        ),
        Visibility(
          visible: ordine?.data == "" ? false : true,
          child: const SizedBox(
            height: 5,
          ),
        ),
        Visibility(
          visible: ordine?.data == "" ? false : true,
          child: Text(
            'Data: ${formatDate(ordine!.data!)}',
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: Colors.black),
          ),
        ),
        Visibility(
          visible: ordine.scadenza == "" ? false : true,
          child: const SizedBox(
            height: 5,
          ),
        ),
        /* Visibility(
          visible: ordine.scadenza == "" ? false : true,
          child: Text(
            'Consegna: ${formatDate(ordine.scadenza!)}',
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: Colors.black),
          ),
        ),*/
      ],
    );
  }
}
