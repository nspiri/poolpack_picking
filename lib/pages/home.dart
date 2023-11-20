import 'package:flutter/material.dart';
import 'package:poolpack_picking/Pages/login.dart';
import 'package:poolpack_picking/pages/controllo%20giacenze/controllo_giacenze.dart';
import 'package:poolpack_picking/pages/ordini/lista_OF.dart';
import 'package:poolpack_picking/pages/vendite/lista_OC.dart';

class HomePage extends StatefulWidget {
  static const route = "/home";
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  goToOF() {
    Navigator.pushNamed(context, ListaOF.route);
  }

  goToOC() {
    Navigator.pushNamed(context, ListaOC.route);
  }

  goToCG() {
    Navigator.pushNamed(context, ControlloGiacenze.route);
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Vuoi uscire dall'app?"),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Si'),
          ),
        ],
      ),
    ).then((value) {
      if (value) {
        Navigator.pushNamed(context, Login.route);
      }
      return value;
    }));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Home"),
          automaticallyImplyLeading: false,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.start, children: [
              button("Ordini fornitore", goToOF),
              button("Ordini cliente", goToOC),
              button("Controllo giacenze", goToCG)
            ]),
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

  refresh() {
    setState(() {});
  }
}
