import 'package:Oxygen_Mart/common/widgets/custom_image.dart';
import 'package:Oxygen_Mart/features/category/controllers/category_controller.dart';
import 'package:Oxygen_Mart/features/splash/controllers/splash_controller.dart';
import 'package:Oxygen_Mart/helper/route_helper.dart';
import 'package:Oxygen_Mart/util/app_constants.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/styles.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../helper/responsive_helper.dart';

class CategoryView extends StatelessWidget {
  const CategoryView({super.key});

  @override
  Widget build(BuildContext context) {
    ScrollController scrollController = ScrollController();
    final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
    return GetBuilder<SplashController>(builder: (splashController) {
      bool isPharmacy = splashController.module != null &&
          splashController.module!.moduleType.toString() ==
              AppConstants.pharmacy;
      bool isFood = splashController.module != null &&
          splashController.module!.moduleType.toString() == AppConstants.food;

      return GetBuilder<CategoryController>(builder: (categoryController) {
        return (categoryController.categoryList != null &&
                categoryController.categoryList!.isEmpty)
            ? const SizedBox()
            : isPharmacy
                ? PharmacyCategoryView(categoryController: categoryController)
                : isFood
                    ? FoodCategoryView(categoryController: categoryController)
                    : SingleChildScrollView(
                        child: SizedBox(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 60),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "${'explore'.tr} اوكسجين مارت",
                                    style: robotoMedium.copyWith(
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                categoryController.categoryList != null
                                    ? GridView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        controller: scrollController,
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: ResponsiveHelper
                                                  .isDesktop(context)
                                              ? 6
                                              : ResponsiveHelper.isTab(context)
                                                  ? 4
                                                  : 3,
                                          childAspectRatio:
                                              0.7, // نسبة الطول للعرض
                                          mainAxisSpacing:
                                              Dimensions.paddingSizeSmall,
                                          crossAxisSpacing:
                                              Dimensions.paddingSizeSmall,
                                        ),
                                        itemCount: categoryController
                                            .categoryList!.length,
                                        padding: const EdgeInsets.all(
                                            Dimensions.paddingSizeSmall),
                                        itemBuilder: (context, index) {
                                          return InkWell(
                                            onTap: () {
                                              // ... (نفس كود النافيجيشن والأنالتيكس) ...
                                              final category =
                                                  categoryController
                                                      .categoryList![index];
                                              analytics.logEvent(
                                                name: 'open_category',
                                                parameters: {
                                                  'category_id': category.id!,
                                                  'category_name':
                                                      category.name!,
                                                },
                                              );
                                              Get.toNamed(
                                                RouteHelper
                                                    .getCategoryItemRoute(
                                                  categoryController
                                                      .categoryList![index].id,
                                                  categoryController
                                                      .categoryList![index]
                                                      .name!,
                                                ),
                                              );
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color:
                                                    Theme.of(context).cardColor,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        Dimensions.radiusSmall),
                                                boxShadow: const [
                                                  BoxShadow(
                                                      color: Colors.black12,
                                                      blurRadius: 5,
                                                      spreadRadius: 1),
                                                ],
                                                
                                              ),
                                              // ---------------------------------------------
                                              // هنا الـ Stack والـ Positioned اللي طلبتهم
                                              // ---------------------------------------------
                                              child: Stack(
                                                children: [
                                                  // 1. الصورة (في الخلفية)
                                                  Positioned.fill(
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              Dimensions
                                                                  .radiusSmall),
                                                      child: CustomImage(
                                                        image:
                                                            '${categoryController.categoryList![index].imageFullUrl}',
                                                        fit: BoxFit
                                                            .cover, // أو contain حسب رغبتك في شكل الصورة
                                                        width: double.infinity,
                                                        height: double.infinity,
                                                      ),
                                                    ),
                                                  ),

                                                  // 2. النص (فوق الصورة باستخدام Positioned)
                                                  Positioned(
                                                    top: 10, // مسافة من فوق
                                                    left: 5,
                                                    right: 5,
                                                    child: Text(
                                                      categoryController
                                                          .categoryList![index]
                                                          .name!,
                                                      style:
                                                          robotoBold.copyWith(
                                                        fontSize: 14,
                                                        color: Colors
                                                            .black, // أو Colors.white لو الخلفية غامقة
                                                        fontWeight:
                                                            FontWeight.w900,
                                                      ),
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      )
                                    : CategoryShimmer(
                                        categoryController: categoryController),
                              ],
                            ),
                          ),
                        ),
                      );
      });
    });
  }
}

