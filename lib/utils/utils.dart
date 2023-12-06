import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:poolpack_picking/Model/magazzino.dart';
import 'package:poolpack_picking/Model/ordini_fornitori.dart';
import 'package:poolpack_picking/utils/global.dart';
import 'package:poolpack_picking/utils/http.dart';
import 'dart:math' as math;

void showErrorMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      elevation: 0,
      content: Container(
          padding: const EdgeInsets.only(top: 16, bottom: 16, left: 8),
          //height: 80,
          decoration: const BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.all(Radius.circular(20))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                message,
                style: const TextStyle(fontSize: 14, color: Colors.white),
              ),
            ],
          )),
    ),
  );
}

void showSuccessMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      elevation: 0,
      content: Container(
          padding: const EdgeInsets.only(top: 16, bottom: 16, left: 8),
          //height: 80,
          decoration: const BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.all(Radius.circular(20))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                message,
                style: const TextStyle(fontSize: 14, color: Colors.white),
              ),
            ],
          )),
    ),
  );
}

Ubicazione? getUbicazione(int id) {
  for (var ubicazione in ubicazioni) {
    if (ubicazione.id == id) {
      return ubicazione;
    }
  }
  return Ubicazione(codice: "");
}

Ubicazione? getUbicazioneFromCode(String codice) {
  for (var ubicazione in ubicazioni) {
    if (ubicazione.codice == codice) {
      return ubicazione;
    }
  }
  return Ubicazione(codice: "");
}

controlloOrdiniCompletati(List<DocumentoOF> lista) {
  for (int c = 0; c < lista.length; c++) {
    if (controlloOrdineCompletoa(lista[c]) == false) {
      return false;
    }
  }
  return true;
}

controlloOrdiniCompletatia(List<DocumentoOF> lista) {
  for (int c = 0; c < lista.length; c++) {
    if (controlloOrdineCompleto(lista[c]) == false) {
      return false;
    }
  }
  return true;
}

controlloOrdineCompletoa(DocumentoOF documento) {
  int numeroArticoliCompleti = 0;

  for (int c = 0; c < documento.articoli!.length; c++) {
    Articolo art = documento.articoli![c];
    if (art.picking != null) {
      if (art.picking!.stato != " ") {
        if (art.picking!.stato == "<" || art.picking!.stato == ">") {
        } else {
          numeroArticoliCompleti += 1;
        }
      }
    }
  }

  if (numeroArticoliCompleti == documento.articoli?.length) {
    return true;
  }
  return false;
}

controlloOrdineCompleto(DocumentoOF documento) {
  int numeroArticoliCompleti = 0;

  for (int c = 0; c < documento.articoli!.length; c++) {
    Articolo art = documento.articoli![c];
    if (art.picking != null) {
      if (art.picking!.stato != " ") {
        numeroArticoliCompleti += 1;
      }
    }
  }

  if (numeroArticoliCompleti == documento.articoli?.length) {
    return true;
  }
  return false;
}

/*trovaArticoloSuccessivo(DocumentoOF doc, int index, Articolo articolo) {
  for (int c = 0; c < doc.articoli!.length; c++) {
    if (doc.articoli![c].rigo == articolo.rigo) {
      if (!(c + 1 >= doc.articoli!.length)) {
        var num = c + 1;
        for (var i = num; i < doc.articoli!.length; i++) {
          if (doc.articoli![num].picking != null) {
            if (doc.articoli![num].picking!.stato != "=") {
              return i;
            }
          } else {
            return i;
          }
        }
      }
    }
  }
  return 0;
}*/

