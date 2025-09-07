import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_resto_app/data/services/api_service.dart';
import 'package:flutter_resto_app/data/services/api_state.dart';
import 'package:flutter_resto_app/data/providers/restaurant_provider.dart';
import 'package:flutter_resto_app/data/models/restaurant.dart';

import 'restaurant_provider_test.mocks.dart';

@GenerateMocks([ApiService])
void main() {
  late RestaurantProvider provider;
  late MockApiService mockApiService;

  setUp(() {
    mockApiService = MockApiService();
    provider = RestaurantProvider(mockApiService);
  });

  // Test Initial state
  // Memastikan semua state (restaurantsState, searchState, restaurantDetailState) diinisialisasi dengan benar sebagai ApiStateInitialMemverifikasi bahwa provider memiliki state awal yang terdefinisi
  group('RestaurantProvider Tests', () {
    final mockRestaurants = [
      Restaurant(
        id: '1',
        name: 'Test Restaurant',
        description: 'Test Description',
        pictureId: 'test.jpg',
        city: 'Test City',
        rating: 4.5,
      ),
    ];

    test('Initial state should be ApiStateInitial', () {
      expect(provider.restaurantsState, isA<ApiStateInitial>());
      expect(provider.searchState, isA<ApiStateInitial>());
      expect(provider.restaurantDetailState, isA<ApiStateInitial>());
    });

    // Test API Call
    // Menggunakan mock untuk simulasi API call sukses dan gagalnya, serta memverifikasi bahwa state diperbarui dengan benar
    test(
      'Should return list of restaurants when API call is successful',
      () async {
        // Arrange
        when(
          mockApiService.getRestaurants(),
        ).thenAnswer((_) async => mockRestaurants);

        // Act
        await provider.fetchRestaurants();

        // Assert
        verify(mockApiService.getRestaurants()).called(1);
        expect(
          provider.restaurantsState,
          isA<ApiStateSuccess<List<Restaurant>>>(),
        );

        final state =
            provider.restaurantsState as ApiStateSuccess<List<Restaurant>>;
        expect(state.data, equals(mockRestaurants));
      },
    );

    // Test Failed API Call
    // Menggunakan mock untuk simulasi API call gagal, serta memverifikasi bahwa state diperbarui dengan benar
    test('Should return error when API call fails', () async {
      // Arrange
      const errorMessage = 'Failed to fetch restaurants';
      when(mockApiService.getRestaurants()).thenThrow(Exception(errorMessage));

      // Act
      await provider.fetchRestaurants();

      // Assert
      verify(mockApiService.getRestaurants()).called(1);
      expect(provider.restaurantsState, isA<ApiStateError>());

      final state = provider.restaurantsState as ApiStateError;
      expect(state.message, contains(errorMessage));
    });
  });
}
