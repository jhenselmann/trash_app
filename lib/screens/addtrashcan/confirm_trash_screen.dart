import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:trash_app/data/waste_labels.dart';
import 'package:geocoding/geocoding.dart';
import 'package:trash_app/data/trashcan.dart';
import 'package:trash_app/services/user_trashcan_service.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

class ConfirmTrashcanScreen extends StatefulWidget {
  final LatLng location;

  const ConfirmTrashcanScreen({super.key, required this.location});

  @override
  State<ConfirmTrashcanScreen> createState() => _ConfirmTrashcanScreenState();
}

class _ConfirmTrashcanScreenState extends State<ConfirmTrashcanScreen> {
  String? _selectedForm;
  Set<String> _selectedWasteTypes = {};
  String _address = 'Loading address...';
  bool _formError = false;
  bool _wasteTypeError = false;
  bool _formFilledSent = false;

  @override
  void initState() {
    super.initState();
    _loadAddress();
  }

  Future<void> _loadAddress() async {
    try {
      final placemarks = await placemarkFromCoordinates(
        widget.location.latitude,
        widget.location.longitude,
      );
      final place = placemarks.first;
      setState(() {
        _address =
            '${place.street}, ${place.postalCode} ${place.locality}, ${place.country}';
      });
    } catch (e) {
      setState(() {
        _address = 'Address not found';
      });
    }
  }

  void _checkFormFilled() {
    final isFilled = _selectedForm != null && _selectedWasteTypes.isNotEmpty;
    if (isFilled && !_formFilledSent) {
      Posthog().capture(eventName: 'form_filled_complete');
      _formFilledSent = true;
    }
  }

  String _getTitleForForm(String? form) {
    switch (form) {
      case 'basket':
        return 'Trash can';
      case 'container':
        return 'Container';
      case 'centre':
        return 'Recycling center';
      default:
        return 'Select type';
    }
  }

  void _toggleWasteType(String type) {
    setState(() {
      if (_selectedWasteTypes.contains(type)) {
        _selectedWasteTypes.remove(type);
      } else {
        _selectedWasteTypes.add(type);
      }
      if (_wasteTypeError) _wasteTypeError = false;
      _checkFormFilled();
    });
  }

  @override
  Widget build(BuildContext context) {
    final showFormError = _selectedForm == null;
    final showWasteTypeError = _selectedWasteTypes.isEmpty;
    final isValid = !showFormError && !showWasteTypeError;

    return Scaffold(
      appBar: AppBar(title: const Text("Confirm Location")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  const Text(
                    "Select Type of Trashcan",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildFormChip('basket'),
                      _buildFormChip('container'),
                      _buildFormChip('centre'),
                    ],
                  ),
                  if (showFormError)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        "Please select a trashcan type.",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  const SizedBox(height: 20),
                  const Text(
                    "What can be disposed here?",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        wasteTypeLabels.entries.map((entry) {
                          return FilterChip(
                            label: Text(entry.value),
                            selected: _selectedWasteTypes.contains(entry.key),
                            onSelected: (_) => _toggleWasteType(entry.key),
                          );
                        }).toList(),
                  ),
                  if (showWasteTypeError)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        "Please select at least one waste type.",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  const SizedBox(height: 20),
                  const Text(
                    "Location",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _address,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.location.latitude.toStringAsFixed(6)}, ${widget.location.longitude.toStringAsFixed(6)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      Posthog().capture(eventName: 'trashcan_add_attempt');

                      final isValid =
                          _selectedForm != null &&
                          _selectedWasteTypes.isNotEmpty;

                      if (!isValid) {
                        Posthog().capture(eventName: 'form_validation_error');
                        setState(() {
                          _formError = _selectedForm == null;
                          _wasteTypeError = _selectedWasteTypes.isEmpty;
                        });
                        return;
                      }

                      Posthog().capture(eventName: 'trashcan_add_success');

                      final id =
                          'user/${DateTime.now().millisecondsSinceEpoch}';
                      final newTrashcan = Trashcan(
                        id: id,
                        coordinates: [
                          widget.location.longitude,
                          widget.location.latitude,
                        ],
                        wasteTypes: _selectedWasteTypes.toList(),
                        wasteForm: _selectedForm!,
                        addedByUser: true,
                      );

                      await UserTrashcanService.addUserTrashcan(newTrashcan);

                      if (context.mounted) {
                        Navigator.pop(context, id);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          (_selectedForm != null &&
                                  _selectedWasteTypes.isNotEmpty)
                              ? Colors.yellow
                              : Colors.grey.shade400, // Farbe je nach Validität
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Add Trashcan'),
                  ),
                ),

                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade300,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormChip(String form) {
    return ChoiceChip(
      label: Text(_getTitleForForm(form)),
      selected: _selectedForm == form,
      onSelected: (_) {
        setState(() {
          _selectedForm = form;
          if (_formError) _formError = false;
          _checkFormFilled();
        });
      },
    );
  }
}
