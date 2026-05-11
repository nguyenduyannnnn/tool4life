import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'package:changmeeting/common/theme.dart';
import '../../domain/entities/place_tag_entity.dart';
import 'place_image_picker.dart';

class PlaceFormData {
  String name;
  String description;
  DateTime visitedAt;
  double latitude;
  double longitude;
  String? tag;
  List<String> imagePaths;

  PlaceFormData({
    required this.name,
    required this.description,
    required this.visitedAt,
    required this.latitude,
    required this.longitude,
    required this.tag,
    required this.imagePaths,
  });
}

class PlaceForm extends StatefulWidget {
  final PlaceFormData initial;
  final ValueChanged<PlaceFormData> onSubmit;
  final String submitLabel;

  const PlaceForm({
    super.key,
    required this.initial,
    required this.onSubmit,
    required this.submitLabel,
  });

  @override
  State<PlaceForm> createState() => _PlaceFormState();
}

class _PlaceFormState extends State<PlaceForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _desc;
  late final TextEditingController _lat;
  late final TextEditingController _lng;
  late DateTime _date;
  String? _tag;
  late List<String> _imagePaths;

  @override
  void initState() {
    super.initState();
    final i = widget.initial;
    _name = TextEditingController(text: i.name);
    _desc = TextEditingController(text: i.description);
    _lat = TextEditingController(text: i.latitude.toStringAsFixed(6));
    _lng = TextEditingController(text: i.longitude.toStringAsFixed(6));
    _date = i.visitedAt;
    _tag = i.tag;
    _imagePaths = List.from(i.imagePaths);
  }

  @override
  void dispose() {
    _name.dispose();
    _desc.dispose();
    _lat.dispose();
    _lng.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final result = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (result != null) {
      setState(() => _date = DateTime(result.year, result.month, result.day));
    }
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final lat = double.tryParse(_lat.text.trim()) ?? 0;
    final lng = double.tryParse(_lng.text.trim()) ?? 0;
    widget.onSubmit(PlaceFormData(
      name: _name.text.trim(),
      description: _desc.text.trim(),
      visitedAt: _date,
      latitude: lat,
      longitude: lng,
      tag: _tag,
      imagePaths: _imagePaths,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _name,
            decoration: const InputDecoration(
              labelText: 'Tên địa điểm *',
              border: OutlineInputBorder(),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Tên địa điểm không được để trống';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _desc,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Mô tả / kỷ niệm',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: _pickDate,
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Ngày đã đến',
                border: OutlineInputBorder(),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 18),
                  const SizedBox(width: 8),
                  Text(DateFormat('dd/MM/yyyy').format(_date)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _lat,
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true, signed: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[-\d.]')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Latitude *',
                    border: OutlineInputBorder(),
                  ),
                  validator: _validateLat,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: _lng,
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true, signed: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[-\d.]')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Longitude *',
                    border: OutlineInputBorder(),
                  ),
                  validator: _validateLng,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _tag,
            decoration: const InputDecoration(
              labelText: 'Thẻ',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem<String>(
                value: null,
                child: Text('Không'),
              ),
              ...PlaceTagEntity.defaults.map(
                (t) => DropdownMenuItem<String>(
                  value: t.id,
                  child: Text(t.name),
                ),
              ),
            ],
            onChanged: (v) => setState(() => _tag = v),
          ),
          const SizedBox(height: 12),
          PlaceImagePicker(
            imagePaths: _imagePaths,
            onChanged: (list) => setState(() => _imagePaths = list),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                widget.submitLabel,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? _validateLat(String? v) {
    if (v == null || v.trim().isEmpty) return 'Bắt buộc';
    final n = double.tryParse(v.trim());
    if (n == null) return 'Không hợp lệ';
    if (n < -90 || n > 90) return 'Phạm vi -90 đến 90';
    return null;
  }

  String? _validateLng(String? v) {
    if (v == null || v.trim().isEmpty) return 'Bắt buộc';
    final n = double.tryParse(v.trim());
    if (n == null) return 'Không hợp lệ';
    if (n < -180 || n > 180) return 'Phạm vi -180 đến 180';
    return null;
  }
}
