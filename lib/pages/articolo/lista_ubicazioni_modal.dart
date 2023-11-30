import 'package:flutter/material.dart';
import 'package:poolpack_picking/Model/magazzino.dart';
import 'package:poolpack_picking/utils/global.dart';

class FullScreenSearchModal extends ModalRoute {
  final Ubicazione? ubicazioneSel;
  final Ubicazione? ubicazionePredefinita;
  FullScreenSearchModal(
      {required this.ubicazioneSel, required this.ubicazionePredefinita});

  @override
  Duration get transitionDuration => const Duration(milliseconds: 500);

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => false;

  @override
  Color get barrierColor => Colors.black.withOpacity(0.6);

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  TextEditingController cerca = TextEditingController();
  List<Ubicazione> ubicazioniFiltrate = ubicazioni;

  List<Ubicazione> ordinaUbicazioni(List<Ubicazione> ubi) {
    for (var i = 0; i < ubi.length; i++) {
      if (ubi[i].id == ubicazionePredefinita?.id) {
        var ubiTemp = ubi[i];
        ubi.remove(ubi[i]);
        ubi.insert(0, ubiTemp);
      }
    }
    return ubi;
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    ubicazioniFiltrate.sort((a, b) {
      return a.codice!.toLowerCase().compareTo(b.codice!.toLowerCase());
    });
    for (var i = 0; i < ubicazioniFiltrate.length; i++) {
      if (ubicazioniFiltrate[i].id == ubicazionePredefinita?.id) {
        var ubiTemp = ubicazioniFiltrate[i];
        ubicazioniFiltrate.remove(ubicazioniFiltrate[i]);
        ubicazioniFiltrate.insert(0, ubiTemp);
      }
    }
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // implement the search field
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextField(
                      controller: cerca,
                      autofocus: true,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 20),
                        filled: true,
                        fillColor: Colors.grey.shade300,
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            cerca.text = "";
                            ubicazioniFiltrate = ubicazioni
                                .where((item) =>
                                    item.codice!.toLowerCase().contains(""))
                                .toList();
                            changedExternalState();
                          },
                        ),
                        hintText: 'Cerca',
                        border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(30)),
                      ),
                      onChanged: (value) {
                        ubicazioniFiltrate = ubicazioni
                            .where((item) => item.codice!
                                .toLowerCase()
                                .contains(value.toLowerCase()))
                            .toList();
                        changedExternalState();
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  TextButton(
                      onPressed: () => Navigator.of(context).pop(null),
                      child: const Text('Esci'))
                ],
              ),

              const SizedBox(
                height: 20,
              ),
              const Padding(
                padding: EdgeInsets.only(left: 5, bottom: 5),
                child: Text('Ubicazioni',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: ubicazioniFiltrate.length,
                  itemBuilder: (context, index) {
                    return Container(
                      color: (index % 2 == 0)
                          ? Colors.grey.shade200
                          : Colors.white,
                      child: ListTile(
                        title: Text(
                          ubicazioniFiltrate[index].codice!,
                          style: TextStyle(
                              color: ubicazioniFiltrate[index].id ==
                                      ubicazioneSel?.id
                                  ? Colors.grey
                                  : ubicazioniFiltrate[index].id ==
                                          ubicazionePredefinita?.id
                                      ? Colors.green
                                      : Colors.black,
                              fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          ubicazioniFiltrate[index].descrizione!,
                          style: TextStyle(
                              color: ubicazioniFiltrate[index].id ==
                                      ubicazioneSel?.id
                                  ? Colors.grey
                                  : ubicazioniFiltrate[index].id ==
                                          ubicazionePredefinita?.id
                                      ? Colors.green
                                      : Colors.black,
                              fontSize: 12),
                        ),
                        onTap: () {
                          if (ubicazioniFiltrate[index].id !=
                              ubicazioneSel?.id) {
                            Navigator.of(context)
                                .pop(ubicazioniFiltrate[index]);
                          }
                        },
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    // add fade animation
    return FadeTransition(
      opacity: animation,
      // add slide animation
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -1),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }
}
