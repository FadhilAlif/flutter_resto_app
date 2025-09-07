import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/providers/restaurant_provider.dart';
import 'data/providers/theme_provider.dart';
import 'data/providers/favorite_provider.dart';
import 'data/services/api_service.dart';
import 'data/db/database_helper.dart';
import 'data/db/db_config.dart';
import 'ui/screens/restaurant_detail_screen.dart';
import 'ui/screens/restaurant_list_screen.dart';
import 'ui/screens/search_screen.dart';
import 'ui/screens/favorite_screen.dart';
import 'ui/screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database based on platform
  await initializeDatabase();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(
          create: (context) => RestaurantProvider(ApiService()),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              FavoriteProvider(databaseHelper: DatabaseHelper()),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Restaurant App',
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode: themeProvider.themeMode,
            initialRoute: '/',
            onGenerateRoute: (settings) {
              switch (settings.name) {
                case '/':
                  return MaterialPageRoute(
                    builder: (_) => const RestaurantListScreen(),
                  );
                case '/search':
                  return MaterialPageRoute(
                    builder: (_) => const SearchScreen(),
                  );
                case '/favorite':
                  return MaterialPageRoute(
                    builder: (_) => const FavoriteScreen(),
                  );
                case '/detail':
                  final restaurantId = settings.arguments as String?;
                  if (restaurantId == null) {
                    return MaterialPageRoute(
                      builder: (_) => const RestaurantListScreen(),
                    );
                  }
                  return MaterialPageRoute(
                    builder: (_) =>
                        RestaurantDetailScreen(restaurantId: restaurantId),
                  );
                case '/settings':
                  return MaterialPageRoute(
                    builder: (_) => const SettingsScreen(),
                  );
                default:
                  return MaterialPageRoute(
                    builder: (_) => const RestaurantListScreen(),
                  );
              }
            },
          );
        },
      ),
    );
  }
}
