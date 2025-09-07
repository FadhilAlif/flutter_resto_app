import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_resto_app/data/providers/favorite_provider.dart';
import 'package:flutter_resto_app/ui/widgets/restaurant_item.dart';

class FavoriteScreen extends StatelessWidget {
  static const routeName = '/favorite';

  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorite Restaurants')),
      body: Consumer<FavoriteProvider>(
        builder: (context, provider, child) {
          if (provider.favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 100,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No favorite restaurants yet',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.favorites.length,
            itemBuilder: (context, index) {
              final restaurant = provider.favorites[index];
              return RestaurantItem(
                restaurant: restaurant,
                onTap: () => Navigator.pushNamed(
                  context,
                  '/detail',
                  arguments: restaurant.id,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
