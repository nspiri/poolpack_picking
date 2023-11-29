import 'package:flutter/material.dart';
import 'package:poolpack_picking/pages/controllo%20giacenze/componenti/lista_articoli.dart';
import 'package:poolpack_picking/pages/home.dart';

class ControlloGiacenze extends StatefulWidget {
  static const route = "/controllogiacenze";
  const ControlloGiacenze({super.key});

  @override
  ControlloGiacenzeState createState() => ControlloGiacenzeState();
}

class ControlloGiacenzeState extends State<ControlloGiacenze>
    with TickerProviderStateMixin {
  late TabController controller;
  TextEditingController codice = TextEditingController();
  GlobalKey<ListaArticoliGState> globalKey = GlobalKey();
  GlobalKey<ListaArticoliGState> globalKey2 = GlobalKey();
  @override
  void initState() {
    super.initState();
    controller = TabController(vsync: this, length: 2);
    controller.addListener(() {
      globalKey.currentState?.setFocus();
      globalKey2.currentState?.setFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Controllo giacenze"),
          bottom: TabBar(
            // controller: controller,
            tabs: const [
              Tab(
                text: "Articolo",
              ),
              Tab(
                text: "Ubicazione",
              ),
            ],
            indicatorColor: Theme.of(context).primaryColorDark,
            labelColor: Colors.white,
          ),
        ),
        body: TabBarView(
          // controller: controller,
          children: [
            ListaArticoliG(isCercaArticolo: true, key: globalKey),
            ListaArticoliG(isCercaArticolo: false, key: globalKey2)
          ],
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
