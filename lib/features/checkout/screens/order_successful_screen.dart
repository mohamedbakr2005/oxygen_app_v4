import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Oxygen_Mart/common/controllers/theme_controller.dart';
import 'package:Oxygen_Mart/common/widgets/custom_button.dart';
import 'package:Oxygen_Mart/common/widgets/footer_view.dart';
import 'package:Oxygen_Mart/common/widgets/menu_drawer.dart';
import 'package:Oxygen_Mart/common/widgets/web_menu_bar.dart';
import 'package:Oxygen_Mart/features/auth/controllers/auth_controller.dart';
import 'package:Oxygen_Mart/features/auth/widgets/auth_dialog_widget.dart';
import 'package:Oxygen_Mart/features/checkout/widgets/payment_failed_dialog.dart';
import 'package:Oxygen_Mart/features/location/domain/models/zone_response_model.dart';
import 'package:Oxygen_Mart/features/order/controllers/order_controller.dart';
import 'package:Oxygen_Mart/features/splash/controllers/splash_controller.dart';
import 'package:Oxygen_Mart/helper/address_helper.dart';
import 'package:Oxygen_Mart/helper/auth_helper.dart';
import 'package:Oxygen_Mart/helper/responsive_helper.dart';
import 'package:Oxygen_Mart/helper/route_helper.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/images.dart';
import 'package:Oxygen_Mart/util/styles.dart';

class OrderSuccessfulScreen extends StatefulWidget {
  final String? orderID;
  final String? contactPersonNumber;
  final bool? createAccount;
  final String guestId;
  const OrderSuccessfulScreen(
      {super.key,
      required this.orderID,
      this.contactPersonNumber,
      this.createAccount = false,
      required this.guestId});

  @override
  State<OrderSuccessfulScreen> createState() => _OrderSuccessfulScreenState();
}

class _OrderSuccessfulScreenState extends State<OrderSuccessfulScreen> {
  bool? _isCashOnDeliveryActive = false;
  String? orderId;

