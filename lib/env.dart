// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

String base_url = "";
String basicAuth = "";
String passAuth = "";
Map<String, String>? headers;
Map<String, String>? passHeaders;

setIp() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  base_url = prefs.getString("ip") ?? "";

  String user = prefs.getString("user") ?? "";
  String pass = prefs.getString("pass") ?? "";
  String sigla = prefs.getString("sigla") ?? "";

  basicAuth = 'Basic ${base64.encode(utf8.encode('$user:$pass'))}';
  headers = <String, String>{
    'Content-Type': 'application/json; charset=UTF-8',
    HttpHeaders.authorizationHeader: basicAuth
  };
  String currentYear = DateTime.now().year.toString();
  passAuth = 'Passepartout ${base64Encode(utf8.encode('$user:$pass'))}';
  passHeaders = <String, String>{
    'Content-Type': 'application/json; charset=UTF-8',
    "Coordinate-Gestionale": "Azienda=$sigla Anno=$currentYear",
    "Authorization": passAuth
  };
}
