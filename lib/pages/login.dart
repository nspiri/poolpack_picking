import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as hp;
import 'package:http/http.dart';
import 'package:poolpack_picking/Model/login_data.dart';
import 'package:poolpack_picking/Pages/home.dart';
import 'package:poolpack_picking/Pages/impostazioni.dart';
import 'package:poolpack_picking/utils/dropdown.dart';
import 'package:poolpack_picking/utils/global.dart';
import 'package:poolpack_picking/utils/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/utils.dart';
import 'package:ota_update/ota_update.dart';

class Login extends StatefulWidget {
  static const route = "/login";
  const Login({super.key});

  @override
  LoginDemoState createState() => LoginDemoState();
}

bool isLoading = false;
Http http = Http();

class LoginDemoState extends State<Login> {
  final controllerPassword = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  List<String> utenti = [];
  String? utenteSelezionato;
  Map<dynamic, dynamic> _packageUpdateUrl = {};
  OtaEvent? currentEvent;
  String currentVersion = "2023112701";

  @override
  void initState() {
    super.initState();
    //setIp();
    getUtenti();
    tryOtaUpdate();
  }

  Future<void> tryOtaUpdate() async {
    var url = Uri.parse("https://datasistemi.cloud/apk/poolpack/version1.txt");
    Response response = await hp.get(url);

    if (response.body != "") {
      try {
        int version = int.parse(response.body);
        int curVer = int.parse(currentVersion);
        if (version != curVer) {
          print('ABI Platform: ${await OtaUpdate().getAbi()}');
          OtaUpdate()
              .execute(
            'https://github.com/nspiri/poolpack_picking/releases/download/TRA/app-release.apk',
            destinationFilename: 'poolpack_picking.apk',
          )
              .listen(
            (OtaEvent event) {
              setState(() => currentEvent = event);
            },
          );
        }
      } catch (e) {
        print('Failed to make OTA update. Details: $e');
      }
    }
  }

  void validaCampi() {
    if (_formKey.currentState!.validate()) {
      if (utenteSelezionato != null) {
        doLogin();
      } else {
        showErrorMessage(context, "Seleziona un utente");
      }
    }
  }

  getUtenti() {
    isLoading = true;
    setState(() {});
    http.getUtenti(context).then((value) {
      isLoading = false;
      utenti = value;
      setState(() {});
    });
  }

  void doLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      isLoading = true;
    });
    http
        .doLogin(LoginData(
            username: utenteSelezionato!, password: controllerPassword.text))
        .then((value) {
      switch (value) {
        case "200":
          http.getMagazzini().then((value) {
            magazzini = value;
            http.getUbicazioni().then((value) {
              ubicazioni = value;
              http.getArticoli().then((value) {
                articoli = value;
                numeroStampante = int.parse(prefs.getString("numStamp") ?? "");
                idUbicazioneScarico = prefs.getString("codUbi").toString();
                isLoading = false;
                Navigator.pushNamed(context, HomePage.route);
                setState(() {});
              });
            });
          });

          break;
        case "401":
          isLoading = false;
          setState(() {});
          showErrorMessage(context, "Utente o password errati");
          break;
        case "403":
          isLoading = false;
          setState(() {});
          showErrorMessage(context, "Utente non attivo");
          break;
        case "404":
          isLoading = false;
          setState(() {});
          showErrorMessage(context,
              "La risorsa chiamata ha impiegato troppo tempo per rispondere");
          break;
        default:
          isLoading = false;
          setState(() {});
          showErrorMessage(context, "Si è verificato un errore");
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColorDark,
      body: Stack(children: [
        Align(
          alignment: Alignment.bottomRight,
          child: Text(
            'Versione: $currentVersion',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[Center(child: cardLogin())],
            ),
          ),
        ),
      ]),
    );
  }

  Widget cardLogin() {
    return Card(
      margin: const EdgeInsets.only(left: 20, right: 20),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      elevation: 10,
      child: Form(
        key: _formKey,
        child: Stack(alignment: Alignment.center, children: [
          Positioned(
            child: Column(children: [
              InkWell(
                  onLongPress: () {
                    Navigator.pushNamed(context, ImpostazioniPage.route);
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 20),
                    child: Image.asset(
                      'assets/logo.jpg',
                      width: 250,
                    ),
                  )),
              selectUtente(),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: TextFormField(
                  controller: controllerPassword,
                  obscureText: true,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Password',
                      hintText: 'Inserisci la password'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
                child: Container(
                  height: 50,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: Theme.of(context).primaryColorDark,
                      borderRadius: BorderRadius.circular(10)),
                  child: TextButton(
                    onPressed: () => validaCampi(),
                    child: const Text(
                      'Login',
                      style: TextStyle(color: Colors.white, fontSize: 25),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text('© 2023 DATA SISTEMI All Rights Reserved'),
              ),
              Text(
                  'OTA status: ${currentEvent?.status} : ${currentEvent?.value} \n')
            ]),
          ),
          Positioned.fill(child: loading())
        ]),
      ),
    );
  }

  Widget selectUtente() {
    return Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
        child: CustomDropdownButton<String>(
            nome: "Seleziona utente",
            items: utenti.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      value,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              );
            }).toList(),
            selectedItemBuilder: utenti.map<Widget>((String item) {
              return Text(
                item,
                style: const TextStyle(fontSize: 12),
              );
            }).toList(),
            value: utenteSelezionato,
            onChanged: (String newValue) {
              setState(() {
                utenteSelezionato = newValue;
              });
            }));
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
