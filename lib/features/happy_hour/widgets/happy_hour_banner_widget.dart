import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Oxygen_Mart/common/widgets/custom_image.dart';
import 'package:Oxygen_Mart/features/happy_hour/controllers/happy_hour_controller.dart';
import 'package:Oxygen_Mart/features/happy_hour/screens/happy_hour_screen.dart';
import 'package:Oxygen_Mart/features/happy_hour/widgets/happy_hour_palette.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/images.dart';
import 'package:Oxygen_Mart/util/styles.dart';

class HappyHourBannerWidget extends StatefulWidget {
  final double bottomTuck;

  const HappyHourBannerWidget({super.key, this.bottomTuck = 0});

  @override
  State<HappyHourBannerWidget> createState() => _HappyHourBannerWidgetState();
}

class _HappyHourBannerWidgetState extends State<HappyHourBannerWidget> {
  final GlobalKey _bannerKey = GlobalKey();

  void _reportHeight(bool visible) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if(!mounted) {
        return;
      }
      final HappyHourController happyHourController = Get.find<HappyHourController>();
      if(!visible) {
        happyHourController.reportHeight(0);
        return;
      }
      final double? height = (_bannerKey.currentContext?.findRenderObject() as RenderBox?)?.size.height;
      if(height != null) {
        happyHourController.reportHeight(height);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HappyHourController>(builder: (happyHourController) {
      final bool visible = happyHourController.showHomeBanner;
      _reportHeight(visible);

      if(!visible) {
        return const SizedBox.shrink();
      }

      final String offLabel = 'percentage_off'.tr.replaceAll('{percentage}', happyHourController.discountLabel);
      final String? iconUrl = happyHourController.happyHour?.iconFullUrl;
      final Color primaryColor = Theme.of(context).primaryColor;

      return Container(
        key: _bannerKey,
        height: 64,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: HappyHourPalette.card(context),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: HappyHourPalette.border(context), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.12),
              blurRadius: 16,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(22),
          child: InkWell(
            onTap: () => HappyHourScreen.show(context),
            borderRadius: BorderRadius.circular(22),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: (iconUrl != null && iconUrl.isNotEmpty)
                        ? CustomImage(image: iconUrl, height: 40, width: 40, fit: BoxFit.cover)
                        : Image.asset(Images.happyHours, height: 40, width: 40, fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 10),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                '$offLabel ${'happy_hour'.tr}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: robotoBold.copyWith(
                                  color: primaryColor,
                                  fontSize: Dimensions.fontSizeDefault + 1,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text('⚡', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'grab_best_price_for_your_order'.tr,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: robotoRegular.copyWith(
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.65),
                            fontSize: Dimensions.fontSizeExtraSmall + 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  const HappyHourCountdownChip(),
                  const SizedBox(width: 6),

                  InkWell(
                    onTap: happyHourController.dismiss,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Theme.of(context).disabledColor.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: 14,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}

class HappyHourCountdownChip extends StatelessWidget {
  final Color? background;
  final Color? textColor;

  final double? fontSize;

  const HappyHourCountdownChip({super.key, this.background, this.textColor, this.fontSize});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HappyHourController>(id: HappyHourController.timerBuilderId, builder: (happyHourController) {
      return Container(
        height: 28,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFE53935), Color(0xFFFF5252)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE53935).withValues(alpha: 0.30),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.timer_outlined, size: 13, color: Colors.white),
            const SizedBox(width: 4),
            Text(
              happyHourController.formattedRemaining.split(':').join(' : '),
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.center,
              style: robotoBold.copyWith(
                color: Colors.white,
                fontSize: fontSize ?? Dimensions.fontSizeExtraSmall + 1,
              ),
            ),
          ],
        ),
      );
    });
  }
}
