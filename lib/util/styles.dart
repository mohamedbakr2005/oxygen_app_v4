import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Oxygen_Mart/util/app_constants.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';

final robotoRegular = TextStyle(
  fontFamily: AppConstants.fontFamily,
  fontWeight: FontWeight.w600,
  fontSize: Dimensions.fontSizeDefault,
);

final robotoMedium = TextStyle(
  fontFamily: AppConstants.fontFamily,
  fontWeight: FontWeight.w800,
  fontSize: Dimensions.fontSizeDefault,
);

final robotoBold = TextStyle(
  fontFamily: AppConstants.fontFamily,
  fontWeight: FontWeight.w900,
  fontSize: Dimensions.fontSizeDefault,
);

final robotoBlack = TextStyle(
  fontFamily: AppConstants.fontFamily,
  fontWeight: FontWeight.w900,
  fontSize: Dimensions.fontSizeDefault,
);

final BoxDecoration riderContainerDecoration = BoxDecoration(
  borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusSmall)),
  color: Theme.of(Get.context!).primaryColor.withOpacity(0.1),
  shape: BoxShape.rectangle,
);
