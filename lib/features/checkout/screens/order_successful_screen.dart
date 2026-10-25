import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Oxygen_Mart/common/controllers/theme_controller.dart';
import 'package:Oxygen_Mart/common/models/response_model.dart';
import 'package:Oxygen_Mart/common/widgets/footer_view.dart';
import 'package:Oxygen_Mart/common/widgets/menu_drawer.dart';
import 'package:Oxygen_Mart/common/widgets/web_menu_bar.dart';
import 'package:Oxygen_Mart/features/auth/controllers/auth_controller.dart';
import 'package:Oxygen_Mart/features/auth/domain/enum/centralize_login_enum.dart';
import 'package:Oxygen_Mart/features/checkout/screens/digital_payment_failed_screen.dart';
import 'package:Oxygen_Mart/features/order/controllers/order_controller.dart';
import 'package:Oxygen_Mart/features/order/domain/models/order_model.dart';
import 'package:Oxygen_Mart/features/profile/controllers/profile_controller.dart';
import 'package:Oxygen_Mart/features/splash/controllers/splash_controller.dart';
import 'package:Oxygen_Mart/helper/auth_helper.dart';
import 'package:Oxygen_Mart/helper/price_converter.dart';
import 'package:Oxygen_Mart/helper/responsive_helper.dart';
import 'package:Oxygen_Mart/helper/route_helper.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/images.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:Oxygen_Mart/common/widgets/custom_snackbar.dart';
import 'package:Oxygen_Mart/helper/custom_validator.dart';
import 'package:Oxygen_Mart/util/styles.dart';

class OrderSuccessfulScreen extends StatefulWidget {
  final String? orderID;
  final String? contactPersonNumber;
  final bool? createAccount;
  final String guestId;
  final String? customerName;
  final String? customerEmail;

  const OrderSuccessfulScreen({super.key,
    required this.orderID, this.contactPersonNumber, this.createAccount = false, required this.guestId,
    this.customerName, this.customerEmail,
  });

  @override
  State<OrderSuccessfulScreen> createState() => _OrderSuccessfulScreenState();
}

class _OrderSuccessfulScreenState extends State<OrderSuccessfulScreen> {
  String? orderId;
  bool _isSendingOtp = false;
  bool _otpFailed = false;
  String? _otpErrorMessage;

  @override
  void initState() {
    super.initState();

    orderId = widget.orderID ?? '';
    if (orderId != null && orderId!.isNotEmpty && orderId!.contains('?')) {
      final List<String> parts = orderId!.split('?');
      orderId = parts[0].trim();
    }

    if (GetPlatform.isWeb) {
      if (orderId != null && orderId!.isNotEmpty && orderId != 'null') {
        Get.find<OrderController>().getPaymentFailedDetails(orderId);
      }
    } else if (!(widget.createAccount ?? false) && !GetPlatform.isWeb) {
      final OrderController orderController = Get.find<OrderController>();

      if (orderId != null && orderId!.isNotEmpty && orderId != 'null') {
        orderController.trackOrder(orderId.toString(), null, false, contactNumber: widget.contactPersonNumber).then((_) {
          if (orderController.trackModel != null) {
            final bool success = orderController.trackModel!.paymentStatus == 'paid' ||
                orderController.trackModel!.paymentMethod == 'cash_on_delivery' ||
                orderController.trackModel!.paymentMethod == 'partial_payment' ||
                orderController.trackModel!.paymentMethod == 'wallet';

            if (!success && !(Get.isDialogOpen ?? false) && orderController.trackModel!.orderStatus != 'canceled' && Get.currentRoute.startsWith(RouteHelper.orderSuccess)) {
              orderController.getPaymentFailedDetails(orderId);
            }
          }
        }).catchError((e) {
          debugPrint('Error tracking order in OrderSuccessfulScreen: $e');
        });
      }
    }

    if (widget.createAccount == true && widget.contactPersonNumber != null && widget.contactPersonNumber!.isNotEmpty) {
      _initiatePostCheckoutOtp();
    }
  }

