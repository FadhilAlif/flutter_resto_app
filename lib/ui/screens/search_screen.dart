import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/restaurant_provider.dart';
import '../../data/providers/theme_provider.dart';
import '../../data/services/api_state.dart';
import '../../utils/debouncer.dart';
import '../widgets/error_state.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/restaurant_item.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final _debouncer = Debouncer();

  @override
  void dispose() {
    _searchController.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debouncer.run(() {
      if (!mounted) return;
      context.read<RestaurantProvider>().searchRestaurants(query);
    });
  }

  String _getErrorMessage(String message) {
    if (message.toLowerCase().contains('failed to connect') ||
        message.toLowerCase().contains('socket')) {
      return 'Unable to connect to the server.\nPlease check your internet connection and try again.';
    } else if (message.toLowerCase().contains('timeout')) {
      return 'Connection timed out.\nPlease check your internet connection and try again.';
    } else {
      return 'Failed to search restaurants.\nPlease try again with different keywords.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search restaurants...',
            border: InputBorder.none,
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      context.read<RestaurantProvider>().searchRestaurants('');
                    },
                  )
                : null,
          ),
          onChanged: _onSearchChanged,
          textInputAction: TextInputAction.search,
        ),
        actions: [
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
          PopupMenuButton<ColorSeed>(
            icon: const Icon(Icons.palette),
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
        ],
      ),
      body: Consumer<RestaurantProvider>(
        builder: (context, provider, child) {
          return switch (provider.searchState) {
            ApiStateInitial() => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search,
                    size: 100,
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Search for restaurants\nby name, category, or menu',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            ApiStateLoading() => const LoadingIndicator(),
            ApiStateSuccess(data: final restaurants) =>
              restaurants.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 100,
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No restaurants found\nTry different keywords',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primary.withValues(alpha: 0.7),
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: restaurants.length,
                      padding: const EdgeInsets.symmetric(vertical: 8),
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
              title: 'Search Failed',
              message: _getErrorMessage(message),
              onRetry: () {
                context.read<RestaurantProvider>().searchRestaurants(
                  _searchController.text,
                );
              },
            ),
          };
        },
      ),
    );
  }
}
