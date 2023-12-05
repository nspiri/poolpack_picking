// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:poolpack_picking/Model/magazzino.dart';
import 'package:poolpack_picking/pages/articolo/anagrafica_articolo.dart';
import 'package:poolpack_picking/utils/http.dart';
import 'package:poolpack_picking/Model/ordini_fornitori.dart';
import 'package:poolpack_picking/utils/utils.dart';

class Indicatore extends StatefulWidget {
  final List<Articolo> articoli;
  final Function(String val) setColoreFiltro;
  const Indicatore(
      {super.key, required this.articoli, required this.setColoreFiltro});

  @override
  IndicatoreState createState() => IndicatoreState();
}

class IndicatoreState extends State<Indicatore> {
  Http http = Http();

  @override
  void initState() {
    super.initState();
  }

  List<Widget> contaArticoli() {
    double grigi = 0;
    double rossi = 0;
    double gialli = 0;
    double verdi = 0;
    List<Widget> lista = [];
    for (var art in widget.articoli) {
      if (art.picking != null) {
        if (art.picking!.stato == "=") {
          verdi++;
          continue;
        }
        if (art.picking!.stato == "#") {
          gialli++;
          continue;
        }
        if (art.picking!.stato == ">" || art.picking!.stato == "<") {
          rossi++;
          continue;
        }
      } else {
        grigi++;
        continue;
      }
    }

    if (verdi > 0) {
      lista.add(container(verdi.round(), Colors.green, "V"));
    }

    if (gialli > 0) {
      lista.add(container(gialli.round(), Colors.yellow.shade700, "GI"));
    }

    if (rossi > 0) {
      lista.add(container(rossi.round(), Colors.red, "R"));
    }

    if (grigi > 0) {
      lista.add(container(grigi.round(), Colors.grey, "GR"));
    }

    return lista;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.only(right: 10, left: 10, bottom: 8, top: 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ...contaArticoli(),
            ],
          ),
        ),
      ),
    );
  }

  Widget container(int nArt, Color colore, String col) {
    int flex = (nArt / widget.articoli.length * 10).round();
    if (flex < 2) flex = 2;
    return Expanded(
      flex: flex,
      child: InkWell(
        onTap: () {
          widget.setColoreFiltro(col);
        },
        child: Container(
          decoration: BoxDecoration(
            color: colore,
          ),
          height: 20,
          child: Center(
              child: Text(
            "$nArt/${widget.articoli.length}",
            style: const TextStyle(color: Colors.white),
          )),
        ),
      ),
    );
  }
}
