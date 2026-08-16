import 'dart:convert';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class MetaAnalyticsService extends GetxService {
  final FacebookAppEvents _facebookAppEvents = FacebookAppEvents();

  /// Called when the application starts
  Future<void> activateApp() async {
    try {
      // Typically, setting advertiser tracking and auto log is enough for activate app on startup
      await _facebookAppEvents.setAdvertiserTracking(enabled: true);
      await _facebookAppEvents.setAutoLogAppEventsEnabled(true);
      debugPrint('Meta: activateApp triggered');
    } catch (e) {
      debugPrint('Meta activateApp error: $e');
    }
  }

  /// Called after successful account creation
  Future<void> completeRegistration({required String registrationMethod}) async {
    try {
      await _facebookAppEvents.logEvent(
        name: 'CompleteRegistration',
        parameters: {
          'registration_method': registrationMethod,
        },
      );
      debugPrint('Meta: completeRegistration triggered ($registrationMethod)');
    } catch (e) {
      debugPrint('Meta completeRegistration error: $e');
    }
  }

  /// Called after successful login
  Future<void> login({required String loginMethod}) async {
    try {
      // Can be a standard event if used as custom event or native standard event.
      // Usually "Login" or we can just use the custom string if no standard method exists.
      await _facebookAppEvents.logEvent(
        name: 'Login',
        parameters: {
          'login_method': loginMethod,
        },
      );
      debugPrint('Meta: login triggered ($loginMethod)');
    } catch (e) {
      debugPrint('Meta login error: $e');
    }
  }

  /// Called whenever a user performs a search
  Future<void> search({required String searchString}) async {
    try {
      await _facebookAppEvents.logEvent(
        name: 'Search',
        parameters: {
          'search_string': searchString,
        },
      );
      debugPrint('Meta: search triggered ($searchString)');
    } catch (e) {
      debugPrint('Meta search error: $e');
    }
  }

  /// Called when a user views a category
  Future<void> viewCategory({required String categoryId, required String categoryName}) async {
    try {
      await _facebookAppEvents.logEvent(
        name: 'view_category',
        parameters: {
          'category_id': categoryId,
          'category_name': categoryName,
        },
      );
      debugPrint('Meta: viewCategory triggered ($categoryName)');
    } catch (e) {
      debugPrint('Meta viewCategory error: $e');
    }
  }

  /// Called when a user views product details
  Future<void> viewContent({
    required String contentId,
    required String contentName,
    String currency = 'EGP',
    required double value,
    required String category,
    List<String>? contentIds,
    List<Map<String, dynamic>>? contents,
  }) async {
    try {
      await _facebookAppEvents.logEvent(
        name: 'fb_mobile_content_view',
        valueToSum: value,
        parameters: {
          'fb_content_id': contentIds != null ? jsonEncode(contentIds) : contentId,
          'fb_content_type': 'product',
          'fb_currency': currency,
          if (contents != null) 'fb_content': jsonEncode(contents),
        },
      );
      // Extra params like content_name and category can be logged via a complementary custom event if needed
      // Or we can rely on logViewContent's core standard capability
      debugPrint('Meta: viewContent triggered ($contentName)');
    } catch (e) {
      debugPrint('Meta viewContent error: $e');
    }
  }

  /// Called when a product is added to wishlist
  Future<void> addWishlist({
    required String contentId,
    required String contentName,
    String currency = 'EGP',
    required double value,
  }) async {
    try {
      await _facebookAppEvents.logEvent(
        name: 'add_to_wishlist',
        parameters: {
          'content_id': contentId,
          'content_name': contentName,
          'currency': currency,
          'value': value,
        },
      );
      debugPrint('Meta: addWishlist triggered ($contentName)');
    } catch (e) {
      debugPrint('Meta addWishlist error: $e');
    }
  }

  /// Called when a product is added to cart
  Future<void> addToCart({
    required String contentId,
    required String contentName,
    required int quantity,
    required double price,
    String currency = 'EGP',
    required double value,
    List<String>? contentIds,
    List<Map<String, dynamic>>? contents,
  }) async {
    try {
      await _facebookAppEvents.logEvent(
        name: 'fb_mobile_add_to_cart',
        valueToSum: value,
        parameters: {
          'fb_content_id': contentIds != null ? jsonEncode(contentIds) : contentId,
          'fb_content_type': 'product',
          'fb_currency': currency,
          if (contents != null) 'fb_content': jsonEncode(contents),
        },
      );
      debugPrint('Meta: addToCart triggered ($contentName, qty: $quantity)');
    } catch (e) {
      debugPrint('Meta addToCart error: $e');
    }
  }

  /// Called when a product is removed from cart
  Future<void> removeFromCart({
    required String contentId,
    required String contentName,
  }) async {
    try {
      await _facebookAppEvents.logEvent(
        name: 'remove_from_cart',
        parameters: {
          'content_id': contentId,
          'content_name': contentName,
        },
      );
      debugPrint('Meta: removeFromCart triggered ($contentName)');
    } catch (e) {
      debugPrint('Meta removeFromCart error: $e');
    }
  }

  /// Called when checkout is initiated
  Future<void> initiateCheckout({
    required double value,
    String currency = 'EGP',
    required int numItems,
    List<String>? contentIds,
    List<Map<String, dynamic>>? contents,
  }) async {
    try {
      await _facebookAppEvents.logEvent(
        name: 'fb_mobile_initiated_checkout',
        valueToSum: value,
        parameters: {
          if (contentIds != null) 'fb_content_id': jsonEncode(contentIds),
          'fb_content_type': 'product',
          'fb_currency': currency,
          'fb_num_items': numItems,
          if (contents != null) 'fb_content': jsonEncode(contents),
        },
      );
      debugPrint('Meta: initiateCheckout triggered');
    } catch (e) {
      debugPrint('Meta initiateCheckout error: $e');
    }
  }

  /// Called when payment info is added
  Future<void> addPaymentInfo() async {
    try {
      await _facebookAppEvents.logEvent(name: 'AddPaymentInfo');
      debugPrint('Meta: addPaymentInfo triggered');
    } catch (e) {
      debugPrint('Meta addPaymentInfo error: $e');
    }
  }

  /// Called when an order is completed successfully
  Future<void> purchase({
    required String orderId,
    required double value,
    String currency = 'EGP',
    required int numItems,
    required String paymentMethod,
    String? coupon,
    List<String>? contentIds,
    List<Map<String, dynamic>>? contents,
  }) async {
    try {
      await _facebookAppEvents.logPurchase(
        amount: value,
        currency: currency,
        parameters: {
          'order_id': orderId,
          'num_items': numItems,
          'payment_method': paymentMethod,
          if (coupon != null) 'coupon': coupon,
          if (contentIds != null) 'fb_content_id': jsonEncode(contentIds),
          'fb_content_type': 'product',
          if (contents != null) 'fb_content': jsonEncode(contents),
        },
      );
      debugPrint('Meta: purchase triggered ($orderId)');
    } catch (e) {
      debugPrint('Meta purchase error: $e');
    }
  }

  /// Called when an order is cancelled
  Future<void> cancelOrder({required String orderId}) async {
    try {
      await _facebookAppEvents.logEvent(
        name: 'cancel_order',
        parameters: {
          'order_id': orderId,
        },
      );
      debugPrint('Meta: cancelOrder triggered ($orderId)');
    } catch (e) {
      debugPrint('Meta cancelOrder error: $e');
    }
  }

  /// Called when an order is reordered
  Future<void> reorder({required String orderId}) async {
    try {
      await _facebookAppEvents.logEvent(
        name: 'reorder',
        parameters: {
          'order_id': orderId,
        },
      );
      debugPrint('Meta: reorder triggered ($orderId)');
    } catch (e) {
      debugPrint('Meta reorder error: $e');
    }
  }

  /// Called when a product is rated/reviewed
  Future<void> rateProduct({required String contentId, required double rating}) async {
    try {
      await _facebookAppEvents.logEvent(
        name: 'rate_product',
        parameters: {
          'content_id': contentId,
          'rating': rating,
        },
      );
      debugPrint('Meta: rateProduct triggered ($contentId)');
    } catch (e) {
      debugPrint('Meta rateProduct error: $e');
    }
  }

  /// Called when contacting the store
  Future<void> contactStore({required String storeId}) async {
    try {
      await _facebookAppEvents.logEvent(
        name: 'contact_store',
        parameters: {
          'store_id': storeId,
        },
      );
      debugPrint('Meta: contactStore triggered ($storeId)');
    } catch (e) {
      debugPrint('Meta contactStore error: $e');
    }
  }

  /// Called when a coupon is applied
  Future<void> applyCoupon({required String coupon}) async {
    try {
      await _facebookAppEvents.logEvent(
        name: 'apply_coupon',
        parameters: {
          'coupon': coupon,
        },
      );
      debugPrint('Meta: applyCoupon triggered ($coupon)');
    } catch (e) {
      debugPrint('Meta applyCoupon error: $e');
    }
  }
}
