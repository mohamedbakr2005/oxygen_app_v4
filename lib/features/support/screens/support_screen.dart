import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:Oxygen_Mart/common/controllers/theme_controller.dart';
import 'package:Oxygen_Mart/common/widgets/custom_app_bar.dart';
import 'package:Oxygen_Mart/common/widgets/custom_snackbar.dart';
import 'package:Oxygen_Mart/common/widgets/footer_view.dart';
import 'package:Oxygen_Mart/common/widgets/menu_drawer.dart';
import 'package:Oxygen_Mart/features/splash/controllers/splash_controller.dart';
import 'package:Oxygen_Mart/features/support/widgets/support_button_widget.dart';
import 'package:Oxygen_Mart/features/support/widgets/web_help_support_widget.dart';
import 'package:Oxygen_Mart/helper/responsive_helper.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/images.dart';
import 'package:Oxygen_Mart/util/styles.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  String formatPhoneForUI(String phone) {
    if (phone.startsWith('+2')) {
      return phone.substring(2);
    }
    return phone;
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Get.find<ThemeController>().darkTheme;
    final Color primaryColor = Theme.of(context).primaryColor;
    final config = Get.find<SplashController>().configModel;

    return Scaffold(
      appBar: CustomAppBar(title: 'help_support'.tr),
      endDrawer: const MenuDrawer(),
      endDrawerEnableOpenDragGesture: false,
      body: SingleChildScrollView(
        padding: ResponsiveHelper.isDesktop(context)
            ? EdgeInsets.zero
            : const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeDefault,
                vertical: Dimensions.paddingSizeSmall,
              ),
        physics: const BouncingScrollPhysics(),
        child: Center(
          child: FooterView(
            child: ResponsiveHelper.isDesktop(context)
                ? const SizedBox(
                    width: double.infinity,
                    height: 650,
                    child: WebSupportScreen(),
                  )
                : SizedBox(
                    width: Dimensions.webMaxWidth,
                    child: Column(
                      children: [
                        // Hero Header Card
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(
                            top: Dimensions.paddingSizeSmall,
                            bottom: Dimensions.paddingSizeLarge,
                          ),
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
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withValues(alpha: 0.2),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Image.asset(
                                  Images.supportImage,
                                  height: 80,
                                  width: 80,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                'help_support'.tr,
                                style: robotoBold.copyWith(
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'can_not_find_answers_contact_our_support_team'
                                    .tr,
                                style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),

                        // WhatsApp Action Card
                        if (config?.phone != null && config!.phone!.isNotEmpty)
                          SupportButtonWidget(
                            iconPath: Images.whatsappIcon,
                            icon: Icons.chat_bubble_outline_rounded,
                            title: 'messageWhatsapp'.tr,
                            subtitle: 'chat_with_support_team'.tr,
                            color: const Color(0xFF25D366),
                            actionText: 'chat'.tr,
                            info: formatPhoneForUI(config.phone!),
                            onTap: () async {
                              try {
                                await launchWhatsApp(
                                  phone: config.phone!,
                                  message: '',
                                );
                              } catch (e) {
                                showCustomSnackBar(
                                    '${'can_not_launch'.tr} WhatsApp');
                              }
                            },
                          ),

                        // Phone Call Card
                        SupportButtonWidget(
                          icon: Icons.phone_in_talk_rounded,
                          title: 'call'.tr,
                          subtitle: 'call_us_directly'.tr,
                          color: const Color(0xFF007AFF),
                          actionText: 'call'.tr,
                          info: "0882138424",
                          onTap: () async {
                            const phone = "+20882138424";
                            try {
                              if (await canLaunchUrlString('tel:$phone')) {
                                await launchUrlString('tel:$phone');
                              } else {
                                Clipboard.setData(
                                    const ClipboardData(text: "0882138424"));
                                showCustomSnackBar(
                                    'phone_copied_to_clipboard'.tr,
                                    isError: false);
                              }
                            } catch (e) {
                              Clipboard.setData(
                                  const ClipboardData(text: "0882138424"));
                              showCustomSnackBar('phone_copied_to_clipboard'.tr,
                                  isError: false);
                            }
                          },
                        ),

                        // Email Card
                        if (config?.email != null && config!.email!.isNotEmpty)
                          SupportButtonWidget(
                            icon: Icons.mark_email_read_rounded,
                            title: 'email_us'.tr,
                            subtitle: 'send_us_an_email'.tr,
                            color: const Color(0xFFFF9500),
                            actionText: 'email'.tr,
                            info: config.email,
                            onTap: () async {
                              final Uri emailLaunchUri = Uri(
                                scheme: 'mailto',
                                path: config.email,
                              );
                              try {
                                if (await canLaunchUrlString(
                                    emailLaunchUri.toString())) {
                                  await launchUrlString(
                                      emailLaunchUri.toString());
                                } else {
                                  Clipboard.setData(
                                      ClipboardData(text: config.email ?? ''));
                                  showCustomSnackBar(
                                      'email_copied_to_clipboard'.tr,
                                      isError: false);
                                }
                              } catch (e) {
                                Clipboard.setData(
                                    ClipboardData(text: config.email ?? ''));
                                showCustomSnackBar(
                                    'email_copied_to_clipboard'.tr,
                                    isError: false);
                              }
                            },
                          ),

                        // Address / Location Card
                        if (config?.address != null &&
                            config!.address!.isNotEmpty)
                          SupportButtonWidget(
                            icon: Icons.location_on_rounded,
                            title: 'address'.tr,
                            subtitle: 'our_headquarters_location'.tr,
                            color: primaryColor,
                            info: config.address,
                            onTap: () {
                              Clipboard.setData(
                                  ClipboardData(text: config.address ?? ''));
                              showCustomSnackBar('address_copied'.tr,
                                  isError: false);
                            },
                          ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

Future<void> launchWhatsApp({required String phone, String? message}) async {
  final url =
      "https://wa.me/$phone?text=${Uri.encodeComponent(message ?? '')}";
  if (await canLaunchUrl(Uri.parse(url))) {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  } else {
    throw "Could not launch WhatsApp";
  }
}
