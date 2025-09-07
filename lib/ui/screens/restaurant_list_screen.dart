import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/restaurant_provider.dart';
import '../../data/providers/theme_provider.dart';
import '../../data/services/api_state.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/restaurant_item.dart';
import '../widgets/error_state.dart';

class RestaurantListScreen extends StatefulWidget {
  const RestaurantListScreen({super.key});

  @override
  State<RestaurantListScreen> createState() => _RestaurantListScreenState();
}

class _RestaurantListScreenState extends State<RestaurantListScreen> {
  final _searchController = TextEditingController();
  final bool _isSearching = false;

  String _getErrorMessage(String message) {
    if (message.toLowerCase().contains('failed to connect') ||
        message.toLowerCase().contains('socket')) {
      return 'Unable to connect to the server.\nPlease check your internet connection and try again.';
    } else if (message.toLowerCase().contains('timeout')) {
      return 'Connection timed out.\nPlease check your internet connection and try again.';
    } else if (_isSearching) {
      return 'Failed to search restaurants.\nPlease try again with different keywords.';
    } else {
      return 'Something went wrong while loading restaurants.\nPlease try again.';
    }
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<RestaurantProvider>().fetchRestaurants();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurant App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () => Navigator.pushNamed(context, '/favorite'),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.pushNamed(context, '/search'),
          ),
          IconButton(
            icon: Consumer<ThemeProvider>(
              builder: (context, provider, child) => Icon(
                provider.themeMode == ThemeMode.light
                    ? Icons.dark_mode
                    : Icons.light_mode,
              ),
            ),
            onPressed: () => context.read<ThemeProvider>().toggleTheme(),
          ),
        ],
      ),
      body: Consumer<RestaurantProvider>(
        builder: (context, provider, child) {
          final restaurantsState = _isSearching
              ? provider.searchState
              : provider.restaurantsState;

          return switch (restaurantsState) {
            ApiStateInitial() => const SizedBox(),
            ApiStateLoading() => const LoadingIndicator(),
            ApiStateSuccess(data: final restaurants) => ListView.builder(
              itemCount: restaurants.length,
              itemBuilder: (context, index) {
                final restaurant = restaurants[index];
                return RestaurantItem(
                  restaurant: restaurant,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/detail',
                      arguments: restaurant.id,
                    );
                  },
                );
              },
            ),
            ApiStateError(message: final message) => ErrorStateWidget(
              title: _isSearching
                  ? 'Search Failed'
                  : 'Failed to Load Restaurants',
              message: _getErrorMessage(message),
              onRetry: () {
                if (_isSearching) {
                  context.read<RestaurantProvider>().searchRestaurants(
                    _searchController.text,
                  );
                } else {
                  context.read<RestaurantProvider>().fetchRestaurants();
                }
              },
            ),
          };
        },
      ),
    );
  }
}
