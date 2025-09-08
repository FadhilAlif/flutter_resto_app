import 'package:flutter/material.dart';
import 'package:flutter_resto_app/data/providers/theme_provider.dart';
import 'package:flutter_resto_app/data/providers/notification_provider.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  static const routeName = '/settings';

  const SettingsScreen({super.key});

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
          Consumer<NotificationProvider>(
            builder: (context, notificationProvider, child) {
              if (notificationProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              return Column(
                children: [
                  ListTile(
                    title: const Text('Lunch Reminder'),
                    subtitle: const Text('Notify at 11:00 AM'),
                    trailing: Switch(
                      value: notificationProvider.isReminderEnabled,
                      onChanged: (_) => notificationProvider.toggleReminder(),
                    ),
                  ),
                  if (notificationProvider.isReminderEnabled)
                    ListTile(
                      title: const Text('Test Notification'),
                      subtitle: const Text('Try send notification now'),
                      trailing: IconButton(
                        icon: const Icon(Icons.notifications_active),
                        onPressed: () =>
                            notificationProvider.sendTestNotification(),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
