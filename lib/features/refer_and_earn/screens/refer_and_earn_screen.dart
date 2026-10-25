import 'package:dotted_border/dotted_border.dart';
import 'package:expandable_bottom_sheet/expandable_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:Oxygen_Mart/common/controllers/theme_controller.dart';
import 'package:Oxygen_Mart/common/widgets/custom_app_bar.dart';
import 'package:Oxygen_Mart/common/widgets/custom_button.dart';
import 'package:Oxygen_Mart/common/widgets/custom_snackbar.dart';
import 'package:Oxygen_Mart/common/widgets/footer_view.dart';
import 'package:Oxygen_Mart/common/widgets/menu_drawer.dart';
import 'package:Oxygen_Mart/common/widgets/not_logged_in_screen.dart';
import 'package:Oxygen_Mart/common/widgets/web_page_title_widget.dart';
import 'package:Oxygen_Mart/features/profile/controllers/profile_controller.dart';
import 'package:Oxygen_Mart/features/refer_and_earn/widgets/bottom_sheet_view_widget.dart';
import 'package:Oxygen_Mart/features/splash/controllers/splash_controller.dart';
import 'package:Oxygen_Mart/helper/auth_helper.dart';
import 'package:Oxygen_Mart/helper/price_converter.dart';
import 'package:Oxygen_Mart/helper/responsive_helper.dart';
import 'package:Oxygen_Mart/util/app_constants.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/images.dart';
import 'package:Oxygen_Mart/util/styles.dart';

class ReferAndEarnScreen extends StatefulWidget {
  const ReferAndEarnScreen({super.key});

  @override
  State<ReferAndEarnScreen> createState() => _ReferAndEarnScreenState();
}

class _ReferAndEarnScreenState extends State<ReferAndEarnScreen> {
  GlobalKey<ExpandableBottomSheetState> key = GlobalKey();

  @override
  void initState() {
    super.initState();
    _initCall();
  }

  void _initCall() {
    if (AuthHelper.isLoggedIn() &&
        Get.find<ProfileController>().userInfoModel == null) {
      Get.find<ProfileController>().getUserInfo();
    }
  }

  void _shareCode(String refCode) {
    final splash = Get.find<SplashController>().configModel;
    final String shareText = splash?.appUrlAndroid != null
        ? '${AppConstants.appName} ${'referral_code'.tr}: $refCode\n${'download_app_from_this_link'.tr}: ${splash?.appUrlAndroid}'
        : '${AppConstants.appName} ${'referral_code'.tr}: $refCode';
    Share.share(shareText);
  }

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = AuthHelper.isLoggedIn();
    final bool isDark = Get.find<ThemeController>().darkTheme;
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color cardBg = Theme.of(context).cardColor;

