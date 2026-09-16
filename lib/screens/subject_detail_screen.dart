import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import 'subject_add_screen.dart';

class SubjectDetailScreen extends StatelessWidget {
  const SubjectDetailScreen({super.key, required this.subject});
  final Map<String, dynamic> subject;

  String _two(dynamic value) => value.toString().padLeft(2, '0');
  String get _time => _two(subject['startHour']) + ':' + _two(subject['startMinute']) + ' - ' + _two(subject['endHour']) + ':' + _two(subject['endMinute']);

  Future<void> _edit(BuildContext context) async {
    final value = await Navigator.push<Map<String, dynamic>>(context, MaterialPageRoute(builder: (_) => SubjectAddScreen(subject: subject)));
    if (value != null && context.mounted) Navigator.pop(context, {'updated': value});
  }

  @override
  Widget build(BuildContext context) {
    final color = Color(subject['color'] as int);
    return Scaffold(
      appBar: AppBar(title: const Text('\uC2DC\uAC04\uD45C \uC0C1\uC138', style: TextStyle(fontWeight: FontWeight.bold))),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: color.withOpacity(.16), borderRadius: BorderRadius.circular(20)),
                child: Row(children: [
                  Container(width: 58, height: 58, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(15)), child: const Icon(Icons.laptop_mac_rounded, color: Colors.white)),
                  const SizedBox(width: 15),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(subject['subject'].toString(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(subject['professor'].toString().isEmpty ? '\uAD50\uC218\uBA85 \uBBF8\uB4F1\uB85D' : subject['professor'].toString() + ' \uAD50\uC218', style: const TextStyle(color: AppColors.textSecondary)),
                  ])),
                ]),
              ),
              const SizedBox(height: 16),
              _info(Icons.calendar_today_outlined, '\uC694\uC77C', subject['day'].toString()),
              _info(Icons.access_time_rounded, '\uC2DC\uAC04', _time),
              _info(Icons.meeting_room_outlined, '\uAC15\uC758\uC2E4', subject['classroom'].toString().isEmpty ? '\uBBF8\uC9C0\uC815' : subject['classroom'].toString()),
              _info(Icons.school_outlined, '\uC218\uC5C5 \uC720\uD615', '\uC774\uB860 / \uC2E4\uC2B5'),
              const Spacer(),
              SizedBox(width: double.infinity, height: 54, child: ElevatedButton.icon(onPressed: () => _edit(context), icon: const Icon(Icons.edit_outlined), label: const Text('\uC218\uC815\uD558\uAE30'), style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _info(IconData icon, String label, String value) => Container(
    padding: const EdgeInsets.symmetric(vertical: 16),
    decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFE9ECF6)))),
    child: Row(children: [Icon(icon, color: AppColors.navy), const SizedBox(width: 12), Text(label, style: const TextStyle(fontWeight: FontWeight.w600)), const Spacer(), Text(value, style: const TextStyle(color: AppColors.textSecondary))]),
  );
}
