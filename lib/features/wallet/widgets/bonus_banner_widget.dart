import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Oxygen_Mart/features/splash/controllers/splash_controller.dart';
import 'package:Oxygen_Mart/features/wallet/controllers/wallet_controller.dart';
import 'package:Oxygen_Mart/helper/date_converter.dart';
import 'package:Oxygen_Mart/helper/price_converter.dart';
import 'package:Oxygen_Mart/helper/responsive_helper.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/images.dart';
import 'package:Oxygen_Mart/util/styles.dart';

class BonusBannerWidget extends StatelessWidget {
  const BonusBannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<WalletController>(builder: (walletController) {
      return walletController.fundBonusList != null &&
              walletController.fundBonusList!.isNotEmpty &&
              Get.find<SplashController>().configModel!.addFundStatus!
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: Dimensions.paddingSizeDefault),
                SizedBox(
                  height: ResponsiveHelper.isDesktop(context) ? 120 : 115,
                  child: CarouselSlider.builder(
                    options: CarouselOptions(
                      autoPlay: true,
                      enlargeCenterPage: true,
                      disableCenter: true,
                      viewportFraction: 0.9,
                      autoPlayInterval: const Duration(seconds: 7),
                      onPageChanged: (index, reason) {
                        walletController.setCurrentIndex(index, true);
                      },
                    ),
                    itemCount: walletController.fundBonusList!.length,
                    itemBuilder: (context, index, _) {
                      final item = walletController.fundBonusList![index];
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFF2FBF6),
                              Color(0xFFE4F8ED),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border.all(
                            color: const Color(0xFF1EA35D).withOpacity(0.35),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1EA35D).withOpacity(0.08),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF0F7A42),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          '${item.bonusAmount} ${item.bonusType == 'amount' ? Get.find<SplashController>().configModel!.currencySymbol : '%'} ${'bonus'.tr}',
                                          style: robotoBold.copyWith(
                                            fontSize: 10,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          item.title!,
                                          maxLines: 1,
                                          style: robotoBold.copyWith(
                                            fontSize:
                                                Dimensions.fontSizeDefault,
                                            color: const Color(0xFF0F7A42),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${'add_fund_to_wallet_minimum'.tr} ${PriceConverter.convertPrice(item.minimumAddAmount)}',
                                    style: robotoRegular.copyWith(
                                      fontSize:
                                          Dimensions.fontSizeExtraSmall + 1,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.color,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.access_time_rounded,
                                        size: 12,
                                        color: Theme.of(context).hintColor,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${'valid_till'.tr} ${DateConverter.stringToReadableString(item.endDate!)}',
                                        style: robotoMedium.copyWith(
                                          fontSize: 11,
                                          color: Theme.of(context).hintColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Image.asset(
                              Images.walletBonus,
                              height: 55,
                              width: 55,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: walletController.fundBonusList!.map((bnr) {
                    int index = walletController.fundBonusList!.indexOf(bnr);
                    return TabPageSelectorIndicator(
                      backgroundColor: index == walletController.currentIndex
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).primaryColor.withOpacity(0.3),
                      borderColor: Colors.transparent,
                      size: index == walletController.currentIndex ? 8 : 6,
                    );
                  }).toList(),
                ),
              ],
            )
          : const SizedBox();
    });
  }
}