class PharmacyCategoryView extends StatelessWidget {
  final CategoryController categoryController;
  const PharmacyCategoryView({super.key, required this.categoryController});

  @override
  Widget build(BuildContext context) {
    final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
    final ScrollController scrollController = ScrollController();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(
        height: 160,
        child: categoryController.categoryList != null
            ? ListView.builder(
                controller: scrollController,
                physics: const BouncingScrollPhysics(),
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(
                    left: Dimensions.paddingSizeDefault,
                    top: Dimensions.paddingSizeDefault),
                itemCount: categoryController.categoryList!.length > 10
                    ? 10
                    : categoryController.categoryList!.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(
                        bottom: Dimensions.paddingSizeDefault,
                        right: Dimensions.paddingSizeSmall,
                        top: Dimensions.paddingSizeDefault),
                    child: InkWell(
                      onTap: () {
                        if (index == 9 &&
                            categoryController.categoryList!.length > 10) {
                          analytics.logEvent(
                            name: 'open_subcategory',
                            parameters: {
                              'action': 'see_all_categories',
                              'module': 'pharmacy',
                            },
                          );
                          Get.toNamed(RouteHelper.getCategoryRoute());
                        } else {
                          final category =
                              categoryController.categoryList![index];

                          analytics.logEvent(
                            name: 'open_category',
                            parameters: {
                              'category_id': category.id!,
                              'category_name': category.name!,
                              'module': 'pharmacy',
                            },
                          );

                          analytics.logEvent(
                            name: 'open_category_list',
                            parameters: {
                              'category_id': category.id!,
                              'category_name': category.name!,
                            },
                          );
                          Get.toNamed(RouteHelper.getCategoryItemRoute(
                            categoryController.categoryList![index].id,
                            categoryController.categoryList![index].name!,
                          ));
                        }
                      },
                      borderRadius:
                          BorderRadius.circular(Dimensions.radiusSmall),
                      child: Column(
                        children: [
                          Container(
                            width: 70,
                            height: 70,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(100)),
                                // gradient: LinearGradient(
                                //   begin: Alignment.topCenter,
                                //   end: Alignment.bottomCenter,
                                //   colors: [
                                //     Theme.of(context)
                                //         .primaryColor
                                //         .withOpacity(0.3),
                                //     Theme.of(context).cardColor.withOpacity(0.3),
                                //   ],
                                // ),
                                color: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.1)),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(100),
                                        ),
                                        child: CustomImage(
                                          image:
                                              '${categoryController.categoryList![index].imageFullUrl}',
                                          height: 50,
                                          width: 50,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      (index == 9 &&
                                              categoryController
                                                      .categoryList!.length >
                                                  10)
                                          ? Positioned(
                                              right: 0,
                                              left: 0,
                                              top: 0,
                                              bottom: 0,
                                              child: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        const BorderRadius.only(
                                                            topLeft:
                                                                Radius.circular(
                                                                    100),
                                                            topRight:
                                                                Radius.circular(
                                                                    100)),
                                                    gradient: LinearGradient(
                                                      begin:
                                                          Alignment.topCenter,
                                                      end: Alignment
                                                          .bottomCenter,
                                                      colors: [
                                                        Theme.of(context)
                                                            .primaryColor
                                                            .withOpacity(0.4),
                                                        Theme.of(context)
                                                            .primaryColor
                                                            .withOpacity(0.6),
                                                        Theme.of(context)
                                                            .primaryColor
                                                            .withOpacity(0.4),
                                                      ],
                                                    ),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      '+${categoryController.categoryList!.length - 10}',
                                                      style: robotoMedium.copyWith(
                                                          fontSize: Dimensions
                                                              .fontSizeExtraLarge,
                                                          color:
                                                              Theme.of(context)
                                                                  .cardColor),
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  )),
                                            )
                                          : const SizedBox(),
                                    ],
                                  ),
                                ]),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeSmall),
                          Expanded(
                              child: Text(
                            (index == 9 &&
                                    categoryController.categoryList!.length >
                                        10)
                                ? 'see_all'.tr
                                : categoryController.categoryList![index].name!,
                            style: robotoMedium.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: (index == 9 &&
                                        categoryController
                                                .categoryList!.length >
                                            10)
                                    ? Theme.of(context).primaryColor
                                    : Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .color),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          )),
                        ],
                      ),
                    ),
                  );
                },
              )
            : PharmacyCategoryShimmer(categoryController: categoryController),
      ),
    ]);
  }
}

