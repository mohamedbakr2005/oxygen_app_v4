// import 'dart:js' as js;

// class GTMEvents {

//   /// ✅ Core Sender
//   static void _push(Map<String, dynamic> data) {
//     final payload = js.JsObject.jsify(data);
//     js.context['dataLayer'].callMethod('push', [payload]);
//   }

//   /// ✅ View Content
//   static void viewContent({
//     required String productId,
//     required String name,
//     required double price,
//   }) {
//     _push({
//       'event': 'view_content',
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
//     _push({
//       'event': 'add_to_cart',
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
//     _push({
//       'event': 'remove_from_cart',
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
//     _push({
//       'event': 'add_to_wishlist',
//       'content_ids': [productId.toString()],
//       'content_name': name.toString(),
//       'content_type': 'product',
//       'value': price,
//       'currency': 'EGP',
//     });
//   }

//   /// ✅ Search
//   static void search(String keyword) {
//     _push({
//       'event': 'search',
//       'search_string': keyword,
//     });
//   }

//   /// ✅ Initiate Checkout
//   static void initiateCheckout({
//     required double total,
//     required int itemsCount,
//   }) {
//     _push({
//       'event': 'initiate_checkout',
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
//     _push({
//       'event': 'add_payment_info',
//       'value': total,
//       'currency': 'EGP',
//       'payment_method': paymentMethod,
//     });
//   }

//   /// ✅ Purchase ✅
//   static void purchase({
//     required String orderId,
//     required double total,
//   }) {
//     _push({
//       'event': 'purchase',
//       'value': total,
//       'currency': 'EGP',
//       'order_id': orderId.toString(),
//     });
//   }

//   /// ✅ Lead
//   static void lead() {
//     _push({
//       'event': 'lead',
//     });
//   }

//   /// ✅ Complete Registration
//   static void completeRegistration() {
//     _push({
//       'event': 'complete_registration',
//     });
//   }

//   /// ✅ Contact
//   static void contact() {
//     _push({
//       'event': 'contact',
//     });
//   }

//   /// ✅ Subscribe
//   static void subscribe() {
//     _push({
//       'event': 'subscribe',
//     });
//   }

//   /// ✅ Customize Product
//   static void customizeProduct({
//     required String productId,
//   }) {
//     _push({
//       'event': 'customize_product',
//       'content_ids': [productId.toString()],
//     });
//   }

//   /// ✅ Donate
//   static void donate(double amount) {
//     _push({
//       'event': 'donate',
//       'value': amount,
//       'currency': 'EGP',
//     });
//   }

//   /// ✅ Find Location
//   static void findLocation() {
//     _push({
//       'event': 'find_location',
//     });
//   }

//   /// ✅ Schedule
//   static void schedule() {
//     _push({
//       'event': 'schedule',
//     });
//   }

//   /// ✅ Start Trial
//   static void startTrial() {
//     _push({
//       'event': 'start_trial',
//     });
//   }

//   /// ✅ Submit Application
//   static void submitApplication() {
//     _push({
//       'event': 'submit_application',
//     });
//   }
// }
