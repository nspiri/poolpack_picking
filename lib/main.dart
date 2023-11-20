import 'dart:io';

import 'package:flutter/material.dart';
import 'package:poolpack_picking/Model/magazzino.dart';
import 'package:poolpack_picking/Model/ordini_fornitori.dart';
import 'package:poolpack_picking/pages/articolo/anagrafica_articolo.dart';
import 'package:poolpack_picking/pages/controllo%20giacenze/controllo_giacenze.dart';
import 'package:poolpack_picking/pages/home.dart';
import 'package:poolpack_picking/pages/impostazioni.dart';
import 'package:poolpack_picking/pages/ordini/lista_ART.dart';
import 'package:poolpack_picking/pages/ordini/lista_OF.dart';
import 'package:poolpack_picking/pages/login.dart';
import 'package:poolpack_picking/pages/vendite/lista_OC.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [GlobalMaterialLocalizations.delegate],
      supportedLocales: const [
        Locale('it'),
      ],
      initialRoute: "/",
      debugShowCheckedModeBanner: false,
      onGenerateRoute: (settings) {
        final routes = {
          Login.route: (context) => const Login(),
          ImpostazioniPage.route: (context) => const ImpostazioniPage(),
          HomePage.route: (context) => const HomePage(),
          ListaOF.route: (context) => const ListaOF(),
          PaginaListaArticoli.route: (context) => PaginaListaArticoli(
                ordine: settings.arguments as PassaggioDatiOrdini,
              ),
          AnagraficaArticolo.route: (context) => AnagraficaArticolo(
                dati: settings.arguments as PassaggioDatiArticolo,
              ),
          ControlloGiacenze.route: (context) => const ControlloGiacenze(),
          ListaOC.route: (context) => const ListaOC(),
        };
        return MaterialPageRoute(builder: routes[settings.name]!);
      },
      title: 'Flutter Demo',
      theme: lightTheme(),
      home: const Login(),
    );
  }
}

ThemeData lightTheme() {
  return ThemeData(
      primarySwatch: MaterialColor(0xFF252850, color), //0xFFf0a213
      primaryColor: MaterialColor(0xFF252850, color),
      primaryColorDark: MaterialColor(0xFF252850, color),
      textTheme: const TextTheme(headline1: TextStyle(color: Colors.white)));
}

Map<int, Color> color = {
  50: const Color.fromRGBO(51, 166, 76, .1),
  100: const Color.fromRGBO(51, 166, 76, .2),
  200: const Color.fromRGBO(51, 166, 76, .3),
  300: const Color.fromRGBO(51, 166, 76, .4),
  400: const Color.fromRGBO(51, 166, 76, .5),
  500: const Color.fromRGBO(51, 166, 76, .6),
  600: const Color.fromRGBO(51, 166, 76, .7),
  700: const Color.fromRGBO(51, 166, 76, .8),
  800: const Color.fromRGBO(51, 166, 76, .9),
  900: const Color.fromRGBO(51, 166, 76, 1),
};

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
