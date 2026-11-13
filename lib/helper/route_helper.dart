import 'dart:convert';

import 'package:Oxygen_Mart/common/widgets/image_viewer_screen.dart';
import 'package:Oxygen_Mart/common/widgets/not_found.dart';
import 'package:Oxygen_Mart/features/address/domain/models/address_model.dart';
import 'package:Oxygen_Mart/features/address/screens/add_address_screen.dart';
import 'package:Oxygen_Mart/features/address/screens/address_screen.dart';
import 'package:Oxygen_Mart/features/ai_chat_bot/screens/ai_chat_bot_screen.dart';
import 'package:Oxygen_Mart/features/ai_chat_bot/screens/ai_chat_details_screen.dart';
import 'package:Oxygen_Mart/features/auth/screens/delivery_man_registration_screen.dart';
import 'package:Oxygen_Mart/features/auth/screens/new_user_setup_screen.dart';
import 'package:Oxygen_Mart/features/auth/screens/rider_registration_screen.dart';
import 'package:Oxygen_Mart/features/auth/screens/sign_in_screen.dart';
import 'package:Oxygen_Mart/features/auth/screens/sign_up_screen.dart';
import 'package:Oxygen_Mart/features/auth/screens/store_registration_screen.dart';
import 'package:Oxygen_Mart/features/verification/screens/forget_pass_screen.dart';
import 'package:Oxygen_Mart/features/verification/screens/new_pass_screen.dart';
import 'package:Oxygen_Mart/features/verification/screens/verification_screen.dart';
import 'package:Oxygen_Mart/features/brands/screens/brands_product_screen.dart';
import 'package:Oxygen_Mart/features/brands/screens/brands_screen.dart';
import 'package:Oxygen_Mart/features/business/screens/subscription_payment_screen.dart';
import 'package:Oxygen_Mart/features/business/screens/subscription_success_or_failed_screen.dart';
import 'package:Oxygen_Mart/features/cart/screens/cart_screen.dart';
import 'package:Oxygen_Mart/features/cart/screens/global_cart_screen.dart';
import 'package:Oxygen_Mart/features/category/screens/category_item_screen.dart';
import 'package:Oxygen_Mart/features/category/screens/category_screen.dart';
import 'package:Oxygen_Mart/features/chat/domain/models/conversation_model.dart';
import 'package:Oxygen_Mart/features/chat/domain/models/order_chat_model.dart';
import 'package:Oxygen_Mart/features/chat/screens/chat_screen.dart';
import 'package:Oxygen_Mart/features/chat/screens/conversation_screen.dart';
import 'package:Oxygen_Mart/features/checkout/screens/checkout_screen.dart';
import 'package:Oxygen_Mart/features/checkout/screens/order_successful_screen.dart';
import 'package:Oxygen_Mart/features/coupon/screens/coupon_screen.dart';
import 'package:Oxygen_Mart/features/dashboard/screens/dashboard_screen.dart';
import 'package:Oxygen_Mart/features/favourite/screens/favourite_screen.dart';
import 'package:Oxygen_Mart/features/flash_sale/screens/flash_sale_details_screen.dart';
import 'package:Oxygen_Mart/features/home/screens/all_stores_screen.dart';
import 'package:Oxygen_Mart/features/home/screens/preference_screen.dart';
import 'package:Oxygen_Mart/features/html/screens/html_viewer_screen.dart';
import 'package:Oxygen_Mart/features/interest/screens/interest_screen.dart';
import 'package:Oxygen_Mart/features/splash/screens/qr_screen.dart';
import 'package:Oxygen_Mart/features/item/domain/models/basic_campaign_model.dart';
import 'package:Oxygen_Mart/features/item/domain/models/item_model.dart';
import 'package:Oxygen_Mart/features/item/screens/item_campaign_screen.dart';
import 'package:Oxygen_Mart/features/item/screens/item_details_screen.dart';
import 'package:Oxygen_Mart/features/item/screens/popular_item_screen.dart';
import 'package:Oxygen_Mart/features/language/screens/language_new_screen.dart';
import 'package:Oxygen_Mart/features/location/screens/access_location_screen.dart';
import 'package:Oxygen_Mart/features/location/screens/map_screen.dart';
import 'package:Oxygen_Mart/features/location/screens/pick_map_screen.dart';
import 'package:Oxygen_Mart/features/loyalty/screens/loyalty_screen.dart';
import 'package:Oxygen_Mart/features/notification/domain/models/notification_body_model.dart';
import 'package:Oxygen_Mart/features/notification/screens/notification_screen.dart';
import 'package:Oxygen_Mart/features/onboard/screens/onboarding_new_screen.dart';
import 'package:Oxygen_Mart/features/order/domain/models/order_model.dart';
import 'package:Oxygen_Mart/features/order/screens/guest_track_order_screen.dart';
import 'package:Oxygen_Mart/features/order/screens/order_details_screen.dart';
import 'package:Oxygen_Mart/features/order/screens/order_screen.dart';
import 'package:Oxygen_Mart/features/order/screens/order_tracking_screen.dart';
import 'package:Oxygen_Mart/features/order/screens/refund_request_screen.dart';
import 'package:Oxygen_Mart/features/parcel/domain/models/parcel_category_model.dart';
import 'package:Oxygen_Mart/features/parcel/screens/parcel_category_screen.dart';
import 'package:Oxygen_Mart/features/parcel/screens/parcel_location_screen.dart';
import 'package:Oxygen_Mart/features/parcel/screens/parcel_request_screen.dart';
import 'package:Oxygen_Mart/features/payment/screens/offline_payment_screen.dart';
import 'package:Oxygen_Mart/features/payment/screens/payment_screen.dart';
import 'package:Oxygen_Mart/features/payment/screens/payment_webview_screen.dart';
import 'package:Oxygen_Mart/features/pro/screens/subscription_plan_screen.dart';
import 'package:Oxygen_Mart/features/profile/domain/models/update_user_model.dart';
import 'package:Oxygen_Mart/features/profile/screens/profile_screen.dart';
import 'package:Oxygen_Mart/features/profile/screens/update_profile_screen.dart';
import 'package:Oxygen_Mart/features/refer_and_earn/screens/refer_and_earn_screen.dart';
import 'package:Oxygen_Mart/features/rental_module/rental_cart_screen/rental_cart_screen.dart';
import 'package:Oxygen_Mart/features/rental_module/vendor/screens/provider_detail_screen.dart';
import 'package:Oxygen_Mart/features/review/screens/review_screen.dart';
import 'package:Oxygen_Mart/features/ride_share_module/ride_location/screens/map_screen.dart' as ride_map;
import 'package:Oxygen_Mart/features/ride_share_module/safety_alert/screens/safety_policy_screen.dart';
import 'package:Oxygen_Mart/features/search/screens/search_screen.dart';
import 'package:Oxygen_Mart/features/service_module/booking_details/screens/booking_details_screen.dart';
import 'package:Oxygen_Mart/features/service_module/booking_details/screens/my_bookings_screen.dart';
import 'package:Oxygen_Mart/features/service_module/booking_details/screens/track_booking_screen.dart';
import 'package:Oxygen_Mart/features/service_module/common/models/service_provider_model.dart';
import 'package:Oxygen_Mart/features/service_module/custom_service_request/screens/custom_service_details_screen.dart';
import 'package:Oxygen_Mart/features/service_module/custom_service_request/screens/custom_service_list_screen.dart';
import 'package:Oxygen_Mart/features/service_module/custom_service_request/screens/custom_service_request_screen.dart';
import 'package:Oxygen_Mart/features/service_module/provider_details/screens/provider_details_screen.dart';
import 'package:Oxygen_Mart/features/service_module/provider_details/screens/provider_service_search_screen.dart';
import 'package:Oxygen_Mart/features/service_module/request_service/screens/new_service_request_screen.dart';
import 'package:Oxygen_Mart/features/service_module/request_service/screens/requested_service_screen.dart';
import 'package:Oxygen_Mart/features/service_module/service_campaign/screens/service_campaign_detail_screen.dart';
import 'package:Oxygen_Mart/features/service_module/service_cart/screens/service_cart_screen.dart';
import 'package:Oxygen_Mart/features/service_module/service_category/screens/service_category_screen.dart';
import 'package:Oxygen_Mart/features/service_module/service_checkout/domain/models/service_buy_now_variant.dart';
import 'package:Oxygen_Mart/features/service_module/service_checkout/screens/service_bid_checkout_screen.dart';
import 'package:Oxygen_Mart/features/service_module/service_checkout/screens/service_booking_success_screen.dart';
import 'package:Oxygen_Mart/features/service_module/service_checkout/screens/service_buy_now_checkout_screen.dart';
import 'package:Oxygen_Mart/features/service_module/service_checkout/screens/service_checkout_screen.dart';
import 'package:Oxygen_Mart/features/service_module/service_checkout/widgets/service_digital_payment_failed_screen.dart';
import 'package:Oxygen_Mart/features/service_module/service_details/screens/service_details_screen.dart';
import 'package:Oxygen_Mart/features/service_module/service_home/domain/models/service_category_model.dart';
import 'package:Oxygen_Mart/features/service_module/service_review/screens/provider_reviews_screen.dart';
import 'package:Oxygen_Mart/features/service_module/service_review/screens/service_reviews_screen.dart';
import 'package:Oxygen_Mart/features/splash/controllers/splash_controller.dart';
import 'package:Oxygen_Mart/features/splash/screens/splash_screen.dart';
import 'package:Oxygen_Mart/features/store/domain/models/store_model.dart';
import 'package:Oxygen_Mart/features/store/screens/all_store_screen.dart';
import 'package:Oxygen_Mart/features/store/screens/campaign_screen.dart';
import 'package:Oxygen_Mart/features/store/screens/store_item_search_screen.dart';
import 'package:Oxygen_Mart/features/store/screens/store_screen.dart';
import 'package:Oxygen_Mart/features/support/screens/support_screen.dart';
import 'package:Oxygen_Mart/features/update/screens/update_screen.dart';
import 'package:Oxygen_Mart/features/wallet/screens/wallet_screen.dart';
import 'package:Oxygen_Mart/helper/address_helper.dart';
import 'package:Oxygen_Mart/helper/analytics_route_wrapper.dart';
import 'package:Oxygen_Mart/helper/date_converter.dart';
import 'package:Oxygen_Mart/api/api_client.dart';
import 'package:Oxygen_Mart/common/enums/data_source_enum.dart';
import 'package:Oxygen_Mart/common/models/module_model.dart';
import 'package:Oxygen_Mart/common/models/response_model.dart';
import 'package:Oxygen_Mart/common/widgets/custom_loader.dart';
import 'package:Oxygen_Mart/common/widgets/custom_snackbar.dart';
import 'package:Oxygen_Mart/features/auth/controllers/auth_controller.dart';
import 'package:Oxygen_Mart/features/home/screens/home_screen.dart';
import 'package:Oxygen_Mart/features/language/controllers/language_controller.dart';
import 'package:Oxygen_Mart/helper/auth_helper.dart';
import 'package:Oxygen_Mart/helper/module_helper.dart';
import 'package:Oxygen_Mart/util/app_constants.dart';
import 'package:Oxygen_Mart/util/html_type.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Oxygen_Mart/features/bogo_offer/screen/bogo_offer_details_screen.dart';
import 'package:Oxygen_Mart/features/bogo_offer/screen/bogo_offer_screen.dart';


