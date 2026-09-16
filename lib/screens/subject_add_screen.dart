import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

class SubjectAddScreen extends StatefulWidget {
  const SubjectAddScreen({super.key, this.subject});
  final Map<String, dynamic>? subject;

  @override
  State<SubjectAddScreen> createState() => _SubjectAddScreenState();
}

class _SubjectAddScreenState extends State<SubjectAddScreen> {
  static const _days = ['\uC6D4\uC694\uC77C', '\uD654\uC694\uC77C', '\uC218\uC694\uC77C', '\uBAA9\uC694\uC77C', '\uAE08\uC694\uC77C'];
  final _subject = TextEditingController();
  final _professor = TextEditingController();
  final _classroom = TextEditingController();
  final _colors = const [Color(0xFF6C63FF), Color(0xFF4D96FF), Color(0xFF4CAF50), Color(0xFFFFB703), Color(0xFFFF6B6B), Color(0xFFFF8CC7)];
  late String _day;
  late TimeOfDay _start;
  late TimeOfDay _end;
  late Color _color;

  bool get _editing => widget.subject != null;

  @override
  void initState() {
    super.initState();
    final item = widget.subject;
    _subject.text = item?['subject']?.toString() ?? '';
    _professor.text = item?['professor']?.toString() ?? '';
    _classroom.text = item?['classroom']?.toString() ?? '';
    _day = item?['day']?.toString() ?? _days.first;
    _start = TimeOfDay(hour: item?['startHour'] as int? ?? 9, minute: item?['startMinute'] as int? ?? 0);
    _end = TimeOfDay(hour: item?['endHour'] as int? ?? 10, minute: item?['endMinute'] as int? ?? 0);
    _color = Color(item?['color'] as int? ?? AppColors.primary.value);
  }

  @override
  void dispose() { _subject.dispose(); _professor.dispose(); _classroom.dispose(); super.dispose(); }

  Future<void> _pickTime(bool start) async {
    final selected = await showTimePicker(context: context, initialTime: start ? _start : _end);
    if (selected != null) setState(() { if (start) _start = selected; else _end = selected; });
  }

  void _submit() {
    final start = _start.hour * 60 + _start.minute;
    final end = _end.hour * 60 + _end.minute;
    if (_subject.text.trim().isEmpty) return _notice('\uACFC\uBAA9\uBA85\uC744 \uC785\uB825\uD574 \uC8FC\uC138\uC694.');
    if (end <= start) return _notice('\uC885\uB8CC \uC2DC\uAC04\uC740 \uC2DC\uC791 \uC2DC\uAC04\uBCF4\uB2E4 \uB2A6\uC5B4\uC57C \uD569\uB2C8\uB2E4.');
    Navigator.pop(context, {'subject': _subject.text.trim(), 'professor': _professor.text.trim(), 'classroom': _classroom.text.trim(), 'day': _day, 'startHour': _start.hour, 'startMinute': _start.minute, 'endHour': _end.hour, 'endMinute': _end.minute, 'color': _color.value});
  }

  void _notice(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  String _time(TimeOfDay value) => '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
  InputDecoration _input(String hint) => InputDecoration(hintText: hint, filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: AppColors.primary, width: 2)));

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(_editing ? '\uACFC\uBAA9 \uC218\uC815' : '\uACFC\uBAA9 \uCD94\uAC00', style: const TextStyle(fontWeight: FontWeight.bold))),
    body: SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _label('\uACFC\uBAA9\uBA85'), TextField(controller: _subject, decoration: _input('\uC608: \uCEF4\uD4E8\uD130\uD504\uB85C\uADF8\uB798\uBC0D \uAE30\uCD08')),
      _gap(), _label('\uAD50\uC218\uBA85'), TextField(controller: _professor, decoration: _input('\uC608: \uD64D\uAE38\uB3D9')),
      _gap(), _label('\uC694\uC77C'), _dayPicker(),
      _gap(), _label('\uC2DC\uAC04'), Row(children: [Expanded(child: _timeButton('\uC2DC\uC791 \uC2DC\uAC04', _time(_start), () => _pickTime(true))), const Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text('~')), Expanded(child: _timeButton('\uC885\uB8CC \uC2DC\uAC04', _time(_end), () => _pickTime(false)))]),
      _gap(), _label('\uAC15\uC758\uC2E4'), TextField(controller: _classroom, decoration: _input('\uC608: \uACF5\uD559\uAD00 212\uD638')),
      _gap(), _label('\uC0C9\uC0C1'), const SizedBox(height: 10), Wrap(spacing: 12, children: _colors.map((value) => GestureDetector(onTap: () => setState(() => _color = value), child: Container(width: 42, height: 42, decoration: BoxDecoration(color: value, shape: BoxShape.circle, border: _color == value ? Border.all(color: AppColors.navy, width: 3) : null)))).toList()),
      const SizedBox(height: 40), SizedBox(width: double.infinity, height: 55, child: ElevatedButton(onPressed: _submit, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white), child: Text(_editing ? '\uC800\uC7A5\uD558\uAE30' : '\uCD94\uAC00\uD558\uAE30'))),
    ]))),
  );
  Widget _label(String text) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)));
  Widget _gap() => const SizedBox(height: 22);
  Widget _dayPicker() => Container(padding: const EdgeInsets.symmetric(horizontal: 15), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)), child: DropdownButtonHideUnderline(child: DropdownButton<String>(value: _day, isExpanded: true, items: _days.map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(), onChanged: (value) => setState(() => _day = value!))));
  Widget _timeButton(String label, String time, VoidCallback onTap) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(15), child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)), const SizedBox(height: 5), Text(time, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold))])));
}