int trovaArticoloSuccessivo(DocumentoOF doc, int index, Articolo articolo) {
  int primoRosso = 0;
  bool fatto = false;
  for (int c = 0; c < doc.articoli!.length; c++) {
    if (doc.articoli![c].rigo == articolo.rigo) {
      if (!(c + 1 >= doc.articoli!.length)) {
        var num = c + 1;
        for (var i = 0; i < doc.articoli!.length; i++) {
          if (doc.articoli![i].picking == null) {
            return i;
          } else {
            if (doc.articoli![i].picking!.stato != "=") {
              if (!fatto) {
                primoRosso = i;
                fatto = true;
              }
            }
          }
        }
      }
    }
  }
  return primoRosso;
}

trovaOrdineSuccessivo(List<DocumentoOF> lista, DocumentoOF documento) {
  for (int c = 0; c < lista.length; c++) {
    if (lista[c].serie == documento.serie &&
        lista[c].numero == documento.numero) {
      if (!(c + 1 >= lista.length)) {
        var num = c + 1;
        for (var i = num; i < lista.length; i++) {
          if (!controlloOrdineCompleto(lista[num])) {
            return i;
          }
        }
      }
    }
  }
  return 0;
}

int articoloSuccessivo(int index, List<Articolo> articoli, Articolo articolo) {
  int primoRosso = 0;
  bool fatto = false;
  for (var c = index + 1; c < articoli.length; c++) {
    if (articoli[c].picking == null) {
      return c;
    } else {
      if (articoli[c].picking!.stato != "=" &&
          articoli[c].picking!.stato != "#") {
        if (!fatto) {
          primoRosso = c;
          fatto = true;
        }
      }
    }
  }
  for (var c = 0; c < index; c++) {
    if (articoli[c].picking == null) {
      return c;
    } else {
      if (articoli[c].picking!.stato != "=" &&
          articoli[c].picking!.stato != "#") {
        if (!fatto) {
          primoRosso = c;
          fatto = true;
        }
      }
    }
  }
  return primoRosso;
}

apriDialogConferma(
    BuildContext context,
    DocumentoOF documento,
    int inde,
    Articolo articolo,
    Function(int index) setArticolo,
    List<Articolo> listaArticoli) {
  showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      title: const Text("Passare all'articolo successivo?"),
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
            Navigator.pop(c, true);
          },
        ),
      ],
    ),
  ).then((value) {
    if (value == true) {
      //int index = trovaArticoloSuccessivo(documento, inde, articolo);
      int index = articoloSuccessivo(inde, listaArticoli, articolo);
      setArticolo(index);
    }
  });
}

apriDialogConfermaOrdineCompletato(BuildContext context,
    List<DocumentoOF> lista, DocumentoOF documento, Function() tornaIndietro) {
  showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      title: const Text('Ordine completato.'),
      //content: const Text("Vuoi passare all'ordine successivo?"),
      actions: [
        /*  TextButton(
          child: const Text('No'),
          onPressed: () {
            //isShowing = false;
            Navigator.pop(c, false);
          },
        ),*/
        TextButton(
          child: const Text('Ok'),
          onPressed: () {
            // DocumentoOF a = lista[trovaOrdineSuccessivo(lista, documento)];
            tornaIndietro();
            Navigator.pop(c, false);
          },
        ),
      ],
    ),
  );
}

apriDialogConfermaOrdineCompletatoOF(
    BuildContext context, Function() tornaIndietro) {
  showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      title: const Text('Ordine completato.'),
      actions: [
        TextButton(
          child: const Text('Ok'),
          onPressed: () {
            tornaIndietro();
            Navigator.pop(c, false);
          },
        ),
      ],
    ),
  );
}

apriDialogOrdiniCompletati(BuildContext context) {
  showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      title: const Text('Ordini completati.'),
      content: const Text("Tutti gli ordini sono stati completati."),
      actions: [
        TextButton(
          child: const Text('Ok'),
          onPressed: () {
            Navigator.pop(c, false);
            Navigator.pop(c, false);
          },
        ),
      ],
    ),
  );
}

