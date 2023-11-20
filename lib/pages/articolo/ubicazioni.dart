import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:poolpack_picking/Model/magazzino.dart';
import 'package:poolpack_picking/Model/ordini_fornitori.dart';
import 'package:poolpack_picking/pages/articolo/anagrafica_articolo.dart';
import 'package:poolpack_picking/pages/articolo/lista_ubicazioni_modal.dart';
import 'package:poolpack_picking/utils/global.dart';
import 'package:poolpack_picking/utils/http.dart';
import 'package:poolpack_picking/utils/utils.dart';

class UbicazioniPage extends StatefulWidget {
  final List<Esistenza> esistenze;
  final Articolo articolo;
  final bool isTrasferisci;
  final PassaggioDatiArticolo dati;
  final Function(bool value) setLoading;
  //final Function(DocumentoOF documento) tornaIndietro;
  const UbicazioniPage(
      {super.key,
      required this.esistenze,
      required this.articolo,
      required this.isTrasferisci,
      required this.dati,
      required this.setLoading});

  @override
  UbicazioniPageState createState() => UbicazioniPageState();
}

class UbicazioniPageState extends State<UbicazioniPage> {
  List<Esistenza> esistenze = [];
  List<Esistenza> esistenzeAggiunte = [];
  late Articolo articolo;
  bool isLoading = false;
  List<TextEditingController> colli = [];
  List<TextEditingController> qta = [];
  Http http = Http();

  @override
  void initState() {
    super.initState();
    esistenze = ordinaEsistenza(widget.esistenze);
    articolo = widget.articolo;
    setController();
  }

  List<Esistenza> ordinaEsistenza(List<Esistenza> esistenze) {
    for (int c = 0; c < esistenze.length; c++) {
      if (esistenze[c].ubicazionePredefinita!) {
        if (c > 0) {
          var esistenzaTemp = esistenze[c];
          esistenze.remove(esistenze[c]);
          esistenze.insert(0, esistenzaTemp);
        }
      }
    }
    return esistenze;
  }

  setController() {
    colli = [];
    qta = [];
    for (var c = 0; c < esistenzeAggiunte.length; c++) {
      esistenze.remove(esistenzeAggiunte[c]);
    }
    esistenzeAggiunte = [];
    for (var element in esistenze) {
      TextEditingController c = TextEditingController();
      if (articolo.prgTaglia == 0) {
        c.text = (element.quantita! / articolo.confezione!)
            .floor()
            .toStringAsFixed(0);
      } else {
        c.text = "0";
      }
      TextEditingController q = TextEditingController(
          text: (element.quantita!).toStringAsFixed(
              element.quantita!.truncateToDouble() == element.quantita
                  ? 0
                  : articolo.decimali!));
      colli.add(c);
      qta.add(q);
    }
    setState(() {});
  }