  void _initiatePostCheckoutOtp() {
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      _sendOtpAndNavigate();
    });
  }

  Future<void> _sendOtpAndNavigate() async {
    if (_isSendingOtp) return;
    setState(() {
      _isSendingOtp = true;
      _otpFailed = false;
      _otpErrorMessage = null;
    });

    String phone = (widget.contactPersonNumber ?? '').replaceAll(' ', '').trim();
    if (phone.isEmpty) {
      if (!mounted) return;
      setState(() {
        _isSendingOtp = false;
        _otpFailed = true;
        _otpErrorMessage = 'invalid_phone_number'.tr;
      });
      return;
    }

    String countryDialCode = Get.find<AuthController>().getUserCountryCode().isNotEmpty
        ? Get.find<AuthController>().getUserCountryCode()
        : (Get.find<SplashController>().configModel?.country != null
            ? CountryCode.fromCountryCode(Get.find<SplashController>().configModel!.country!).dialCode ?? '+20'
            : '+20');

    String numberWithCountryCode = phone.startsWith('+') ? phone : (countryDialCode + phone);
    PhoneValid phoneValid = await CustomValidator.isPhoneValid(numberWithCountryCode);
    numberWithCountryCode = phoneValid.phone;

    if (!phoneValid.isValid) {
      if (!mounted) return;
      setState(() {
        _isSendingOtp = false;
        _otpFailed = true;
        _otpErrorMessage = 'invalid_phone_number'.tr;
      });
      showCustomSnackBar('invalid_phone_number'.tr);
      return;
    }

    try {
      ResponseModel response = await Get.find<AuthController>().otpLogin(
        phone: numberWithCountryCode,
        loginType: CentralizeLoginType.otp.name,
        otp: '',
        verified: '',
      );

      if (!mounted) return;

      if (response.isSuccess) {
        setState(() {
          _isSendingOtp = false;
        });
        Get.offNamed(RouteHelper.getVerificationRoute(
          numberWithCountryCode,
          widget.customerEmail,
          '',
          RouteHelper.orderSuccess,
          null,
          CentralizeLoginType.otp.name,
          customerName: widget.customerName,
          orderId: orderId,
        ));
      } else {
        setState(() {
          _isSendingOtp = false;
          _otpFailed = true;
          _otpErrorMessage = response.message;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSendingOtp = false;
        _otpFailed = true;
        _otpErrorMessage = e.toString();
      });
    }
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
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                Theme.of(context).cardColor,
                const Color(0xFFF8E9F0).withValues(alpha: 0.3),
                const Color(0xFFE8F5E9).withValues(alpha: 0.4),
              ],
            ),
          ),
          child: GetBuilder<OrderController>(builder: (orderController) {
            double total = 0;
            bool success = true;
            bool parcel = false;
            bool takeAway = false;

            if (orderController.trackModel != null) {
              final double orderAmt = orderController.trackModel?.orderAmount ?? 0.0;
              final double loyaltyRate = Get.isRegistered<SplashController>()
                  ? (Get.find<SplashController>().configModel?.loyaltyPointItemPurchasePoint ?? 1.0)
                  : 1.0;
              total = (orderAmt / 100) * loyaltyRate;
              success = orderController.trackModel!.paymentStatus == 'paid' ||
                  orderController.trackModel!.paymentMethod == 'cash_on_delivery' ||
                  orderController.trackModel!.paymentMethod == 'partial_payment' ||
                  orderController.trackModel!.paymentMethod == 'wallet';
              parcel = orderController.trackModel!.orderType == 'parcel';
              takeAway = orderController.trackModel!.orderType == 'take_away';
            }

            if (orderController.paymentModel != null && GetPlatform.isWeb) {
              success = orderController.paymentModel!.paymentStatus == 'paid' ||
                  orderController.paymentModel!.paymentMethod == 'cash_on_delivery' ||
                  orderController.paymentModel!.paymentMethod == 'wallet';
              final double orderAmt = orderController.paymentModel?.orderAmount ?? 0.0;
              final double loyaltyRate = Get.isRegistered<SplashController>()
                  ? (Get.find<SplashController>().configModel?.loyaltyPointItemPurchasePoint ?? 1.0)
                  : 1.0;
              total = (orderAmt / 100) * loyaltyRate;
              parcel = orderController.paymentModel!.orderType == 'parcel';
              takeAway = orderController.paymentModel!.orderType == 'take_away';
            }

            if (GetPlatform.isWeb) {
              return orderController.paymentModel != null
                  ? SingleChildScrollView(
                      child: FooterView(
                        child: SizedBox(
                          width: Dimensions.webMaxWidth,
                          child: success
                              ? _OrderSuccessfulContent(
                                  total: total,
                                  parcel: parcel,
                                  takeAway: takeAway,
                                  success: success,
                                  orderId: orderId,
                                  createAccount: widget.createAccount ?? false,
                                  isSendingOtp: _isSendingOtp,
                                  otpFailed: _otpFailed,
                                  otpErrorMessage: _otpErrorMessage,
                                  onRetryOtp: _sendOtpAndNavigate,
                                )
                              : const PaymentIncompleteView(),
                        ),
                      ),
                    )
                  : const Center(child: CircularProgressIndicator());
            }

            return Center(
              child: SingleChildScrollView(
                child: FooterView(
                  child: SizedBox(
                    width: Dimensions.webMaxWidth,
                    child: _OrderSuccessfulContent(
                      total: total,
                      parcel: parcel,
                      takeAway: takeAway,
                      success: success,
                      orderId: orderId,
                      createAccount: widget.createAccount ?? false,
                      isSendingOtp: _isSendingOtp,
                      otpFailed: _otpFailed,
                      otpErrorMessage: _otpErrorMessage,
                      onRetryOtp: _sendOtpAndNavigate,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _OrderSuccessfulContent extends StatelessWidget {
  final double total;
  final bool parcel;
  final bool takeAway;
  final bool success;
  final String? orderId;
  final bool createAccount;
  final bool isSendingOtp;
  final bool otpFailed;
  final String? otpErrorMessage;
  final VoidCallback? onRetryOtp;

  const _OrderSuccessfulContent({
    required this.total, required this.parcel, required this.takeAway, required this.success, required this.orderId,
    required this.createAccount,
    this.isSendingOtp = false,
    this.otpFailed = false,
    this.otpErrorMessage,
    this.onRetryOtp,
  });

  @override
  Widget build(BuildContext context) {
    const Color brandGreen = Color(0xFF56B573);

    return Container(
      decoration: !ResponsiveHelper.isDesktop(context)
          ? null
          : BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusDefault)),
              color: Theme.of(context).cardColor,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.2),
                  blurRadius: 5,
                  spreadRadius: 1,
                ),
              ],
            ),
      margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeLarge),
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeLarge),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const SizedBox(height: Dimensions.paddingSizeExtraLarge),

          // Ripple + Elastic Rotate Pop Animation
          Stack(
            alignment: Alignment.center,
            children: <Widget>[
              // Ripple Effect
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 1500),
                curve: Curves.easeOutQuad,
                builder: (BuildContext context, double value, Widget? child) {
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
                            color: success ? brandGreen : Colors.red,
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
                builder: (BuildContext context, double value, Widget? child) {
                  return Transform.scale(
                    scale: value,
                    child: Transform.rotate(
                      angle: (1 - value) * 0.5,
                      child: child,
                    ),
                  );
                },
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: success ? brandGreen.withValues(alpha: 0.15) : Colors.red.withValues(alpha: 0.15),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: success ? brandGreen : Colors.red,
                      border: Border.all(color: Theme.of(context).cardColor, width: 4),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: success ? brandGreen.withValues(alpha: 0.4) : Colors.red.withValues(alpha: 0.4),
                          blurRadius: 20,
                          spreadRadius: 5,
                          offset: const Offset(0, 4),
                        ),
                      ],
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

          // Order ID Badge
          SelectableText(
            '${'order'.tr} #$orderId',
            style: robotoMedium.copyWith(
              fontSize: Dimensions.fontSizeLarge,
              color: brandGreen,
            ),
          ),

          const SizedBox(height: Dimensions.paddingSizeSmall),

          // Title
          Text(
            success
                ? parcel
                    ? 'you_placed_the_parcel_request_successfully'.tr
                    : 'you_placed_the_order_successfully'.tr
                : 'your_order_is_failed_to_place'.tr,
            style: robotoMedium.copyWith(
              fontSize: Dimensions.fontSizeLarge + 2,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: Dimensions.paddingSizeSmall),

          // Subtitle
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeLarge,
              vertical: Dimensions.paddingSizeExtraSmall,
            ),
            child: Text(
              success
                  ? parcel
                      ? 'your_parcel_request_is_placed_successfully'.tr
                      : takeAway
                          ? 'your_takeaway_order_has_been_placed_successfully'.tr
                          : 'your_order_is_placed_successfully'.tr
                  : 'your_order_is_failed_to_place_because'.tr,
              style: robotoMedium.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: Theme.of(context).disabledColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: Dimensions.paddingSizeSmall),

          _ProSavingsView(success: success),

          if (createAccount)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeLarge,
                vertical: Dimensions.paddingSizeSmall,
              ),
              child: Container(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                decoration: BoxDecoration(
                  color: (otpFailed ? Colors.red : Theme.of(context).primaryColor).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  border: Border.all(
                    color: (otpFailed ? Colors.red : Theme.of(context).primaryColor).withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isSendingOtp)
                          const Padding(
                            padding: EdgeInsetsDirectional.only(end: Dimensions.paddingSizeSmall),
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        else
                          Icon(
                            otpFailed ? Icons.error_outline : Icons.phonelink_ring_rounded,
                            size: 20,
                            color: otpFailed ? Colors.red : Theme.of(context).primaryColor,
                          ),
                        const SizedBox(width: Dimensions.paddingSizeSmall),
                        Flexible(
                          child: Text(
                            otpFailed
                                ? (otpErrorMessage != null && otpErrorMessage!.isNotEmpty
                                    ? otpErrorMessage!
                                    : 'could_not_send_otp_please_retry'.tr)
                                : isSendingOtp
                                    ? 'sending_otp_code'.tr
                                    : 'redirecting_to_verification'.tr,
                            style: robotoMedium.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: otpFailed ? Colors.red : Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    if (otpFailed && onRetryOtp != null) ...[
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                      TextButton.icon(
                        onPressed: isSendingOtp ? null : onRetryOtp,
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: Text('resend_code'.tr),
                        style: TextButton.styleFrom(
                          foregroundColor: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

          if (ResponsiveHelper.isDesktop(context) &&
              (success && (Get.find<SplashController>().configModel?.loyaltyPointStatus ?? 0) == 1 && total.floor() > 0) &&
              AuthHelper.isLoggedIn())
            Column(
              children: <Widget>[
                Image.asset(
                  Get.find<ThemeController>().darkTheme ? Images.congratulationDark : Images.congratulationLight,
                  width: 150,
                  height: 150,
                ),
                Text(
                  'congratulations'.tr,
                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                  child: Text(
                    '${'you_have_earned'.tr} ${total.floor().toString()} ${'points_it_will_add_to'.tr}',
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeLarge,
                      color: Theme.of(context).disabledColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),

          const SizedBox(height: 30),

          // Primary: "Track Order" Button
          if (success)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
              child: SizedBox(
                width: ResponsiveHelper.isDesktop(context) ? 300 : double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    try {
                      final int? parsedId = int.tryParse(orderId ?? '');
                      if (parsedId != null) {
                        Get.toNamed(RouteHelper.getOrderDetailsRoute(parsedId));
                      } else {
                        Get.offAllNamed(RouteHelper.getInitialRoute());
                      }
                    } catch (e) {
                      debugPrint('Navigation to tracking failed: $e');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandGreen,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                  child: Text(
                    'track_order'.tr,
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

          // Secondary: "Back to Home" Button
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
                    Get.find<AuthController>().saveEarningPoint(total.toStringAsFixed(0));
                  }
                  Get.offAllNamed(RouteHelper.getInitialRoute());
                },
                child: Text(
                  'back_to_home'.tr,
                  style: robotoMedium.copyWith(
                    fontSize: 16,
                    color: Theme.of(context).textTheme.bodyLarge?.color ?? Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: Dimensions.paddingSizeLarge),
        ],
      ),
    );
  }
}

class _ProSavingsView extends StatelessWidget {
  final bool success;
  const _ProSavingsView({required this.success});

  @override
  Widget build(BuildContext context) {
    final OrderModel? order = Get.find<OrderController>().trackModel;
    final double proSavings = (order?.proDiscount ?? 0) + (order?.deliveryFeeReductionAmount ?? 0);
    final bool isProUser = Get.find<ProfileController>().proStatus;

    if (!success || !isProUser || proSavings <= 0) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeLarge,
        vertical: Dimensions.paddingSizeSmall,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Image.asset(Images.proPlanCrown, height: 18, width: 18, color: const Color(0xFFFFC107)),
          const SizedBox(width: Dimensions.paddingSizeExtraSmall),
          Flexible(
            child: Text(
              '${'you_saved'.tr} ${PriceConverter.convertPrice(proSavings)} ${'with_pro'.tr}',
              textAlign: TextAlign.center,
              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Colors.deepPurpleAccent),
            ),
          ),
        ],
      ),
    );
  }
}