class RouteHelper {
  static const String initial = '/';
  static const String splash = '/splash';
  static const String language = '/language';
  static const String onBoarding = '/on-boarding';
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
  static const String verification = '/verification';
  static const String accessLocation = '/access-location';
  static const String pickMap = '/pick-map';
  static const String interest = '/interest';
  static const String main = '/main';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String search = '/search';
  static const String store = '/store';
  static const String orderDetails = '/order-details';
  static const String profile = '/profile';
  static const String updateProfile = '/update-profile';
  static const String coupon = '/coupon';
  static const String notification = '/notification';
  static const String map = '/map';
  static const String address = '/address';
  static const String orderSuccess = '/order-successful';
  static const String payment = '/payment';
  static const String checkout = '/checkout';
  static const String orderTracking = '/track-order';
  static const String basicCampaign = '/basic-campaign';
  static const String html = '/html-page';
  static const String privacyPolicy = '/privacy-policy';
  static const String cancellationPolicy = '/cancellation-policy';
  static const String refundPolicy = '/refund-policy';
  static const String termsAndCondition = '/terms-and-condition';
  static const String shippingPolicy = '/shipping-policy';
  static const String categories = '/categories';
  static const String categoryItem = '/category-item';
  static const String popularItems = '/popular-items';
  static const String itemCampaign = '/item-campaign';
  static const String support = '/help-and-support';
  static const String rateReview = '/rate-and-review';
  static const String update = '/update';
  static const String cart = '/cart';
  static const String globalCart = '/global-cart';
  static const String addAddress = '/add-address';
  static const String editAddress = '/edit-address';
  static const String storeReview = '/store-review';
  static const String allStores = '/stores';
  static const String itemImages = '/item-images';
  static const String parcelCategory = '/parcel-category';
  static const String parcelLocation = '/parcel-location';
  static const String parcelRequest = '/parcel-request';
  static const String rentalCart = '/rental-cart';
  static const String rideMap = '/ride-map';
  static const String vendorDetail = '/vendor-detail';
  static const String serviceDetails = '/service-details';
  static const String providerDetails = '/provider-details';
  static const String providerServiceSearch = '/provider-service-search';
  static const String serviceCategory = '/service-category';
  static const String serviceReviews = '/service-reviews';
  static const String providerReviews = '/provider-reviews';
  static const String searchStoreItem = '/search-store-item';
  static const String order = '/order';
  static const String itemDetails = '/item-details';
  static const String wallet = '/wallet';
  static const String loyalty = '/loyalty';
  static const String referAndEarn = '/refer-and-earn';
  static const String messages = '/messages';
  static const String conversation = '/conversation';
  static const String restaurantRegistration = '/store-registration';
  static const String deliveryManRegistration = '/delivery-man-registration';
  static const String riderRegistration = '/rider-registration';
  static const String refund = '/refund';
  static const String aiChatBot = '/ai-chat-bot';
  static const String aiChatDetails = '/ai-chat-details';
  static const String preference = '/preference';

  static const String offlinePaymentScreen = '/offline-payment-screen';
  static const String flashSaleDetailsScreen = '/flash-sale-details-screen';
  static const String bogoOfferScreen = '/bogo-offer';
  static const String bogoOfferDetailsScreen = '/bogo-offer-details';

  static const String guestTrackOrderScreen = '/guest-track-order-screen';
  static const String favourite = '/favourite';
  static const String brands = '/brands';
  static const String brandsItemScreen = '/brands-item-screen';

  static const String subscriptionSuccess = '/subscription-success';
  static const String subscriptionPayment = '/subscription-payment';
  static const String subscriptionPlan = '/subscription-plan';
  static const String newUserSetupScreen = '/new-user-setup-screen';
  static const String safety = '/safety';
  static const String customServiceRequest = '/custom-service-request';
  static const String customServiceList = '/custom-service-list';
  static const String customServiceDetails = '/custom-service-details';
  static const String requestedService = '/requested-service';
  static const String newServiceRequest = '/new-service-request';
  static const String serviceCheckout = '/service-checkout';
  static const String serviceBidCheckout = '/service-bid-checkout';
  static const String serviceBuyNowCheckout = '/service-buy-now-checkout';
  static const String serviceCampaignDetails = '/service-campaign-details';
  static const String serviceBookingSuccess = '/service-booking-success';
  static const String serviceCart = '/service-cart';
  static const String myBookings = '/my-bookings';
  static const String bookingDetails = '/booking-details';
  static const String subBookingDetails = '/sub-booking-details';
  static const String bookingTrack = '/booking-track';
  static const String serviceRateReview = '/service-rate-review';
  static const String serviceDigitalPaymentFailedScreen = '/service-digital-payment-failed-screen';
  static const String allStoresScreen = '/all-Stores';

  static String getAllStoreScreenRoute() => allStoresScreen;

  static String getInitialRoute({bool fromSplash = false, String? moduleId, bool fromDeeplink = false}) {
    String? targetModule;
    if (moduleId != null) {
      targetModule = moduleId;
    } else if (Get.find<SplashController>().configModel?.module != null) {
      targetModule = Get.find<SplashController>().configModel!.module!.slug ?? Get.find<SplashController>().configModel!.module!.id?.toString();
    } else if (!fromSplash) {
      targetModule = ModuleHelper.getModule()?.slug ?? ModuleHelper.getModule()?.id?.toString() ?? ModuleHelper.getCacheModule()?.slug;
    }

    String moduleParam = (targetModule != null && targetModule.isNotEmpty && targetModule != 'null') ? 'module=$targetModule&' : '';
    return '$initial?${moduleParam}from-splash=$fromSplash${fromDeeplink ? '&from_deeplink=true' : ''}';
  }
  static String getSplashRoute(NotificationBodyModel? body) {
    String data = 'null';
    if (body != null) {
      List<int> encoded = utf8.encode(jsonEncode(body.toJson()));
      data = base64Encode(encoded);
    }
    return '$splash?data=$data';
  }

  static String getLanguageRoute(String page) => '$language?page=$page';
  static String getOnBoardingRoute() => onBoarding;
  static String getSignInRoute(String page) => '$signIn?page=$page';
  static String getSignUpRoute() => signUp;

  static String getVerificationRoute(String? number, String? email, String? token, String page, String? pass, String loginType, {String? session, UpdateUserModel? updateUserModel, bool? backFromThis, String? customerName, String? orderId}) {
    String? authSession;
    String? userModel;
    if(session != null) {
      authSession = base64Url.encode(utf8.encode(session));
    }
    if(updateUserModel != null) {
      userModel = base64Url.encode(utf8.encode(jsonEncode(updateUserModel.toJson())));
    }
    String data = pass != null ? base64Url.encode(utf8.encode(pass)) : 'null';
    String? cleanNumber = number != null ? Uri.encodeComponent(number.replaceAll(' ', '')) : 'null';
    String? cleanEmail = email != null ? Uri.encodeComponent(email) : 'null';
    String? cleanName = customerName != null ? Uri.encodeComponent(customerName) : 'null';
    String? cleanOrderId = orderId != null ? Uri.encodeComponent(orderId) : 'null';
    return '$verification?page=$page&number=$cleanNumber&email=$cleanEmail&token=$token&pass=$data&session=$authSession&user_model=$userModel&login_type=$loginType&back_from_this=${backFromThis.toString()}&customer_name=$cleanName&order_id=$cleanOrderId';
  }
  static String getAccessLocationRoute(String page) =>
      '$accessLocation?page=$page';
  static String getPickMapRoute(String? page, bool canRoute) =>
      '$pickMap?page=$page&route=${canRoute.toString()}';
  static String getInterestRoute() => interest;
  static String getMainRoute(String page) => '$main?page=$page';

  static String getForgotPassRoute() => forgotPassword;

  static String getResetPasswordRoute({String? phone, String? email, required String token, required String page}) =>
      '$resetPassword?phone=$phone&token=$token&page=$page&email=$email';

