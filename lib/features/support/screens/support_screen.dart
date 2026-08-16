import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
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

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  String formatPhoneForUI(String phone) {
    if (phone.startsWith('+2')) {
      return '' + phone.substring(2);
    }
    return phone;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'help_support'.tr),
      endDrawer: const MenuDrawer(),
      endDrawerEnableOpenDragGesture: false,
      body: SingleChildScrollView(
        padding: ResponsiveHelper.isDesktop(context)
            ? EdgeInsets.zero
            : const EdgeInsets.all(Dimensions.paddingSizeSmall),
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
                  child: Column(children: [
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    Image.asset(Images.supportImage, height: 120),
                    const SizedBox(height: 30),
                    Image.asset(Images.logo, width: 200),
                    const SizedBox(height: 40),
                    SupportButtonWidget(
                      icon: Icons.location_on,
                      title: 'address'.tr,
                      color: Colors.blue,
                      info: Get.find<SplashController>().configModel!.address,
                      onTap: () {},
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    SupportButtonWidget(
                      icon: Icons.phone,
                      title: 'call'.tr,
                      color: Colors.red,
                      info: "0882138424",
                      onTap: () async {
                        final phone = "+20882138424";
                        if (await canLaunchUrlString('tel:$phone')) {
                          launchUrlString('tel:$phone');
                        } else {
                          showCustomSnackBar('${'can_not_launch'.tr} $phone');
                        }
                      },
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    SupportButtonWidget(
                      iconPath: Images.whatsappIcon,
                      icon: Icons
                          .call_end, // This will be used if iconPath is null
                      title: 'messageWhatsapp'.tr,
                      color: Colors.green,
                      info: formatPhoneForUI(Get.find<SplashController>().configModel!.phone!),
                      onTap: () async {
                        launchWhatsApp(
                            phone: Get.find<SplashController>()
                                .configModel!
                                .phone!,
                            message: '');
                      },
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    SupportButtonWidget(
                      icon: Icons.mail_outline,
                      title: 'email_us'.tr,
                      color: Colors.green,
                      info: Get.find<SplashController>().configModel!.email,
                      onTap: () {
                        final Uri emailLaunchUri = Uri(
                          scheme: 'mailto',
                          path: Get.find<SplashController>().configModel!.email,
                        );
                        launchUrlString(emailLaunchUri.toString());
                      },
                    ),
                  ])),
        )),
      ),
    );
  }
}

Future<void> launchWhatsApp({required String phone, String? message}) async {
  final url = "https://wa.me/$phone?text=${Uri.encodeComponent(message ?? '')}";
  if (await canLaunchUrl(Uri.parse(url))) {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  } else {
    throw "Could not launch WhatsApp";
  }
}
