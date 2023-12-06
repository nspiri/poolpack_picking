// ignore_for_file: file_names

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:poolpack_picking/Model/magazzino.dart';
import 'package:poolpack_picking/pages/articolo/anagrafica_articolo.dart';
import 'package:poolpack_picking/pages/ordini/componenti/indicatore_ordine.dart';
import 'package:poolpack_picking/utils/global.dart';
import 'package:poolpack_picking/utils/http.dart';
import 'package:poolpack_picking/Model/ordini_fornitori.dart';
import 'package:poolpack_picking/utils/utils.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

class ListaArticoli extends StatefulWidget {
  final List<Articolo>? articoli;
  final bool visualizzaDatiOrdine;
  final DocumentoOF? documento;
  final List<DocumentoOF> listaDocumenti;
  final bool isOF;
  final Function() controlloOrdineCompleto;
  final Function(DocumentoOF doc) setDocumento;
  final Function(bool val) setLoading;
  final Function() aggiornaLista;
  final bool? isUbicazione;
  const ListaArticoli(
      {super.key,
      required this.articoli,
      required this.visualizzaDatiOrdine,
      required this.controlloOrdineCompleto,
      required this.documento,
      required this.listaDocumenti,
      required this.setDocumento,
      required this.isOF,
      required this.setLoading,
      required this.isUbicazione,
      required this.aggiornaLista});

  @override
  ListaArticoliState createState() => ListaArticoliState();
}

class ListaArticoliState extends State<ListaArticoli> {
  Http http = Http();
  bool isLoading = false;
  bool isShowing = false;
  TextEditingController codiceArticolo = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final _scrollController = ScrollController();
  List<Articolo> articoliFiltrati = [];
  String coloreFiltro = "";
  late StreamSubscription<bool> keyboardSubscription;
  bool chiusa = false;

  @override
  void initState() {
    super.initState();
    var keyboardVisibilityController = KeyboardVisibilityController();
    keyboardSubscription =
        keyboardVisibilityController.onChange.listen((bool visible) {
      if (!chiusa) {
        chiusa = true;
        SystemChannels.textInput.invokeMethod('TextInput.hide');
      }
      setState(() {});
    });
  }

  refresh() {
    chiusa = false;
    if (!widget.isOF) {
      widget.controlloOrdineCompleto();
    }
    setState(() {});
  }

  setDocumento(DocumentoOF doc) {
    widget.setDocumento(doc);
  }