  static String getSearchRoute({String? queryText}) =>
      '$search?query=${queryText ?? ''}&module=${ModuleHelper.getModule()?.slug ?? ModuleHelper.getModule()?.id}';
  static String getStoreRoute({required int? id, required String page, String? slug, String? moduleId, bool fromDeeplink = false}) {
    return '$store?id=$id&page=$page&module=${moduleId ?? ModuleHelper.getModule()?.slug ?? ModuleHelper.getModule()?.id}${fromDeeplink ? '&from_deeplink=true' : ''}';
  }

  static String getOrderDetailsRoute(int? orderID,
      {bool? fromNotification, bool? fromOffline, String? contactNumber}) {
    return '$orderDetails?id=$orderID&from=${fromNotification.toString()}&from_offline=$fromOffline&contact=$contactNumber';
  }

  static String getProfileRoute() => profile;
  static String getUpdateProfileRoute() => updateProfile;
  static String getCouponRoute() => coupon;
  static String getNotificationRoute({bool? fromNotification}) =>
      '$notification?from=${fromNotification.toString()}';
  static String getMapRoute(AddressModel addressModel, String page, bool isFood,
      {String? storeName, int? moduleId}) {
    List<int> encoded = utf8.encode(jsonEncode(addressModel.toJson()));
    String data = base64Encode(encoded);
    return '$map?address=$data&page=$page&module=$isFood&store-name=$storeName&module_id=${moduleId ?? ModuleHelper.getModule()?.id}';
  }

  static String getAddressRoute() => address;
  static String getOrderSuccessRoute(String orderID, String? contactNumber,
      {bool? createAccount, String guestId = '', String? customerName, String? customerEmail}) {
    String nameParam = customerName != null ? Uri.encodeComponent(customerName) : '';
    String emailParam = customerEmail != null ? Uri.encodeComponent(customerEmail) : '';
    String phoneParam = contactNumber != null ? Uri.encodeComponent(contactNumber) : '';
    return '$orderSuccess?id=$orderID&contact_number=$phoneParam&create_account=$createAccount&guest_id=$guestId&customer_name=$nameParam&customer_email=$emailParam';
  }

  static String? safeDecodeParam(String? value) {
    if (value == null || value.isEmpty || value == 'null') return null;
    try {
      if (value.contains('%')) {
        return Uri.decodeComponent(value);
      }
      return value;
    } catch (_) {
      return value;
    }
  }

  static String getPaymentRoute(
    String id,
    int? user,
    String? type,
    double amount,
    bool? codDelivery,
    String? paymentMethod, {
    required String guestId,
    String? contactNumber,
    String? addFundUrl,
    String? subscriptionUrl,
    int? storeId,
    bool? createAccount,
    int? createUserId,
    int? contentId,
    bool isProSubscription = false,
    bool isRenew = false,
  }) {
    String addFundParam = (addFundUrl != null && addFundUrl.isNotEmpty && addFundUrl != 'null') ? Uri.encodeComponent(addFundUrl) : '';
    String subParam = (subscriptionUrl != null && subscriptionUrl.isNotEmpty && subscriptionUrl != 'null') ? Uri.encodeComponent(subscriptionUrl) : '';
    return '$payment?id=$id&user=$user&type=$type&amount=$amount&cod-delivery=$codDelivery&add-fund-url=$addFundParam&payment-method=$paymentMethod&guest-id=$guestId&number=$contactNumber&subscription-url=$subParam&store_id=$storeId&create_account=$createAccount&create_user_id=$createUserId&is_pro_subscription=$isProSubscription&is_renew=$isRenew';
  }
  static String getCheckoutRoute(String page, {int? storeId}) =>
      '$checkout?page=$page${storeId != null ? '&store-id=$storeId' : ''}&module=${ModuleHelper.getModule()?.slug ?? ModuleHelper.getModule()?.id ?? ModuleHelper.getCacheModule()?.slug}';
  static String getOrderTrackingRoute(int? id, String? contactNumber) =>
      '$orderTracking?id=$id&number=$contactNumber';
  static String getBasicCampaignRoute(BasicCampaignModel basicCampaignModel) {
    String data =
        base64Encode(utf8.encode(jsonEncode(basicCampaignModel.toJson())));
    return '$basicCampaign?module=${ModuleHelper.getModule()?.slug ?? ModuleHelper.getModule()?.id}&data=$data';
  }

  static String getHtmlRoute(String page) => '$html?page=$page';
  static String getPrivacyPolicyRoute() => privacyPolicy;
  static String getCancellationPolicyRoute() => cancellationPolicy;
  static String getRefundPolicyRoute() => refundPolicy;
  static String getTermsAndConditionRoute() => termsAndCondition;
  static String getShippingPolicyRoute() => shippingPolicy;
  static String getCategoryRoute({int? moduleId}) => '$categories?module=${moduleId ?? ModuleHelper.getModule()?.slug ?? ModuleHelper.getModule()?.id}';
  static String getCategoryItemRoute(int? id, String name, {int? moduleId, String? slug}) {
    List<int> encoded = utf8.encode(name);
    String data = base64Encode(encoded);
    return '$categoryItem?id=$id&name=$data&module=${moduleId ?? ModuleHelper.getModule()?.slug ?? ModuleHelper.getModule()?.id}';
  }

  static String getPopularItemRoute(bool isPopular, bool isSpecial) =>
      '$popularItems?page=${isPopular ? 'popular' : 'reviewed'}&special=${isSpecial.toString()}&module=${ModuleHelper.getModule()?.slug ?? ModuleHelper.getModule()?.id}';
  static String getItemCampaignRoute({bool isJustForYou = false}) =>
      '$itemCampaign?${isJustForYou ? 'just-for-you=${isJustForYou.toString()}&' : ''}module=${ModuleHelper.getModule()?.slug ?? ModuleHelper.getModule()?.id}';
  static String getSupportRoute() => support;
  static String getReviewRoute() => rateReview;
  static String getUpdateRoute(bool isUpdate) =>
      '$update?update=${isUpdate.toString()}';
  static String getCartRoute({int? storeId}) => '$cart?module=${ModuleHelper.getModule()?.slug ?? ModuleHelper.getModule()?.id}${storeId != null ? '&store_id=$storeId' : ''}';
  static void openCart({int? storeId}) {
    if (Get.currentRoute.startsWith(cart)) {
      return;
    }
    Get.toNamed(getCartRoute(storeId: storeId));
  }
  static String getGlobalCartRoute({bool fromNav = false, int? initialModuleId}) => '$globalCart?from_nav=$fromNav${initialModuleId != null ? '&module_id=$initialModuleId' : ''}';
  static String getAddAddressRoute(
          bool fromCheckout, bool fromRide, int? zoneId,
          {bool isNavbar = false}) =>
      '$addAddress?page=${fromCheckout ? 'checkout' : 'address'}&ride=$fromRide&zone_id=$zoneId&navbar=$isNavbar';
  static String getEditAddressRoute(AddressModel? address,
      {bool fromGuest = false}) {
    String data = 'null';
    if (address != null) {
      data = base64Url.encode(utf8.encode(jsonEncode(address.toJson())));
    }
    return '$editAddress?data=$data&from-guest=$fromGuest';
  }

  static String getStoreReviewRoute(
      int? storeID, String? storeName, Store store) {
    String data = base64Url.encode(utf8.encode(jsonEncode(store.toJson())));
    return '$storeReview?storeID=$storeID&storeName=$storeName&store=$data';
  }

  static String getAllStoreRoute(String page, {bool isNearbyStore = false, int? moduleId}) =>
      '$allStores?page=$page${isNearbyStore ? '&nearby=${isNearbyStore.toString()}' : ''}&module=${moduleId ?? ModuleHelper.getModule()?.slug ?? ModuleHelper.getModule()?.id}';
  static String getItemImagesRoute(Item item) {
    String data = base64Url.encode(utf8.encode(jsonEncode(item.toJson())));
    return '$itemImages?item=$data';
  }

  static String getParcelCategoryRoute() => parcelCategory;
  static String getRentalCartRoute() => rentalCart;
  static String getRideMapRoute() => rideMap;
  static String getVendorDetailRoute(int? vendorId) => '$vendorDetail?id=$vendorId';
  static String getParcelLocationRoute(ParcelCategoryModel category) {
    String data = base64Url.encode(utf8.encode(jsonEncode(category.toJson())));
    return '$parcelLocation?data=$data';
  }

  static String getParcelRequestRoute(ParcelCategoryModel category,
      AddressModel pickupAddress, AddressModel destinationAddress) {
    String category0 =
        base64Url.encode(utf8.encode(jsonEncode(category.toJson())));
    String pickedUpAddress =
        base64Url.encode(utf8.encode(jsonEncode(pickupAddress.toJson())));
    String destinationAddress0 =
        base64Url.encode(utf8.encode(jsonEncode(destinationAddress.toJson())));
    return '$parcelRequest?category=$category0&picked=$pickedUpAddress&destination=$destinationAddress0';
  }

  static String getServiceDetailsRoute({required int id, String slug = ''}) =>
      '$serviceDetails?id=$id&slug=$slug';
  static String getProviderDetailsRoute(int id, {String? slug, bool fromGlobalCart = false}) =>
      '$providerDetails?id=$id&slug=${slug ?? ''}${fromGlobalCart ? '&from_global_cart=true' : ''}';
  static String getProviderServiceSearchRoute(int providerId) => '$providerServiceSearch?provider_id=$providerId';
  static String getServiceCategoryRoute(int id) => '$serviceCategory?id=$id';
  static String getServiceReviewsRoute({required int serviceId, String serviceName = ''}) =>
      '$serviceReviews?service_id=$serviceId&name=${Uri.encodeComponent(serviceName)}';
  static String getProviderReviewsRoute({required int providerId, String providerName = '', double avgRating = 0, int ratingCount = 0}) =>
      '$providerReviews?provider_id=$providerId&name=${Uri.encodeComponent(providerName)}&avg_rating=$avgRating&rating_count=$ratingCount';

