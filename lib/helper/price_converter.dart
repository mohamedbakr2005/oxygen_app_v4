import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Oxygen_Mart/features/splash/controllers/splash_controller.dart';
import 'package:Oxygen_Mart/util/styles.dart';

class PriceConverter {
  static String getCustomCurrencySymbol() {
    String lang = Get.locale?.languageCode ?? "en";

    if (lang == "ar") {
      return "ج.م";
    } else {
      return "EGP";
    }
  }

  static String convertPrice(double? price,
      {double? discount,
      String? discountType,
      bool forDM = false,
      bool isFoodVariation = false}) {
    if (discount != null && discountType != null) {
      if (discountType == 'amount' && !isFoodVariation) {
        price = price! - discount;
      } else if (discountType == 'percent') {
        price = price! - ((discount / 100) * price);
      }
    }

    String symbol = getCustomCurrencySymbol();
    bool isArabic = Get.locale?.languageCode == "ar";

    String formatted = toFixed(price!)
        .toStringAsFixed(forDM
            ? 0
            : Get.find<SplashController>().configModel!.digitAfterDecimalPoint!)
        .replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');

    return isArabic ? "$formatted $symbol" : "$symbol $formatted";
  }

  static Widget convertAnimationPrice(double? price,
      {double? discount,
      String? discountType,
      bool forDM = false,
      TextStyle? textStyle}) {
    if (discount != null && discountType != null) {
      if (discountType == 'amount') {
        price = price! - discount;
      } else if (discountType == 'percent') {
        price = price! - ((discount / 100) * price);
      }
    }

    String symbol = getCustomCurrencySymbol();
    bool isArabic = Get.locale?.languageCode == "ar";

    return Directionality(
      textDirection: TextDirection.ltr,
      child: AnimatedFlipCounter(
        duration: Duration(milliseconds: 500),
        value: toFixed(price!),
        textStyle: textStyle ?? robotoMedium,
        fractionDigits: forDM
            ? 0
            : Get.find<SplashController>().configModel!.digitAfterDecimalPoint!,
        prefix: isArabic ? '' : '$symbol ',
        suffix: isArabic ? ' $symbol' : '',
      ),
    );
  }

  static double? convertWithDiscount(
      double? price, double? discount, String? discountType,
      {bool isFoodVariation = false}) {
    if (discountType == 'amount' && !isFoodVariation) {
      price = price! - discount!;
    } else if (discountType == 'percent') {
      price = price! - ((discount! / 100) * price);
    }
    return price;
  }

  static double calculation(
      double amount, double? discount, String type, int quantity) {
    double calculatedAmount = 0;
    if (type == 'amount') {
      calculatedAmount = discount! * quantity;
    } else if (type == 'percent') {
      calculatedAmount = (discount! / 100) * (amount * quantity);
    }
    return calculatedAmount;
  }

  static String percentageCalculation(
      String price, String discount, String discountType) {
    return '$discount${discountType == 'percent' ? '%' : PriceConverter.getCustomCurrencySymbol()} OFF';
  }

  static double toFixed(double val) {
    num mod = power(
        10, Get.find<SplashController>().configModel!.digitAfterDecimalPoint!);
    return (((val * mod).toPrecision(Get.find<SplashController>()
                .configModel!
                .digitAfterDecimalPoint!))
            .floor()
            .toDouble() /
        mod);
  }

  static int power(int x, int n) {
    int retval = 1;
    for (int i = 0; i < n; i++) {
      retval *= x;
    }
    return retval;
  }
}
