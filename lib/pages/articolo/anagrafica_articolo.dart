// ignore_for_file: unrelated_type_equality_checks

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:poolpack_picking/Model/magazzino.dart';
import 'package:poolpack_picking/Model/ordini_fornitori.dart';
import 'package:poolpack_picking/pages/articolo/lista_ubicazioni_modal.dart';
import 'package:poolpack_picking/pages/articolo/picking.dart';
import 'package:poolpack_picking/pages/articolo/ubicazioni.dart';
import 'package:poolpack_picking/pages/home.dart';
import 'package:poolpack_picking/utils/global.dart' as g;
import 'package:poolpack_picking/utils/http.dart';
import 'package:poolpack_picking/utils/utils.dart';

class AnagraficaArticolo extends StatefulWidget {
  static const route = "/articolo";
  final PassaggioDatiArticolo dati;
  const AnagraficaArticolo({super.key, required this.dati});

  @override
  AnagraficaArticoloState createState() => AnagraficaArticoloState();
}

class AnagraficaArticoloState extends State<AnagraficaArticolo> {
  late Articolo articolo;
  late int index;
  late DocumentoOF? documento;
  late Ubicazione? ubicazione;
  late String modalita;
  bool isLoading = false;
  Http http = Http();
  List<PopupMenuItem<int>> menu = [];
  ScrollController scrollController = ScrollController();
  bool isTrasferisci = true;
  GlobalKey<UbicazioniPageState> globalKey = GlobalKey();
  GlobalKey<PickingPageState> globalKeyPicking = GlobalKey();
  late StreamSubscription<bool> keyboardSubscription;
  bool chiusa = false;

