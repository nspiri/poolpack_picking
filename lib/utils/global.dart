// ignore_for_file: non_constant_identifier_names

library my_prj.globals;

import 'package:flutter/material.dart';
import 'package:poolpack_picking/Model/login_data.dart';
import 'package:poolpack_picking/Model/magazzino.dart';
import 'package:poolpack_picking/pages/articolo/ubicazioni.dart';

bool isLoggedIn = false;
Utente? utente_selezionato;
List<Magazzino> magazzini = [];
List<Ubicazione> ubicazioni = [];
List<ArticoloLista> articoli = [];
String idUbicazioneScarico = "";
int numeroStampante = 0;