    return Scaffold(
      endDrawer: const MenuDrawer(),
      endDrawerEnableOpenDragGesture: false,
      appBar: CustomAppBar(title: 'refer_and_earn'.tr),
      body: ExpandableBottomSheet(
        key: key,
        background: isLoggedIn
            ? SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.isDesktop(context)
                      ? 0
                      : Dimensions.paddingSizeDefault,
                  vertical: Dimensions.paddingSizeSmall,
                ),
                child: Column(
                  children: [
                    WebScreenTitleWidget(title: 'refer_and_earn'.tr),
                    FooterView(
                      child: Center(
                        child: SizedBox(
                          width: Dimensions.webMaxWidth,
                          child: GetBuilder<ProfileController>(
                            builder: (profileController) {
                              final String refCode = profileController
                                      .userInfoModel?.refCode ??
                                  '';
                              final double exchangeRate =
                                  Get.find<SplashController>()
                                          .configModel
                                          ?.refEarningExchangeRate
                                          ?.toDouble() ??
                                      0.0;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Hero Card Container
                                  Container(
                                    width: double.infinity,
                                    margin: const EdgeInsets.symmetric(
                                        vertical: Dimensions.paddingSizeSmall),
                                    padding: const EdgeInsets.all(
                                        Dimensions.paddingSizeLarge),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: isDark
                                            ? [
                                                const Color(0xFF134E36),
                                                const Color(0xFF0D3323),
                                              ]
                                            : [
                                                primaryColor,
                                                primaryColor.withValues(alpha: 0.85),
                                              ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(24),
                                      boxShadow: [
                                        BoxShadow(
                                          color: primaryColor.withValues(alpha: 0.25),
                                          blurRadius: 18,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        // Reward Rate Pill
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 14, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(alpha: 0.2),
                                            borderRadius: BorderRadius.circular(30),
                                            border: Border.all(
                                              color: Colors.white.withValues(alpha: 0.35),
                                              width: 1,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.card_giftcard_rounded,
                                                  color: Colors.white, size: 16),
                                              const SizedBox(width: 6),
                                              Text(
                                                '${'one_referral'.tr} = ${PriceConverter.convertPrice(exchangeRate)}',
                                                style: robotoBold.copyWith(
                                                  color: Colors.white,
                                                  fontSize: Dimensions.fontSizeSmall,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 16),

                                        // Illustration
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(alpha: 0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Image.asset(
                                            Images.referImage,
                                            width: ResponsiveHelper.isDesktop(context)
                                                ? 300
                                                : 140,
                                            height: ResponsiveHelper.isDesktop(context)
                                                ? 180
                                                : 110,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                        const SizedBox(height: 14),

                                        // Title & Subtitle
                                        Text(
                                          'invite_friends_and_business'.tr,
                                          style: robotoBold.copyWith(
                                            fontSize: Dimensions.fontSizeExtraLarge,
                                            color: Colors.white,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          'earn_money_on_every_referral'.tr,
                                          style: robotoRegular.copyWith(
                                            fontSize: Dimensions.fontSizeSmall,
                                            color: Colors.white.withValues(alpha: 0.9),
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: Dimensions.paddingSizeSmall),

                                  // Personal Code Box
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(
                                        Dimensions.paddingSizeDefault),
                                    decoration: BoxDecoration(
                                      color: cardBg,
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: primaryColor.withValues(alpha: 0.15),
                                        width: 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: isDark
                                              ? Colors.black.withValues(alpha: 0.2)
                                              : primaryColor.withValues(alpha: 0.05),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'your_personal_code'.tr,
                                          style: robotoMedium.copyWith(
                                            fontSize: Dimensions.fontSizeSmall,
                                            color: Theme.of(context).hintColor,
                                          ),
                                        ),
                                        const SizedBox(height: 8),

                                        DottedBorder(
                                          color: primaryColor.withValues(alpha: 0.5),
                                          strokeWidth: 1.5,
                                          strokeCap: StrokeCap.butt,
                                          dashPattern: const [8, 5],
                                          padding: const EdgeInsets.all(4),
                                          borderType: BorderType.RRect,
                                          radius: const Radius.circular(14),
                                          child: Container(
                                            height: 52,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: Dimensions.paddingSizeDefault),
                                            decoration: BoxDecoration(
                                              color: primaryColor.withValues(alpha: 0.04),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: (profileController.userInfoModel != null)
                                                ? Row(
                                                    children: [
                                                      Expanded(
                                                        child: SelectableText(
                                                          refCode,
                                                          style: robotoBold.copyWith(
                                                            fontSize: Dimensions.fontSizeExtraLarge,
                                                            letterSpacing: 2,
                                                            color: primaryColor,
                                                          ),
                                                        ),
                                                      ),
                                                      InkWell(
                                                        onTap: () {
                                                          if (refCode.isNotEmpty) {
                                                            Clipboard.setData(
                                                                ClipboardData(text: refCode));
                                                            showCustomSnackBar(
                                                                'referral_code_copied'.tr,
                                                                isError: false);
                                                          }
                                                        },
                                                        borderRadius: BorderRadius.circular(10),
                                                        child: Container(
                                                          padding: const EdgeInsets.symmetric(
                                                              horizontal: 14, vertical: 8),
                                                          decoration: BoxDecoration(
                                                            color: primaryColor,
                                                            borderRadius:
                                                                BorderRadius.circular(10),
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: primaryColor.withValues(alpha: 0.3),
                                                                blurRadius: 6,
                                                                offset: const Offset(0, 2),
                                                              ),
                                                            ],
                                                          ),
                                                          child: Row(
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: [
                                                              const Icon(Icons.copy_rounded,
                                                                  color: Colors.white, size: 14),
                                                              const SizedBox(width: 4),
                                                              Text(
                                                                'copy'.tr,
                                                                style: robotoBold.copyWith(
                                                                  color: Colors.white,
                                                                  fontSize: Dimensions.fontSizeSmall,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                : const Center(
                                                    child: SizedBox(
                                                      height: 20,
                                                      width: 20,
                                                      child: CircularProgressIndicator(strokeWidth: 2),
                                                    ),
                                                  ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: Dimensions.paddingSizeDefault),

                                  // Primary Share Button
                                  CustomButton(
                                    buttonText: 'share'.tr,
                                    icon: Icons.share_rounded,
                                    onPressed: () {
                                      if (refCode.isNotEmpty) {
                                        _shareCode(refCode);
                                      }
                                    },
                                    radius: 14,
                                    height: 50,
                                  ),

                                  const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                                  // How It Works inline (for desktop & mobile view)
                                  if (ResponsiveHelper.isDesktop(context))
                                    const Padding(
                                      padding: EdgeInsets.only(
                                          top: Dimensions.paddingSizeExtraLarge),
                                      child: BottomSheetViewWidget(),
                                    )
                                  else
                                    const BottomSheetViewWidget(),

                                  const SizedBox(height: 40),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : NotLoggedInScreen(callBack: (value) {
                _initCall();
                setState(() {});
              }),
        persistentHeader: null,
        expandableContent: const SizedBox(),
      ),
    );
  }
}