class FoodCategoryView extends StatelessWidget {
  final CategoryController categoryController;
  const FoodCategoryView({super.key, required this.categoryController});

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();
    final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
    return Stack(children: [
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          height: 160,
          child: categoryController.categoryList != null
              ? ListView.builder(
                  controller: scrollController,
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(
                      left: Dimensions.paddingSizeDefault,
                      top: Dimensions.paddingSizeDefault),
                  itemCount: categoryController.categoryList!.length > 10
                      ? 10
                      : categoryController.categoryList!.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(
                          bottom: Dimensions.paddingSizeDefault,
                          right: Dimensions.paddingSizeDefault,
                          top: Dimensions.paddingSizeDefault),
                      child: InkWell(
                        onTap: () {
                          if (index == 9 &&
                              categoryController.categoryList!.length > 10) {
                            analytics.logEvent(
                              name: 'open_subcategory',
                              parameters: {
                                'action': 'see_all_categories',
                                'module': 'food',
                              },
                            );
                            Get.toNamed(RouteHelper.getCategoryRoute());
                          } else {
                            final category =
                                categoryController.categoryList![index];

                            analytics.logEvent(
                              name: 'open_category',
                              parameters: {
                                'category_id': category.id!,
                                'category_name': category.name!,
                                'module': 'food',
                              },
                            );

                            analytics.logEvent(
                              name: 'open_category_list',
                              parameters: {
                                'category_id': category.id!,
                                'category_name': category.name!,
                              },
                            );

                            Get.toNamed(RouteHelper.getCategoryItemRoute(
                              categoryController.categoryList![index].id,
                              categoryController.categoryList![index].name!,
                            ));
                          }
                        },
                        borderRadius:
                            BorderRadius.circular(Dimensions.radiusSmall),
                        child: SizedBox(
                          width: 60,
                          child: Column(children: [
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(100)),
                                  child: CustomImage(
                                    image:
                                        '${categoryController.categoryList![index].imageFullUrl}',
                                    height: 60,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                (index == 9 &&
                                        categoryController
                                                .categoryList!.length >
                                            10)
                                    ? Positioned(
                                        right: 0,
                                        left: 0,
                                        top: 0,
                                        bottom: 0,
                                        child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(100)),
                                              gradient: LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [
                                                  Theme.of(context)
                                                      .primaryColor
                                                      .withOpacity(0.4),
                                                  Theme.of(context)
                                                      .primaryColor
                                                      .withOpacity(0.6),
                                                  Theme.of(context)
                                                      .primaryColor
                                                      .withOpacity(0.4),
                                                ],
                                              ),
                                            ),
                                            child: Center(
                                              child: Text(
                                                '+${categoryController.categoryList!.length - 10}',
                                                style: robotoMedium.copyWith(
                                                    fontSize: Dimensions
                                                        .fontSizeExtraLarge,
                                                    color: Theme.of(context)
                                                        .cardColor),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.center,
                                              ),
                                            )),
                                      )
                                    : const SizedBox(),
                              ],
                            ),
                            const SizedBox(height: Dimensions.paddingSizeSmall),
                            Expanded(
                                child: Text(
                              (index == 9 &&
                                      categoryController.categoryList!.length >
                                          10)
                                  ? 'see_all'.tr
                                  : categoryController
                                          .categoryList![index].name ??
                                      '',
                              style: robotoMedium.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                  color: (index == 9 &&
                                          categoryController
                                                  .categoryList!.length >
                                              10)
                                      ? Theme.of(context).primaryColor
                                      : Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .color),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            )),
                          ]),
                        ),
                      ),
                    );
                  },
                )
              : FoodCategoryShimmer(categoryController: categoryController),
        ),
      ]),
    ]);
  }
}

