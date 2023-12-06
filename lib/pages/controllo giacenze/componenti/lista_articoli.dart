import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:poolpack_picking/Model/magazzino.dart';
import 'package:poolpack_picking/Model/ordini_fornitori.dart';
import 'package:poolpack_picking/pages/articolo/anagrafica_articolo.dart';
import 'package:poolpack_picking/pages/articolo/lista_articoli_modal.dart';
import 'package:poolpack_picking/pages/articolo/lista_ubicazioni_modal.dart';
import 'package:poolpack_picking/utils/global.dart';
import 'package:poolpack_picking/utils/http.dart';
import 'package:poolpack_picking/utils/utils.dart';

class ListaArticoliG extends StatefulWidget {
  final bool isCercaArticolo;
  const ListaArticoliG({super.key, required this.isCercaArticolo});

  @override
  ListaArticoliGState createState() => ListaArticoliGState();
}

class ListaArticoliGState extends State<ListaArticoliG>
    with AutomaticKeepAliveClientMixin<ListaArticoliG> {
  TextEditingController codice = TextEditingController();
  late final bool isCercaArticolo;
  Http http = Http();
  bool isLoading = false;
  List<Articolo> articoli = [];
  String codiceSelezionato = "";
  FocusNode focus = FocusNode();
  late StreamSubscription<bool> keyboardSubscription;
  bool chiusa = false;

  @override
  void initState() {
    super.initState();
    isCercaArticolo = widget.isCercaArticolo;
    setFocus();
    var keyboardVisibilityController = KeyboardVisibilityController();
    keyboardSubscription =
        keyboardVisibilityController.onChange.listen((bool visible) {
      if (!chiusa) {
        if (visible) {
          chiusa = true;
          SystemChannels.textInput.invokeMethod('TextInput.hide');
        }
      }
      setState(() {});
    });
  }

  @override
  bool get wantKeepAlive => true;

  controlloArticoli(List<Articolo> articoli) {
    if (articoli.length == 1) {
      Navigator.pushNamed(context, AnagraficaArticolo.route,
              arguments: PassaggioDatiArticolo(
                  articolo: articoli[0],
                  modalita: "CG",
                  documentoOF: null,
                  index: 0,
                  controlloOrdineCompleto: () {},
                  listaDocumenti: null,
                  setDocumento: (DocumentoOF a) {},
                  listaArticoli: articoli,
                  articoloPicking: null,
                  isUbicazione: false,
                  aggiornaDocumenti: null))
          .then((value) {
        aggiornaArticoli();
      });

      this.articoli = [];
    }
    setState(() {});
  }

  setFocus() {
    chiusa = false;
    focus.requestFocus();
    setState(() {});
  }

  int? cercaIdUbicazione(String ubicazione) {
    for (var element in ubicazioni) {
      if (element.codice == ubicazione) {
        return element.id;
      }
    }
    return -1;
  }

  Ubicazione? cercaUbicazionePerCodice(String ubicazione) {
    for (var element in ubicazioni) {
      if (element.codice == ubicazione) {
        return element;
      }
    }
    return null;
  }

  Ubicazione? cercaUbicazione(int id) {
    for (var element in ubicazioni) {
      if (element.id == id) {
        return element;
      }
    }
    return null;
  }

  double getEsistenzaFromUbicazione(List<Esistenza> esistenze) {
    for (var es in esistenze) {
      if (es.idUbicazione == getUbicazioneFromCode(codiceSelezionato)?.id) {
        return es.quantita!;
      }
    }
    return 0;
  }

  aggiornaArticoli() {
    setFocus();
    isLoading = true;
    setState(() {});
    if (isCercaArticolo) {
      http.getArticoliArt(codiceSelezionato, 0).then((value) {
        isLoading = false;
        articoli = value;
        codice.text = "";
        SystemChannels.textInput.invokeMethod('TextInput.hide');
        setState(() {});
      });
    } else {
      http
          .getArticoliUbi(cercaIdUbicazione(codiceSelezionato) ?? 0)
          .then((value) {
        isLoading = false;
        articoli = value;
        codice.text = "";
        SystemChannels.textInput.invokeMethod('TextInput.hide');
        setState(() {});
      });
    }
  }

  void apriListaUbicazioni() {
    chiusa = false;
    setState(() {});
    Navigator.of(context)
        .push(FullScreenSearchModal(
            ubicazioneSel: null, ubicazionePredefinita: null))
        .then((value) {
      if (value != null) {
        isLoading = true;
        setState(() {});
        http
            .getArticoliUbi(
                cercaIdUbicazione((value as Ubicazione).codice ?? "") ?? 0)
            .then((val) {
          isLoading = false;
          articoli = val;
          codiceSelezionato = value.codice!;
          //codice.text = "";
          controlloArticoli(articoli);
        });
      }
      chiusa = false;
      SystemChannels.textInput.invokeMethod('TextInput.hide');
      setState(() {});
    });
  }

  void apriListaArticoli() {
    chiusa = false;
    setState(() {});
    Navigator.of(context).push(FullScreenSearchModalArticoli()).then((value) {
      if (value != null) {
        isLoading = true;
        setState(() {});
        http
            .getArticoliArt((value as ArticoloLista).codiceArticolo ?? "", 0)
            .then((val) {
          isLoading = false;
          articoli = val;
          codice.text = "";
          chiusa = false;
          controlloArticoli(articoli);
        });
      }
      chiusa = false;
      SystemChannels.textInput.invokeMethod('TextInput.hide');
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: TextField(
                        controller: codice,
                        focusNode: focus,
                        onTap: () {
                          chiusa = true;
                          setState(() {});
                        },
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                        decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            labelText: isCercaArticolo
                                ? "Codice articolo"
                                : "Codice ubicazione"),
                        onSubmitted: (a) {
                          isLoading = true;
                          setState(() {});
                          if (isCercaArticolo) {
                            http.getArticoliArt(codice.text, 0).then((value) {
                              isLoading = false;
                              articoli = value;
                              codiceSelezionato = codice.text;
                              codice.text = "";
                              setFocus();
                              SystemChannels.textInput
                                  .invokeMethod('TextInput.hide');
                              controlloArticoli(articoli);
                              setState(() {});
                            });
                          } else {
                            http
                                .getArticoliUbi(
                                    cercaIdUbicazione(codice.text) ?? 0)
                                .then((value) {
                              isLoading = false;
                              articoli = value;
                              codiceSelezionato = codice.text;
                              codice.text = "";
                              setFocus();
                              SystemChannels.textInput
                                  .invokeMethod('TextInput.hide');
                              controlloArticoli(articoli);
                              setState(() {});
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: Theme.of(context).primaryColorDark,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10))),
                    child: IconButton(
                      onPressed: () {
                        if (isCercaArticolo) {
                          apriListaArticoli();
                        } else {
                          apriListaUbicazioni();
                        }
                      },
                      icon: const Icon(Icons.list),
                      color: Colors.white,
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: articoli.length,
                itemBuilder: (context, index) {
                  return cardArticolo(articoli[index], index);
                },
              ),
            ),
          ],
        ),
        loading()
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
                        modalita: "CG",
                        documentoOF: null,
                        index: index,
                        controlloOrdineCompleto: () {},
                        listaDocumenti: null,
                        setDocumento: (DocumentoOF doc) {},
                        listaArticoli: articoli,
                        articoloPicking: null,
                        isUbicazione: false,
                        aggiornaDocumenti: null))
                .then((value) {
              aggiornaArticoli();
            });
            articoli = [];
          },
          onLongPress: () {
            //chiediConfermaResiduoSospeso(articolo, index);
          },
          child: ClipPath(
            clipper: ShapeBorderClipper(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            child: Container(
              padding: const EdgeInsets.all(16),
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
              isCercaArticolo
                  ? '${cercaUbicazione(articolo.idUbicazione!)?.codice}'
                  : '${cercaUbicazionePerCodice(codiceSelezionato)?.codice}',
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
              'Esistenza: ',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: Colors.black),
            ),
            Text(
              isCercaArticolo
                  ? "${formatStringDecimal(articolo.esistenzaTotale!, articolo.decimali!)} ${articolo.um}"
                  : "${formatStringDecimal(getEsistenzaFromUbicazione(articolo.esistenza!), articolo.decimali!)} ${articolo.um}",
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            )
          ],
        ),
      ],
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

  Widget button(String titolo, Function() f) {
    return ConstrainedBox(
      constraints:
          const BoxConstraints(minWidth: double.infinity, minHeight: 70),
      child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, top: 20),
        child: ElevatedButton(
            style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                backgroundColor: MaterialStateProperty.all<Color>(
                    Theme.of(context).primaryColorDark),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ))),
            onPressed: () => f(),
            child: Text(titolo.toUpperCase(),
                style: const TextStyle(fontSize: 14))),
      ),
    );
  }
}
