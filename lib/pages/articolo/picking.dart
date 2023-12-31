import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:poolpack_picking/Model/magazzino.dart';
import 'package:poolpack_picking/Model/ordini_fornitori.dart';
import 'package:poolpack_picking/utils/global.dart';
import 'package:poolpack_picking/utils/http.dart';
import 'package:poolpack_picking/utils/utils.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

class PickingPage extends StatefulWidget {
  final Articolo articolo;
  final int index;
  final DocumentoOF? documento;
  final List<DocumentoOF> listaDocumenti;
  final List<Articolo> listaArticoli;
  final bool isOF;
  final Articolo? articoloPicking;
  final Function() controlloOrdineCompleto;
  final Function(int index) cambiaArticolo;
  final Function(DocumentoOF documento) tornaIndietro;
  final Function() setScrollDown;
  final bool? isUbicazione;
  const PickingPage(
      {super.key,
      required this.articolo,
      required this.documento,
      required this.index,
      required this.controlloOrdineCompleto,
      required this.cambiaArticolo,
      required this.listaDocumenti,
      required this.tornaIndietro,
      required this.isOF,
      required this.setScrollDown,
      required this.listaArticoli,
      required this.articoloPicking,
      required this.isUbicazione});

  @override
  PickingPageState createState() => PickingPageState();
}

class PickingPageState extends State<PickingPage> {
  late Articolo articolo;
  late DocumentoOF? documento;
  late String modalita;
  bool isLoading = false;
  Http http = Http();
  TextEditingController codiceArticolo = TextEditingController();
  TextEditingController colli = TextEditingController();
  TextEditingController qta = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Articolo? articoloRicerca;
  bool isEnabled = false;
  bool isQtaEnabled = false;
  TextInputType tastiera = TextInputType.none;
  late StreamSubscription<bool> keyboardSubscription;
  bool chiusa = false;

