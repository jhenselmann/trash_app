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

  void toggleSelection(String type) {
    setState(() {
      selected.contains(type) ? selected.remove(type) : selected.add(type);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filter Waste Types'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: SizedBox(
        width: double.maxFinite,
        child: GridView.count(
          shrinkWrap: true,
          crossAxisCount: 2,
          childAspectRatio: 3.5,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children:
              WasteTypeListPopup.orderedWasteTypes.map((type) {
                final isSelected = selected.contains(type);
                return GestureDetector(
                  onTap: () => toggleSelection(type),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? const Color(0xFFFFF3B0)
                              : Colors.grey[100],
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? Colors.brown : Colors.grey[300]!,
                        width: 1.4,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 0,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            wasteTypeLabels[type] ?? type,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check,
                            size: 18,
                            color: Colors.black54,
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
        ),
      ),
      actionsPadding: const EdgeInsets.only(right: 16, bottom: 12),
      actions: [
        TextButton(
          onPressed: () {
            setState(() {
              selected.clear();
            });
          },
          child: const Text("Reset"),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
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
