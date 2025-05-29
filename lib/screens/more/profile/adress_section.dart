import 'package:flutter/material.dart';

class AddressSection extends StatefulWidget {
  const AddressSection({super.key});

  @override
  State<AddressSection> createState() => _AddressSectionState();
}

class _AddressSectionState extends State<AddressSection> {
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();

  final _streetController = TextEditingController(text: 'Arcisstraße');
  final _houseNumberController = TextEditingController(text: '21');
  final _zipController = TextEditingController(text: '80333');
  final _cityController = TextEditingController(text: 'Munich');
  final _countryController = TextEditingController(text: 'Germany');

  final _textOnlyRegex = RegExp(r"^[a-zA-ZäöüÄÖÜß\s\-]+$");
  final _zipRegex = RegExp(r"^\d{5}$");
  final _houseNumberRegex = RegExp(r"^[a-zA-Z0-9\s\-]+$");

  void _toggleEditing() {
    if (_isEditing) {
      if (_formKey.currentState!.validate()) {
        setState(() => _isEditing = false);
      }
    } else {
      setState(() => _isEditing = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Address', _isEditing, _toggleEditing),
          const SizedBox(height: 16),
          _buildValidatedField(
            label: 'Country',
            controller: _countryController,
            enabled: _isEditing,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a country.';
              }
              if (!_textOnlyRegex.hasMatch(value.trim())) {
                return 'Only letters, spaces, and hyphens allowed.';
              }
              return null;
            },
          ),
          _buildValidatedField(
            label: 'Zip Code',
            controller: _zipController,
            enabled: _isEditing,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a zip code.';
              }
              if (!_zipRegex.hasMatch(value.trim())) {
                return 'Must be exactly 5 digits.';
              }
              return null;
            },
          ),
          _buildValidatedField(
            label: 'City',
            controller: _cityController,
            enabled: _isEditing,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a city.';
              }
              if (!_textOnlyRegex.hasMatch(value.trim())) {
                return 'Only letters, spaces, and hyphens allowed.';
              }
              return null;
            },
          ),
          _buildValidatedField(
            label: 'Street',
            controller: _streetController,
            enabled: _isEditing,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a street.';
              }
              if (!_textOnlyRegex.hasMatch(value.trim())) {
                return 'Only letters, spaces, and hyphens allowed.';
              }
              return null;
            },
          ),
          _buildValidatedField(
            label: 'House Number',
            controller: _houseNumberController,
            enabled: _isEditing,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a house number.';
              }
              if (!_houseNumberRegex.hasMatch(value.trim())) {
                return 'Only letters, numbers, and hyphens allowed.';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(
    String title,
    bool isEditing,
    VoidCallback onEditToggle,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: Icon(isEditing ? Icons.check : Icons.edit),
          tooltip: isEditing ? 'Save' : 'Edit',
          onPressed: onEditToggle,
        ),
      ],
    );
  }

  Widget _buildValidatedField({
    required String label,
    required TextEditingController controller,
    required bool enabled,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            filled: true,
            fillColor: enabled ? Colors.white : Colors.grey.shade200,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
