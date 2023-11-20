import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:poolpack_picking/Model/ordini_fornitori.dart';
import 'package:poolpack_picking/pages/ordini/componenti/lista_ordini.dart';
import 'package:poolpack_picking/utils/http.dart';

class ListaOF extends StatefulWidget {
  static const route = "/listaordini";
  const ListaOF({super.key});

  @override
  ListaOFState createState() => ListaOFState();
}

class ListaOFState extends State<ListaOF> {
  TextEditingController data = TextEditingController();
  bool isLoading = false;
  Http http = Http();
  List<DocumentoOF> documenti = [];

  @override
  void initState() {
    super.initState();
    data.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
    getDocumenti(DateFormat("yyyyMMdd")
        .format(DateFormat("dd-MM-yyyy").parse(data.text)));
  }

  refresh() {
    setState(() {});
  }

  getDocumenti(String data) {
    isLoading = true;
    setState(() {});
    http.getOrdini(data).then((value) {
      isLoading = false;
      documenti = value;
      documenti.sort((a, b) {
        return DateFormat("yyyy-MM-dd")
            .parse(a.scadenza!)
            .compareTo(DateFormat("yyyy-MM-dd").parse(b.scadenza!));
      });
      setState(() {});
    });
  }

  aggiornaDocumenti() {
    getDocumenti(DateFormat("yyyyMMdd")
        .format(DateFormat("dd-MM-yyyy").parse(data.text)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ordini fornitore")),
      body: Stack(
        children: [
          Expanded(
            child: Container(
              child: Column(
                children: [
                  //cardFiltri(),
                  campoData(),
                  Expanded(
                      child: ListaOrdiniFornitore(
                    documenti: documenti,
                    getDocumenti: aggiornaDocumenti,
                  ))
                ],
              ),
            ),
          ),
          loading()
        ],
      ),
    );
  }

  Widget campoData() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
      child: TextField(
        controller: data,
        style: const TextStyle(
          color: Colors.black,
        ),
        decoration: const InputDecoration(
            suffixIcon: Icon(Icons.calendar_today),
            border: OutlineInputBorder(),
            labelText: "Data scadenza"),
        readOnly: true,
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
              locale: const Locale("it", "IT"),
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(1950),
              lastDate: DateTime(2100));

          if (pickedDate != null) {
            String formattedDate = DateFormat('dd-MM-yyyy').format(pickedDate);
            setState(() {
              data.text = formattedDate;
              getDocumenti(DateFormat("yyyyMMdd")
                  .format(DateFormat("dd-MM-yyyy").parse(data.text)));
            });
          } else {}
        },
      ),
    );
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
                    child: TextField(
                      controller: data,
                      style: const TextStyle(
                        color: Colors.black,
                      ),
                      decoration: const InputDecoration(
                          suffixIcon: Icon(Icons.calendar_today),
                          border: OutlineInputBorder(),
                          labelText: "Data scadenza"),
                      readOnly: true,
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1950),
                            lastDate: DateTime(2100));

                        if (pickedDate != null) {
                          String formattedDate =
                              DateFormat('dd-MM-yyyy').format(pickedDate);
                          setState(() {
                            data.text = formattedDate;
                          });
                        } else {}
                      },
                    ),
                  ),
                  button(
                      "Cerca",
                      () => getDocumenti(DateFormat("yyyyMMdd")
                          .format(DateFormat("dd-MM-yyyy").parse(data.text))))
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
