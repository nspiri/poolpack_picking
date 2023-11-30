import 'package:flutter/material.dart';
import 'package:poolpack_picking/Model/magazzino.dart';
import 'package:poolpack_picking/utils/global.dart';

class FullScreenSearchModalArticoli extends ModalRoute {
  FullScreenSearchModalArticoli();

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
  List<ArticoloLista> articoliFiltrati = articoli;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    articoliFiltrati.sort((a, b) {
      return a.codiceArticolo!
          .toLowerCase()
          .compareTo(b.codiceArticolo!.toLowerCase());
    });
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
                            articoliFiltrati = articoli
                                .where((item) => item.codiceArticolo!
                                    .toLowerCase()
                                    .contains(""))
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
                        articoliFiltrati = articoli
                            .where((item) =>
                                item.codiceArticolo!
                                    .toLowerCase()
                                    .contains(value.toLowerCase()) ||
                                item.descrizione!
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
                child: Text('Articoli',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: articoliFiltrati.length,
                  itemBuilder: (context, index) {
                    return Container(
                      color: (index % 2 == 0)
                          ? Colors.grey.shade200
                          : Colors.white,
                      child: ListTile(
                        title: Text(
                          articoliFiltrati[index].codiceArticolo!,
                          style: const TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          articoliFiltrati[index].descrizione!,
                          style: const TextStyle(
                              color: Colors.black, fontSize: 12),
                        ),
                        onTap: () {
                          Navigator.of(context).pop(articoliFiltrati[index]);
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