  static String getSearchStoreItemRoute(int? storeID) =>
      '$searchStoreItem?id=$storeID';
  static String getOrderRoute() => order;
  static String getItemDetailsRoute(int? itemID, bool isRestaurant, {String? moduleId, String slug = '', bool fromDeeplink = false, bool isCampaign = false}) =>
      '$itemDetails?id=$itemID&page=${isRestaurant ? 'restaurant' : 'item'}&module=${moduleId ?? ModuleHelper.getModule()?.slug ?? ModuleHelper.getModule()?.id}${fromDeeplink ? '&from_deeplink=true' : ''}&is_campaign=$isCampaign';
  static String getWalletRoute(
          {String? fundStatus, String? token, bool fromNotification = false}) =>
      '$wallet?payment_status=$fundStatus&token=$token&from_notification=$fromNotification';
  static String getLoyaltyRoute({bool fromNotification = false}) =>
      '$loyalty?from_notification=$fromNotification';
  static String getReferAndEarnRoute() => referAndEarn;
  static String getChatRoute(
      {required NotificationBodyModel? notificationBody,
      User? user,
      int? conversationID,
      int? index,
      bool? fromNotification,
      OrderChatModel? orderChatModel}) {
    String notificationBody0 = 'null';
    if (notificationBody != null) {
      notificationBody0 =
          base64Encode(utf8.encode(jsonEncode(notificationBody.toJson())));
    }
    String orderChat = 'null';
    if (orderChatModel != null) {
      orderChat =
          base64Encode(utf8.encode(jsonEncode(orderChatModel.toJson())));
    }
    String user0 = 'null';
    if (user != null) {
      user0 = base64Encode(utf8.encode(jsonEncode(user.toJson())));
    }
    return '$messages?notification=$notificationBody0&user=$user0&conversation_id=$conversationID&index=$index&from=${fromNotification.toString()}&order-chat=$orderChat';
  }

  static String getBogoOfferRoute({int? moduleId}) => moduleId != null ? '$bogoOfferScreen?module_id=$moduleId' : bogoOfferScreen;
  static String getBogoOfferDetailsRoute(String idOrSlug, {int? moduleId}) =>
      '$bogoOfferDetailsScreen?id=$idOrSlug${moduleId != null ? '&module_id=$moduleId' : ''}';

  static String getConversationRoute() => conversation;
  static String getRestaurantRegistrationRoute() => restaurantRegistration;
  static String getDeliverymanRegistrationRoute() => deliveryManRegistration;
  static String getRiderRegistrationRoute() => riderRegistration;
  static String getRefundRequestRoute(String orderID) => '$refund?id=$orderID';
  static String getAiChatBotScreen() => aiChatBot;
  static String getAiChatDetailsScreen({int? conversationId, String? title, String? initialMessage}) {
    return '$aiChatDetails?conversation_id=${conversationId ?? ''}&title=${title ?? ''}&initial_message=${initialMessage ?? ''}';
  }

  static String getOfflinePaymentScreen({
    required int? zoneId,
    required double total,
    required double? maxCodOrderAmount,
    required bool fromCart,
    required bool? isCodActive,
    required bool forParcel,
    required String orderId,
    required String contactNumber,
  }) {
    return '$offlinePaymentScreen?zone_id=$zoneId&total=$total&max_cod_amount=$maxCodOrderAmount&from_cart=$fromCart&cod_active=$isCodActive&for_parcel=$forParcel&order_id=$orderId&contact_number=$contactNumber';
  }

  static String getFlashSaleDetailsScreen(int id) =>
      '$flashSaleDetailsScreen?id=$id';
  static String getGuestTrackOrderScreen(String orderId, String number) =>
      '$guestTrackOrderScreen?order_id=$orderId&number=$number';
  static String getFavouriteScreen() => favourite;
  static String getBrandsScreen() => brands;
  static String getBrandsItemScreen(int brandId, String brandName) =>
      '$brandsItemScreen?brandId=$brandId&brandName=$brandName';

  static String getSubscriptionSuccessRoute(
          {String? status, required bool fromSubscription, int? storeId}) =>
      '$subscriptionSuccess?flag=$status&from_subscription=$fromSubscription&store_id=$storeId';
  static String getSubscriptionPaymentRoute(
          {required int? storeId, required int? packageId}) =>
      '$subscriptionPayment?store-id=$storeId&package-id=$packageId';
  static String getSubscriptionPlanRoute({bool? flag, bool isRenew = false}) {
    String route = (isRenew && GetPlatform.isWeb ? '$subscriptionPlan/renew' : subscriptionPlan);
    if(flag != null) {
      route = '$route?flag=${flag ? 'success' : 'fail'}&renew=$isRenew';
    }
    return route;
  }
  static String getPreferenceRoute() => preference;
  static String getNewUserSetupScreen({required String name, required String loginType, required String? phone, required String? email, required bool? backFromThis, int? moduleId}) {
    return '$newUserSetupScreen?name=$name&login_type=$loginType&phone=$phone&email=$email&back_from_this=${backFromThis.toString()}&module=${moduleId ?? ModuleHelper.getModule()?.id}';
  }
  static String getSafetyScreen() => safety;
  static String getCustomServiceRequestRoute() => customServiceRequest;
  static String getCustomServiceListRoute({int? createdId}) => createdId != null ? '$customServiceList?created_id=$createdId' : customServiceList;
  static String getCustomServiceDetailsRoute(int id) => '$customServiceDetails?id=$id';
  static String getRequestedServiceRoute() => requestedService;
  static String getNewServiceRequestRoute({int? id}) => id != null ? '$newServiceRequest?id=$id' : newServiceRequest;
  static String getServiceCheckoutRoute(int providerId) => '$serviceCheckout?provider_id=$providerId';
  static String getServiceBidCheckoutRoute(int providerId, int bidId, double offerPrice, {String? scheduleDate, String? scheduleTime}) =>
      '$serviceBidCheckout?provider_id=$providerId&bid_id=$bidId&offer_price=$offerPrice'
      '${(scheduleDate != null && scheduleDate.isNotEmpty) ? '&schedule_date=${Uri.encodeComponent(scheduleDate)}' : ''}'
      '${(scheduleTime != null && scheduleTime.isNotEmpty) ? '&schedule_time=${Uri.encodeComponent(scheduleTime)}' : ''}';
  static String getServiceCampaignDetailsRoute(String idOrSlug) =>
      '$serviceCampaignDetails?id=${Uri.encodeComponent(idOrSlug)}';
  static String getServiceBuyNowCheckoutRoute({required int providerId, required int campaignId, double? price, int quantity = 1, String? variation, List<ServiceBuyNowVariant>? variants}) =>
      '$serviceBuyNowCheckout?provider_id=$providerId&campaign_id=$campaignId&is_campaign=1&price=${price ?? 0}&quantity=$quantity'
      '${(variation != null && variation.isNotEmpty) ? '&variation=${Uri.encodeComponent(variation)}' : ''}'
      '${(variants != null && variants.isNotEmpty) ? '&variants=${Uri.encodeComponent(jsonEncode(variants.map((ServiceBuyNowVariant v) => v.toRouteJson()).toList()))}' : ''}';
  static String getServiceBookingSuccessRoute(String bookingId, {bool? createAccount}) =>
      '$serviceBookingSuccess?id=$bookingId&create_account=$createAccount';
  static String getServiceCartRoute(int providerId) => '$serviceCart?provider_id=$providerId';
  static String getMyBookingsRoute() => myBookings;
  static String getBookingDetailsRoute(int? bookingId, {String? contactNumber, bool fromNotification = false}) =>
      '$bookingDetails?id=$bookingId${contactNumber != null ? '&contact_number=$contactNumber' : ''}${fromNotification ? '&from_notification=true' : ''}';
  static String getSubBookingDetailsRoute(int? bookingId) => '$subBookingDetails?id=$bookingId';
  static String getBookingTrackRoute() => bookingTrack;
  static String getServiceRateReviewRoute() => serviceRateReview;
  static String getServiceDigitalPaymentFailedScreen(String bookingId, double totalPrice, {bool isPayAfterServiceActive = true, bool isDigitalPaymentActive = false, bool isOfflinePaymentActive = false, bool? createAccount}) =>
      '$serviceDigitalPaymentFailedScreen?booking_id=$bookingId&total_price=$totalPrice&is_pay_after_service_active=$isPayAfterServiceActive'
      '&is_digital_payment_active=$isDigitalPaymentActive&is_offline_payment_active=$isOfflinePaymentActive&create_account=$createAccount';