  @override
  void initState() {
    super.initState();
    articolo = widget.articolo;
    documento = widget.documento;
    colli.text = "0";
    setCampi();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.articoloPicking != null) {
        controlloArticolo(widget.articoloPicking);
      } else {
        if (widget.isOF) {
          controlloArticolo(widget.articolo);
        }
      }
    });

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
    setState(() {});
  }

  setArticolo(int i) {
    codiceArticolo.text = "";
    //articolo = documento!.articoli![i];
    articolo = widget.listaArticoli[i];
    widget.cambiaArticolo(i);
    isEnabled = false;
    isQtaEnabled = false;
    setCampiCambio(articolo);
    _focusNode.requestFocus();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    chiusa = false;
    setState(() {});
  }

  setCampiCambio(Articolo articolo) {
    this.articolo = articolo;
    if (articolo.colli != 0) {
      if (articolo.picking != null) {
        colli.text = articolo.picking!.colli.toString();
        qta.text = formatStringDecimal(
            articolo.picking!.quantita!, articolo.decimali!);
      } else {
        colli.text = articolo.colli.toString();
        qta.text = formatStringDecimal(
            articolo.colli! * articolo.quantita!, articolo.decimali!);
      }
    } else {
      isQtaEnabled = true;
      if (articolo.picking != null) {
        qta.text = formatStringDecimal(
            articolo.picking!.quantita!, articolo.decimali!);
      } else {
        qta.text = formatStringDecimal(0, articolo.decimali!);
      }
    }
  }

  setCampi() {
    if (articolo.colli != 0) {
      if (articolo.picking != null) {
        colli.text = articolo.picking!.colli.toString();
        qta.text = formatStringDecimal(
            articolo.picking!.quantita!, articolo.decimali!);
      } else {
        colli.text = articolo.colli.toString();
        qta.text = formatStringDecimal(
            articolo.colli! * articolo.quantita!, articolo.decimali!);
      }
    } else {
      isQtaEnabled = true;
      if (articolo.picking != null) {
        qta.text = formatStringDecimal(
            articolo.picking!.quantita!, articolo.decimali!);
      } else {
        qta.text = formatStringDecimal(articolo.quantita!, articolo.decimali!);
      }
    }
    _focusNode.requestFocus();
    chiusa = false;
    setState(() {});
  }

  confermaQuantita(String stato) {
    salvaPicking(stato);
  }

  salvaPicking(String stato) {
    isLoading = true;
    setState(() {});
    Picking data = Picking(
        documento: documento?.documento,
        serie: documento?.serie,
        numero: documento?.numero,
        rigo: articolo.rigo,
        prgTaglia: articolo.prgTaglia,
        codiceArticolo: articolo.codiceArticolo,
        colli: int.parse(colli.text),
        quantita:
            articolo.colli == 0 ? double.parse(qta.text) : articolo.quantita,
        idMagazzino: articolo.idMagazzino,
        idUbicazione: articolo.idUbicazione,
        stato: stato,
        idUtente: utente_selezionato!.nome.toString());

    http.setPickingOrdini(data, context).then((value) {
      isLoading = false;
      setState(() {});
      if (value != null) {
        articolo.picking = value;
        setState(() {});
        if (!widget.isOF) {
          if (widget.isUbicazione != null) {
            if (widget.isUbicazione!) {
              if (controlloOrdiniCompletatia(widget.listaDocumenti)) {
                apriDialogOrdiniCompletati(context);
              } else {
                int index = articoloSuccessivo(
                    widget.index, widget.listaArticoli, articolo);
                setArticolo(index);
              }
            } else {
              if (controlloOrdineCompleto(documento!)) {
                if (!controlloOrdiniCompletati(widget.listaDocumenti)) {
                  if (!widget.isOF) {
                    apriDialogConfermaOrdineCompletato(
                      context,
                      widget.listaDocumenti,
                      widget.documento!,
                      () => Navigator.pop(context),
                    );
                  }
                } else {
                  apriDialogOrdiniCompletati(context);
                }
              } else {
                if (articolo.picking != null) {
                  var completo = true;
                  if (documento != null) {
                    if (documento!.articoli != null) {
                      for (int c = 0; c < documento!.articoli!.length; c++) {
                        if (documento?.articoli?[c].picking == null) {
                          completo = false;
                        }
                      }
                    }
                  }
                  if (documento!.articoli!.length > 1) {
                    int index = articoloSuccessivo(
                        widget.index, widget.listaArticoli, articolo);
                    setArticolo(index);
                    /* apriDialogConferma(context, documento!, widget.index,
                        articolo, setArticolo, widget.listaArticoli);
                    _focusNode.unfocus();*/
                  }
                }
              }
            }
          } else {
            if (controlloOrdineCompleto(documento!)) {
              if (!controlloOrdiniCompletati(widget.listaDocumenti)) {
                if (!widget.isOF) {
                  apriDialogConfermaOrdineCompletato(
                      context,
                      widget.listaDocumenti,
                      widget.documento!,
                      /*widget.tornaIndietro*/ () => Navigator.pop(context));
                }
              } else {
                apriDialogOrdiniCompletati(context);
              }
            } else {
              if (articolo.picking != null) {
                var completo = true;
                if (documento != null) {
                  if (documento!.articoli != null) {
                    for (int c = 0; c < documento!.articoli!.length; c++) {
                      if (documento?.articoli?[c].picking == null) {
                        completo = false;
                      }
                    }
                  }
                }
                if (documento!.articoli!.length > 1) {
                  int index = articoloSuccessivo(
                      widget.index, widget.listaArticoli, articolo);
                  setArticolo(index);
                  /*apriDialogConferma(context, documento!, widget.index,
                      articolo, setArticolo, widget.listaArticoli);
                  _focusNode.unfocus();*/
                }
              }
            }
          }
        } else {
          setArticolo(widget.index);
          _focusNode.unfocus();
          if (controlloOrdineCompleto(documento!)) {
            apriDialogConfermaOrdineCompletatoOF(
                context, () => Navigator.pop(context));
          } else {
            Navigator.pop(context);
          }
        }
      } else {
        showErrorMessage(context, "Si è verificato un errore");
      }
    });
  }

  validaArticolo() {
    isEnabled = true;
    widget.setScrollDown();
    if (articolo.colli == 0) {
      if (articolo.picking != null) {
        qta.text = formatStringDecimal(
            articolo.picking!.quantita!, articolo.decimali!);
      } else {
        qta.text = formatStringDecimal(articolo.quantita!, articolo.decimali!);
      }

      isQtaEnabled = true;
    } else {
      if (articolo.picking != null) {
        colli.text = articolo.picking!.colli.toString();
      } else {
        colli.text = articolo.colli.toString();
      }
    }
    _focusNode.unfocus();
    chiusa = false;
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    setState(() {});
  }

  controlloArticolo(Articolo? art) {
    bool isValid = true;
    do {
      if (art == null) {
        showErrorMessage(context, "Articolo non trovato");
        chiusa = false;
        _focusNode.requestFocus();
        setState(() {});
        SystemChannels.textInput.invokeMethod('TextInput.hide');
        isValid = false;
        break;
      }
      if (articolo.codiceArticolo != art.codiceArticolo) {
        showErrorMessage(context, "Articolo errato");
        chiusa = false;
        _focusNode.requestFocus();
        setState(() {});
        SystemChannels.textInput.invokeMethod('TextInput.hide');
        isValid = false;
        break;
      }
      if (art.alias != null) {
        if (articolo.colli != 0) {
          if (widget.isOF) {
            if (art.alias!.quantita! > 0) {
              if (articolo.quantita != art.alias!.quantita) {
                showErrorMessage(context, "Quantità non corrispondente");
                chiusa = false;
                _focusNode.requestFocus();
                setState(() {});
                SystemChannels.textInput.invokeMethod('TextInput.hide');
                isValid = false;
                break;
              }
            }
          }
        }
        if (articolo.prgTaglia != 0) {
          if (articolo.prgTaglia != art.prgTaglia) {
            showErrorMessage(context, "Taglia non corrispondente");
            chiusa = false;
            _focusNode.requestFocus();
            setState(() {});
            SystemChannels.textInput.invokeMethod('TextInput.hide');
            isValid = false;
            break;
          }
        }
      }
    } while (false);

    if (isValid) {
      isEnabled = true;
      widget.setScrollDown();
      if (articolo.colli == 0) {
        if (articolo.picking != null) {
          qta.text = formatStringDecimal(
              articolo.picking!.quantita!, articolo.decimali!);
        } else {
          qta.text =
              formatStringDecimal(articolo.quantita!, articolo.decimali!);
        }

        isQtaEnabled = true;
      } else {
        if (articolo.picking != null) {
          colli.text = articolo.picking!.colli.toString();
        } else {
          colli.text = articolo.colli.toString();
        }
      }
    } else {
      isEnabled = false;
      codiceArticolo.text = "";
      articoloRicerca = null;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    articolo = widget.articolo;
    documento = widget.documento;
    return picking();
  }

  Widget picking() {
    double quantitaMoltiplicata;
    double quantitaPicking;
    Color colore;

    if (articolo.picking != null) {
      if (articolo.colli != 0) {
        quantitaMoltiplicata = articolo.colli == 0 && articolo.prgTaglia == 0
            ? articolo.quantita!
            : articolo.quantita! * articolo.colli!;
        quantitaPicking = articolo.colli == 0 && articolo.prgTaglia == 0
            ? double.parse(qta.text == "" ? "0" : qta.text)
            : /*double.parse(qta.text)*/ articolo.quantita! *
                double.parse(colli.text == "" ? "0" : colli.text);
        qta.text = formatStringDecimal(quantitaPicking, articolo.decimali!);
        if (quantitaPicking > (articolo.quantita! * articolo.colli!) ||
            quantitaPicking < (articolo.quantita! * articolo.colli!)) {
          colore = Colors.red;
        } else {
          colore = Colors.green;
        }
      } else {
        quantitaMoltiplicata = articolo.quantita!;
        quantitaPicking = double.parse(qta.text == "" ? "0" : qta.text);
        if (quantitaPicking > quantitaMoltiplicata ||
            quantitaPicking < quantitaMoltiplicata) {
          colore = Colors.red;
        } else {
          colore = Colors.green;
        }
      }
      setState(() {});
    } else {
      if (isEnabled) {
        if (articolo.colli != 0) {
          quantitaMoltiplicata = articolo.colli == 0 && articolo.prgTaglia == 0
              ? articolo.quantita!
              : articolo.quantita! * articolo.colli!;
          quantitaPicking = articolo.colli == 0 && articolo.prgTaglia == 0
              ? double.parse(qta.text == "" ? "0" : qta.text)
              : /*double.parse(qta.text)*/ articolo.quantita! *
                  double.parse(colli.text == "" ? "0" : colli.text);
          qta.text = formatStringDecimal(quantitaPicking, articolo.decimali!);
          if (quantitaPicking > (articolo.quantita! * articolo.colli!) ||
              quantitaPicking < (articolo.quantita! * articolo.colli!)) {
            colore = Colors.red;
          } else {
            colore = Colors.green;
          }
        } else {
          quantitaMoltiplicata = articolo.quantita!;
          quantitaPicking = double.parse(qta.text == "" ? "0" : qta.text);
          if (quantitaPicking > quantitaMoltiplicata ||
              quantitaPicking < quantitaMoltiplicata) {
            colore = Colors.red;
          } else {
            colore = Colors.green;
          }
        }
        setState(() {});
      } else {
        if (articolo.colli != 0) {
          quantitaMoltiplicata = articolo.colli == 0 && articolo.prgTaglia == 0
              ? articolo.quantita!
              : articolo.quantita! * articolo.colli!;
          quantitaPicking = 0;
          qta.text = formatStringDecimal(quantitaPicking, articolo.decimali!);
          if (quantitaPicking > (articolo.quantita! * articolo.colli!) ||
              quantitaPicking < (articolo.quantita! * articolo.colli!)) {
            colore = Colors.red;
          } else {
            colore = Colors.green;
          }
        } else {
          quantitaMoltiplicata = articolo.quantita!;
          quantitaPicking = 0;
          qta.text = formatStringDecimal(quantitaPicking, articolo.decimali!);
          if (quantitaPicking > quantitaMoltiplicata ||
              quantitaPicking < quantitaMoltiplicata) {
            colore = Colors.red;
          } else {
            colore = Colors.green;
          }
        }
        colli.text = "0";
      }
    }

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side:
              BorderSide(color: controlloArticoloCompleto(articolo), width: 2)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ExpansionTile(
                  initiallyExpanded: true,
                  leading: Icon(
                    Icons.warehouse,
                    color: controlloArticoloCompleto(articolo),
                    size: 40,
                  ),
                  title: const Text(
                    'Picking',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  childrenPadding: const EdgeInsets.only(bottom: 8),
                  expandedCrossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Visibility(
                      //visible: widget.articoloPicking == null,
                      child: Padding(
                        padding:
                            const EdgeInsets.only(top: 8, left: 8, right: 8),
                        child: TextField(
                          focusNode: _focusNode,
                          autofocus: true,
                          controller: codiceArticolo,
                          onTap: () => codiceArticolo.selection = TextSelection(
                              baseOffset: 0,
                              extentOffset: codiceArticolo.value.text.length),
                          /* onTap: () {
                            tastiera = TextInputType.text;
                            _focusNode.requestFocus();
                            setState(() {});
                          },*/
                          //keyboardType: tastiera,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Codice"),
                          onSubmitted: (v) {
                            isLoading = true;
                            setState(() {});
                            http
                                .getArticoliArt(codiceArticolo.text, 0)
                                .then((value) {
                              isLoading = false;
                              if (value.isNotEmpty) {
                                for (var element in value) {
                                  if (element.codiceArticolo ==
                                      articolo.codiceArticolo) {
                                    articoloRicerca = element;
                                    break;
                                  }
                                }
                              } else {
                                articoloRicerca = null;
                              }
                              controlloArticolo(articoloRicerca);
                              setState(() {});
                            });
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 16, left: 8, right: 8),
                      child: Column(
                        children: [
                          Visibility(
                            visible:
                                articolo.taglia == "" && articolo.colli != 0,
                            child: Column(
                              //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                    padding: const EdgeInsets.only(right: 4),
                                    child: componenteColli()),
                                Visibility(
                                  visible: qta != 0,
                                  child: Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        "${articolo.colli}/${colli.text} CL [${formatStringDecimal(articolo.quantita, articolo.decimali!)}]",
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: colore,
                                            fontWeight: FontWeight.bold),
                                      )),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Column(
                              //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                    padding: const EdgeInsets.only(right: 4),
                                    child: componenteQta()),
                                Visibility(
                                  visible: qta != 0,
                                  child: Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        "${formatStringDecimal(quantitaMoltiplicata, articolo.decimali!)}/${formatStringDecimal(quantitaPicking, articolo.decimali!)} ${articolo.um!.toUpperCase()}",
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: colore,
                                            fontWeight: FontWeight.bold),
                                      )),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    button("Salva", () {
                      if (!widget.isOF) {
                        if (quantitaPicking <= articolo.esistenzaUbicazione!) {
                          salvaPicking("");
                        } else {
                          showErrorMessage(context,
                              "L'esistenza non è sufficente a soddisfare la richiesta del documento");
                          if (articolo.colli != 0) {
                            quantitaPicking = articolo.esistenzaUbicazione!;
                            qta.text = formatStringDecimal(
                                quantitaPicking, articolo.decimali!);
                            colli.text = (quantitaPicking / articolo.quantita!)
                                .toStringAsFixed(0);
                          } else {
                            quantitaPicking = articolo.esistenzaUbicazione!;
                            qta.text = formatStringDecimal(
                                quantitaPicking, articolo.decimali!);
                          }
                        }
                      } else {
                        salvaPicking("");
                      }
                      setState(() {});
                    })
                  ],
                ),
              ],
            ),
            Positioned(
              top: 0,
              bottom: 0,
              left: 0,
              right: 0,
              child: loading(),
            )
          ],
        ),
      ),
    );
  }

  Widget componenteColli() {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(10))),
      child: Row(
        children: [
          btnMeno(articolo, int.parse(colli.text == "" ? "0" : colli.text)),
          Expanded(
            child: TextField(
              controller: colli,
              style: const TextStyle(color: Colors.black, fontSize: 20),
              enabled: isEnabled,
              onChanged: (value) {
                if (!widget.isOF) {
                  if (articolo.colli != 0) {
                    if (!(double.parse(value) * articolo.quantita! <=
                        articolo.colli! * articolo.quantita!)) {
                      colli.text = articolo.colli.toString();
                      qta.text = formatStringDecimal(
                          articolo.colli! * articolo.quantita!,
                          articolo.decimali!);
                    }
                  } else {
                    if (!(double.parse(value) <= articolo.quantita!)) {
                      qta.text = formatStringDecimal(
                          articolo.quantita!, articolo.decimali!);
                    }
                  }
                }
                setState(() {});
              },
              onTap: () => colli.selection = TextSelection(
                  baseOffset: 0, extentOffset: colli.value.text.length),
              textAlign: TextAlign.center,
              decoration: const InputDecoration.collapsed(hintText: ''),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
            ),
          ),
          btnPiu(articolo, int.parse(colli.text == "" ? "0" : colli.text)),
        ],
      ),
    );
  }

  Widget componenteQta() {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(10))),
      child: Row(
        children: [
          isQtaEnabled
              ? btnMenoQta(
                  articolo, double.parse(qta.text == "" ? "0" : qta.text))
              : btnMeno(
                  articolo, int.parse(colli.text == "" ? "0" : colli.text)),
          Expanded(
            child: TextField(
              controller: qta,
              style: const TextStyle(color: Colors.black, fontSize: 20),
              enabled: isQtaEnabled && isEnabled,
              onChanged: (value) {
                if (value.endsWith(",")) {
                  value =
                      value.replaceRange(value.length - 1, value.length, ".");
                  qta.text = value;
                }
                if (!widget.isOF) {
                  if (!value.endsWith(".")) {
                    if (articolo.colli == 0) {
                      if (!(double.parse(value) <= articolo.quantita!)) {
                        qta.text = formatStringDecimal(
                            articolo.quantita!, articolo.decimali!);
                      }
                    }
                  }
                }
                setState(() {});
              },
              onTap: () => qta.selection = TextSelection(
                  baseOffset: 0, extentOffset: qta.value.text.length),
              textAlign: TextAlign.center,
              decoration: const InputDecoration.collapsed(hintText: ''),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: <TextInputFormatter>[
                DecimalTextInputFormatter(
                    decimalRange:
                        articolo.decimali! == 0 ? 2 : articolo.decimali!)
              ],
            ),
          ),
          isQtaEnabled
              ? btnPiuQta(
                  articolo, double.parse(qta.text == "" ? "0" : qta.text))
              : btnPiu(
                  articolo, int.parse(colli.text == "" ? "0" : colli.text)),
        ],
      ),
    );
  }

  Widget btnMeno(Articolo articolo, int colli) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(9), bottomLeft: Radius.circular(9)),
      ),
      child: IconButton(
          onPressed: () {
            if (isEnabled) {
              if (colli > 0) {
                colli = colli - 1;
                this.colli.text = "$colli";
                setState(() {});
              }
            }
          },
          icon: const Icon(
            Icons.remove,
            size: 26,
            color: Colors.black,
          )),
    );
  }

  Widget btnMenoQta(Articolo articolo, double quantita) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(9), bottomLeft: Radius.circular(9)),
      ),
      child: IconButton(
          onPressed: () {
            if (isEnabled) {
              if (isQtaEnabled) {
                if (quantita - 1 >= 0) {
                  if (quantita.truncateToDouble() == quantita) {
                    quantita = quantita - 1;
                  }
                  qta.text = formatStringDecimal(
                      quantita.floorToDouble(), articolo.decimali!);
                  setState(() {});
                } else {
                  quantita = 0;
                  qta.text = formatStringDecimal(
                      quantita.floorToDouble(), articolo.decimali!);
                  setState(() {});
                }
              }
            }
          },
          icon: const Icon(
            Icons.remove,
            size: 26,
            color: Colors.black,
          )),
    );
  }

  Widget btnPiu(Articolo articolo, int colli) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: const BorderRadius.only(
            topRight: Radius.circular(9), bottomRight: Radius.circular(9)),
      ),
      child: IconButton(
          onPressed: () {
            if (isEnabled) {
              if (!widget.isOF) {
                if (colli < articolo.colli!) {
                  colli = colli + 1;
                  this.colli.text = "$colli";
                  setState(() {});
                }
              } else {
                colli = colli + 1;
                this.colli.text = "$colli";
                setState(() {});
              }
            }
          },
          icon: const Icon(
            Icons.add,
            size: 26,
            color: Colors.black,
          )),
    );
  }

  Widget btnPiuQta(Articolo articolo, double quantita) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: const BorderRadius.only(
            topRight: Radius.circular(9), bottomRight: Radius.circular(9)),
      ),
      child: IconButton(
          onPressed: () {
            if (isEnabled) {
              if (isQtaEnabled) {
                if (!widget.isOF) {
                  if (quantita + 1 <= articolo.quantita!) {
                    quantita = quantita + 1;
                    qta.text = formatStringDecimal(
                        quantita.floorToDouble(), articolo.decimali!);
                    setState(() {});
                  } else {
                    quantita = articolo.quantita!;
                    qta.text = formatStringDecimal(
                        quantita.floorToDouble(), articolo.decimali!);
                    setState(() {});
                  }
                } else {
                  quantita = quantita + 1;
                  qta.text = formatStringDecimal(
                      quantita.floorToDouble(), articolo.decimali!);
                  setState(() {});
                }
              }
            }
          },
          icon: const Icon(
            Icons.add,
            size: 26,
            color: Colors.black,
          )),
    );
  }

  Widget button(String titolo, Function() f) {
    return ConstrainedBox(
      constraints:
          const BoxConstraints(minWidth: double.infinity, minHeight: 70),
      child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, top: 20),
        child: ElevatedButton(
            style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                backgroundColor: MaterialStateProperty.all<Color>(isEnabled
                    ? Theme.of(context).primaryColorDark
                    : Colors.grey),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ))),
            onPressed: () {
              if (isEnabled) {
                f();
              }
            },
            child: Text(titolo.toUpperCase(),
                style: const TextStyle(fontSize: 14))),
      ),
    );
  }

  Widget loading() {
    return Visibility(
      visible: isLoading,
      child: Container(
        decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.5),
            borderRadius: const BorderRadius.all(Radius.circular(10))),
        child: const Center(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}
