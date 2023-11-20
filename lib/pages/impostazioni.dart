// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:poolpack_picking/Pages/login.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:poolpack_picking/env.dart';
import 'package:poolpack_picking/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ImpostazioniPage extends StatefulWidget {
  static const route = "/impostazioni";
  const ImpostazioniPage({super.key});

  @override
  ImpostazioniPageState createState() => ImpostazioniPageState();
}

class ImpostazioniPageState extends State<ImpostazioniPage> {
  bool isLoading = false;
  bool isShowing = false;
  final controlloIp = TextEditingController();
  final controlloUser = TextEditingController();
  final controlloPassword = TextEditingController();
  final numeroStampante = TextEditingController();
  final codUbicazioneScarico = TextEditingController();
  final siglaAzienza = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    BackButtonInterceptor.add(myInterceptor);
    getIp();
    super.initState();
  }

  getIp() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    controlloIp.text = prefs.getString("ip") ?? "";
    controlloUser.text = prefs.getString("user") ?? "";
    controlloPassword.text = prefs.getString("pass") ?? "";
    numeroStampante.text = prefs.getString("numStamp") ?? "";
    codUbicazioneScarico.text = prefs.getString("codUbi") ?? "";
    siglaAzienza.text = prefs.getString("sigla") ?? "";
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    Navigator.pushNamed(context, Login.route);
    return true;
  }

  salvaIp(String ip, String user, String pass, String numStampante,
      String codiceUbicazione, String sigla) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("ip", ip);
    prefs.setString("user", user);
    prefs.setString("pass", pass);
    prefs.setString("numStamp", numStampante);
    prefs.setString("codUbi", codiceUbicazione);
    prefs.setString("sigla", sigla);
    setIp();
    showSuccessMessage(context, "Dati salvati correttamente");
  }

  @override
  Widget build(BuildContext context) {
    return scaffold();
  }

  Widget scaffold() {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Impostazioni"),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: controlloIp,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Ip',
                      hintText: "Inserisci l'ip del server"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Il campo Ip non può essere vuoto';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: controlloUser,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'User',
                      hintText: "Inserisci l'user del server"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Il campo User non può essere vuoto';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: controlloPassword,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Password',
                      hintText: "Inserisci la password del server"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Il campo Password non può essere vuoto';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: siglaAzienza,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Sigla azienza',
                      hintText: "Inserisci la sigla dell'azienda"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Il campo non può essere vuoto';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: numeroStampante,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Numero stampante',
                      hintText: "Inserisci il numero della stampante"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Il campo non può essere vuoto';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: codUbicazioneScarico,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Codice ubicazione carico',
                      hintText: "Inserisci il codice ubicazione"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Il campo non può essere vuoto';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(bottom: 100, left: 50, right: 50),
                child: Container(
                  height: 50,
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  decoration: BoxDecoration(
                      color: Theme.of(context).primaryColorDark,
                      borderRadius: BorderRadius.circular(10)),
                  child: TextButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        salvaIp(
                            controlloIp.text,
                            controlloUser.text,
                            controlloPassword.text,
                            numeroStampante.text,
                            codUbicazioneScarico.text,
                            siglaAzienza.text);
                      }
                    },
                    child: const Text(
                      'Salva',
                      style: TextStyle(color: Colors.white, fontSize: 25),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
