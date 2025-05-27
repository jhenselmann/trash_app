import 'package:flutter/material.dart';
import '../data/waste_labels.dart';

class WasteTypeListPopup extends StatefulWidget {
  final Set<String> selected;
  final void Function(Set<String>) onChanged;

  const WasteTypeListPopup({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  static final List<String> orderedWasteTypes = [
    'trash',
    'plastic',
    'glass_bottles',
    'cans',
    'clothes',
    'shoes',
    'beverage_cartons',
    'aluminium',
    'paper',
    'glass',
    'dog_excrement',
    'mixed',
    'scrap_metal',
    'cigarettes',
    'metal',
    'PET',
  ];

  @override
  State<WasteTypeListPopup> createState() => _WasteTypeListPopupState();
}

class _WasteTypeListPopupState extends State<WasteTypeListPopup> {
  late Set<String> selected;

  @override
  void initState() {
    super.initState();
    selected = {...widget.selected};
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filter Waste Types'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView(
          shrinkWrap: true,
          children:
              WasteTypeListPopup.orderedWasteTypes.map((type) {
                final isSelected = selected.contains(type);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      isSelected ? selected.remove(type) : selected.add(type);
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.yellow : null,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: Text(wasteTypeLabels[type] ?? type)),
                        if (isSelected)
                          const Icon(Icons.check, color: Colors.black54),
                      ],
                    ),
                  ),
                );
              }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.onChanged(selected);
            Navigator.pop(context);
          },
          child: const Text("Apply"),
        ),
      ],
    );
  }
}
