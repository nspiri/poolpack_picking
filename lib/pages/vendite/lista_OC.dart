import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:poolpack_picking/Model/ordini_fornitori.dart';
import 'package:poolpack_picking/Model/vendite.dart';
import 'package:poolpack_picking/pages/home.dart';
import 'package:poolpack_picking/pages/ordini/componenti/lista_articoli.dart';
import 'package:poolpack_picking/pages/ordini/componenti/lista_ordini.dart';
import 'package:poolpack_picking/pages/vendite/componenti/lista_vendite.dart';
import 'package:poolpack_picking/utils/dropdown.dart';
import 'package:poolpack_picking/utils/http.dart';
import 'package:poolpack_picking/utils/utils.dart';
import 'package:dartbag/collection.dart';

class ListaOC extends StatefulWidget {
  static const route = "/listaordiniclienti";
  const ListaOC({super.key});

  @override
  ListaOCState createState() => ListaOCState();
}

const List<Widget> ordineUbicazione = <Widget>[
  Text('Ordine'),
  Text('Ubicazione'),
];

class ListaOCState extends State<ListaOC> {
  bool isLoading = false;
  Http http = Http();
  List<DocumentoOF> documenti = [];
  List<Articolo> articoli = [];
  List<Zona> zone = [];
  Zona? zonaSelezionata;

  final List<bool> ordineUbicazioneSelezionato = <bool>[true, false];
  bool visualizzaListaOrdini = true;
  bool isShowing = false;
  bool mostraPulsanteEvadi = false;

  @override
  void initState() {
    super.initState();
    getZone();
  }

  refresh() {
    setState(() {});
  }

  getZone() {
    isLoading = true;
    setState(() {});
    int? a = zonaSelezionata?.id!;
    zonaSelezionata = null;
    http.getZone().then((value) {
      isLoading = false;
      zone = value;
      if (a != null) {
        zonaSelezionata = cercaZona(a);
      }
      setState(() {});
    });
  }

  Zona? cercaZona(int id) {
    for (var z in zone) {
      if (id == z.id) {
        return z;
      }
    }
    return null;
  }

  getDocumenti(int? zona) {
    isLoading = true;
    setState(() {});
    http.getVendite(zona!).then((value) {
      isLoading = false;
      documenti = ordinaDocumenti(value);
      getListaArticoliFromDocumenti();
      setState(() {});
    });
  }

  setLoading(bool val) {
    isLoading = val;
    setState(() {});
  }

  ordinaDocumenti(List<DocumentoOF> docs) {
    for (var c = 0; c < docs.length; c++) {
      docs[c].articoli?.sort((a, b) {
        int percorso = b.percorso!.compareTo(a.percorso!);
        int codArt = b.codiceArticolo!.compareTo(a.codiceArticolo!);
        int prTaglia = b.prgTaglia!.compareTo(a.prgTaglia!);
        if (percorso == 0) {
          if (codArt == 0) {
            return -prTaglia;
          }
          return -codArt;
        }
        if (codArt == 0) {
          return -prTaglia;
        }
        return -percorso;
      });
    }
    return docs;
  }

  getListaArticoliFromDocumenti() {
    articoli = [];
    for (var c = 0; c < documenti.length; c++) {
      for (var i = 0; i < documenti[c].articoli!.length; i++) {
        documenti[c].articoli![i].documento =
            "${documenti[c].documento} ${documenti[c].serie}/${documenti[c].numero}";
      }
      articoli.addAll(documenti[c].articoli!);
    }
    articoli.sort((a, b) {
      int percorso = b.percorso!.compareTo(a.percorso!);
      int codArt = b.codiceArticolo!.compareTo(a.codiceArticolo!);
      int prTaglia = b.prgTaglia!.compareTo(a.prgTaglia!);
      if (percorso == 0) {
        if (codArt == 0) {
          return -prTaglia;
        }
        return -codArt;
      }
      if (codArt == 0) {
        return -prTaglia;
      }
      return -percorso;
    });
  }

  aggiornaDocumenti() {
    getDocumenti(zonaSelezionata!.id!);
    getZone();
  }

