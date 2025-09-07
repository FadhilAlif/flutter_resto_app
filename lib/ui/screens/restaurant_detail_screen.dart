import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/restaurant_provider.dart';
import '../../data/providers/favorite_provider.dart';
import '../../data/services/api_service.dart';
import '../../data/services/api_state.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/toast.dart';
import '../widgets/error_state.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final String restaurantId;

  const RestaurantDetailScreen({super.key, required this.restaurantId});

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  final _reviewController = TextEditingController();
  final _nameController = TextEditingController();

  String _getErrorMessage(String message) {
    if (message.toLowerCase().contains('failed to connect') ||
        message.toLowerCase().contains('socket')) {
      return 'Unable to connect to the server.\nPlease check your internet connection and try again.';
    } else if (message.toLowerCase().contains('timeout')) {
      return 'Connection timed out.\nPlease check your internet connection and try again.';
    } else {
      return 'Failed to load restaurant details.\nPlease try again.';
    }
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<RestaurantProvider>().fetchRestaurantDetail(
        widget.restaurantId,
      );
    });
  }

  @override
  void dispose() {
    _reviewController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _showReviewDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add Review'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Your Name',
                hintText: 'Enter your name',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _reviewController,
              decoration: const InputDecoration(
                labelText: 'Review',
                hintText: 'Write your review',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (_nameController.text.isEmpty ||
                  _reviewController.text.isEmpty) {
                return;
              }

              final error = await context.read<RestaurantProvider>().addReview(
                restaurantId: widget.restaurantId,
                name: _nameController.text,
                review: _reviewController.text,
              );

              // Lindungi context milik builder setelah await:
              if (!dialogContext.mounted) return;

              if (error == null) {
                Navigator.of(dialogContext).pop();
                _nameController.clear();
                _reviewController.clear();
                showToast(dialogContext, message: 'Review added successfully!');
              } else {
                showToast(dialogContext, message: error, isError: true);
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<RestaurantProvider>(
        builder: (context, provider, child) {
          return switch (provider.restaurantDetailState) {
            ApiStateInitial() => const SizedBox(),
            ApiStateLoading() => const LoadingIndicator(),
            ApiStateSuccess(data: final restaurant) => CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 200,
                  pinned: true,
                  actions: [
                    Consumer<FavoriteProvider>(
                      builder: (context, provider, child) {
                        return FutureBuilder<bool>(
                          future: provider.isFavorited(restaurant.id),
                          builder: (context, snapshot) {
                            final isFavorited = snapshot.data ?? false;
                            return IconButton(
                              icon: Icon(
                                isFavorited
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                if (isFavorited) {
                                  provider.removeFavorite(restaurant.id);
                                } else {
                                  provider.addFavorite(restaurant);
                                }
                              },
                            );
                          },
                        );
                      },
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    title: Hero(
                      tag: 'name-${restaurant.id}',
                      child: Material(
                        color: Colors.transparent,
                        child: Text(
                          restaurant.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    background: Hero(
                      tag: 'image-${restaurant.id}',
                      child: Image.network(
                        ApiService.getImageUrl(
                          restaurant.pictureId,
                          size: ImageSize.large,
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.location_on),
                            const SizedBox(width: 8),
                            Text('${restaurant.city} - ${restaurant.address}'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber),
                            const SizedBox(width: 8),
                            Text(restaurant.rating.toString()),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Description',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(restaurant.description),
                        const SizedBox(height: 16),
                        Text(
                          'Categories',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: restaurant.categories
                              .map(
                                (category) => Chip(label: Text(category.name)),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Menu',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        ExpansionTile(
                          title: const Text('Foods'),
                          children: restaurant.menus.foods
                              .map(
                                (food) => ListTile(
                                  title: Text(food.name),
                                  leading: const Icon(Icons.restaurant),
                                ),
                              )
                              .toList(),
                        ),
                        ExpansionTile(
                          title: const Text('Drinks'),
                          children: restaurant.menus.drinks
                              .map(
                                (drink) => ListTile(
                                  title: Text(drink.name),
                                  leading: const Icon(Icons.local_drink),
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Reviews',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            TextButton.icon(
                              onPressed: _showReviewDialog,
                              icon: const Icon(Icons.add),
                              label: const Text('Add Review'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...restaurant.customerReviews.map(
                          (review) => Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        review.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        review.date,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(review.review),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            ApiStateError(message: final message) => ErrorStateWidget(
              title: 'Failed to Load Restaurant',
              message: _getErrorMessage(message),
              onRetry: () {
                context.read<RestaurantProvider>().fetchRestaurantDetail(
                  widget.restaurantId,
                );
              },
            ),
          };
        },
      ),
    );
  }
}
