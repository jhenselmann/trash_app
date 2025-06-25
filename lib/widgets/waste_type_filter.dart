import 'package:flutter/material.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
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
                Posthog().capture(eventName: 'filter_opened');

                showDialog(
                  context: context,
                  builder:
                      (_) => WasteTypeListPopup(
                        selected: activeFilters,
                        onChanged: (updated) {
                          Posthog().capture(
                            eventName: 'filters_updated',
                            properties: {'active_filters': updated.toList()},
                          );
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
        ],
      ),
    );
  }
}
