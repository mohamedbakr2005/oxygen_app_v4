import 'dart:collection';
import 'dart:convert';

import 'package:Oxygen_Mart/common/widgets/custom_app_bar.dart';
import 'package:Oxygen_Mart/core/services/meta/meta_analytics_service.dart';
import 'package:Oxygen_Mart/features/checkout/widgets/payment_failed_dialog.dart';
import 'package:Oxygen_Mart/features/location/domain/models/zone_response_model.dart';
import 'package:Oxygen_Mart/features/order/controllers/order_controller.dart';
import 'package:Oxygen_Mart/features/order/domain/models/order_model.dart';
import 'package:Oxygen_Mart/features/splash/controllers/splash_controller.dart';
import 'package:Oxygen_Mart/features/wallet/widgets/fund_payment_dialog_widget.dart';
import 'package:Oxygen_Mart/helper/address_helper.dart';
import 'package:Oxygen_Mart/helper/route_helper.dart';
import 'package:Oxygen_Mart/util/app_constants.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:universal_html/js.dart' as js;
import 'package:url_launcher/url_launcher.dart';

class PaymentWebViewScreen extends StatefulWidget {
  // final Item? item;
  final OrderModel orderModel;
  final bool isCashOnDelivery;
  final String? addFundUrl;
  final String paymentMethod;
  final String guestId;
  final String contactNumber;
  final String? subscriptionUrl;
  final int? storeId;
  final bool? createAccount;
  final bool isProSubscription;
  final bool isRenew;
  // final int? contentIds;
  const PaymentWebViewScreen({
    super.key,
    required this.orderModel,
    // required this.contentIds,
    required this.isCashOnDelivery,
    this.addFundUrl,
    required this.paymentMethod,
    required this.guestId,
    required this.contactNumber,
    this.subscriptionUrl,
    this.storeId,
    this.createAccount = false,
    this.isProSubscription = false,
    this.isRenew = false,
    // this.item,
  });

  @override
  PaymentScreenState createState() => PaymentScreenState();
}

class PaymentScreenState extends State<PaymentWebViewScreen> {
  late String selectedUrl;
  bool _isLoading = true;
  final bool _canRedirect = true;
  double? _maximumCodOrderAmount;
  PullToRefreshController? pullToRefreshController;
  InAppWebViewController? webViewController;
  final GlobalKey webViewKey = GlobalKey();
  bool _isPaymentHandled = false;

  // bool isSuccessPayment = false;

  bool isPaymentSuccessPage = false;

  bool _isValidUrl(String? url) {
    if (url == null) return false;
    final trimmed = url.trim();
    if (trimmed.isEmpty ||
        trimmed == 'null' ||
        trimmed == 'http://null/' ||
        trimmed == 'http://null') {
      return false;
    }
    return trimmed.startsWith('http://') || trimmed.startsWith('https://');
  }

  @override
  void initState() {
    super.initState();
    print(
        "========================================================================${widget.paymentMethod}==================================  ");
    if (_isValidUrl(widget.subscriptionUrl)) {
      selectedUrl = widget.subscriptionUrl!.trim();
    } else if (_isValidUrl(widget.addFundUrl)) {
      selectedUrl = widget.addFundUrl!.trim();
    } else {
      final customerId = widget.orderModel.userId == 0 ? widget.guestId : widget.orderModel.userId;
      selectedUrl =
          '${AppConstants.baseUrl}/payment-mobile?customer_id=$customerId&order_id=${widget.orderModel.id}&payment_method=${widget.paymentMethod}';
      print(
          "selectedUrl =============================================================== $selectedUrl");
    }

    _initData();
  }

