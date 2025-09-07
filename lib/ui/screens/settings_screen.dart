import 'package:flutter/material.dart';
import 'package:flutter_resto_app/data/providers/theme_provider.dart';
import 'package:flutter_resto_app/data/services/notification_service.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  static const routeName = '/settings';

  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // Theme Settings
          ListTile(
            title: const Text('Dark Theme'),
            trailing: Switch(
              value: context.watch<ThemeProvider>().themeMode == ThemeMode.dark,
              onChanged: (_) => context.read<ThemeProvider>().toggleTheme(),
            ),
          ),
          // Color Theme Settings
          ListTile(
            title: const Text('Theme Color'),
            trailing: PopupMenuButton<ColorSeed>(
              icon: Icon(
                Icons.color_lens,
                color: context.watch<ThemeProvider>().colorSeed.color,
              ),
              itemBuilder: (context) => ColorSeed.values
                  .map(
                    (color) => PopupMenuItem(
                      value: color,
                      child: Row(
                        children: [
                          Icon(Icons.color_lens, color: color.color),
                          const SizedBox(width: 8),
                          Text(color.name.toUpperCase()),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              onSelected: (color) =>
                  context.read<ThemeProvider>().setColorSeed(color),
            ),
          ),
          const Divider(),
          // Daily Reminder Settings
          FutureBuilder<NotificationService>(
            future: NotificationService.getInstance(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const CircularProgressIndicator();
              }

              final notificationService = snapshot.data!;
              return FutureBuilder<bool>(
                future: notificationService.isReminderEnabled(),
                builder: (context, snapshot) {
                  final isEnabled = snapshot.data ?? false;
                  return ListTile(
                    title: const Text('Lunch Reminder'),
                    subtitle: const Text('Notify at 11:00 AM'),
                    trailing: Switch(
                      value: isEnabled,
                      onChanged: (value) async {
                        await notificationService.toggleReminder();
                        // Rebuild to update UI
                        if (mounted) setState(() {});
                      },
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
