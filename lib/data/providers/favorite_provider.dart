import 'package:flutter/foundation.dart';
import 'package:flutter_resto_app/data/db/database_helper.dart';
import 'package:flutter_resto_app/data/models/restaurant.dart';

class FavoriteProvider extends ChangeNotifier {
  final DatabaseHelper databaseHelper;

  FavoriteProvider({required this.databaseHelper}) {
    _getFavorites();
  }

  List<Restaurant> _favorites = [];
  List<Restaurant> get favorites => _favorites;

  void _getFavorites() async {
    _favorites = await databaseHelper.getFavorites();
    notifyListeners();
  }

  Future<bool> isFavorited(String id) async {
    final favoriteRestaurant = await databaseHelper.getFavoriteById(id);
    return favoriteRestaurant != null;
  }

  void addFavorite(Restaurant restaurant) async {
    await databaseHelper.insertFavorite(restaurant);
    _getFavorites();
  }

  void removeFavorite(String id) async {
    await databaseHelper.removeFavorite(id);
    _getFavorites();
  }
}