  setColoreFiltro(String colore) {
    if (coloreFiltro == colore) {
      coloreFiltro = "";
    } else {
      coloreFiltro = colore;
    }
    setState(() {});
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
    chiusa = false;
    setState(() {});
    SystemChannels.textInput.invokeMethod('TextInput.hide');
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

  chiudiTastiera() {
    chiusa = false;
    setState(() {});
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  DocumentoOF? cercaDocumento(Articolo articolo) {
    DocumentoOF? d;
    for (var c = 0; c < widget.listaDocumenti.length; c++) {
      var doc = widget.listaDocumenti[c];
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
          widget.articoli![index].picking = value;
          /*widget.listaDocumenti[idDocumento(articolo)!].articoli?[index]
              .picking = value;*/
        }
        if (!widget.isOF) {
          widget.controlloOrdineCompleto();
        }
      } else {
        showErrorMessage(context, "Si è verificato un errore");
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Visibility(
          visible: widget.isOF,
          child: Padding(
            padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
            child: TextField(
              focusNode: _focusNode,
              autofocus: true,
              controller: codiceArticolo,
              onTap: () => codiceArticolo.selection = TextSelection(
                  baseOffset: 0,
                  extentOffset: codiceArticolo.value.text.length),
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black,
              ),
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), labelText: "Codice"),
              onSubmitted: (value) {
                widget.setLoading(true);
                http.getArticoliArt(codiceArticolo.text, 0).then((value) {
                  widget.setLoading(false);
                  var trovato = false;
                  if (value.isNotEmpty) {
                    for (var element in widget.articoli!) {
                      var c = widget.articoli!.indexOf(element);
                      if (element.codiceArticolo == value[0].codiceArticolo &&
                          (element.prgTaglia == value[0].prgTaglia ||
                              value.length > 1)) {
                        if (value.length > 1) {
                          int cont = 0;
                          for (var i = 0; i < widget.articoli!.length; i++) {
                            if (widget.articoli![i].codiceArticolo ==
                                value[0].codiceArticolo) {
                              cont++;
                            }
                          }
                          if (cont > 1) {
                            _scrollController.animateTo(
                                double.parse((200 * c).toString()),
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeIn);
                            showSuccessMessage(
                                context, "Seleziona l'articolo dalla lista");
                            trovato = true;
                            break;
                          } else {
                            if (!trovato) {
                              trovato = true;
                              Navigator.pushNamed(
                                      context,
                                      AnagraficaArticolo
                                          .route, //PAGINA LISTA ARTICOLI DA DOCUMENTI
                                      arguments: PassaggioDatiArticolo(
                                          articolo: widget.articoli![c],
                                          modalita: widget.isOF ? "OF" : "OC",
                                          documentoOF: widget.documento,
                                          index: 0,
                                          controlloOrdineCompleto:
                                              widget.controlloOrdineCompleto,
                                          listaDocumenti: widget.listaDocumenti,
                                          setDocumento: setDocumento,
                                          listaArticoli: widget.isOF
                                              ? widget.documento!.articoli!
                                              : widget.articoli!,
                                          articoloPicking: value[0],
                                          isUbicazione: false,
                                          aggiornaDocumenti:
                                              widget.aggiornaLista))
                                  .then((value) => refresh());
                            }
                          }
                        } else {
                          int cont = 0;
                          for (var i = 0; i < widget.articoli!.length; i++) {
                            if (widget.articoli![i].codiceArticolo ==
                                    value[0].codiceArticolo &&
                                widget.articoli![i].prgTaglia ==
                                    value[0].prgTaglia) {
                              if (value[0].alias != null &&
                                  value[0].alias?.quantita != 0) {
                                if (value[0].alias!.quantita ==
                                    widget.articoli![i].confezione) {
                                  cont++;
                                }
                              } else {
                                cont++;
                              }
                            }
                          }
                          if (cont > 1) {
                            _scrollController.animateTo(
                                double.parse((200 * c).toString()),
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeIn);
                            showSuccessMessage(
                                context, "Seleziona l'articolo dalla lista");
                            trovato = true;
                            break;
                          } else {
                            if (!trovato) {
                              if (value[0].alias != null &&
                                  value[0].alias?.quantita != 0) {
                                if (value[0].alias!.quantita ==
                                    widget.articoli![c].confezione) {
                                  trovato = true;
                                  Navigator.pushNamed(
                                          context,
                                          AnagraficaArticolo
                                              .route, //PAGINA LISTA ARTICOLI DA DOCUMENTI
                                          arguments: PassaggioDatiArticolo(
                                              articolo: widget.articoli![c],
                                              modalita:
                                                  widget.isOF ? "OF" : "OC",
                                              documentoOF: widget.documento,
                                              index: 0,
                                              controlloOrdineCompleto: widget
                                                  .controlloOrdineCompleto,
                                              listaDocumenti:
                                                  widget.listaDocumenti,
                                              setDocumento: setDocumento,
                                              listaArticoli: widget.isOF
                                                  ? widget.documento!.articoli!
                                                  : widget.articoli!,
                                              articoloPicking: value[0],
                                              isUbicazione: false,
                                              aggiornaDocumenti:
                                                  widget.aggiornaLista))
                                      .then((value) => refresh());
                                }
                              } else {
                                trovato = true;
                                Navigator.pushNamed(
                                        context,
                                        AnagraficaArticolo
                                            .route, //PAGINA LISTA ARTICOLI DA DOCUMENTI
                                        arguments: PassaggioDatiArticolo(
                                            articolo: widget.articoli![c],
                                            modalita: widget.isOF ? "OF" : "OC",
                                            documentoOF: widget.documento,
                                            index: 0,
                                            controlloOrdineCompleto:
                                                widget.controlloOrdineCompleto,
                                            listaDocumenti:
                                                widget.listaDocumenti,
                                            setDocumento: setDocumento,
                                            listaArticoli: widget.isOF
                                                ? widget.documento!.articoli!
                                                : widget.articoli!,
                                            articoloPicking: value[0],
                                            isUbicazione: false,
                                            aggiornaDocumenti:
                                                widget.aggiornaLista))
                                    .then((value) => refresh());
                              }
                            }
                          }
                        }
                      }
                    }
                    /*if (controlloOrdineCompleto(widget.documento!)) {
                      showSuccessMessage(context, "Documento completato");
                    }*/
                    if (!trovato) {
                      showErrorMessage(
                          context, "Articolo non presente in lista");
                    }
                  } else {
                    showErrorMessage(context, "Codice articolo non trovato");
                  }
                  chiudiTastiera();
                  codiceArticolo.text = "";
                  setState(() {});
                });
              },
              onEditingComplete: () {},
            ),
          ),
        ),
        Indicatore(
          articoli: widget.articoli ?? [],
          setColoreFiltro: setColoreFiltro,
        ),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            itemCount: widget.articoli?.length,
            itemBuilder: (context, index) {
              //coloreFiltro = "";
              print(coloreFiltro);
              if (coloreFiltro == "") {
                return cardArticolo(widget.articoli![index], index);
              }
              if (coloreFiltro == "GR") {
                if (widget.articoli?[index].picking == null) {
                  return cardArticolo(widget.articoli![index], index);
                }
              }
              if (coloreFiltro == "R") {
                if (widget.articoli?[index].picking?.stato == "<" ||
                    widget.articoli?[index].picking?.stato == ">") {
                  return cardArticolo(widget.articoli![index], index);
                }
              }
              if (coloreFiltro == "GI") {
                if (widget.articoli?[index].picking?.stato == "#") {
                  return cardArticolo(widget.articoli![index], index);
                }
              }
              if (coloreFiltro == "V") {
                if (widget.articoli?[index].picking?.stato == "=") {
                  return cardArticolo(widget.articoli![index], index);
                }
              }
              return SizedBox();
            },
          ),
        ),
      ],
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
                        setDocumento: setDocumento,
                        listaArticoli: widget.isOF
                            ? widget.documento!.articoli!
                            : widget.articoli!,
                        articoloPicking: null,
                        isUbicazione: widget.isUbicazione,
                        aggiornaDocumenti: widget.aggiornaLista))
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
