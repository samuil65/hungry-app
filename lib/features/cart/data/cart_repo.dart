import 'package:huungry/core/network/api_error.dart';
import 'package:huungry/core/network/api_service.dart';
import 'package:huungry/features/cart/data/cart_model.dart';

class CartRepo {
  final ApiService _apiService = ApiService();

  /// AddToCart
  Future<void> addToCart(CartRequestModel cartData) async {
    try {
      final res = await _apiService.post('/cart/add', cartData.toJson());

      if (res is ApiError) {
        throw res;
      }

      if (res is Map<String, dynamic> &&
          res['code'] != null &&
          res['code'] != 200) {
        throw ApiError(message: res['message'] ?? 'Unable to add item to cart');
      }
    } catch (e) {
      if (e is ApiError) {
        throw e;
      }
      throw ApiError(message: e.toString());
    }
  }

  /// GetCart
  Future<GetCartResponse?> getCartData() async {
    try {
      final res = await _apiService.get('/cart');

      if (res is ApiError) {
        throw ApiError(message: res.message);
      }

      return GetCartResponse.fromJson(res);
    } catch (e) {
      throw ApiError(message: e.toString());
    }
  }

  /// deleteCartItem
  Future<void> removeCartItem(int id) async {
    try {
      final res = await _apiService.delete('/cart/remove/$id', {});

      if (res is ApiError) {
        throw res;
      }

      if (res is! Map<String, dynamic>) {
        throw ApiError(message: 'Unexpected response while removing from cart');
      }

      if (res['code'] == 200 && res['data'] == null) {
        throw ApiError(
          message: res['message'] ?? 'Unable to remove item from cart',
        );
      }
    } catch (e) {
      if (e is ApiError) {
        throw e;
      }
      throw ApiError(message: 'Remove Item From Cart : ${e.toString()}');
    }
  }
}
