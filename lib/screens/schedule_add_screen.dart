import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class ScheduleAddScreen extends StatefulWidget {
  const ScheduleAddScreen({super.key});
  @override State<ScheduleAddScreen> createState() => _ScheduleAddScreenState();
}

class _ScheduleAddScreenState extends State<ScheduleAddScreen> {
  final _title = TextEditingController();
  final _memo = TextEditingController();
  DateTime _date = DateTime.now();
  TimeOfDay _start = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _end = const TimeOfDay(hour: 10, minute: 0);
  String _category = '\uAC1C\uC778';
  bool _notice = true;

  @override void dispose() { _title.dispose(); _memo.dispose(); super.dispose(); }
  String _time(TimeOfDay value) => value.hour.toString().padLeft(2, '0') + ':' + value.minute.toString().padLeft(2, '0');
  Future<void> _pickTime(bool start) async { final value = await showTimePicker(context: context, initialTime: start ? _start : _end); if (value != null) setState(() { if (start) _start = value; else _end = value; }); }
  void _save() {
    if (_title.text.trim().isEmpty) return;
    Navigator.pop(context, {'id': DateTime.now().microsecondsSinceEpoch.toString(), 'title': _title.text.trim(), 'memo': _memo.text.trim(), 'date': _date.toIso8601String(), 'startHour': _start.hour, 'startMinute': _start.minute, 'endHour': _end.hour, 'endMinute': _end.minute, 'category': _category, 'notification': _notice});
  }

  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('\uC77C\uC815 \uCD94\uAC00', style: TextStyle(fontWeight: FontWeight.bold))),
    body: SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('\uC81C\uBAA9', style: TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 8),
      TextField(controller: _title, decoration: _input('\uC77C\uC815\uBA85\uC744 \uC785\uB825\uD558\uC138\uC694')), const SizedBox(height: 20),
      const Text('\uB0A0\uC9DC', style: TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 8),
      _button(_date.year.toString() + '. ' + _date.month.toString() + '. ' + _date.day.toString(), () async { final value = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime(2020), lastDate: DateTime(2100)); if (value != null) setState(() => _date = value); }),
      const SizedBox(height: 20), const Text('\uC2DC\uAC04', style: TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 8),
      Row(children: [Expanded(child: _button(_time(_start), () => _pickTime(true))), const Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text('~')), Expanded(child: _button(_time(_end), () => _pickTime(false)))]),
      const SizedBox(height: 20), const Text('\uCE74\uD14C\uACE0\uB9AC', style: TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 8),
      Wrap(spacing: 8, children: ['\uD559\uAD50','\uC5C5\uBB34','\uC6B4\uB3D9','\uAC1C\uC778','\uC57D\uC18D','\uAE30\uD0C0'].map((value) => ChoiceChip(label: Text(value), selected: _category == value, onSelected: (_) => setState(() => _category = value))).toList()),
      const SizedBox(height: 20), TextField(controller: _memo, maxLines: 3, decoration: _input('\uBA54\uBAA8')), SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('\uC54C\uB9BC \uC124\uC815'), value: _notice, onChanged: (value) => setState(() => _notice = value)),
      const SizedBox(height: 18), SizedBox(width: double.infinity, height: 54, child: ElevatedButton(onPressed: _save, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white), child: const Text('\uC800\uC7A5\uD558\uAE30'))),
    ]))),
  );
  InputDecoration _input(String hint) => InputDecoration(hintText: hint, filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none));
  Widget _button(String text, VoidCallback onTap) => InkWell(onTap: onTap, child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)), child: Text(text)));
}
