import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/restaurant.dart';

class ApiService {
  // Hard Code URL (Sementara)
  static const String _baseUrl = 'https://restaurant-api.dicoding.dev';

  Future<List<Restaurant>> getRestaurants() async {
    final response = await http.get(Uri.parse('$_baseUrl/list'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);
      final List<dynamic> restaurants = json['restaurants'];
      return restaurants.map((json) => Restaurant.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load restaurants');
    }
  }

  Future<RestaurantDetail> getRestaurantDetail(String id) async {
    final response = await http.get(Uri.parse('$_baseUrl/detail/$id'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);
      return RestaurantDetail.fromJson(json['restaurant']);
    } else {
      throw Exception('Failed to load restaurant detail');
    }
  }

  Future<List<Restaurant>> searchRestaurants(String query) async {
    final response = await http.get(Uri.parse('$_baseUrl/search?q=$query'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);
      final List<dynamic> restaurants = json['restaurants'];
      return restaurants.map((json) => Restaurant.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search restaurants');
    }
  }

  Future<List<CustomerReview>> addReview({
    required String id,
    required String name,
    required String review,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/review'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id': id, 'name': name, 'review': review}),
      );

      final Map<String, dynamic> json = jsonDecode(response.body);

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          json['error'] == false) {
        final List<dynamic> reviews = json['customerReviews'];
        return reviews.map((json) => CustomerReview.fromJson(json)).toList();
      } else if (json['error'] == true) {
        throw Exception(json['message']);
      } else {
        throw Exception('Failed to add review');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Failed to add review: $e');
    }
  }

  static String getImageUrl(
    String pictureId, {
    ImageSize size = ImageSize.medium,
  }) {
    switch (size) {
      case ImageSize.small:
        return '$_baseUrl/images/small/$pictureId';
      case ImageSize.medium:
        return '$_baseUrl/images/medium/$pictureId';
      case ImageSize.large:
        return '$_baseUrl/images/large/$pictureId';
    }
  }
}

enum ImageSize { small, medium, large }