  static List<GetPage> routes = [
    GetPage(name: initial, page: () {
      if (Get.parameters['qr'] != null) {
        return const QrScreen();
      }
      return getRoute(
        byPuss: (Get.parameters['module'] != null && Get.parameters['module']!.isNotEmpty && Get.parameters['module'] != 'null'),
        _waitForModule(
          Get.parameters['module'], fromDeeplink: Get.parameters['from_deeplink'] == 'true',
          DashboardScreen(pageIndex: 0, fromSplash: Get.parameters['from-splash'] == 'true'),
        ),
      );
    }),
    GetPage(
        name: splash,
        page: () {
          NotificationBodyModel? data;
          if (Get.parameters['data'] != 'null') {
            List<int> decode =
                base64Decode(Get.parameters['data']!.replaceAll(' ', '+'));
            data =
                NotificationBodyModel.fromJson(jsonDecode(utf8.decode(decode)));
          }
          return SplashScreen(body: data);
        }),
    GetPage(
        name: language,
        page: () => ChooseLanguageNewScreen(fromMenu: Get.parameters['page'] == 'menu')),
    GetPage(name: onBoarding, page: () => const OnBoardingNewScreen()),
    GetPage(
      name: signIn,
      page: () => SignInScreen(
        exitFromApp: Get.parameters['page'] == signUp ||
            Get.parameters['page'] == splash ||
            Get.parameters['page'] == onBoarding,
        backFromThis: Get.parameters['page'] != splash &&
            Get.parameters['page'] != onBoarding,
        fromNotification: Get.parameters['page'] == notification,
        fromResetPassword: Get.parameters['page'] == resetPassword,
      ),
      transition: Transition.downToUp,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: signUp,
      page: () => const SignUpScreen(),
      transition: Transition.downToUp,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: verification,
      page: () {
        String? pass;
        if (Get.parameters['pass'] != 'null') {
          List<int> decode =
              base64Decode(Get.parameters['pass']!.replaceAll(' ', '+'));
          pass = utf8.decode(decode);
        }
        String? session;
        if (Get.parameters['session'] != null &&
            Get.parameters['session'] != 'null') {
          session =
              utf8.decode(base64Url.decode(Get.parameters['session'] ?? ''));
        }
        UpdateUserModel? userModel;
        if (Get.parameters['user_model'] != null &&
            Get.parameters['user_model'] != 'null') {
          List<int> decode = base64Decode(Get.parameters['user_model'] != null
              ? Get.parameters['user_model']!.replaceAll(' ', '+')
              : '');
          userModel = UpdateUserModel.fromJson(jsonDecode(utf8.decode(decode)));
        }
        String? customerName = safeDecodeParam(Get.parameters['customer_name']);
        String? orderId = safeDecodeParam(Get.parameters['order_id']);

        return VerificationScreen(
          number: Get.parameters['number'] != '' &&
                  Get.parameters['number'] != 'null'
              ? Get.parameters['number']!.replaceAll(' ', '+')
              : null,
          fromSignUp: Get.parameters['page'] == signUp || Get.parameters['page'] == orderSuccess,
          token: Get.parameters['token'],
          password: pass,
          email: Get.parameters['email'] != '' &&
                  Get.parameters['email'] != 'null'
              ? Get.parameters['email']
              : null,
          loginType: Get.parameters['login_type'] ?? 'otp',
          firebaseSession: session,
          fromForgetPassword: Get.parameters['page'] == forgotPassword,
          userModel: userModel,
          backFromThis: Get.parameters['back_from_this'] == 'true',
          customerName: customerName,
          orderId: orderId,
        );
      },
      transition: Transition.downToUp,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
        name: accessLocation,
        page: () => AccessLocationScreen(
              fromSignUp: Get.parameters['page'] == signUp,
              fromHome: Get.parameters['page'] == 'home',
              route: null,
            )),
    GetPage(
        name: pickMap,
        page: () {
          PickMapScreen? pickMapScreen = Get.arguments;
          bool fromAddress = Get.parameters['page'] == 'add-address';
          return ((Get.parameters['page'] == 'parcel' && pickMapScreen == null) ||
                  (fromAddress && pickMapScreen == null))
              ? const NotFound()
              : pickMapScreen ??
                  PickMapScreen(
                    fromSignUp: Get.parameters['page'] == signUp,
                    fromAddAddress: fromAddress,
                    route: Get.parameters['page'],
                    canRoute: Get.parameters['route'] == 'true',
                  );
        }),
    GetPage(name: interest, page: () => const InterestScreen()),
    GetPage(
        name: main,
        page: () {
          final bool hasModule = Get.isRegistered<SplashController>() &&
              Get.find<SplashController>().module != null;
          final String? page = Get.parameters['page'];
          int pageIndex = 0;
          if (page == 'home') {
            pageIndex = 0;
          } else if (page == 'categories' || page == 'category') {
            pageIndex = hasModule ? 1 : 0;
          } else if (page == 'cart') {
            pageIndex = hasModule ? 2 : 1;
          } else if (page == 'favourite' || page == 'offer' || page == 'offers') {
            pageIndex = hasModule ? 3 : 2;
          } else if (page == 'menu' || page == 'profile') {
            pageIndex = hasModule ? 4 : 3;
          }
          return DashboardScreen(pageIndex: pageIndex);
        }),
    GetPage(
        name: forgotPassword,
        page: () => const ForgetPassScreen()),
    GetPage(
        name: resetPassword,
        page: () => NewPassScreen(
              resetToken: Get.parameters['token'] ?? '',
              number: Get.parameters['phone'] != 'null'
                  ? Get.parameters['phone']
                  : null,
              email: Get.parameters['email'] != 'null'
                  ? Get.parameters['email']
                  : null,
              fromPasswordChange: Get.parameters['page'] == 'password-change',
            )),
    GetPage(
        name: search,
        page: () => getRoute(
          _waitForModule(
            Get.parameters['module'],
            SearchScreen(queryText: Get.parameters['query']),
          ),
        )),
    GetPage(
        name: store,
        page: () {
          return getRoute(
            _waitForModule(
              Get.parameters['module'], fromDeeplink: Get.parameters['from_deeplink'] == 'true',
              Get.arguments ??
                  StoreScreen(
                    store: Store(id: int.parse(Get.parameters['id']!)),
                    fromModule: Get.parameters['page'] == 'module',
                    slug: Get.parameters['slug'] ?? '',
                  ),
            ),
          );
        }),
    GetPage(
        name: orderDetails,
        page: () {
          return getRoute(Get.arguments ??
              OrderDetailsScreen(
                orderId: int.parse(Get.parameters['id'] ?? '0'),
                orderModel: null,
                fromNotification: Get.parameters['from'] == 'true',
                fromOfflinePayment: Get.parameters['from_offline'] == 'true',
                contactNumber: Get.parameters['contact'],
              ));
        }),
    GetPage(name: profile, page: () => getRoute(const ProfileScreen())),
    GetPage(
        name: updateProfile, page: () => getRoute(const UpdateProfileScreen())),
    GetPage(
        name: coupon,
        page: () => getRoute(const CouponScreen())),
    GetPage(
        name: notification,
        page: () => getRoute(NotificationScreen(
            fromNotification: Get.parameters['from'] == 'true'))),
    GetPage(
        name: map,
        page: () {
          List<int> decode =
              base64Decode(Get.parameters['address']!.replaceAll(' ', '+'));
          AddressModel data =
              AddressModel.fromJson(jsonDecode(utf8.decode(decode)));
          return getRoute(MapScreen(
              fromStore: Get.parameters['page'] == 'store',
              address: data,
              isFood: Get.parameters['module'] == 'true',
              storeName: Get.parameters['store-name'] ?? ''));
        }),
    GetPage(name: address, page: () => getRoute(const AddressScreen())),
    GetPage(
        name: orderSuccess,
        page: () {
          String? name = safeDecodeParam(Get.parameters['customer_name']);
          String? email = safeDecodeParam(Get.parameters['customer_email']);
          String? contactNumber = safeDecodeParam(Get.parameters['contact_number']);
          if (contactNumber != null && contactNumber.startsWith(' ')) {
            contactNumber = '+${contactNumber.trim()}';
          }
          String? rawId = Get.parameters['id'];
          if (rawId != null && rawId.contains('?')) {
            rawId = rawId.split('?')[0].trim();
          }
          return getRoute(OrderSuccessfulScreen(
            orderID: rawId,
            contactPersonNumber: contactNumber,
            createAccount: Get.parameters['create_account'] == 'true',
            guestId: Get.parameters['guest_id'] ?? '',
            customerName: name,
            customerEmail: email,
          ));
        }),
    GetPage(
        name: payment,
        page: () {
          OrderModel order = OrderModel(
            id: int.tryParse(Get.parameters['id'] ?? '0') ?? 0,
            orderType: Get.parameters['type'] ?? '',
            userId: int.tryParse(Get.parameters['user'] ?? '0') ?? 0,
            orderAmount: double.tryParse(Get.parameters['amount'] ?? '0') ?? 0.0,
          );
          bool isCodActive = Get.parameters['cod-delivery'] == 'true';
          String addFundUrl = (Get.parameters['add-fund-url'] == null ||
                  Get.parameters['add-fund-url'] == 'null')
              ? ''
              : Get.parameters['add-fund-url']!;
          String paymentMethod = Get.parameters['payment-method'] ?? '';
          String guestId = Get.parameters['guest-id'] ?? '';
          String number = Get.parameters['number'] ?? '';
          String? subscriptionUrl = (Get.parameters['subscription-url'] == null ||
                  Get.parameters['subscription-url'] == 'null')
              ? ''
              : Get.parameters['subscription-url'];
          int? storeId = Get.parameters['store_id'] != null &&
                  Get.parameters['store_id'] != 'null'
              ? int.parse(Get.parameters['store_id']!)
              : null;
          bool createAccount = Get.parameters['create_account'] == 'true';
          int? createUserId = Get.parameters['create_user_id'] != null &&
                  Get.parameters['create_user_id'] != 'null'
              ? int.parse(Get.parameters['create_user_id']!)
              : null;
          bool isProSubscription = Get.parameters['is_pro_subscription'] == 'true';
          bool isRenew = Get.parameters['is_renew'] == 'true';
          return getRoute(AppConstants.payInWevView
              ? PaymentWebViewScreen(
                  orderModel: order,
                  isCashOnDelivery: isCodActive,
                  addFundUrl: addFundUrl,
                  paymentMethod: paymentMethod,
                  guestId: guestId,
                  contactNumber: number,
                  subscriptionUrl: subscriptionUrl,
                  storeId: storeId,
                  createAccount: createAccount,
                  isProSubscription: isProSubscription,
                  isRenew: isRenew,
                )
              : PaymentScreen(
                  orderModel: order,
                  isCashOnDelivery: isCodActive,
                  addFundUrl: addFundUrl,
                  paymentMethod: paymentMethod,
                  guestId: guestId,
                  contactNumber: number,
                  subscriptionUrl: subscriptionUrl,
                  storeId: storeId,
                  createAccount: createAccount,
                  createUserId: createUserId,
                  isProSubscription: isProSubscription,
                  isRenew: isRenew,
                ));
        }),
    GetPage(
      name: checkout,
      page: () {
        FirebaseAnalytics.instance.logBeginCheckout(
          value: 0,
          currency: "EGP",
        );

        CheckoutScreen? checkoutScreen = Get.arguments;
        bool fromCart = Get.parameters['page'] == 'cart';

        return getRoute(
          _waitForModule(
            Get.parameters['module'],
            checkoutScreen ??
                (!fromCart
                    ? const NotFound()
                    : CheckoutScreen(
                        cartList: null,
                        fromCart: fromCart,
                        storeId: Get.parameters['store-id'] != 'null' && Get.parameters['store-id'] != null
                            ? int.parse(Get.parameters['store-id']!)
                            : null,
                      )),
          ),
        );
      },
    ),
    GetPage(
        name: orderTracking,
        page: () => getRoute(OrderTrackingScreen(
              orderID: Get.parameters['id'],
              contactNumber: Get.parameters['number'],
            ))),
    GetPage(
        name: basicCampaign,
        page: () {
          BasicCampaignModel data = BasicCampaignModel.fromJson(jsonDecode(
              utf8.decode(
                  base64Decode(Get.parameters['data']!.replaceAll(' ', '+')))));
          return getRoute(CampaignScreen(campaign: data));
        }),
    GetPage(name: privacyPolicy, page: () => const HtmlViewerScreen(htmlType: HtmlType.privacyPolicy)),
    GetPage(name: cancellationPolicy, page: () => const HtmlViewerScreen(htmlType: HtmlType.cancellation)),
    GetPage(name: refundPolicy, page: () => const HtmlViewerScreen(htmlType: HtmlType.refund)),
    GetPage(name: termsAndCondition, page: () => const HtmlViewerScreen(htmlType: HtmlType.termsAndCondition)),
    GetPage(name: shippingPolicy, page: () => const HtmlViewerScreen(htmlType: HtmlType.shippingPolicy)),
    GetPage(
        name: html,
        page: () => HtmlViewerScreen(
              htmlType: Get.parameters['page'] == 'terms-and-condition'
                  ? HtmlType.termsAndCondition
                  : Get.parameters['page'] == 'privacy-policy'
                      ? HtmlType.privacyPolicy
                      : Get.parameters['page'] == 'shipping-policy'
                          ? HtmlType.shippingPolicy
                          : Get.parameters['page'] == 'cancellation-policy'
                              ? HtmlType.cancellation
                              : Get.parameters['page'] == 'refund-policy'
                                  ? HtmlType.refund
                                  : HtmlType.aboutUs,
            )),
    GetPage(name: categories, page: () => getRoute(_waitForModule(Get.parameters['module'], const CategoryScreen()))),
    GetPage(
        name: categoryItem,
        page: () {
          List<int> decode =
              base64Decode(Get.parameters['name']!.replaceAll(' ', '+'));
          String data = utf8.decode(decode);

          FirebaseAnalytics.instance.logEvent(
            name: "open_category",
            parameters: {
              "category_id": Get.parameters['id'] ?? 'unknown',
              "category_name": data,
            },
          );

          return getRoute(
            _waitForModule(
              Get.parameters['module'],
              CategoryItemScreen(
                  categoryID: Get.parameters['id'], categoryName: data),
            ),
          );
        }),
    GetPage(
        name: popularItems,
        page: () => getRoute(
          _waitForModule(
            Get.parameters['module'],
            PopularItemScreen(
                isPopular: Get.parameters['page'] == 'popular',
                isSpecial: Get.parameters['special'] == 'true'),
          ),
        )),
    GetPage(
        name: itemCampaign,
        page: () => getRoute(
          _waitForModule(
            Get.parameters['module'],
            ItemCampaignScreen(
                isJustForYou: Get.parameters['just-for-you'] == 'true'),
          ),
        )),
    GetPage(name: support, page: () => const SupportScreen()),
    GetPage(
        name: update,
        page: () => UpdateScreen(isUpdate: Get.parameters['update'] == 'true')),
    GetPage(
      name: cart,
      page: () {
        FirebaseAnalytics.instance.logEvent(name: "view_cart");
        return getRoute(
          byPuss: (Get.parameters['module'] != null && Get.parameters['module']!.isNotEmpty && Get.parameters['module'] != 'null'),
          _waitForModule(
            Get.parameters['module'],
            Get.arguments ?? CartScreen(fromNav: false, storeId: int.tryParse(Get.parameters['store_id'] ?? '')),
          ),
        );
      },
    ),
    GetPage(name: globalCart, page: () => getRoute(GlobalCartScreen(
      fromNav: Get.parameters['from_nav'] == 'true',
      initialModuleId: int.tryParse(Get.parameters['module_id'] ?? ''),
    ))),
    GetPage(
        name: addAddress,
        page: () => getRoute(AddAddressScreen(
              fromCheckout: Get.parameters['page'] == 'checkout',
              fromRide: Get.parameters['ride'] == 'true',
              zoneId: int.parse(Get.parameters['zone_id']!),
              fromNavBar: Get.parameters['navbar'] == 'true',
            ))),
    GetPage(
        name: editAddress,
        page: () {
          AddressModel? data;
          if (Get.parameters['data'] != null &&
              Get.parameters['data'] != 'null' &&
              Get.parameters['data']!.isNotEmpty) {
            try {
              data = AddressModel.fromJson(jsonDecode(utf8.decode(base64Url
                  .decode(Get.parameters['data']!.replaceAll(' ', '+')))));
            } catch (e) {
              debugPrint('Error decoding address data: $e');
            }
          }
          return getRoute(AddAddressScreen(
            fromCheckout: false,
            fromRide: false,
            address: data,
            forGuest: Get.parameters['from-guest'] == 'true',
          ));
        }),
    GetPage(
        name: rateReview,
        page: () => getRoute(Get.arguments ?? const NotFound())),
    GetPage(
        name: storeReview,
        page: () => getRoute(ReviewScreen(
            storeID: Get.parameters['storeID'],
            storeName: Get.parameters['storeName'],
            store: Store.fromJson(jsonDecode(utf8.decode(base64Url
                .decode(Get.parameters['store']!.replaceAll(' ', '+')))))))),
    GetPage(
        name: allStores,
        page: () => getRoute(
          _waitForModule(
            Get.parameters['module'],
            AllStoreScreen(
              isPopular: Get.parameters['page'] == 'popular',
              isFeatured: Get.parameters['page'] == 'featured',
              isTopOfferStore: Get.parameters['page'] == 'topOffer',
              isNearbyStore: Get.parameters['nearby'] == 'true',
            ),
          ),
        )),
    GetPage(
        name: itemImages,
        page: () => getRoute(ImageViewerScreen(
              item: Item.fromJson(jsonDecode(utf8.decode(base64Url
                  .decode(Get.parameters['item']!.replaceAll(' ', '+'))))),
            ))),
    GetPage(
        name: parcelCategory,
        page: () => getRoute(const ParcelCategoryScreen())),
    GetPage(name: rentalCart, page: () => getRoute(const RentalCartScreen())),
    GetPage(name: rideMap, page: () => getRoute(const ride_map.MapScreen(fromScreen: ride_map.MapScreenType.ride, isShowCurrentPosition: false))),
    GetPage(name: vendorDetail, page: () => getRoute(ProviderDetailScreen(vendorId: int.tryParse(Get.parameters['id'] ?? '')))),
    GetPage(
        name: parcelLocation,
        page: () => getRoute(ParcelLocationScreen(
              category: ParcelCategoryModel.fromJson(jsonDecode(utf8.decode(
                  base64Url
                  .decode(Get.parameters['data']!.replaceAll(' ', '+'))))),
            ))),
    GetPage(
        name: parcelRequest,
        page: () => getRoute(ParcelRequestScreen(
              parcelCategory: ParcelCategoryModel.fromJson(jsonDecode(
                  utf8.decode(base64Url.decode(
                      Get.parameters['category']!.replaceAll(' ', '+'))))),
              pickedUpAddress: AddressModel.fromJson(jsonDecode(utf8.decode(
                  base64Url.decode(
                      Get.parameters['picked']!.replaceAll(' ', '+'))))),
              destinationAddress: AddressModel.fromJson(jsonDecode(utf8.decode(
                  base64Url.decode(
                      Get.parameters['destination']!.replaceAll(' ', '+'))))),
            ))),
    GetPage(
        name: searchStoreItem,
        page: () =>
            getRoute(StoreItemSearchScreen(storeID: Get.parameters['id']))),
    GetPage(name: order, page: () => getRoute(const OrderScreen())),
    GetPage(
      name: itemDetails,
      page: () {
        FirebaseAnalytics.instance.logViewItem(
          items: [
            AnalyticsEventItem(
              itemId: Get.parameters['id'].toString(),
              itemName: "product_details",
            )
          ],
        );

        return getRoute(
          byPuss: (Get.parameters['module'] != null && Get.parameters['module']!.isNotEmpty && Get.parameters['module'] != 'null'),
          _waitForModule(
            Get.parameters['module'], fromDeeplink: Get.parameters['from_deeplink'] == 'true',
            Get.arguments ??
                ItemDetailsScreen(
                  item: Item(id: int.tryParse(Get.parameters['id'] ?? '') ?? 0),
                  inStorePage: Get.parameters['page'] == 'restaurant',
                ),
          ),
        );
      },
    ),
    GetPage(
        name: wallet,
        page: () {
          return getRoute(WalletScreen(
            fundStatus:
                Get.parameters['flag'] ?? Get.parameters['payment_status'],
            token: Get.parameters['token'],
            fromNotification: Get.parameters['from_notification'] == 'true',
          ));
        }),
    GetPage(
        name: loyalty,
        page: () => getRoute(LoyaltyScreen(
            fromNotification: Get.parameters['from_notification'] == 'true'))),
    GetPage(
        name: referAndEarn, page: () => getRoute(const ReferAndEarnScreen())),
    GetPage(
        name: messages,
        page: () {
          NotificationBodyModel? notificationBody;
          if (Get.parameters['notification'] != 'null') {
            notificationBody = NotificationBodyModel.fromJson(jsonDecode(
                utf8.decode(base64Url.decode(
                    Get.parameters['notification']!.replaceAll(' ', '+')))));
          }
          OrderChatModel? orderChat;
          if (Get.parameters['order-chat'] != 'null') {
            orderChat = OrderChatModel.fromJson(jsonDecode(utf8.decode(base64Url
                .decode(Get.parameters['order-chat']!.replaceAll(' ', '+')))));
          }
          User? user;
          if (Get.parameters['user'] != 'null') {
            user = User.fromJson(jsonDecode(utf8.decode(base64Url
                .decode(Get.parameters['user']!.replaceAll(' ', '+')))));
          }
          return getRoute(ChatScreen(
            notificationBody: notificationBody,
            user: user,
            index: Get.parameters['index'] != 'null'
                ? int.parse(Get.parameters['index']!)
                : null,
            fromNotification: Get.parameters['from'] == 'true',
            conversationID: (Get.parameters['conversation_id'] != null &&
                    Get.parameters['conversation_id'] != 'null')
                ? int.parse(Get.parameters['conversation_id']!)
                : null,
            orderChatModel: orderChat,
          ));
        }),
    GetPage(name: conversation, page: () => const ConversationScreen()),
    GetPage(
        name: restaurantRegistration,
        page: () => const StoreRegistrationScreen()),
    GetPage(
        name: deliveryManRegistration,
        page: () => const DeliveryManRegistrationScreen()),
    GetPage(name: riderRegistration, page: () => const RiderRegistrationScreen()),
    GetPage(
        name: refund,
        page: () => RefundRequestScreen(orderId: Get.parameters['id'])),
    GetPage(name: aiChatBot, page: () => const AiChatBotScreen()),
    GetPage(name: aiChatDetails, page: () {
      final String? rawId = Get.parameters['conversation_id'];
      final int? conversationId = (rawId != null && rawId.isNotEmpty) ? int.tryParse(rawId) : null;
      final String? rawTitle = Get.parameters['title'];
      final String? rawInitialMessage = Get.parameters['initial_message'];
      return AiChatDetailsScreen(
        conversationId: conversationId,
        title: (rawTitle != null && rawTitle.isNotEmpty) ? rawTitle : null,
        initialMessage: (rawInitialMessage != null && rawInitialMessage.isNotEmpty) ? rawInitialMessage : null,
      );
    }),
    GetPage(
      name: offlinePaymentScreen,
      page: () {
        return OfflinePaymentScreen(
          zoneId: int.parse(Get.parameters['zone_id']!),
          total: double.parse(Get.parameters['total']!),
          maxCodOrderAmount: (Get.parameters['max_cod_amount'] != null &&
                  Get.parameters['max_cod_amount'] != 'null')
              ? double.parse(Get.parameters['max_cod_amount']!)
              : null,
          fromCart: Get.parameters['from_cart'] == 'true',
          isCashOnDeliveryActive: Get.parameters['cod_active'] == 'true',
          forParcel: Get.parameters['for_parcel'] == 'true',
          orderId: Get.parameters['order_id']!,
          contactNumber: Get.parameters['contact_number'],
        );
      },
    ),
    GetPage(
        name: flashSaleDetailsScreen,
        page: () =>
            FlashSaleDetailsScreen(id: int.parse(Get.parameters['id']!))),
    GetPage(name: bogoOfferScreen, page: () => getRoute(BogoOfferScreen(moduleId: int.tryParse(Get.parameters['module_id'] ?? '')))),
    GetPage(name: bogoOfferDetailsScreen, page: () => getRoute(BogoOfferDetailsScreen(
      offerIdOrSlug: Get.parameters['id'],
      moduleId: int.tryParse(Get.parameters['module_id'] ?? ''),
    ))),

    GetPage(
        name: guestTrackOrderScreen,
        page: () => GuestTrackOrderScreen(
              orderId: Get.parameters['order_id']!,
              number: Get.parameters['number']!,
            )),
    GetPage(name: favourite, page: () => const FavouriteScreen()),
    GetPage(name: brands, page: () => const BrandsScreen()),
    GetPage(
        name: brandsItemScreen,
        page: () => BrandsItemScreen(
              brandId: int.parse(Get.parameters['brandId']!),
              brandName: Get.parameters['brandName']!,
            )),
    GetPage(
        name: subscriptionSuccess,
        page: () => SubscriptionSuccessOrFailedScreen(
            success: Get.parameters['flag'] == 'success',
            fromSubscription: Get.parameters['from_subscription'] == 'true',
            storeId: (Get.parameters['store_id'] != null &&
                    Get.parameters['store_id'] != 'null')
                ? int.parse(Get.parameters['store_id']!)
                : null)),
    GetPage(
        name: subscriptionPayment,
        page: () => SubscriptionPaymentScreen(
            storeId: int.parse(Get.parameters['store-id']!),
            packageId: int.parse(Get.parameters['package-id']!))),
    GetPage(
        name: subscriptionPlan,
        page: () {
          final bool isRenew = Uri.base.toString().contains('$subscriptionPlan/renew') || Get.parameters['renew'] == 'true';
          final String? flag = Get.parameters['flag'];
          return SubscriptionPlanScreen(
            flag: flag == 'success' ? true : (flag == 'fail' ? false : null),
            isRenewalMode: isRenew,
          );
        }),
    GetPage(
        name: newUserSetupScreen,
        page: () => NewUserSetupScreen(
              name: Get.parameters['name'] ?? '',
              loginType: Get.parameters['login_type'] ?? 'otp',
              phone: Get.parameters['phone'] != '' &&
                      Get.parameters['phone'] != 'null'
                  ? Get.parameters['phone']!.replaceAll(' ', '+')
                  : null,
              email: Get.parameters['email'] != '' &&
                      Get.parameters['email'] != 'null'
                  ? Get.parameters['email']!.replaceAll(' ', '+')
                  : null,
              backFromThis: Get.parameters['back_from_this'] == 'true',
            )),
    GetPage(name: preference, page: () => const PreferenceScreen()),
    GetPage(name: safety, page: () => getRoute(const SafetyPolicyScreen())),

    // Service module routes
    GetPage(name: customServiceRequest, page: () => const CustomServiceRequestScreen()),
    GetPage(name: customServiceList, page: () => CustomServiceListScreen(
      createdRequestId: int.tryParse(Get.parameters['created_id'] ?? ''),
    )),
    GetPage(name: customServiceDetails, page: () => const CustomServiceDetailsScreen()),
    GetPage(name: requestedService, page: () => const RequestedServiceScreen()),
    GetPage(name: newServiceRequest, page: () => const NewServiceRequestScreen()),
    GetPage(name: serviceCheckout, page: () => getRoute(ServiceCheckoutScreen(
      providerId: int.tryParse(Get.parameters['provider_id'] ?? '') ?? 0,
    ))),
    GetPage(name: serviceBidCheckout, page: () => getRoute(ServiceBidCheckoutScreen(
      providerId: int.tryParse(Get.parameters['provider_id'] ?? '') ?? 0,
      bidId: int.tryParse(Get.parameters['bid_id'] ?? '') ?? 0,
      offerPrice: double.tryParse(Get.parameters['offer_price'] ?? '') ?? 0,
      initialServiceAddress: Get.arguments is AddressModel ? Get.arguments as AddressModel : null,
      initialScheduleAt: DateConverter.dateAndTimeStringToDate(Get.parameters['schedule_date'], Get.parameters['schedule_time']),
    ))),
    GetPage(name: serviceBuyNowCheckout, page: () => getRoute(ServiceBuyNowCheckoutScreen(
      providerId: int.tryParse(Get.parameters['provider_id'] ?? '') ?? 0,
      campaignId: int.tryParse(Get.parameters['campaign_id'] ?? '') ?? 0,
      isCampaign: Get.parameters['is_campaign'] != '0',
      unitPrice: double.tryParse(Get.parameters['price'] ?? '') ?? 0,
      quantity: int.tryParse(Get.parameters['quantity'] ?? '') ?? 1,
      variation: (Get.parameters['variation']?.isNotEmpty ?? false) ? Get.parameters['variation'] : null,
      variants: (Get.parameters['variants']?.isNotEmpty ?? false)
          ? (jsonDecode(Get.parameters['variants']!) as List<dynamic>)
              .map((dynamic e) => ServiceBuyNowVariant.fromJson(e as Map<String, dynamic>)).toList()
          : null,
    ))),
    GetPage(name: serviceCampaignDetails, page: () => getRoute(ServiceCampaignDetailScreen(
      idOrSlug: Get.parameters['id'] ?? '',
    ))),
    GetPage(name: serviceBookingSuccess, page: () => getRoute(ServiceBookingSuccessScreen(
      bookingId: Get.parameters['id'] ?? '',
      createAccount: Get.parameters['create_account'] == 'true',
    ))),
    GetPage(name: serviceCart, page: () => getRoute(ServiceCartScreen(
      providerId: int.tryParse(Get.parameters['provider_id'] ?? '') ?? 0,
    ))),
    GetPage(name: serviceDetails, page: () => getRoute(ServiceDetailsScreen(
      serviceId: int.tryParse(Get.parameters['id'] ?? ''),
    ))),
    GetPage(name: providerDetails, page: () => getRoute(ProviderDetailsScreen(
      providerId: int.tryParse(Get.parameters['id'] ?? '') ?? 0,
      slug: (Get.parameters['slug']?.isNotEmpty ?? false) ? Get.parameters['slug'] : null,
      initialProvider: Get.arguments is ServiceProvider ? Get.arguments as ServiceProvider : null,
      fromGlobalCart: Get.parameters['from_global_cart'] == 'true',
    ))),
    GetPage(name: providerServiceSearch, page: () => getRoute(ProviderServiceSearchScreen(
      providerId: int.tryParse(Get.parameters['provider_id'] ?? '') ?? 0,
    ))),
    GetPage(name: serviceCategory, page: () => getRoute(
      Get.arguments is ServiceCategoryModel
          ? ServiceCategoryScreen(category: Get.arguments as ServiceCategoryModel)
          : ServiceCategoryScreen(category: ServiceCategoryModel(id: int.tryParse(Get.parameters['id'] ?? ''))),
    )),
    GetPage(name: serviceReviews, page: () => getRoute(ServiceReviewsScreen(
      serviceId: int.tryParse(Get.parameters['service_id'] ?? '') ?? 0,
      serviceName: Get.parameters['name'],
    ))),
    GetPage(name: providerReviews, page: () => getRoute(ProviderReviewsScreen(
      providerId: int.tryParse(Get.parameters['provider_id'] ?? '') ?? 0,
      providerName: Get.parameters['name'],
      avgRating: double.tryParse(Get.parameters['avg_rating'] ?? ''),
      ratingCount: int.tryParse(Get.parameters['rating_count'] ?? ''),
    ))),
    GetPage(name: myBookings, page: () => getRoute(const MyBookingsScreen())),
    GetPage(name: bookingDetails, page: () => getRoute(BookingDetailsScreen(
      bookingId: int.tryParse(Get.parameters['id'] ?? ''), trackContactNumber: Get.parameters['contact_number'],
      fromNotification: Get.parameters['from_notification'] == 'true',
    ))),
    GetPage(name: subBookingDetails, page: () => getRoute(BookingDetailsScreen(
      bookingId: int.tryParse(Get.parameters['id'] ?? ''), isSubBooking: true,
    ))),
    GetPage(name: bookingTrack, page: () => getRoute(const TrackBookingScreen())),
    GetPage(name: serviceRateReview, page: () => getRoute(Get.arguments ?? const NotFound())),
    GetPage(name: serviceDigitalPaymentFailedScreen, page: () => getRoute(ServiceDigitalPaymentFailedScreen(
      bookingId: Get.parameters['booking_id'] ?? '',
      totalPrice: double.tryParse(Get.parameters['total_price'] ?? '') ?? 0,
      isPayAfterServiceActive: Get.parameters['is_pay_after_service_active'] != 'false',
      isDigitalPaymentActive: Get.parameters['is_digital_payment_active'] == 'true',
      isOfflinePaymentActive: Get.parameters['is_offline_payment_active'] == 'true',
      createAccount: Get.parameters['create_account'] == 'true',
    ))),
    GetPage(name: allStoresScreen, page: () => getRoute(const AllStoresScreen())),
  ];