  @override
  void initState() {
    super.initState();

    orderId = widget.orderID!;
    if (widget.orderID != null) {
      if (widget.orderID!.contains('?')) {
        var parts = widget.orderID!.split('?');
        String id = parts[0].trim();
        orderId = id;
      }
    }

    Get.find<OrderController>().trackOrder(orderId.toString(), null, false,
        contactNumber: widget.contactPersonNumber);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        await Get.offAllNamed(RouteHelper.getInitialRoute());
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).cardColor,
        appBar: ResponsiveHelper.isDesktop(context) ? const WebMenuBar() : null,
        endDrawer: const MenuDrawer(),
        endDrawerEnableOpenDragGesture: false,
        body: Container(
          // Soft gradient background matching the UI
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).cardColor,
                const Color(0xFFF8E9F0).withOpacity(0.3),
                const Color(0xFFE8F5E9).withOpacity(0.4),
              ],
            ),
          ),
          child: GetBuilder<OrderController>(builder: (orderController) {
            double total = 0;
            bool success = true;
            bool parcel = false;
            double? maximumCodOrderAmount;
            if (orderController.trackModel != null) {
              total = ((orderController.trackModel!.orderAmount! / 100) *
                  Get.find<SplashController>()
                      .configModel!
                      .loyaltyPointItemPurchasePoint!);
              success = orderController.trackModel!.paymentStatus == 'paid' ||
                  orderController.trackModel!.paymentMethod ==
                      'cash_on_delivery' ||
                  orderController.trackModel!.paymentMethod == 'partial_payment';
              parcel = orderController.trackModel!.paymentMethod == 'parcel';
              for (ZoneData zData
                  in AddressHelper.getUserAddressFromSharedPref()!.zoneData!) {
                for (Modules m in zData.modules!) {
                  if (m.id == Get.find<SplashController>().module!.id) {
                    maximumCodOrderAmount = m.pivot!.maximumCodOrderAmount;
                    break;
                  }
                }
                if (zData.id ==
                    AddressHelper.getUserAddressFromSharedPref()!.zoneId) {
                  _isCashOnDeliveryActive = zData.cashOnDelivery;
                }
              }

              if (!success &&
                  !Get.isDialogOpen! &&
                  orderController.trackModel!.orderStatus != 'canceled' &&
                  Get.currentRoute.startsWith(RouteHelper.orderSuccess)) {
                Future.delayed(const Duration(seconds: 1), () {
                  Get.dialog(
                      PaymentFailedDialog(
                        orderID: orderId,
                        isCashOnDelivery: _isCashOnDeliveryActive,
                        orderAmount: total,
                        maxCodOrderAmount: maximumCodOrderAmount,
                        orderType: parcel ? 'parcel' : 'delivery',
                        guestId: widget.guestId,
                      ),
                      barrierDismissible: false);
                });
              }
            }

            return orderController.trackModel != null
                ? Center(
                    child: SingleChildScrollView(
                      child: FooterView(
                          child: SizedBox(
                              width: Dimensions.webMaxWidth,
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(height: Dimensions.paddingSizeExtraLarge),
                                    
                                    // UI CHANGE: "Fager" Animation (Ripple + Elastic Rotate Pop)
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        // Ripple Effect
                                        TweenAnimationBuilder<double>(
                                          tween: Tween<double>(begin: 0.0, end: 1.0),
                                          duration: const Duration(milliseconds: 1500),
                                          curve: Curves.easeOutQuad,
                                          builder: (context, value, child) {
                                            return Transform.scale(
                                              scale: 1.0 + (value * 0.8),
                                              child: Opacity(
                                                opacity: 1.0 - value,
                                                child: Container(
                                                  width: 150,
                                                  height: 150,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color: success ? const Color(0xFF56B573) : Colors.red,
                                                      width: 3,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                        // Elastic Pop with slight rotation
                                        TweenAnimationBuilder<double>(
                                          tween: Tween<double>(begin: 0.0, end: 1.0),
                                          duration: const Duration(milliseconds: 1000),
                                          curve: Curves.elasticOut,
                                          builder: (context, value, child) {
                                            return Transform.scale(
                                              scale: value,
                                              child: Transform.rotate(
                                                angle: (1 - value) * 0.5, // لفة خفيفة وهي بتكبر
                                                child: child,
                                              ),
                                            );
                                          },
                                          child: Container(
                                            width: 130,
                                            height: 130,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: success ? const Color(0xFF56B573).withOpacity(0.15) : Colors.red.withOpacity(0.15),
                                            ),
                                            padding: const EdgeInsets.all(16),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: success ? const Color(0xFF56B573) : Colors.red,
                                                border: Border.all(color: Theme.of(context).cardColor, width: 4),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: success ? const Color(0xFF56B573).withOpacity(0.4) : Colors.red.withOpacity(0.4),
                                                    blurRadius: 20,
                                                    spreadRadius: 5,
                                                    offset: const Offset(0, 4),
                                                  )
                                                ]
                                              ),
                                              child: Icon(
                                                success ? Icons.check_rounded : Icons.close_rounded,
                                                color: Colors.white,
                                                size: 50,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: Dimensions.paddingSizeExtraLarge),
                                    
                                    // ORIGINAL LOGIC: Original Translated Title
                                    Text(
                                      success
                                          ? parcel
                                              ? 'you_placed_the_parcel_request_successfully'.tr
                                              : 'you_placed_the_order_successfully'.tr
                                          : 'your_order_is_failed_to_place'.tr,
                                      style: robotoMedium.copyWith(
                                          fontSize: Dimensions.fontSizeLarge),
                                    ),
                                    
                                    const SizedBox(height: Dimensions.paddingSizeSmall),
                                    
                                    // ORIGINAL LOGIC: Original Translated Subtitle
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: Dimensions.paddingSizeLarge,
                                          vertical: Dimensions.paddingSizeSmall),
                                      child: Text(
                                        success
                                            ? parcel
                                                ? 'your_parcel_request_is_placed_successfully'.tr
                                                : 'your_order_is_placed_successfully'.tr
                                            : 'your_order_is_failed_to_place_because'.tr,
                                        style: robotoMedium.copyWith(
                                            fontSize: Dimensions.fontSizeSmall,
                                            color: Theme.of(context).disabledColor),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    
                                    const SizedBox(height: Dimensions.paddingSizeLarge),

                                    // ORIGINAL LOGIC KEEPS GOING: Create Account
                                    widget.createAccount!
                                        ? Padding(
                                            padding: const EdgeInsets.only(
                                                bottom:
                                                    Dimensions.paddingSizeSmall),
                                            child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    'and_create_account_successfully'
                                                        .tr,
                                                    style: robotoMedium,
                                                  ),
                                                  InkWell(
                                                    onTap: () {
                                                      if (ResponsiveHelper
                                                          .isDesktop(context)) {
                                                        Get.dialog(const Center(
                                                            child:
                                                                AuthDialogWidget(
                                                                    exitFromApp:
                                                                        false,
                                                                    backFromThis:
                                                                        false)));
                                                      } else {
                                                        Get.toNamed(RouteHelper
                                                            .getSignInRoute(
                                                                RouteHelper
                                                                    .splash));
                                                      }
                                                    },
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                          .all(Dimensions
                                                              .paddingSizeExtraSmall),
                                                      child: Text('sign_in'.tr,
                                                          style: robotoMedium
                                                              .copyWith(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .primaryColor)),
                                                    ),
                                                  ),
                                                ]),
                                          )
                                        : const SizedBox(),

                                    // ORIGINAL LOGIC: Guest ID
                                    AuthHelper.isGuestLoggedIn()
                                        ? SelectableText(
                                            '${'order_id'.tr}: $orderId',
                                            style: robotoMedium.copyWith(
                                                fontSize:
                                                    Dimensions.fontSizeLarge,
                                                color: Theme.of(context)
                                                    .primaryColor),
                                          )
                                        : const SizedBox(),

                                    // ORIGINAL LOGIC: Loyalty Points
                                    ResponsiveHelper.isDesktop(context) &&
                                            (success &&
                                                Get.find<SplashController>()
                                                        .configModel!
                                                        .loyaltyPointStatus ==
                                                    1 &&
                                                total.floor() > 0) &&
                                            AuthHelper.isLoggedIn()
                                        ? Column(children: [
                                            Image.asset(
                                                Get.find<ThemeController>()
                                                        .darkTheme
                                                    ? Images.congratulationDark
                                                    : Images.congratulationLight,
                                                width: 150,
                                                height: 150),
                                            Text('congratulations'.tr,
                                                style: robotoMedium.copyWith(
                                                    fontSize: Dimensions
                                                        .fontSizeLarge)),
                                            const SizedBox(
                                                height:
                                                    Dimensions.paddingSizeSmall),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: Dimensions
                                                      .paddingSizeLarge),
                                              child: Text(
                                                '${'you_have_earned'.tr} ${total.floor().toString()} ${'points_it_will_add_to'.tr}',
                                                style: robotoRegular.copyWith(
                                                    fontSize:
                                                        Dimensions.fontSizeLarge,
                                                    color: Theme.of(context)
                                                        .disabledColor),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ])
                                        : const SizedBox.shrink(),
                                        
                                    const SizedBox(height: 30),

                                    // UI CHANGE: "Track Order" Button added above the original Back Home
                                    if (success)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                                        child: SizedBox(
                                          width: ResponsiveHelper.isDesktop(context) ? 300 : double.infinity,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              try {
                                                Get.toNamed(RouteHelper.getOrderDetailsRoute(int.parse(orderId!)));
                                              } catch (e) {
                                                debugPrint('Navigation to tracking failed: $e');
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFF56B573), // Matching exact green
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(16),
                                              ),
                                              padding: const EdgeInsets.symmetric(vertical: 18),
                                            ),
                                            child: Text(
                                              'track_order'.tr, // حطيتلك الـ translation key لو متسجل عندك
                                              style: robotoMedium.copyWith(
                                                fontSize: 16,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    
                                    const SizedBox(height: Dimensions.paddingSizeSmall),

                                    // UI CHANGE: Converted "Back to home" to TextButton to match design, keeping Original Logic
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                                      child: SizedBox(
                                        width: ResponsiveHelper.isDesktop(context) ? 300 : double.infinity,
                                        child: TextButton(
                                          style: TextButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(vertical: 16),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                          ),
                                          onPressed: () {
                                            if (AuthHelper.isLoggedIn()) {
                                              Get.find<AuthController>()
                                                  .saveEarningPoint(
                                                      total.toStringAsFixed(0));
                                            }
                                            Get.offAllNamed(
                                                RouteHelper.getInitialRoute());
                                          },
                                          child: Text(
                                            'back_to_home'.tr,
                                            style: robotoMedium.copyWith(
                                              fontSize: 16,
                                              color: Theme.of(context).textTheme.bodyLarge!.color,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: Dimensions.paddingSizeLarge),
                                  ]))),
                    ),
                  )
                : const Center(child: CircularProgressIndicator());
          }),
        ),
      ),
    );
  }
}