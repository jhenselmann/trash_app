import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trash_app/providers/waste_filter_provider.dart';
import 'waste_type_list.dart';

class WasteTypeFilter extends StatelessWidget {
  const WasteTypeFilter({super.key});

  @override
  Widget build(BuildContext context) {
    final activeFilters = context.watch<WasteFilterProvider>().filters;

    return SizedBox(
      height: 135,
      child: Stack(
        children: [
          // Filter-Button
          Positioned(
            top: 50,
            left: 20,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                elevation: 4,
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder:
                      (_) => WasteTypeListPopup(
                        selected: activeFilters,
                        onChanged: (updated) {
                          context.read<WasteFilterProvider>().updateFilters(
                            updated,
                          );
                        },
                      ),
                );
              },
              icon: const Icon(Icons.search),
              label: const Text("Filter"),
            ),
          ),

          // Clear Button
          if (activeFilters.isNotEmpty)
            Positioned(
              top: 100,
              left: 20,
              child: SizedBox(
                height: 32,
                child: TextButton(
                  onPressed: () => context.read<WasteFilterProvider>().clear(),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text("Clear filters"),
                ),
              ),
            ),

          // Filter-Chips
          if (activeFilters.isNotEmpty)
            Positioned(
              top: 50,
              left: 130,
              right: 80,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children:
                        activeFilters.map((filter) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.amber[100],
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    filter,
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                  const SizedBox(width: 4),
                                  GestureDetector(
                                    onTap: () {
                                      final updated = Set<String>.from(
                                        activeFilters,
                                      )..remove(filter);
                                      context
                                          .read<WasteFilterProvider>()
                                          .updateFilters(updated);
                                    },
                                    child: const Icon(
                                      Icons.close,
                                      size: 16,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
