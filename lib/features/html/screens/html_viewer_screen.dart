import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:Oxygen_Mart/common/controllers/theme_controller.dart';
import 'package:Oxygen_Mart/common/widgets/custom_app_bar.dart';
import 'package:Oxygen_Mart/common/widgets/footer_view.dart';
import 'package:Oxygen_Mart/common/widgets/menu_drawer.dart';
import 'package:Oxygen_Mart/common/widgets/web_page_title_widget.dart';
import 'package:Oxygen_Mart/features/html/controllers/html_controller.dart';
import 'package:Oxygen_Mart/helper/responsive_helper.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/html_type.dart';
import 'package:Oxygen_Mart/util/styles.dart';

class HtmlViewerScreen extends StatefulWidget {
  final HtmlType htmlType;
  const HtmlViewerScreen({super.key, required this.htmlType});

  @override
  State<HtmlViewerScreen> createState() => _HtmlViewerScreenState();
}

class _HtmlViewerScreenState extends State<HtmlViewerScreen> {
  @override
  void initState() {
    super.initState();
    Get.find<HtmlController>().getHtmlText(widget.htmlType);
  }

  String _getPageTitle() {
    switch (widget.htmlType) {
      case HtmlType.termsAndCondition:
        return 'terms_conditions'.tr;
      case HtmlType.aboutUs:
        return 'about_us'.tr;
      case HtmlType.privacyPolicy:
        return 'privacy_policy'.tr;
      case HtmlType.shippingPolicy:
        return 'shipping_policy'.tr;
      case HtmlType.refund:
        return 'refund_policy'.tr;
      case HtmlType.cancellation:
        return 'cancellation_policy'.tr;
      case HtmlType.proTermsAndCondition:
        return 'pro_terms_and_conditions'.tr;
    }
  }

  IconData _getPageIcon() {
    switch (widget.htmlType) {
      case HtmlType.termsAndCondition:
        return Icons.description_rounded;
      case HtmlType.aboutUs:
        return Icons.info_rounded;
      case HtmlType.privacyPolicy:
        return Icons.security_rounded;
      case HtmlType.shippingPolicy:
        return Icons.local_shipping_rounded;
      case HtmlType.refund:
        return Icons.assignment_return_rounded;
      case HtmlType.cancellation:
        return Icons.cancel_presentation_rounded;
      case HtmlType.proTermsAndCondition:
        return Icons.workspace_premium_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String pageTitle = _getPageTitle();
    final IconData pageIcon = _getPageIcon();
    final bool isDark = Get.find<ThemeController>().darkTheme;
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color cardBg = Theme.of(context).cardColor;

    return Scaffold(
      appBar: CustomAppBar(title: pageTitle),
      endDrawer: const MenuDrawer(),
      endDrawerEnableOpenDragGesture: false,
      body: GetBuilder<HtmlController>(builder: (htmlController) {
        return htmlController.htmlText != null
            ? SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    WebScreenTitleWidget(title: pageTitle),
                    FooterView(
                      child: Center(
                        child: Container(
                          width: Dimensions.webMaxWidth,
                          padding: EdgeInsets.all(
                            ResponsiveHelper.isDesktop(context)
                                ? Dimensions.paddingSizeLarge
                                : Dimensions.paddingSizeDefault,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Hero Title Badge
                              Container(
                                padding: const EdgeInsets.all(
                                    Dimensions.paddingSizeLarge),
                                margin: const EdgeInsets.only(
                                    bottom: Dimensions.paddingSizeDefault),
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
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primaryColor.withValues(alpha: 0.2),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.18),
                                        borderRadius:
                                            BorderRadius.circular(14),
                                      ),
                                      child: Icon(pageIcon,
                                          color: Colors.white, size: 26),
                                    ),
                                    const SizedBox(
                                        width: Dimensions.paddingSizeDefault),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            pageTitle,
                                            style: robotoBold.copyWith(
                                              fontSize:
                                                  Dimensions.fontSizeExtraLarge,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'official_policy_details'.tr,
                                            style: robotoRegular.copyWith(
                                              fontSize:
                                                  Dimensions.fontSizeSmall,
                                              color: Colors.white
                                                  .withValues(alpha: 0.85),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Content Card
                              Container(
                                decoration: BoxDecoration(
                                  color: cardBg,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: primaryColor.withValues(alpha: 0.1),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isDark
                                          ? Colors.black.withValues(alpha: 0.2)
                                          : primaryColor.withValues(alpha: 0.04),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(
                                    Dimensions.paddingSizeLarge),
                                child: HtmlWidget(
                                  htmlController.htmlText ?? '',
                                  key: Key(widget.htmlType.toString()),
                                  textStyle: robotoRegular.copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color
                                        ?.withValues(alpha: 0.85),
                                    fontSize: Dimensions.fontSizeDefault,
                                    height: 1.6,
                                  ),
                                  customStylesBuilder: (element) {
                                    if (element.localName == 'h1' ||
                                        element.localName == 'h2' ||
                                        element.localName == 'h3') {
                                      return {
                                        'color': '#0F8A58',
                                        'font-weight': 'bold',
                                        'margin-top': '16px',
                                        'margin-bottom': '8px',
                                      };
                                    }
                                    if (element.localName == 'p') {
                                      return {
                                        'margin-bottom': '12px',
                                        'line-height': '1.6',
                                      };
                                    }
                                    if (element.localName == 'a') {
                                      return {
                                        'color': '#0F8A58',
                                        'text-decoration': 'underline',
                                        'font-weight': '600',
                                      };
                                    }
                                    return null;
                                  },
                                  onTapUrl: (String url) {
                                    return launchUrlString(url);
                                  },
                                ),
                              ),
                              const SizedBox(height: 30),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : const Center(
                child: Padding(
                  padding: EdgeInsets.all(Dimensions.paddingSizeLarge),
                  child: CircularProgressIndicator(),
                ),
              );
      }),
    );
  }
}