  Ubicazione? cercaUbicazione(int id) {
    for (var element in ubicazioni) {
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

  Magazzino? cercaMagazzino(int id) {
    for (var element in magazzini) {
      if (element.id == id) {
        return element;
      }
    }
    return null;
  }

  void _showModal(BuildContext context, bool addUbi, int index) {
    Navigator.of(context)
        .push(FullScreenSearchModal(
            ubicazioneSel: cercaUbicazione(esistenze[index].idUbicazione!),
            ubicazionePredefinita: cercaUbicazione(articolo.idUbicazione!)))
        .then((value) {
      if (value != null) {
        if (addUbi) {
          var es = Esistenza(
              codiceLotto: "",
              idLotto: 0,
              idUbicazione: (value as Ubicazione).id,
              quantita: 0,
              scadenzaLotto: "",
              ubicazionePredefinita: false);
          esistenze.add(es);
          esistenzeAggiunte.add(es);
          TextEditingController c = TextEditingController(text: "0");
          TextEditingController q = TextEditingController(text: "0");
          colli.add(c);
          qta.add(q);
          setState(() {});
        } else {
          apriDialogConferma(index, articolo, value);
        }
      }
    });
  }

  Future<bool?> apriDialogConfermaRettifica() {
    var continua = true;
    for (int c = 0; c < qta.length; c++) {
      if (double.parse(qta[c].text) < 0) {
        showErrorMessage(
            context, "Le quantità da rettificare non possono essere negative");
        continua = false;
      }
    }
    if (continua) {
      return showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text(
              "Vuoi rettificare le quantità delle ubicaioni modificate?"),
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
      );
    }
    return Future(() => false);
  }

  apriDialogConferma(int index, Articolo articolo, Ubicazione ubicazione) {
    showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(
            "Vuoi trasferire la quantità ${double.parse(qta[index].text).toStringAsFixed(double.parse(qta[index].text).truncateToDouble() == double.parse(qta[index].text) ? 0 : articolo.decimali!)} all'ubicazione ${ubicazione.codice}?"),
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
      if (value == true) {
        widget.setLoading(true);
        List<ArticoloMovimento> dati = [];
        ArticoloMovimento art = ArticoloMovimento(
            codiceArticolo: articolo.codiceArticolo,
            idLotto: esistenze[index].idLotto,
            idMagazzino:
                cercaUbicazione(articolo.idUbicazione!)?.idMagazzino ?? 1,
            idUbicazione: esistenze[index].idUbicazione,
            idMagazzinoA: ubicazione.idMagazzino,
            idUbicazioneA: ubicazione.id,
            prgTaglia: articolo.prgTaglia,
            nota: "",
            quantita: double.parse(qta[index].text));
        dati.add(art);
        http.movimento("T", dati, context).then((value) {
          widget.setLoading(false);
          Documento? doc = value;
          if (doc != null) {
            showSuccessMessage(context,
                "Documento ${doc.documento} ${doc.serie}/${doc.numero} creato");
            http.getArticoliArt(articolo.codiceArticolo!).then((value) {
              isLoading = false;
              articolo = value[0];
              //articolo.picking = tempPicking;
              widget.dati.articolo = value[0];
              //setState(() {});
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
  }

  Future<Documento?> rettificaQuantita() {
    widget.setLoading(true);
    List<Esistenza> dati = [];
    for (int c = 0; c < esistenze.length; c++) {
      if (esistenze[c].idUbicazione != 0) {
        Esistenza es = Esistenza(
            idLotto: esistenze[c].idLotto,
            quantita: double.parse(qta[c].text),
            idUbicazione: esistenze[c].idUbicazione);
        dati.add(es);
      }
    }
    return http.rettifica(articolo.idMagazzino ?? 1, articolo, dati, context);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: esistenze.length,
            itemBuilder: (context, index) {
              if (widget.isTrasferisci) {
                return cardUbicazioni(esistenze[index], index);
              } else {
                if (esistenze[index].idUbicazione != 0) {
                  return cardUbicazioni(esistenze[index], index);
                } else {
                  return const SizedBox(height: 0);
                }
              }
            },
          ),
        ),
        Visibility(
          visible: !widget.isTrasferisci,
          child: button("Aggiungi ubicazione", () {
            _showModal(context, true, 0);
          }),
        )
      ],
    );
  }

  Widget cardUbicazioni(Esistenza esistenza, int index) {
    return Padding(
      padding: const EdgeInsets.only(top: 0, right: 0, left: 0),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
                color: esistenza.idUbicazione == 0
                    ? Colors.yellow.shade700
                    : esistenza.ubicazionePredefinita!
                        ? Colors.green
                        : Theme.of(context).primaryColorDark,
                width: 2)),
        child: InkWell(
          onTap: () {
            /* Navigator.pushNamed(
                    context,
                    AnagraficaArticolo
                        .route, //PAGINA LISTA ARTICOLI DA DOCUMENTI
                    arguments: PassaggioDatiArticolo(
                        articolo: articolo,
                        modalita: "OF",
                        documentoOF: widget.documento,
                        index: index,
                        controlloOrdineCompleto: widget.controlloOrdineCompleto,
                        listaDocumenti: widget.listaDocumenti,
                        setDocumento: setDocumento))
                .then((value) => refresh());*/
          },
          onLongPress: () {
            //chiediConfermaResiduoSospeso(articolo, index);
          },
          child: ClipPath(
            clipper: ShapeBorderClipper(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            child: Theme(
              data:
                  Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: Row(
                children: [
                  Expanded(
                    child: ExpansionTile(
                      expandedCrossAxisAlignment: CrossAxisAlignment.start,
                      expandedAlignment: Alignment.topLeft,
                      initiallyExpanded:
                          esistenza.idUbicazione == 0 ? false : true,
                      leading: Icon(
                        Icons.warehouse,
                        color: esistenza.idUbicazione == 0
                            ? Colors.yellow.shade700
                            : esistenza.ubicazionePredefinita!
                                ? Colors.green
                                : Theme.of(context).primaryColorDark,
                        size: 40,
                      ),
                      title: Text(
                        cercaUbicazione(esistenza.idUbicazione!)?.codice ??
                            '00000000',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                      subtitle: Text(
                        "${cercaUbicazione(esistenza.idUbicazione!)?.descrizione}",
                        style: const TextStyle(fontSize: 12),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 16, right: 16, top: 4),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: dettaglioCard(esistenza, index)),
                        ),
                        Visibility(
                          visible: widget.isTrasferisci,
                          child: ElevatedButton(
                            style: ButtonStyle(
                                minimumSize: MaterialStateProperty.all<Size>(
                                    const Size.fromHeight(50)),
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        esistenza.idUbicazione == 0
                                            ? Colors.yellow.shade700
                                            : esistenza.ubicazionePredefinita!
                                                ? Colors.green
                                                : Theme.of(context)
                                                    .primaryColorDark),
                                shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                    const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(0)),
                                ))),
                            onPressed: () {
                              if (double.parse(qta[index].text) <= 0) {
                                showErrorMessage(context,
                                    "Non puoi trasferire una quantità negativa o uguale a zero");
                              } else {
                                _showModal(context, false, index);
                              }
                            },
                            child: const Text(
                              'TRASFERISCI',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> dettaglioCard(Esistenza esistenza, int index) {
    /* qta[index].text =
        (double.parse(colli[index].text) * articolo.confezione!).toString();*/
    Ubicazione? ubicazione;
    Magazzino? magazzino;
    if (esistenza.idUbicazione == 0) {
      ubicazione = Ubicazione(
          id: 0,
          idMagazzino: 1,
          area: "Not defined",
          codice: "00000000",
          descrizione: "Ubicazione inesistente",
          percorso: 0);
      magazzino = cercaMagazzino(ubicazione.idMagazzino!);
    } else {
      ubicazione = cercaUbicazione(esistenza.idUbicazione!);
      magazzino = cercaMagazzino(ubicazione!.idMagazzino!);
    }

    return <Widget>[
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Text(
                'Magazzino:',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  '${magazzino!.descrizione}',
                  style: const TextStyle(fontSize: 12, color: Colors.black),
                ),
              )
            ],
          ),
          Row(
            children: [
              const Text(
                'Area:',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  '${ubicazione.area}',
                  style: const TextStyle(fontSize: 12, color: Colors.black),
                ),
              ),
            ],
          ),
        ],
      ),
      const SizedBox(
        height: 5,
      ),
      Visibility(
        visible: esistenza.idLotto != 0,
        child: Row(
          children: [
            const Text(
              'Lotto:',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                '${esistenza.codiceLotto}',
                style: const TextStyle(fontSize: 12, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(
        height: 5,
      ),
      Visibility(
        visible: articolo.prgTaglia == 0,
        child: Column(
          children: [
            Text(
              'CL [${articolo.confezione!.toStringAsFixed(0)}]',
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: componenteColli(index),
            ),
          ],
        ),
      ),
      Visibility(
        visible: articolo.prgTaglia == 0,
        child: const SizedBox(
          height: 5,
        ),
      ),
      Column(
        children: [
          Text(
            '${articolo.um!.toUpperCase()} [${esistenze[index].quantita!.toStringAsFixed(esistenze[index].quantita!.truncateToDouble() == esistenze[index].quantita ? 0 : articolo.decimali!)}]',
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: componenteQta(index),
          ),
        ],
      ),
      const SizedBox(
        height: 10,
      ),
    ];
  }

  Widget componenteColli(int index) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(10))),
      child: Row(
        children: [
          btnMeno(articolo, index, false),
          Expanded(
            child: TextField(
                controller: colli[index],
                style: const TextStyle(color: Colors.black, fontSize: 14),
                onChanged: (value) {
                  if (value != "") {
                    if (widget.isTrasferisci) {
                      if (double.parse(value) * articolo.confezione! <=
                          esistenze[index].quantita!) {
                        var q = double.parse(value) * articolo.confezione!;
                        qta[index].text = q.toStringAsFixed(
                            q.truncateToDouble() == q ? 0 : articolo.decimali!);
                      } else {
                        colli[index].text =
                            (esistenze[index].quantita! / articolo.confezione!)
                                .floor()
                                .toStringAsFixed(0);
                        var q = double.parse(colli[index].text) *
                            articolo.confezione!;
                        qta[index].text = q.toStringAsFixed(
                            q.truncateToDouble() == q ? 0 : articolo.decimali!);
                      }
                    } else {
                      var q = double.parse(value) * articolo.confezione!;
                      qta[index].text = q.toStringAsFixed(
                          q.truncateToDouble() == q ? 0 : articolo.decimali!);
                    }
                  }
                  setState(() {});
                },
                textAlign: TextAlign.center,
                decoration: const InputDecoration.collapsed(hintText: ''),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ]),
          ),
          btnPiu(articolo, index, false),
        ],
      ),
    );
  }

  Widget componenteQta(int index) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(10))),
      child: Row(
        children: [
          btnMeno(articolo, index, true),
          Expanded(
            child: TextField(
              controller: qta[index],
              style: const TextStyle(color: Colors.black, fontSize: 14),
              onChanged: (value) {
                if (value != "") {
                  if (value.endsWith(",")) {
                    value =
                        value.replaceRange(value.length - 1, value.length, ".");
                    qta[index].text = value;
                  }
                  if (widget.isTrasferisci) {
                    if (!value.endsWith(".")) {
                      if (double.parse(value) <= esistenze[index].quantita!) {
                        var q = double.parse(value);
                        var c = q / articolo.confezione!;
                        /*qta[index].text = q.toStringAsFixed(
                            q.truncateToDouble() == q ? 0 : articolo.decimali!);*/
                        colli[index].text = articolo.prgTaglia == 0
                            ? c.floor().toStringAsFixed(0)
                            : "0";
                      } else {
                        /* qta[index].text = esistenze[index]
                            .quantita!
                            .toStringAsFixed(
                                esistenze[index].quantita!.truncateToDouble() ==
                                        esistenze[index].quantita
                                    ? 0
                                    : articolo.decimali!);*/
                        var c = double.parse(qta[index].text) /
                            articolo.confezione!;
                        colli[index].text = articolo.prgTaglia == 0
                            ? c.floor().toStringAsFixed(0)
                            : "0";
                      }
                    }
                  }
                }
                setState(() {});
              },
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
          btnPiu(articolo, index, true),
        ],
      ),
    );
  }

  Widget btnMeno(Articolo articolo, int index, bool isQta) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(9), bottomLeft: Radius.circular(9)),
      ),
      child: IconButton(
          onPressed: () {
            if (isQta) {
              if (double.parse(qta[index].text) - 1 >= 0) {
                var q = double.parse(qta[index].text) - 1;
                var c = q / articolo.confezione!;
                qta[index].text = q.toStringAsFixed(
                    q.truncateToDouble() == q ? 0 : articolo.decimali!);
                colli[index].text = articolo.prgTaglia == 0
                    ? c.floor().toStringAsFixed(0)
                    : "0";
                setState(() {});
              }
            } else {
              if (double.parse(colli[index].text) - 1 >= 0) {
                var c = double.parse(colli[index].text) - 1;
                var q = c * articolo.confezione!;
                colli[index].text = articolo.prgTaglia == 0
                    ? c.floor().toStringAsFixed(0)
                    : "0";
                qta[index].text = q.toStringAsFixed(
                    q.truncateToDouble() == q ? 0 : articolo.decimali!);
                setState(() {});
              }
            }
          },
          icon: const Icon(
            Icons.remove,
            size: 22,
            color: Colors.black,
          )),
    );
  }

  Widget btnPiu(Articolo articolo, int index, bool isQta) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: const BorderRadius.only(
            topRight: Radius.circular(9), bottomRight: Radius.circular(9)),
      ),
      child: IconButton(
          onPressed: () {
            if (isQta) {
              if (widget.isTrasferisci) {
                if (double.parse(qta[index].text) + 1 <=
                    esistenze[index].quantita!) {
                  var q = double.parse(qta[index].text) + 1;
                  var c = q / articolo.confezione!;
                  qta[index].text = q.toStringAsFixed(
                      q.truncateToDouble() == q ? 0 : articolo.decimali!);
                  colli[index].text = articolo.prgTaglia == 0
                      ? c.floor().toStringAsFixed(0)
                      : "0";
                  setState(() {});
                }
              } else {
                var q = double.parse(qta[index].text) + 1;
                var c = q / articolo.confezione!;
                qta[index].text = q.toStringAsFixed(
                    q.truncateToDouble() == q ? 0 : articolo.decimali!);
                colli[index].text = articolo.prgTaglia == 0
                    ? c.floor().toStringAsFixed(0)
                    : "0";
                setState(() {});
              }
            } else {
              if (widget.isTrasferisci) {
                var c = double.parse(colli[index].text) + 1;
                if (c * articolo.confezione! <= esistenze[index].quantita!) {
                  var q = c * articolo.confezione!;
                  colli[index].text = c.floor().toStringAsFixed(0);
                  qta[index].text = q.toStringAsFixed(
                      q.truncateToDouble() == q ? 0 : articolo.decimali!);
                  setState(() {});
                }
              } else {
                var c = double.parse(colli[index].text) + 1;
                var q = c * articolo.confezione!;
                colli[index].text = c.floor().toStringAsFixed(0);
                qta[index].text = q.toStringAsFixed(
                    q.truncateToDouble() == q ? 0 : articolo.decimali!);
                setState(() {});
              }
            }
          },
          icon: const Icon(
            Icons.add,
            size: 22,
            color: Colors.black,
          )),
    );
  }

  Widget button(String titolo, Function() f) {
    return ConstrainedBox(
      constraints:
          const BoxConstraints(minWidth: double.infinity, minHeight: 60),
      child: Padding(
        padding: const EdgeInsets.only(left: 4, right: 4, top: 10),
        child: ElevatedButton(
            style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                backgroundColor: MaterialStateProperty.all<Color>(
                    Theme.of(context).primaryColorDark),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ))),
            onPressed: () {
              f();
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