  void _initData() async {
    if (!_isValidUrl(widget.addFundUrl)) {
      final userAddress = AddressHelper.getUserAddressFromSharedPref();
      if (userAddress?.zoneData != null) {
        for (ZoneData zData in userAddress!.zoneData!) {
          if (zData.modules != null) {
            for (Modules m in zData.modules!) {
              if (m.id == Get.find<SplashController>().module?.id) {
                _maximumCodOrderAmount = m.pivot?.maximumCodOrderAmount;
                break;
              }
            }
          }
        }
      }
    }

    pullToRefreshController = GetPlatform.isWeb ||
            ![TargetPlatform.iOS, TargetPlatform.android]
                .contains(defaultTargetPlatform)
        ? null
        : PullToRefreshController(
            onRefresh: () async {
              if (defaultTargetPlatform == TargetPlatform.android) {
                webViewController?.reload();
              } else if (defaultTargetPlatform == TargetPlatform.iOS ||
                  defaultTargetPlatform == TargetPlatform.macOS) {
                webViewController?.loadUrl(
                    urlRequest:
                        URLRequest(url: await webViewController?.getUrl()));
              }
            },
          );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        _exitApp();
      },
      child: Scaffold(
        appBar: isPaymentSuccessPage
            ? AppBar(
                title: const Text(
                  "Payment Successful",
                  style: TextStyle(fontSize: 20, color: Colors.black),
                ),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => _exitApp2(),
                ),
              )
            : (_isValidUrl(widget.subscriptionUrl)
                ? AppBar(
                    title: const Text(
                      'Subscription Payment',
                      style: TextStyle(fontSize: 20, color: Colors.black),
                    ),
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => _exitApp2(),
                    ),
                  )
                : CustomAppBar(
                    title: _isValidUrl(widget.addFundUrl)
                        ? 'Add Funds'
                        : "",
                    onBackPressed: () => _exitApp(),
                    backButton: true,
                  )),
        body: Stack(
          children: [
            InAppWebView(
              key: webViewKey,
              initialUrlRequest: URLRequest(url: WebUri(selectedUrl)),
              initialUserScripts: UnmodifiableListView<UserScript>([]),
              pullToRefreshController: pullToRefreshController,
              initialSettings: InAppWebViewSettings(
                isInspectable: kDebugMode,
                mediaPlaybackRequiresUserGesture: false,
                allowsInlineMediaPlayback: true,
                iframeAllow: "camera; microphone",
                iframeAllowFullscreen: true,
              ),
              onWebViewCreated: (controller) async {
                webViewController = controller;
              },
              onLoadStart: (controller, url) async {
                // Get.find<OrderController>().paymentRedirect(
                //   url: url.toString(),
                //   canRedirect: _canRedirect,
                //   onClose: () {
                //     print('1111111111111111111111111111111111');
                //   },
                //   addFundUrl: widget.addFundUrl,
                //   orderID: widget.orderModel.id.toString(),
                //   contactNumber: widget.contactNumber,
                //   subscriptionUrl: widget.subscriptionUrl,
                //   storeId: widget.storeId,
                //   createAccount: widget.createAccount!,
                //   guestId: widget.guestId,
                // );
                setState(() {
                  _isLoading = true;
                });
              },
              shouldOverrideUrlLoading: (controller, navigationAction) async {
                Uri uri = navigationAction.request.url!;
                if (![
                  "http",
                  "https",
                  "file",
                  "chrome",
                  "data",
                  "javascript",
                  "about"
                ].contains(uri.scheme)) {
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                    return NavigationActionPolicy.CANCEL;
                  }
                }
                return NavigationActionPolicy.ALLOW;
              },
              onLoadStop: (controller, url) async {
                pullToRefreshController?.endRefreshing();
                setState(() => _isLoading = false);

                final currentUrl = url.toString();

                print('🔗 Navigated to: $currentUrl');

                // فقط استدعي الـ paymentRedirect مرة واحدة
                if (!_isPaymentHandled) {
                  Get.find<OrderController>().paymentRedirect(
                    url: currentUrl,
                    canRedirect: _canRedirect,
                    onClose: () => print('onClose'),
                    addFundUrl: widget.addFundUrl,
                    orderID: widget.orderModel.id.toString(),
                    contactNumber: widget.contactNumber,
                    subscriptionUrl: widget.subscriptionUrl,
                    storeId: widget.storeId,
                    createAccount: widget.createAccount!,
                    guestId: widget.guestId,
                    isProSubscription: widget.isProSubscription,
                    isRenew: widget.isRenew,
                  );
                }

                // فك الـ conditions من الـ canGoBack لأنه بيبوظ الموضوع
                if (!_isPaymentHandled) {
                  if (currentUrl.contains('success=true') ||
                      currentUrl.contains('status=success') ||
                      currentUrl.contains('payment-success')) {
                    _isPaymentHandled = true;
                    print('✅ Payment SUCCESS detected');
                    if (!isPaymentSuccessPage) {
                      setState(() {
                        isPaymentSuccessPage = true;
                      });
                    }

                    final details = await Get.find<OrderController>()
                        .getOrderDetails(widget.orderModel.id.toString());

                    if (details != null && details.isNotEmpty) {
                      final contentIds =
                          details.map((e) => e.itemId.toString()).toList();

                      if (GetPlatform.isIOS || GetPlatform.isAndroid) {
                      }
                      if (GetPlatform.isWeb) {
                        // FacebookEvents.purchase(
                        //     orderId: widget.orderModel.id.toString(),
                        //     total: widget.orderModel.orderAmount ?? 0.0);
                      }

                      // fbqTrack("Purchase", {
                      //   "content_ids": contentIds,
                      //   "content_type": "product",
                      //   "value": widget.orderModel.orderAmount,
                      //   "currency": "EGP",
                      //   "_valueToSum": widget.orderModel.orderAmount,
                      // });
                      FirebaseAnalytics analytics = FirebaseAnalytics.instance;

                      analytics.logEvent(
                        name: 'Purchase',
                        parameters: {
                          'value': jsonEncode(contentIds),
                          'currency': 'EGP',
                          'tax': widget.orderModel.taxPercentage ?? 0.0,
                          'shipping': widget.orderModel.deliveryCharge ?? 0.0,
                          'coupon': widget.orderModel.couponCode ?? '',
                          'item_id': jsonEncode(contentIds),
                          'price': widget.orderModel.orderAmount ?? 0.0,
                          'quantity': widget.orderModel.orderAmount ?? 0.0,
                        },
                      );

                      try {
                        Get.find<MetaAnalyticsService>().purchase(
                          orderId: widget.orderModel.id.toString(),
                          value: widget.orderModel.orderAmount ?? 0.0,
                          currency: 'EGP',
                          numItems: details.fold<int>(0, (sum, e) => sum + (e.quantity ?? 1)),
                          paymentMethod: widget.paymentMethod,
                          coupon: widget.orderModel.couponCode,
                          contentIds: contentIds,
                          contents: details
                              .map((e) => {
                                    'id': e.itemId?.toString() ?? 'unknown',
                                    'quantity': e.quantity ?? 1,
                                    'item_price': e.price ?? 0.0,
                                  })
                              .toList(),
                        );
                      } catch (_) {}

                      print(
                          "============================== Purchase ${jsonEncode(contentIds)} ========================== ");
                    }
                    Get.offAllNamed(RouteHelper.getInitialRoute());
                  }

                  if (currentUrl.contains('success=false') ||
                      currentUrl.contains('fail=true') ||
                      currentUrl.contains('payment-fail') ||
                      currentUrl.contains('payment-failed') ||
                      currentUrl.contains('payment-cancel') ||
                      currentUrl.contains('status=fail') ||
                      currentUrl.contains('status=cancel')) {
                    _isPaymentHandled = true;
                    print('❌ Payment FAILED / CANCELLED detected');
                    _exitApp();
                  }
                }
              },
              onProgressChanged: (controller, progress) {
                if (progress == 100) {
                  pullToRefreshController?.endRefreshing();
                }
                // setState(() {
                //   _value = progress / 100;
                // });
              },
              onConsoleMessage: (controller, consoleMessage) {
                debugPrint(consoleMessage.message);
              },
            ),
            _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).primaryColor)),
                  )
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  void fbqTrack(String name, Map<String, dynamic> params) {
    if (kIsWeb) {
      try {
        js.context.callMethod('fbq', ['track', name, params]);
      } catch (e) {
        print("fbq error: $e");
      }
    }
  }

  Future<bool?> _exitApp() async {
    if (!_isValidUrl(widget.addFundUrl) ||
        !Get.find<SplashController>()
            .configModel!
            .digitalPaymentInfo!
            .pluginPaymentGateways!) {
      return Get.dialog(PaymentFailedDialog(
        orderID: widget.orderModel.id.toString(),
        orderAmount: widget.orderModel.orderAmount,
        maxCodOrderAmount: _maximumCodOrderAmount,
        orderType: widget.orderModel.orderType,
        isCashOnDelivery: widget.isCashOnDelivery,
        guestId: widget.guestId,
      ));
    } else {
      return Get.dialog(FundPaymentDialogWidget(
          isSubscription: _isValidUrl(widget.subscriptionUrl)));
    }
  }

  Future<bool?> _exitApp2() async {
    if (!_isValidUrl(widget.addFundUrl) ||
        !Get.find<SplashController>()
            .configModel!
            .digitalPaymentInfo!
            .pluginPaymentGateways!) {
      Get.offAllNamed(RouteHelper.getInitialRoute());
      return Get.offAllNamed(RouteHelper.getInitialRoute());
    } else {
      return Get.dialog(FundPaymentDialogWidget(
          isSubscription: _isValidUrl(widget.subscriptionUrl)));
    }
  }
}
