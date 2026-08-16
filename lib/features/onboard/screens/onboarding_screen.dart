import 'package:Oxygen_Mart/common/widgets/custom_button.dart';
import 'package:Oxygen_Mart/common/widgets/web_menu_bar.dart';
import 'package:Oxygen_Mart/features/auth/controllers/auth_controller.dart';
import 'package:Oxygen_Mart/features/location/controllers/location_controller.dart';
import 'package:Oxygen_Mart/features/onboard/controllers/onboard_controller.dart';
import 'package:Oxygen_Mart/features/splash/controllers/splash_controller.dart';
import 'package:Oxygen_Mart/helper/address_helper.dart';
import 'package:Oxygen_Mart/helper/responsive_helper.dart';
import 'package:Oxygen_Mart/helper/route_helper.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/custom_image_view.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    Get.find<OnBoardingController>().getOnBoardingList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ResponsiveHelper.isDesktop(context) ? const WebMenuBar() : null,
      body: GetBuilder<OnBoardingController>(builder: (onBoardingController) {
        bool showIndicatorAndButton = onBoardingController.selectedIndex <
            onBoardingController.onBoardingList.length - 1;
        return onBoardingController.onBoardingList.isNotEmpty
            ? Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                      child: LayoutBuilder(
                    builder: (context, constraints) => PageView.builder(
                      itemCount: onBoardingController.onBoardingList.length,
                      controller: _pageController,
                      // physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        return showIndicatorAndButton &&
                                onBoardingController
                                        .onBoardingList[index].imageUrl !=
                                    ''
                            ? CustomImageView(
                                context: context,
                                fit: BoxFit.cover,
                                imagePath: onBoardingController
                                    .onBoardingList[index].imageUrl,
                              )
                            : const SizedBox();
                      },
                      onPageChanged: (index) {
                        if (index > onBoardingController.selectedIndex) {
                          // Scrolling forward, add to the list
                          onBoardingController.addShowOnBoardings(index);
                        } else if (index < onBoardingController.selectedIndex) {
                          // Scrolling backward, remove from the list
                          onBoardingController.removeShowOnBoardings(index);
                        }
                        onBoardingController.updateColor(index, context);
                        onBoardingController.changeSelectIndex(index);
                        if (onBoardingController.selectedIndex == 2) {
                          _configureToRouteInitialPage();
                        }
                      },
                    ),
                  )),
                  PositionedDirectional(
                    top: context.height * 0.1,
                    start: 0,
                    end: 0,
                    child: showIndicatorAndButton
                        ? GetBuilder<OnBoardingController>(
                            builder: (onBoardingController) {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: _pageIndicators(
                                    onBoardingController, context),
                              );
                            },
                          )
                        : const SizedBox(),
                  ),
                  PositionedDirectional(
                      bottom: context.height * 0.075,
                      start: 0,
                      end: 0,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: context.width * 0.04),
                        child: Column(
                          children: [
                            CustomButton(
                              buttonText:
                                  onBoardingController.selectedIndex != 2
                                      ? 'next'.tr
                                      : 'get_started'.tr,
                              onPressed: () {
                                if (onBoardingController.selectedIndex != 2) {
                                  _pageController.animateToPage(
                                    onBoardingController.selectedIndex +
                                        1, // Go to the next page
                                    duration: const Duration(
                                        milliseconds:
                                            600), // Animation duration
                                    curve:
                                        Curves.ease, // Smooth animation curve
                                  );
                                } else {
                                  _configureToRouteInitialPage();
                                }
                              },
                            ),
                            SizedBox(height: context.height * 0.01),
                            CustomButton(
                              color: context.theme.cardColor,
                              textColor: context.theme.primaryColor,
                              // transparent: true,
                              onPressed: () {
                                _configureToRouteInitialPage();
                              },
                              buttonText: 'skip'.tr,
                            ),
                          ],
                        ),
                      )),
                  PositionedDirectional(
                      bottom: context.height * 0.25,
                      start: 0,
                      end: 0,
                      child: Column(
                        children: [
                          Text(
                            onBoardingController
                                .onBoardingList[
                                    onBoardingController.selectedIndex]
                                .title,
                            style: robotoMedium.copyWith(
                                fontSize: context.height * 0.022,
                                color: Theme.of(context).cardColor,
                                fontWeight: FontWeight.w600),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: context.height * 0.01),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: Dimensions.paddingSizeLarge),
                            child: Text(
                              onBoardingController
                                  .onBoardingList[
                                      onBoardingController.selectedIndex]
                                  .description,
                              style: robotoRegular.copyWith(
                                  fontSize: context.height * 0.015,
                                  color: Theme.of(context).cardColor,
                                  fontWeight: FontWeight.w500),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ))
                ],
              )
            : const SizedBox.shrink();
      }),
    );
  }

// indicators
  List<Widget> _pageIndicators(
      OnBoardingController onBoardingController, BuildContext context) {
    List<Container> indicators = [];
    onBoardingController.colorList[0] = context.theme.primaryColor;
    for (int i = 0; i < onBoardingController.onBoardingList.length - 1; i++) {
      indicators.add(
        Container(
          width: 84,
          height: 5,
          margin: const EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            color: onBoardingController.colorList[i],
            borderRadius: BorderRadius.circular(25),
          ),
        ),
      );
    }
    return indicators;
  }

  void _configureToRouteInitialPage() async {
    Get.find<SplashController>().disableIntro();
    await Get.find<AuthController>().guestLogin();
    if (AddressHelper.getUserAddressFromSharedPref() != null) {
      Get.offNamed(RouteHelper.getInitialRoute(fromSplash: true));
    } else {
      Get.find<LocationController>()
          .navigateToLocationScreen(RouteHelper.onBoarding, offNamed: true);
      //     .then((v) {
      //   _pageController.jumpToPage(
      //       Get.find<OnBoardingController>().onBoardingList.length - 3);
      // });
    }
  }
}
