import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../utils/notification_service.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: const Text('সেটিংস')),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.dark_mode_outlined),
            title: const Text('ডার্ক মোড'),
            trailing: Switch(
              value: state.isDarkMode,
              onChanged: (_) => state.toggleDarkMode(),
            ),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              'নোটিফিকেশন',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('নোটিফিকেশন চালু'),
            subtitle: const Text('ফলো করা পত্রিকার নতুন খবর'),
            trailing: Switch(
              value: state.notificationsEnabled,
              onChanged: (v) => state.toggleNotifications(v),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.notification_add, color: Colors.blue),
            title: const Text('টেস্ট নোটিফিকেশন পাঠান'),
            subtitle: const Text('কাজ করছে কিনা চেক করুন'),
            onTap: () async {
              try {
                await NotificationService.showTestNotification();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('নোটিফিকেশন পাঠানো হয়েছে! স্ক্রিনের উপরে দেখুন'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('সমস্যা হয়েছে। ফোনের Settings → Apps → পত্রিকাঘর → Notifications চালু করুন'),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 5),
                    ),
                  );
                }
              }
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              'অফলাইন রিডিং',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
            ),
          ),
          const ListTile(
            leading: Icon(Icons.download_for_offline_outlined),
            title: Text('কীভাবে অফলাইনে সেভ করবেন'),
            subtitle: Text(
              '১. যেকোনো খবর খুলুন\n'
              '২. উপরে ডাউনলোড আইকনে ট্যাপ করুন\n'
              '৩. নিচের অফলাইন ট্যাব থেকে পড়ুন',
            ),
            isThreeLine: true,
          ),
          ListTile(
            leading: const Icon(Icons.offline_pin, color: Colors.green),
            title: Text('সেভ করা আর্টিকেল: ${state.offlineArticles.length} টি'),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              'ফলো করা পত্রিকা (${state.followedPaperIds.length})',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
            ),
          ),
          if (state.followedPaperIds.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'পত্রিকা ট্যাবে গিয়ে বেল আইকনে ট্যাপ করে পত্রিকা ফলো করুন।',
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            ...state.papers
                .where((p) => state.followedPaperIds.contains(p.id))
                .map(
                  (p) => ListTile(
                    title: Text(p.nameBn),
                    trailing: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => state.toggleFollowPaper(p.id),
                    ),
                  ),
                ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('অ্যাপ সম্পর্কে'),
            subtitle: const Text('পত্রিকাঘর v1.5.0'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'পত্রিকাঘর',
                applicationVersion: '1.5.0',
                applicationLegalese: 'বাংলাদেশি সংবাদপত্র অ্যাগ্রিগেটর',
              );
            },
          ),
        ],
      ),
    );
  }
}
