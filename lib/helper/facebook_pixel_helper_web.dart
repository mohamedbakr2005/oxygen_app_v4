// // ignore: avoid_web_libraries_in_flutter
// import 'dart:js' as js;

// class FacebookEvents {
//   /// ✅ Generate Event ID for Deduplication (اختياري للمستقبل)
//   static String _generateEventId() {
//     return DateTime.now().millisecondsSinceEpoch.toString();
//   }

//   static void _track(String eventName, Map<String, dynamic> data) {
//     final params = js.JsObject.jsify(data);
//     js.context.callMethod('facebookTrack', [eventName, params]);
//   }

//   /// ✅ View Content
//   static void viewContent({
//     required String productId,
//     required String name,
//     required double price,
//   }) {
//     _track('ViewContent', {
//       'content_ids': [productId.toString()],
//       'content_name': name.toString(),
//       'content_type': 'product',
//       'value': price,
//       'currency': 'EGP',
//     });
//   }

//   /// ✅ Add To Cart
//   static void addToCart({
//     required String productId,
//     required String name,
//     required double price,
//     required int quantity,
//   }) {
//     _track('AddToCart', {
//       'content_ids': [productId.toString()],
//       'content_name': name.toString(),
//       'content_type': 'product',
//       'value': price,
//       'currency': 'EGP',
//       'quantity': quantity,
//     });
//   }

//   /// ✅ Remove From Cart
//   static void removeFromCart({
//     required String productId,
//     required String name,
//     required double price,
//   }) {
//     _track('RemoveFromCart', {
//       'content_ids': [productId.toString()],
//       'content_name': name.toString(),
//       'content_type': 'product',
//       'value': price,
//       'currency': 'EGP',
//     });
//   }

//   /// ✅ Add To Wishlist
//   static void addToWishlist({
//     required String productId,
//     required String name,
//     required double price,
//   }) {
//     _track('AddToWishlist', {
//       'content_ids': [productId.toString()],
//       'content_name': name.toString(),
//       'content_type': 'product',
//       'value': price,
//       'currency': 'EGP',
//     });
//   }

//   /// ✅ Search
//   static void search(String keyword) {
//     _track('Search', {
//       'search_string': keyword,
//     });
//   }

//   /// ✅ Initiate Checkout
//   static void initiateCheckout({
//     required double total,
//     required int itemsCount,
//   }) {
//     _track('InitiateCheckout', {
//       'value': total,
//       'currency': 'EGP',
//       'num_items': itemsCount,
//     });
//   }

//   /// ✅ Add Payment Info
//   static void addPaymentInfo({
//     required String paymentMethod,
//     required double total,
//   }) {
//     _track('AddPaymentInfo', {
//       'value': total,
//       'currency': 'EGP',
//       'payment_method': paymentMethod,
//     });
//   }

//   /// ✅ Purchase
//   static void purchase({
//     required String orderId,
//     required double total,
//   }) {
//     final eventId = _generateEventId();

//     _track('Purchase', {
//       'value': total,
//       'currency': 'EGP',
//       'order_id': orderId.toString(),
//       'event_id': eventId, // ✅ جاهز للـ Deduplication
//     });
//   }

//   /// ✅ Lead
//   static void lead() {
//     _track('Lead', {});
//   }

//   /// ✅ Complete Registration
//   static void completeRegistration() {
//     _track('CompleteRegistration', {});
//   }

//   /// ✅ Contact
//   static void contact() {
//     _track('Contact', {});
//   }

//   /// ✅ Subscribe
//   static void subscribe() {
//     _track('Subscribe', {});
//   }

//   /// ✅ Customize Product
//   static void customizeProduct({
//     required String productId,
//   }) {
//     _track('CustomizeProduct', {
//       'content_ids': [productId.toString()],
//     });
//   }

//   /// ✅ Donate
//   static void donate(double amount) {
//     _track('Donate', {
//       'value': amount,
//       'currency': 'EGP',
//     });
//   }

//   /// ✅ Find Location
//   static void findLocation() {
//     _track('FindLocation', {});
//   }

//   /// ✅ Schedule
//   static void schedule() {
//     _track('Schedule', {});
//   }

//   /// ✅ Start Trial
//   static void startTrial() {
//     _track('StartTrial', {});
//   }

//   /// ✅ Submit Application
//   static void submitApplication() {
//     _track('SubmitApplication', {});
//   }
// }
