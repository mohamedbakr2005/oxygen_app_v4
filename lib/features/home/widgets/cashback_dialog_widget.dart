import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Oxygen_Mart/features/home/controllers/home_controller.dart';
import 'package:Oxygen_Mart/features/home/widgets/cashback_logo_widget.dart';
import 'package:Oxygen_Mart/features/language/controllers/language_controller.dart';
import 'package:Oxygen_Mart/helper/date_converter.dart';
import 'package:Oxygen_Mart/helper/price_converter.dart';
import 'package:Oxygen_Mart/helper/responsive_helper.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/styles.dart';

class CashBackDialogWidget extends StatelessWidget {
  const CashBackDialogWidget({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);

    return GetBuilder<HomeController>(builder: (homeController) {
      return homeController.cashBackOfferList != null
          ? Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeLarge, vertical: 50),
              alignment: Get.find<LocalizationController>().isLtr
                  ? Alignment.bottomRight
                  : Alignment.bottomLeft,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  isDesktop
                      ? Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: InkWell(
                            onTap: () => Get.back(),
                            child: Icon(CupertinoIcons.clear_circled_solid,
                                color: Theme.of(context).hintColor, size: 30),
                          ),
                        )
                      : const SizedBox(),
                  homeController.cashBackOfferList!.isNotEmpty
                      ? Container(
                          constraints: BoxConstraints(
                              maxHeight: context.height * 0.5, minHeight: 30),
                          width: isDesktop ? 400 : context.width * 0.8,
                          margin: EdgeInsets.only(right: isDesktop ? 20 : 0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                constraints: BoxConstraints(
                                    maxHeight: context.height * 0.5,
                                    minHeight: 30),
                                padding: const EdgeInsets.only(
                                    bottom: Dimensions.paddingSizeSmall),
                                child: ListView.builder(
                                    itemCount: homeController
                                        .cashBackOfferList!.length,
                                    shrinkWrap: true,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                            bottom: Dimensions.paddingSizeSmall),
                                        child: PhysicalShape(
                                          clipper: TicketClipper(
                                              notchRadius: 7.0,
                                              notchPositionPercentage: 0.38),
                                          color: Theme.of(context).cardColor,
                                          shadowColor: Colors.black.withOpacity(0.12),
                                          elevation: 3.0,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // 1. Header gradient container
                                              Container(
                                                width: double.infinity,
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: Dimensions.paddingSizeDefault,
                                                  vertical: Dimensions.paddingSizeSmall + 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Theme.of(context).primaryColor,
                                                      Theme.of(context)
                                                          .primaryColor
                                                          .withOpacity(0.85),
                                                    ],
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                  ),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      padding: const EdgeInsets.all(5),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white.withOpacity(0.2),
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: const Icon(
                                                        Icons.stars_rounded,
                                                        color: Colors.white,
                                                        size: 18,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                        width: Dimensions
                                                            .paddingSizeSmall),
                                                    Expanded(
                                                      child: Text(
                                                        homeController
                                                                .cashBackOfferList![
                                                                    index]
                                                                .title ??
                                                            '',
                                                        style: robotoBold.copyWith(
                                                          color: Colors.white,
                                                          fontSize: Dimensions
                                                                  .fontSizeLarge -
                                                              1,
                                                        ),
                                                      ),
                                                    ),
                                                    Icon(
                                                      Icons.auto_awesome,
                                                      color: Colors.white
                                                          .withOpacity(0.6),
                                                      size: 14,
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              // 2. Dashed divider
                                              CustomPaint(
                                                size: const Size(double.infinity, 1),
                                                painter: DashedLinePainter(
                                                  color: Theme.of(context)
                                                      .dividerColor
                                                      .withOpacity(0.6),
                                                  strokeWidth: 1.2,
                                                  dashWidth: 6,
                                                  dashSpace: 4,
                                                ),
                                              ),

                                              // 3. Body info details
                                              Padding(
                                                padding: const EdgeInsets.all(
                                                    Dimensions.paddingSizeDefault),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    // Minimum spend row
                                                    Row(
                                                      children: [
                                                        Container(
                                                          padding:
                                                              const EdgeInsets.all(4),
                                                          decoration: BoxDecoration(
                                                            color: Theme.of(context)
                                                                .primaryColor
                                                                .withOpacity(0.08),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(4),
                                                          ),
                                                          child: Icon(
                                                            Icons.shopping_bag_outlined,
                                                            size: 14,
                                                            color: Theme.of(context)
                                                                .primaryColor,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            width: Dimensions
                                                                .paddingSizeSmall),
                                                        Expanded(
                                                          child: Text(
                                                            '${'min_spent'.tr} ${PriceConverter.convertPrice(homeController.cashBackOfferList![index].minPurchase!)}',
                                                            style: robotoMedium.copyWith(
                                                              fontSize: Dimensions
                                                                  .fontSizeSmall,
                                                              color: Theme.of(context)
                                                                  .textTheme
                                                                  .bodyLarge
                                                                  ?.color
                                                                  ?.withOpacity(0.85),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                        height: Dimensions
                                                            .paddingSizeSmall),
                                                    // Validity row
                                                    Row(
                                                      children: [
                                                        Container(
                                                          padding:
                                                              const EdgeInsets.all(4),
                                                          decoration: BoxDecoration(
                                                            color: Colors.orange
                                                                .withOpacity(0.08),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(4),
                                                          ),
                                                          child: const Icon(
                                                            Icons.calendar_today_outlined,
                                                            size: 14,
                                                            color: Colors.orange,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            width: Dimensions
                                                                .paddingSizeSmall),
                                                        Expanded(
                                                          child: Text(
                                                            '${'valid_till'.tr} ${DateConverter.stringToReadableString(homeController.cashBackOfferList![index].endDate!)}',
                                                            style: robotoRegular.copyWith(
                                                              fontSize: Dimensions
                                                                  .fontSizeSmall,
                                                              color: Theme.of(context)
                                                                  .hintColor,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }),
                              ),
                            ],
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius:
                                BorderRadius.circular(Dimensions.radiusSmall),
                          ),
                          padding: const EdgeInsets.all(
                              Dimensions.paddingSizeExtraSmall),
                          child: Text('no_offer_available'.tr,
                              style: robotoRegular.copyWith(
                                  color: Theme.of(context).hintColor)),
                        ),
                  Container(
                    height: 95,
                    width: 80,
                    margin: EdgeInsets.only(
                        bottom: 20,
                        right: ResponsiveHelper.isDesktop(context) ? 50 : 0),
                    child: InkWell(
                        onTap: () => Get.back(),
                        child: const CashBackLogoWidget()),
                  ),
                ],
              ),
            )
          : const SizedBox();
    });
  }
}

class TicketClipper extends CustomClipper<Path> {
  final double notchRadius;
  final double notchPositionPercentage;

  TicketClipper({this.notchRadius = 8.0, this.notchPositionPercentage = 0.5});

  @override
  Path getClip(Size size) {
    Path path = Path();
    double w = size.width;
    double h = size.height;
    double r = notchRadius;
    double ny = h * notchPositionPercentage;

    path.moveTo(0, 0);
    // Top border
    path.lineTo(w, 0);
    // Right border down to notch
    path.lineTo(w, ny - r);
    // Right notch curving inward
    path.arcToPoint(
      Offset(w, ny + r),
      radius: Radius.circular(r),
      clockwise: false,
    );
    // Right border down to bottom
    path.lineTo(w, h);
    // Bottom border
    path.lineTo(0, h);
    // Left border up to notch
    path.lineTo(0, ny + r);
    // Left notch curving inward
    path.arcToPoint(
      Offset(0, ny - r),
      radius: Radius.circular(r),
      clockwise: false,
    );
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class DashedLinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;

  DashedLinePainter({
    this.color = Colors.grey,
    this.strokeWidth = 1.0,
    this.dashWidth = 5.0,
    this.dashSpace = 3.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double startX = 0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
