import 'package:flutter/material.dart';

import '../core/assets/app_assets.dart';
import '../core/theme/app_theme.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) => SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('\uB354\uBCF4\uAE30', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
    const SizedBox(height: 22),
    Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFE4E9FF), Color(0xFFF4F1FF)]), borderRadius: BorderRadius.circular(20)), child: Row(children: [
      ClipRRect(borderRadius: BorderRadius.circular(28), child: Image.asset(AppAssets.morePlanet, width: 56, height: 56, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(width:56,height:56,color:Colors.white54,child:const Icon(Icons.public_rounded,color:AppColors.primary,size:34)))),
      const SizedBox(width: 14), const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('\uD50C\uB798\uB2DB \uC720\uC800', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)), SizedBox(height: 3), Text('PLANET\uC640 \uD568\uAED8\uD558\uB294 \uC911', style: TextStyle(fontSize: 12, color: AppColors.textSecondary))])), const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary)
    ])),
    const SizedBox(height: 18),
    Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: Column(children: [
      _item(Icons.person_outline_rounded, '\uB0B4 \uC815\uBCF4'),
      _item(Icons.palette_outlined, '\uD14C\uB9C8 \uC124\uC815', trailing: '\uB77C\uC774\uD2B8 \uBAA8\uB4DC'),
      _item(Icons.notifications_none_rounded, '\uC54C\uB9BC \uC124\uC815'),
      _item(Icons.cloud_outlined, '\uB370\uC774\uD130 \uBC31\uC5C5'),
      _item(Icons.info_outline_rounded, '\uC571 \uC815\uBCF4'),
      _item(Icons.mail_outline_rounded, '\uBB38\uC758\uD558\uAE30', last: true),
    ])),
    const SizedBox(height: 34),
    Center(child: Column(children: [
      Image.asset(AppAssets.morePlanet, width: 125, height: 100, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.rocket_launch_rounded, size: 74, color: AppColors.primaryLight)),
      const SizedBox(height: 8), const Text('\uC624\uB298\uB3C4 \uD589\uBCF5\uD55C \uD558\uB8E8\uB97C \uBCF4\uB0B4\uC138\uC694! \u2728', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600))
    ])),
  ])));

  Widget _item(IconData icon, String title, {String? trailing, bool last = false}) => Column(children: [
    ListTile(leading: Icon(icon, color: AppColors.navy, size: 21), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)), trailing: Row(mainAxisSize: MainAxisSize.min, children: [if (trailing != null) Text(trailing, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)), const SizedBox(width: 4), const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary)]), onTap: () {}),
    if (!last) const Padding(padding: EdgeInsets.only(left: 56), child: Divider(height: 1, color: Color(0xFFEFF1F8))),
  ]);
}
