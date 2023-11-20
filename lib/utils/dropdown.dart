import 'package:flutter/material.dart';
import 'package:poolpack_picking/Model/vendite.dart';

class CustomDropdownButton<T> extends StatelessWidget {
  final List<DropdownMenuItem<T>>? items;
  final List<Widget> selectedItemBuilder;
  final T? value;
  final Function(T) onChanged;
  final String nome;

  const CustomDropdownButton(
      {super.key,
      this.items,
      this.value,
      required this.onChanged,
      this.nome = 'Seleziona',
      required this.selectedItemBuilder});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: DropdownButtonHideUnderline(
        child: ButtonTheme(
          alignedDropdown: true,
          child: DropdownButtonFormField<T>(
            decoration: InputDecoration(
                filled: false,
                labelText: nome,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                )),
            value: value,
            onChanged: (newValue) => onChanged(newValue as T),
            items: items,
            selectedItemBuilder: (context) => selectedItemBuilder,
            icon: const Icon(
              Icons.arrow_drop_down,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}


/*

              CustomDropdownButton<String>(
                  items: <String>['All', 'Type 1', 'Type 2', 'Type 3']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  value: _selectedType,
                  onChanged: (String newValue) {
                    setState(() {
                      print(newValue);
                      _selectedType = newValue;
                    });
                  })

*/