class CategoryShimmer extends StatelessWidget {
  final CategoryController categoryController;
  const CategoryShimmer({super.key, required this.categoryController});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SizedBox(
        child: GridView.builder(
          shrinkWrap: true, // Makes GridView adapt to its content
          physics:
              const NeverScrollableScrollPhysics(), // Prevents GridView scrolling

          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: ResponsiveHelper.isDesktop(context)
                ? 6
                : ResponsiveHelper.isTab(context)
                    ? 4
                    : 3,
            childAspectRatio: (1 / 1.2),
            mainAxisSpacing: Dimensions.paddingSizeSmall,
            crossAxisSpacing: Dimensions.paddingSizeSmall,
          ),
          itemCount: 20,
          /* > 10
                                                    ? 10
                                                    : categoryController.categoryList!.length, */
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),

          scrollDirection: Axis.vertical,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 1, vertical: Dimensions.paddingSizeDefault),
              child: Shimmer.fromColors(
                period: const Duration(milliseconds: 2000),
                baseColor: Colors.grey,
                highlightColor: Colors.white,
                enabled: true,
                child: SizedBox(
                  width: 80,
                  child: Column(children: [
                    Container(
                        height: 75,
                        width: 75,
                        margin: EdgeInsets.only(
                          left:
                              index == 0 ? 0 : Dimensions.paddingSizeExtraSmall,
                          right: Dimensions.paddingSizeExtraSmall,
                        ),
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(Dimensions.radiusSmall),
                          color: Colors.grey[300],
                        )),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                    Padding(
                      padding: EdgeInsets.only(
                          right: index == 0
                              ? Dimensions.paddingSizeExtraSmall
                              : 0),
                      child: Container(
                        height: 10,
                        width: 50,
                        color: Colors.grey[300],
                      ),
                    ),
                  ]),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class FoodCategoryShimmer extends StatelessWidget {
  final CategoryController categoryController;
  const FoodCategoryShimmer({super.key, required this.categoryController});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      padding:
          const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
      itemCount: 8,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(
              bottom: Dimensions.paddingSizeDefault,
              left: Dimensions.paddingSizeDefault,
              top: Dimensions.paddingSizeDefault),
          child: SizedBox(
            width: 60,
            child: Column(children: [
              ClipOval(
                child: Shimmer.fromColors(
                  period: const Duration(milliseconds: 2000),
                  baseColor: Colors.grey,
                  highlightColor: Colors.white,
                  child: Container(
                      height: 60,
                      width: double.infinity,
                      margin: const EdgeInsets.only(
                          bottom: Dimensions.paddingSizeSmall),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).shadowColor,
                      )),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              Expanded(
                child: Shimmer.fromColors(
                  period: const Duration(milliseconds: 2000),
                  baseColor: Colors.grey,
                  highlightColor: Colors.white,
                  child: Container(
                    height: 10,
                    width: 50,
                    color: Theme.of(context).shadowColor,
                  ),
                ),
              ),
            ]),
          ),
        );
      },
    );
  }
}

class PharmacyCategoryShimmer extends StatelessWidget {
  final CategoryController categoryController;
  const PharmacyCategoryShimmer({super.key, required this.categoryController});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      padding:
          const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
      itemCount: 8,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(
              bottom: Dimensions.paddingSizeDefault,
              left: Dimensions.paddingSizeDefault,
              top: Dimensions.paddingSizeDefault),
          child: Shimmer.fromColors(
            period: const Duration(milliseconds: 2000),
            baseColor: Colors.grey,
            highlightColor: Colors.white,
            enabled: true,
            child: Container(
              width: 70,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(100),
                    topRight: Radius.circular(100)),
              ),
              child: Column(children: [
                Container(
                    height: 60,
                    width: double.infinity,
                    margin: const EdgeInsets.only(
                        bottom: Dimensions.paddingSizeSmall),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(100),
                          topRight: Radius.circular(100)),
                      color: Colors.grey[300],
                    )),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                Expanded(
                  child: Container(
                    height: 10,
                    width: 50,
                    color: Colors.grey[300],
                  ),
                ),
              ]),
            ),
          ),
        );
      },
    );
  }
}