  apriDialogEvadiDocumenti() {
    showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("Vuoi evadere tutti i documenti?"),
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
              evadiOrdini();
              Navigator.pop(c, true);
            },
          ),
        ],
      ),
    );
  }

  evadiOrdini() {
    List<EvadiDocumento> dati = [];
    for (int c = 0; c < documenti.length; c++) {
      EvadiDocumento doc = EvadiDocumento(
        dataTras: DateFormat("yyyyMMdd").format(DateTime.now()),
        documento: "OC",
        documentoTras: "",
        serie: documenti[c].serie,
        numero: documenti[c].numero,
        numeroTras: 0,
      );
      dati.add(doc);
    }

    isLoading = true;
    setState(() {});
    http.evadiDocumenti(dati, context).then((value) {
      if (value) {
        showSuccessMessage(context, "Ordini cliente evasi");
      }
      aggiornaDocumenti();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Ordini cliente"),
          bottom: TabBar(
            tabs: const [
              Tab(
                text: "Documento",
              ),
              Tab(
                text: "Ubicazione",
              ),
            ],
            indicatorColor: Theme.of(context).primaryColorDark,
            labelColor: Colors.white,
          ),
          actions: [
            IconButton(
                onPressed: () {
                  if (documenti.isNotEmpty) {
                    if (controlloOrdiniCompletati(documenti)) {
                      apriDialogEvadiDocumenti();
                    } else {
                      showErrorMessage(
                          context, "Alcuni ordini non sono completi");
                    }
                  }
                },
                icon: const Icon(Icons.send))
          ],
        ),
        body: TabBarView(
          children: [lista(true), lista(false)],
        ),
      ),
    );
  }

  Widget lista(bool isOC) {
    return Stack(
      children: [
        Expanded(
          child: Column(
            children: [
              filtroZone(),
              Visibility(
                  visible: isOC,
                  child: Expanded(
                      child: ListaVendite(
                    documenti: documenti,
                    getDocumenti: aggiornaDocumenti,
                  ))),
              Visibility(
                visible: !isOC,
                child: Expanded(
                  child: ListaArticoli(
                      articoli: articoli, //
                      visualizzaDatiOrdine: false,
                      documento: null, //
                      listaDocumenti: documenti,
                      controlloOrdineCompleto: () {
                        articoli = [];
                        getDocumenti(zonaSelezionata!.id!);
                      },
                      setDocumento: (DocumentoOF d) {},
                      isOF: false,
                      setLoading: setLoading,
                      isUbicazione: true),
                ),
              ),
            ],
          ),
        ),
        loading()
      ],
    );
  }

  Widget filtroZone() {
    return Padding(
        padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
        child: CustomDropdownButton<Zona>(
            nome: "Seleziona zona",
            items: zone.map<DropdownMenuItem<Zona>>((Zona value) {
              return DropdownMenuItem<Zona>(
                value: value,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      value.descrizione!,
                      style: const TextStyle(fontSize: 12),
                    ),
                    Text(
                      value.documenti.toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              );
            }).toList(),
            selectedItemBuilder: zone.map<Widget>((Zona item) {
              return Text(
                item.descrizione!,
                style: const TextStyle(fontSize: 12),
              );
            }).toList(),
            value: zonaSelezionata,
            onChanged: (Zona newValue) {
              setState(() {
                zonaSelezionata = newValue;
                getDocumenti(zonaSelezionata!.id!);
              });
            }));
  }

  Widget cardFiltri() {
    return Padding(
      padding: const EdgeInsets.only(top: 5, left: 5, right: 5),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: Column(
            children: [
              ExpansionTile(
                initiallyExpanded: true,
                leading: Icon(
                  Icons.filter_alt,
                  color: Theme.of(context).primaryColorDark,
                  size: 40,
                ),
                title: const Text(
                  'Filtri di ricerca',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                childrenPadding: const EdgeInsets.only(bottom: 10),
                children: [
                  Padding(
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 15),
                      child: CustomDropdownButton<Zona>(
                          nome: "Seleziona zona",
                          items: zone.map<DropdownMenuItem<Zona>>((Zona value) {
                            return DropdownMenuItem<Zona>(
                              value: value,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    value.descrizione!,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  Text(
                                    value.documenti.toString(),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                            );
                          }).toList(),
                          selectedItemBuilder: zone.map<Widget>((Zona item) {
                            return Text(
                              item.descrizione!,
                              style: const TextStyle(fontSize: 12),
                            );
                          }).toList(),
                          value: zonaSelezionata,
                          onChanged: (Zona newValue) {
                            setState(() {
                              zonaSelezionata = newValue;
                            });
                          })),
                  button("Cerca", () {
                    if (zonaSelezionata != null) {
                      getDocumenti(zonaSelezionata!.id!);
                    }
                  })
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget button(String titolo, Function() f) {
    return ConstrainedBox(
      constraints:
          const BoxConstraints(minWidth: double.infinity, minHeight: 40),
      child: Padding(
        padding: const EdgeInsets.only(
          left: 10,
          right: 10,
        ),
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

  /* Widget switchButton() {
    return ToggleButtons(
      direction: Axis.vertical,
      onPressed: (int index) {
        setState(() {
          for (int i = 0; i < ordineUbicazioneSelezionato.length; i++) {
            ordineUbicazioneSelezionato[i] = i == index;
          }
          if (ordineUbicazioneSelezionato[0] == true) {
            visualizzaListaOrdini = true;
          } else {
            visualizzaListaOrdini = false;
          }
        });
      },
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      selectedBorderColor: Colors.white,
      selectedColor: Colors.white,
      fillColor: Theme.of(context).primaryColorDark,
      color: Colors.grey.shade400,
      borderColor: Colors.grey.shade400,
      constraints: const BoxConstraints(
        minHeight: 20.0,
        minWidth: 70.0,
      ),
      isSelected: ordineUbicazioneSelezionato,
      children: ordineUbicazione,
    );
  }*/

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