  @override
  void initState() {
    super.initState();
    modalita = widget.dati.modalita;
    articolo = widget.dati.articolo;
    documento = widget.dati.documentoOF ?? cercaDocumento();
    index = widget.dati.index!;
    ubicazione = getUbicazione(articolo.idUbicazione!);
    menu = [
      const PopupMenuItem<int>(value: 0, child: Text('Crea EAN')),
      const PopupMenuItem<int>(value: 1, child: Text('Associa ubicazione')),
      const PopupMenuItem<int>(value: 2, child: Text('Associa Alias')),
      const PopupMenuItem<int>(value: 4, child: Text('Stampa etichetta')),
    ];
    if (modalita == "OF" || modalita == "OC") {
      menu.add(
          const PopupMenuItem<int>(value: 3, child: Text('Conferma quantità')));
      menu.add(
          const PopupMenuItem<int>(value: 8, child: Text('Conferma articolo')));
    }
    if (modalita == "CG") {
      if (g.utente_selezionato!.rettifica == true) {
        menu.add(const PopupMenuItem<int>(
            value: 5, child: Text('Rettifica esistenza')));
      }
    }
    /* if (modalita == "CG") {
      menu.add(const PopupMenuItem<int>(
          value: 4, child: Text('Modifica ubicazione')));
    }*/
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

  DocumentoOF? cercaDocumento() {
    DocumentoOF? d;
    if (widget.dati.listaDocumenti != null) {
      for (var c = 0; c < widget.dati.listaDocumenti!.length; c++) {
        var doc = widget.dati.listaDocumenti![c];
        if (articolo.documento ==
            "${doc.documento} ${doc.serie}/${doc.numero}") {
          d = doc;
        }
      }
    }
    return d;
  }

  refresh() {
    setState(() {});
  }

  cambiaArticolo(int index) {
    articolo = widget.dati.listaArticoli[index];
    documento = widget.dati.documentoOF ?? cercaDocumento();
    ubicazione = getUbicazione(articolo.idUbicazione!);
    this.index = index;
    var scrollPosition = scrollController.position;
    scrollController.animateTo(scrollPosition.minScrollExtent,
        duration: const Duration(milliseconds: 500), curve: Curves.ease);
    setState(() {});
    /* PassaggioDatiArticolo dati = widget.dati;
    dati.articolo = widget.dati.listaArticoli[index];
    dati.index = index;
    documento = widget.dati.documentoOF ?? cercaDocumento();
     if (widget.dati.aggiornaDocumenti != null) {
      widget.dati.aggiornaDocumenti!();
    }*/
    /*  Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => AnagraficaArticolo(
          dati: dati,
        ),
      ),
    ).then((value) {
      /*if (widget.dati.aggiornaDocumenti != null) {
        widget.dati.aggiornaDocumenti!();
      }*/
    });*/
  }

  avanti(int index) {
    if (index + 1 < widget.dati.listaArticoli.length) {
      articolo = widget.dati.listaArticoli[index + 1];
      documento = widget.dati.documentoOF ?? cercaDocumento();
      ubicazione = getUbicazione(articolo.idUbicazione!);
      this.index = index + 1;
      globalKeyPicking.currentState?.setCampiCambio(articolo);
      setState(() {});
    }
  }

  indietro(int index) {
    if (index - 1 >= 0) {
      articolo = widget.dati.listaArticoli[index - 1];
      documento = widget.dati.documentoOF ?? cercaDocumento();
      ubicazione = getUbicazione(articolo.idUbicazione!);
      this.index = index - 1;
      globalKeyPicking.currentState?.setCampiCambio(articolo);
      setState(() {});
    }
  }

  setScrollDown() {
    var scrollPosition = scrollController.position;
    scrollController.animateTo(scrollPosition.maxScrollExtent,
        duration: const Duration(milliseconds: 500), curve: Curves.ease);
    setState(() {});
  }

  tornaListaArticoli(DocumentoOF doc) {
    widget.dati.setDocumento!(doc);
    Navigator.pop(context);
  }

  Ubicazione? cercaUbicazione(int id) {
    for (var element in g.ubicazioni) {
      if (element.id == id) {
        return element;
      }
    }
    return Ubicazione(
        codice: "ND",
        id: 0,
        descrizione: "Non definito",
        idMagazzino: 1,
        percorso: 0,
        area: "");
  }

  void _showModal(BuildContext context) {
    Navigator.of(context)
        .push(FullScreenSearchModal(
            ubicazioneSel: cercaUbicazione(articolo.idUbicazione!),
            ubicazionePredefinita: cercaUbicazione(articolo.idUbicazione!)))
        .then((value) {
      if (value != null) {
        apriDialogConfermaAssociaUbicazione(articolo, value);
      }
      chiusa = false;
      setState(() {});
      SystemChannels.textInput.invokeMethod('TextInput.hide');
    });
  }

  apriDialogConfermaAssociaUbicazione(
      Articolo articolo, Ubicazione ubicazione) {
    showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(
            "Vuoi modificare l'ubicazione principare dell'articolo ${articolo.codiceArticolo} all'ubicazione ${ubicazione.codice}"),
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
              Navigator.pop(c, true);
            },
          ),
        ],
      ),
    ).then((value) {
      if (value!) {
        isLoading = true;
        setState(() {});
        http
            .associaUbicazione(ubicazione.id!, articolo.codiceArticolo!)
            .then((val) {
          if (val) {
            showSuccessMessage(context, "Ubicazione associata");
            var tempPicking = articolo.picking;
            var tempColli = articolo.colli;
            var tempQta = articolo.quantita;
            http
                .getArticoliArt(articolo.codiceArticolo!, articolo.prgTaglia!)
                .then((value) {
              isLoading = false;
              articolo = value[0];
              articolo.picking = tempPicking;
              articolo.colli = tempColli;
              articolo.quantita = tempQta;
              widget.dati.articolo = value[0];
              setState(() {});
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => AnagraficaArticolo(
                    dati: widget.dati,
                  ),
                ),
              );
              //setState(() {});
            });
          } else {
            showErrorMessage(context, "Si è verificato un errore");
            isLoading = false;
            setState(() {});
          }
        });
      }
      chiusa = false;
      setState(() {});
      SystemChannels.textInput.invokeMethod('TextInput.hide');
    });
  }

  Future<void> handleClick(int value) async {
    switch (value) {
      case 0:
        apriDialogCreaEAN(
          context,
          articolo,
          setLoading,
          () {
            chiusa = false;
            setState(() {});
            SystemChannels.textInput.invokeMethod('TextInput.hide');
          },
        );
        break;
      case 1:
        chiusa = false;
        setState(() {});
        _showModal(context);
        break;
      case 2:
        chiusa = false;
        setState(() {});
        apriDialogAssociaAlias(
          context,
          articolo,
          setLoading,
          () {
            chiusa = false;
            setState(() {});
            SystemChannels.textInput.invokeMethod('TextInput.hide');
          },
        );
        break;
      case 3:
        chiediConfermaResiduoSospeso(articolo, index);
        break;
      case 4:
        apriDialogStampaEtichetta(context, articolo, setLoading, () {
          chiusa = false;
          setState(() {});
          SystemChannels.textInput.invokeMethod('TextInput.hide');
        });
        break;
      case 5:
        isTrasferisci = false;
        menu.removeLast();
        menu.add(const PopupMenuItem<int>(
            value: 6, child: Text('Annulla rettifica')));
        menu.add(
            const PopupMenuItem<int>(value: 7, child: Text('Salva rettifica')));
        setState(() {});
        break;
      case 6:
        isTrasferisci = true;
        menu.removeLast();
        menu.removeLast();
        menu.add(const PopupMenuItem<int>(
            value: 5, child: Text('Rettifica esistenza')));
        globalKey.currentState?.setController();
        setState(() {});
        break;
      case 7: //RETTIFICA ESISTENZE
        globalKey.currentState
            ?.apriDialogConfermaRettifica()
            .then((value) async {
          if (value!) {
            isLoading = true;
            setState(() {});
            await globalKey.currentState?.rettificaQuantita().then((value) {
              isLoading = false;
              setState(() {});
              Documento? doc = value;
              if (doc != null) {
                showSuccessMessage(context,
                    "Documento ${doc.documento} ${doc.serie}/${doc.numero} creato");
                http
                    .getArticoliArt(
                        articolo.codiceArticolo!, articolo.prgTaglia!)
                    .then((value) {
                  isLoading = false;
                  articolo = value[0];
                  widget.dati.articolo = value[0];
                  /* menu.removeLast();
              menu.removeLast();
              menu.add(
                  const PopupMenuItem<int>(value: 5, child: Text('Rettifica')));
              setState(() {});*/
                  setState(() {});
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AnagraficaArticolo(
                        dati: widget.dati,
                      ),
                    ),
                  );
                });
              }
            });
          }
        });
        break;
      case 8:
        globalKeyPicking.currentState?.validaArticolo();
        break;
    }
  }

  setLoading(bool loading) {
    isLoading = loading;
    setState(() {});
  }

  setArticolo(int i) {
    articolo = widget.dati.listaArticoli[i];
    //articolo = documento!.articoli![i];
    //widget.dati.articolo = documento!.articoli![i];
    widget.dati.articolo = widget.dati.listaArticoli[i];
    cambiaArticolo(i);
    setState(() {});
  }

  /* setPicking(
      Articolo articolo, int colli, String? quantita, String stato, int index) {
    isLoading = true;
    setState(() {});

    Picking payload = Picking(
        documento: documento?.documento,
        serie: documento?.serie,
        numero: documento?.numero,
        rigo: articolo.rigo,
        prgTaglia: articolo.prgTaglia,
        colli: colli,
        quantita: articolo.colli == 0
            ? double.parse(quantita == "" ? "0" : quantita!)
            : articolo.quantita,
        idMagazzino: articolo.idMagazzino,
        idUbicazione: articolo.idUbicazione,
        stato: stato,
        idUtente: g.utente_selezionato!.nome.toString());

    http.setPickingOrdini(payload, context).then((value) {
      isLoading = false;
      setState(() {});
      if (value != null) {
        articolo.picking = value;
        //documento?.articoli?[index].picking = value;
        setState(() {});
        if (controlloOrdineCompleto(documento!)) {
          if (documento?.documento == "OC") {
            if (!controlloOrdiniCompletati(widget.dati.listaDocumenti!)) {
              apriDialogConfermaOrdineCompletato(
                  context,
                  widget.dati.listaDocumenti!,
                  widget.dati.documentoOF!,
                  tornaListaArticoli);
            } else {
              apriDialogOrdiniCompletati(context);
            }
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
            //if (!completo) {
            if (documento!.articoli!.length > 1) {
              apriDialogConferma(
                  context, documento!, index, articolo, setArticolo);
            }
            //} else {
            //  Navigator.pop(context);
            //}
          }
        }
      } else {
        showErrorMessage(context, "Si è verificato un errore");
      }
      setState(() {});
    });
  }*/

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
              chiusa = false;
              setState(() {});
              SystemChannels.textInput.invokeMethod('TextInput.hide');
              Navigator.pop(c, false);
            },
          ),
          TextButton(
            child: const Text('Si'),
            onPressed: () {
              globalKeyPicking.currentState!.confermaQuantita("#");
              /*if (articolo.picking != null) {
                setPicking(articolo, articolo.picking!.colli!,
                    articolo.picking!.quantita!.toString(), "#", index);
              } else {
                setPicking(articolo, 0, "0", "#", index);
              }*/
              chiusa = false;
              setState(() {});
              SystemChannels.textInput.invokeMethod('TextInput.hide');
              Navigator.pop(c, false);
            },
          ),
        ],
      ),
    );
    return true;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: modalita != "CG"
            ? Text(
                "${documento?.documento} ${documento?.serie}/${documento?.numero}",
                style: const TextStyle(fontSize: 18),
              )
            : const Text("Articolo"),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, HomePage.route);
                },
                icon: const Icon(
                  Icons.home,
                  size: 30,
                )),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: PopupMenuButton<int>(
              icon: const Icon(
                Icons.more_vert,
                size: 30,
              ),
              onSelected: handleClick,
              itemBuilder: (BuildContext context) => menu,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.only(top: 8, left: 5, right: 5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                testata(),
                Visibility(
                  visible: modalita == "OF" || modalita == "OC",
                  child: PickingPage(
                    key: globalKeyPicking,
                    articolo: articolo,
                    documento: documento,
                    index: index,
                    controlloOrdineCompleto:
                        widget.dati.controlloOrdineCompleto!,
                    cambiaArticolo: setArticolo,
                    listaDocumenti: widget.dati.listaDocumenti ?? [],
                    tornaIndietro: tornaListaArticoli,
                    isOF: modalita == "OF" ? true : false,
                    setScrollDown: setScrollDown,
                    listaArticoli: widget.dati.listaArticoli,
                    articoloPicking: widget.dati.articoloPicking,
                    isUbicazione: widget.dati.isUbicazione,
                  ),
                ),
                Visibility(
                    visible: widget.dati.modalita != "CG",
                    child: pulsantiNavigazione()),
                UbicazioniPage(
                  key: globalKey,
                  esistenze: articolo.esistenza ?? [],
                  articolo: articolo,
                  isTrasferisci: isTrasferisci,
                  dati: widget.dati,
                  setLoading: setLoading,
                  idUbicazione: widget.dati.idUbicazione,
                ),
                const SizedBox(
                  height: 10,
                )
              ],
            ),
          ),
          loading()
        ],
      ),
    );
  }

  Widget testata() {
    var esistenza = articolo.esistenzaUbicazione ?? articolo.esistenzaTotale;
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side:
              BorderSide(color: Theme.of(context).primaryColorDark, width: 2)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ExpansionTile(
              initiallyExpanded: true,
              leading: Icon(
                Icons.article,
                color: Theme.of(context).primaryColorDark,
                size: 40,
              ),
              title: const Text(
                'Dati articolo',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              childrenPadding:
                  const EdgeInsets.only(bottom: 8, left: 16, right: 16),
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              expandedAlignment: Alignment.topLeft,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '${articolo.descrizione}',
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ),
                testo("Codice: ", articolo.codiceArticolo!),
                //testo("Descrizione:", articolo.descrizione!),
                Visibility(
                  visible: ubicazione != null,
                  child: testo("Ubicazione: ", ubicazione!.codice!),
                ),
                Visibility(
                    visible: articolo.taglia != "",
                    child: testo("Taglia: ", articolo.taglia.toString())),
                Visibility(
                    visible: articolo.esistenzaTotale != null,
                    child: testo(
                        "Esistenza: ",
                        articolo.colli == 0
                            ? "${((esistenza ?? 0).toStringAsFixed(esistenza?.truncateToDouble() == esistenza ? 0 : articolo.decimali!))} ${articolo.um!.toUpperCase()}"
                            : "${((esistenza ?? 0).toStringAsFixed(esistenza?.truncateToDouble() == esistenza ? 0 : articolo.decimali!))} [${articolo.confezione?.toStringAsFixed(articolo.confezione?.truncateToDouble() == articolo.confezione ? 0 : articolo.decimali!)}] ${articolo.um!.toUpperCase()}")),
                /* Visibility(
                    visible: articolo.quantita != "",
                    child: testo("Confezione: ",
                        "${articolo.quantita.toString()} ${articolo.um!.toUpperCase()}")),*/
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget pulsantiNavigazione() {
    return Container(
      padding: const EdgeInsets.only(top: 8),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 4, left: 4),
            child: Container(
              decoration: BoxDecoration(
                  border: Border.all(
                      color: Theme.of(context).primaryColorDark, width: 2),
                  borderRadius: const BorderRadius.all(Radius.circular(10))),
              child: InkWell(
                onTap: () => indietro(index),
                child: const Icon(
                  Icons.keyboard_arrow_left_outlined,
                  size: 40,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 4, right: 4),
            child: Container(
              decoration: BoxDecoration(
                  border: Border.all(
                      color: Theme.of(context).primaryColorDark, width: 2),
                  borderRadius: const BorderRadius.all(Radius.circular(10))),
              child: InkWell(
                onTap: () => avanti(index),
                child: const Icon(
                  Icons.keyboard_arrow_right_outlined,
                  size: 40,
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Widget ubicazioni() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ExpansionTile(
              initiallyExpanded: true,
              leading: Icon(
                Icons.share_location,
                color: Theme.of(context).primaryColorDark,
                size: 40,
              ),
              title: const Text(
                'Ubicazioni',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              childrenPadding: const EdgeInsets.only(bottom: 8),
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Lista ubicazioni e funzioni",
                  maxLines: 2,
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget testo(String label, String dato) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
          Text(
            dato,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            maxLines: 2,
          )
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
}