  static Widget getRoute(Widget navigateTo,
      {AccessLocationScreen? locationScreen, bool byPuss = false}) {
    double? minimumVersion = 0;
    if (GetPlatform.isAndroid) {
      minimumVersion =
          Get.find<SplashController>().configModel!.appMinimumVersionAndroid;
    } else if (GetPlatform.isIOS) {
      minimumVersion =
          Get.find<SplashController>().configModel!.appMinimumVersionIos;
    }

    return (AppConstants.appVersion < minimumVersion! && !GetPlatform.isWeb)
        ? const UpdateScreen(isUpdate: true)
        : Get.find<SplashController>().configModel!.maintenanceMode!
            ? const UpdateScreen(isUpdate: false)
            : (AddressHelper.getUserAddressFromSharedPref() == null && !byPuss)
                ? AccessLocationScreen(
                    fromSignUp: false, fromHome: false, route: Get.currentRoute)
                : AnalyticsRouteWrapper(child: navigateTo);
  }

  static Widget _waitForModule(String? moduleId, Widget child, {bool fromDeeplink = false}) {
    if ((fromDeeplink || GetPlatform.isWeb) && moduleId != null && moduleId.isNotEmpty && moduleId != 'null') {
      return FutureBuilder(
        future: checkModuleId(moduleId, fromDeeplink: fromDeeplink),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CustomLoaderWidget()));
          }
          return child;
        },
      );
    } else {
      return child;
    }
  }

  static Future<void> checkModuleId(String? parameters, {bool fromDeeplink = false}) async {
    if (!fromDeeplink && !GetPlatform.isWeb) {
      return;
    }
    if (parameters != null && parameters.isNotEmpty && parameters != 'null') {
      String moduleSlug = parameters;
      ApiClient apiClient = Get.find<ApiClient>();
      SharedPreferences sharedPreferences = Get.find<SharedPreferences>();
      AddressModel? addressModel = AddressHelper.getUserAddressFromSharedPref();

      if (addressModel != null) {
        await _moduleCheck(moduleSlug, apiClient, sharedPreferences, addressModel);
      } else {
        bool v = await Get.find<SplashController>().getModules(headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          AppConstants.localizationKey: Get.find<LocalizationController>().locale.languageCode,
        }, dataSource: DataSourceEnum.client);
        if (v) {
          if (Get.find<SplashController>().moduleList != null) {
            bool canContinue = true;

            ModuleModel? foundModule;
            for (ModuleModel module in Get.find<SplashController>().moduleList!) {
              if (module.slug == moduleSlug || module.id.toString() == moduleSlug) {
                foundModule = module;
                break;
              }
            }
            if (!AuthHelper.isLoggedIn() && !AuthHelper.isGuestLoggedIn()) {
              ResponseModel responseModel = await Get.find<AuthController>().guestLogin();
              canContinue = responseModel.isSuccess;
            }
            if (!canContinue) {
              Get.offAllNamed(getInitialRoute());
              return;
            }
            if (foundModule != null) {
              Get.find<SplashController>().setModule(foundModule);
              apiClient.updateHeader(
                sharedPreferences.getString(AppConstants.token),
                null,
                null,
                sharedPreferences.getString(AppConstants.languageCode),
                moduleSlug,
                '0',
                '0',
                null,
                fromModule: true,
              );
            } else {
              apiClient.updateHeader(
                sharedPreferences.getString(AppConstants.token),
                null,
                null,
                sharedPreferences.getString(AppConstants.languageCode),
                null,
                '0',
                '0',
                null,
                fromModule: true,
              );
              showCustomSnackBar('no_module_found'.tr);
              Get.offAllNamed(getInitialRoute());
              return;
            }
          }
        }
      }
    }
  }

  static Future<void> _moduleCheck(String moduleSlug, ApiClient apiClient, SharedPreferences sharedPreferences, AddressModel addressModel) async {
    if (Get.find<SplashController>().moduleList != null && GetPlatform.isWeb) {
      return;
    }
    if (Get.find<SplashController>().configModel == null) {
      await Get.find<SplashController>().getConfigData(source: DataSourceEnum.client, canRoute: false);
    }

    bool v = await Get.find<SplashController>().getModules(dataSource: DataSourceEnum.client);
    if (v) {
      if (Get.find<SplashController>().moduleList != null) {
        ModuleModel? foundModule;
        for (ModuleModel module in Get.find<SplashController>().moduleList!) {
          if (module.slug == moduleSlug || module.id.toString() == moduleSlug) {
            foundModule = module;
            break;
          }
        }
        if (foundModule != null) {
          Get.find<SplashController>().setModule(foundModule);
          apiClient.updateHeader(
            sharedPreferences.getString(AppConstants.token),
            addressModel.zoneIds,
            addressModel.areaIds,
            sharedPreferences.getString(AppConstants.languageCode),
            moduleSlug,
            addressModel.latitude,
            addressModel.longitude,
            null,
            fromModule: true,
          );
          Get.find<SplashController>().clearDataNull(foundModule);
          HomeScreen.loadData(true);
        } else {
          Get.find<SplashController>().setModule(null);
          apiClient.updateHeader(
            sharedPreferences.getString(AppConstants.token),
            addressModel.zoneIds,
            addressModel.areaIds,
            sharedPreferences.getString(AppConstants.languageCode),
            null,
            addressModel.latitude,
            addressModel.longitude,
            null,
            fromModule: true,
          );
          showCustomSnackBar('no_module_found'.tr);
          Get.offAllNamed(RouteHelper.getInitialRoute());
        }
      }
    }
  }
}