apriDialogAssociaAlias(BuildContext context, Articolo articolo,
    Function(bool loading) setLoading, Function() chiudiTastiera) {
  Http http = Http();
  TextEditingController codiceAlias = TextEditingController();
  TextEditingController q = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      title: const Text('Associa codice alias'),
      content: SingleChildScrollView(
        child: ListBody(
          children: [
            const SizedBox(
              height: 8,
            ),
            TextField(
              autofocus: true,
              controller: codiceAlias,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black,
              ),
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), labelText: "Codice alias"),
            ),
            Visibility(
              visible: articolo.prgTaglia == 0,
              child: const SizedBox(
                height: 8,
              ),
            ),
            Visibility(
              visible: articolo.prgTaglia == 0,
              child: TextField(
                controller: q,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                ),
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), labelText: "Quantità"),
              ),
            ),
          ],
        ),
      ),
      contentPadding: const EdgeInsets.only(bottom: 0, left: 8, right: 8),
      titlePadding: const EdgeInsets.only(bottom: 8, top: 8, left: 8),
      actions: [
        TextButton(
          child: const Text('Annulla'),
          onPressed: () {
            //isShowing = false;
            chiudiTastiera();
            Navigator.pop(c, false);
          },
        ),
        TextButton(
          child: const Text('Associa'),
          onPressed: () {
            setLoading(true);
            var quantita = articolo.confezione;
            if (articolo.prgTaglia == 0) {
              if (q.text != "") {
                quantita = double.parse(q.text);
              }
            }
            http
                .associaAlias(codiceAlias.text, articolo.codiceArticolo!,
                    articolo.prgTaglia!, quantita ?? 0)
                .then((value) {
              if (value) {
                showSuccessMessage(context, "Alias associato corettamente");
              } else {
                showErrorMessage(context, "Si è verificato un errore");
              }

              setLoading(false);
            });
            chiudiTastiera();
            Navigator.pop(c, true);
          },
        ),
      ],
    ),
  );
}

apriDialogCreaEAN(BuildContext context, Articolo articolo,
    Function(bool loading) setLoading, Function() chiudiTastiera) {
  Http http = Http();
  showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      title: const Text('Vuoi generare un codice EAN per questo articolo?'),
      actions: [
        TextButton(
          child: const Text('No'),
          onPressed: () {
            chiudiTastiera();
            Navigator.pop(c, false);
          },
        ),
        TextButton(
          child: const Text('Si'),
          onPressed: () {
            setLoading(true);
            http.creaEAN(articolo.codiceArticolo!, context).then((value) {
              setLoading(false);
              chiudiTastiera();
            });
            Navigator.pop(c, true);
          },
        ),
      ],
    ),
  );
}

apriDialogStampaEtichetta(BuildContext context, Articolo articolo,
    Function(bool loading) setLoading, Function() chiudiTastiera) {
  Http http = Http();
  showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      title: const Text(
          "Vuoi inviare una stampa dell'etichetta per questo articolo?"),
      actions: [
        TextButton(
          child: const Text('No'),
          onPressed: () {
            chiudiTastiera();
            Navigator.pop(c, false);
          },
        ),
        TextButton(
          child: const Text('Si'),
          onPressed: () {
            setLoading(true);
            http
                .stampaEtichetta(articolo.codiceArticolo!, context)
                .then((value) {
              setLoading(false);
              chiudiTastiera();
            });
            Navigator.pop(c, true);
          },
        ),
      ],
    ),
  );
}

controlloArticoloCompleto(Articolo articolo) {
  var rosso = Colors.red;
  var grigio = Colors.grey;
  var verde = Colors.green;
  var giallo = Colors.yellow[700];

  if (articolo.picking != null) {
    if (articolo.picking!.stato == "=") {
      return verde;
    }
    if (articolo.picking!.stato == "#") {
      return giallo;
    }
    if (articolo.picking!.stato == ">" || articolo.picking!.stato == "<") {
      return rosso;
    }
    if (articolo.picking!.stato == " ") {
      return grigio;
    }
  } else {
    return grigio;
  }
}

