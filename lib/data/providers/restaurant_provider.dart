import 'package:flutter/material.dart';
import '../models/restaurant.dart';
import '../services/api_service.dart';
import '../services/api_state.dart';

class RestaurantProvider extends ChangeNotifier {
  final ApiService _apiService;

  RestaurantProvider(this._apiService);

  ApiState<List<Restaurant>> _restaurantsState = ApiStateInitial();
  ApiState<RestaurantDetail> _restaurantDetailState = ApiStateInitial();
  ApiState<List<Restaurant>> _searchState = ApiStateInitial();

  ApiState<List<Restaurant>> get restaurantsState => _restaurantsState;
  ApiState<RestaurantDetail> get restaurantDetailState =>
      _restaurantDetailState;
  ApiState<List<Restaurant>> get searchState => _searchState;

  Future<void> fetchRestaurants() async {
    try {
      _restaurantsState = ApiStateLoading();
      notifyListeners();

      final restaurants = await _apiService.getRestaurants();
      _restaurantsState = ApiStateSuccess(restaurants);
      notifyListeners();
    } catch (e) {
      _restaurantsState = ApiStateError(e.toString());
      notifyListeners();
    }
  }

  Future<void> fetchRestaurantDetail(String id) async {
    try {
      _restaurantDetailState = ApiStateLoading();
      notifyListeners();

      final restaurant = await _apiService.getRestaurantDetail(id);
      _restaurantDetailState = ApiStateSuccess(restaurant);
      notifyListeners();
    } catch (e) {
      _restaurantDetailState = ApiStateError(e.toString());
      notifyListeners();
    }
  }

  Future<void> searchRestaurants(String query) async {
    if (query.isEmpty) {
      _searchState = ApiStateInitial();
      notifyListeners();
      return;
    }

    try {
      _searchState = ApiStateLoading();
      notifyListeners();

      final restaurants = await _apiService.searchRestaurants(query);
      _searchState = ApiStateSuccess(restaurants);
      notifyListeners();
    } catch (e) {
      _searchState = ApiStateError(e.toString());
      notifyListeners();
    }
  }

  Future<String?> addReview({
    required String restaurantId,
    required String name,
    required String review,
  }) async {
    try {
      final reviews = await _apiService.addReview(
        id: restaurantId,
        name: name,
        review: review,
      );

      // Update the current restaurant detail state with new reviews
      if (_restaurantDetailState is ApiStateSuccess<RestaurantDetail>) {
        final currentState =
            _restaurantDetailState as ApiStateSuccess<RestaurantDetail>;
        final updatedRestaurant = RestaurantDetail(
          id: currentState.data.id,
          name: currentState.data.name,
          description: currentState.data.description,
          pictureId: currentState.data.pictureId,
          city: currentState.data.city,
          rating: currentState.data.rating,
          address: currentState.data.address,
          categories: currentState.data.categories,
          menus: currentState.data.menus,
          customerReviews: reviews, // Update with new reviews
        );
        _restaurantDetailState = ApiStateSuccess(updatedRestaurant);
        notifyListeners();
      }

      return null; // Success
    } catch (e) {
      return e.toString(); // Return error message
    }
  }
}