apriDialogDatiBF(
    DocumentoOF documento,
    BuildContext context,
    Function(
            DocumentoOF documento, String dataDocumento, String numeroDocumento)
        evadiOrdine,
    Function() chiudiTastiera) {
  Http http = Http();
  TextEditingController numeroDocumento = TextEditingController();
  TextEditingController dataDocmento = TextEditingController();
  bool? scaricaUbiStandart = true;
  dataDocmento.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
  showDialog<bool>(
    context: context,
    builder: (c) => StatefulBuilder(builder: (context, setState) {
      return AlertDialog(
        title: const Text('Dati Bolla Fornitore'),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              const SizedBox(
                height: 8,
              ),
              TextField(
                autofocus: true,
                controller: numeroDocumento,
                keyboardType: TextInputType.number,
                maxLength: 6,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                ),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Numero documento",
                  counterText: "",
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: TextField(
                  controller: dataDocmento,
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                  decoration: const InputDecoration(
                      suffixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(),
                      labelText: "Data documento"),
                  readOnly: true,
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                        locale: const Locale("it", "IT"),
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1950),
                        lastDate: DateTime(2100));

                    if (pickedDate != null) {
                      String formattedDate =
                          DateFormat('dd-MM-yyyy').format(pickedDate);
                      setState(() {
                        dataDocmento.text = formattedDate;
                        /*getDocumenti(DateFormat("yyyyMMdd")
                      .format(DateFormat("dd-MM-yyyy").parse(data.text)));*/
                      });
                    } else {}
                  },
                ),
              ),
              CheckboxListTile(
                title: const Text("Ubicazione scarico"),
                value: scaricaUbiStandart,
                onChanged: (newValue) {
                  setState(() {
                    scaricaUbiStandart = newValue;
                  });
                },
                // controlAffinity:
                //   ListTileControlAffinity.leading, //  <-- leading Checkbox
              )
            ],
          ),
        ),
        contentPadding: const EdgeInsets.only(bottom: 0, left: 8, right: 8),
        titlePadding: const EdgeInsets.only(bottom: 8, top: 8, left: 8),
        actions: [
          TextButton(
            child: const Text('Annulla'),
            onPressed: () {
              Navigator.pop(c, false);
            },
          ),
          TextButton(
            child: const Text('Evadi'),
            onPressed: () {
              if (numeroDocumento.text == "") {
                showErrorMessage(context, "Inserisci un numero documento");
              } else {
                Navigator.pop(c, true);
              }
            },
          ),
        ],
      );
    }),
  ).then((val) {
    if (val == true) {
      evadiOrdine(documento, dataDocmento.text, numeroDocumento.text);
    }
    chiudiTastiera();
  });
}

class DecimalTextInputFormatter extends TextInputFormatter {
  DecimalTextInputFormatter({required this.decimalRange})
      : assert(decimalRange > 0);

  final int decimalRange;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue, // unused.
    TextEditingValue newValue,
  ) {
    TextSelection newSelection = newValue.selection;
    String truncated = newValue.text;

    if (decimalRange != null) {
      String value = newValue.text;

      if (value.contains(".") &&
          value.substring(value.indexOf(".") + 1).length > decimalRange) {
        truncated = oldValue.text;
        newSelection = oldValue.selection;
      } else if (value == ".") {
        truncated = "0.";

        newSelection = newValue.selection.copyWith(
          baseOffset: math.min(truncated.length, truncated.length + 1),
          extentOffset: math.min(truncated.length, truncated.length + 1),
        );
      }

      return TextEditingValue(
        text: truncated,
        selection: newSelection,
        composing: TextRange.empty,
      );
    }
    return newValue;
  }
}

String formatStringDecimal(double? value, int decimali) {
  return value
          ?.toStringAsFixed(value.truncateToDouble() == value ? 0 : decimali) ??
      "";
}
