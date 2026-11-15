import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:Oxygen_Mart/common/widgets/custom_image.dart';
import 'package:Oxygen_Mart/features/banner/controllers/banner_controller.dart';
import 'package:Oxygen_Mart/features/dashboard/widgets/banner_slider.dart';
import 'package:Oxygen_Mart/features/parcel/controllers/parcel_controller.dart';
import 'package:Oxygen_Mart/features/parcel/domain/models/parcel_category_model.dart';
import 'package:Oxygen_Mart/features/parcel/widgets/need_help_to_getting_start_widget.dart';
import 'package:Oxygen_Mart/features/parcel/widgets/parcel_app_bar_widget.dart';
import 'package:Oxygen_Mart/features/parcel/widgets/parcel_category_card_widget.dart';
import 'package:Oxygen_Mart/features/profile/controllers/profile_controller.dart';
import 'package:Oxygen_Mart/features/pro/controllers/pro_controller.dart';
import 'package:Oxygen_Mart/features/pro/screens/subscription_plan_screen.dart';
import 'package:Oxygen_Mart/features/pro/widgets/pro_plan_banner_widget.dart';
import 'package:Oxygen_Mart/features/splash/controllers/splash_controller.dart';
import 'package:Oxygen_Mart/helper/auth_helper.dart';
import 'package:Oxygen_Mart/helper/image_cache_helper.dart';
import 'package:Oxygen_Mart/helper/responsive_helper.dart';
import 'package:Oxygen_Mart/helper/route_helper.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/styles.dart';

class ParcelCategoryScreen extends StatefulWidget {
  const ParcelCategoryScreen({super.key});

  @override
  State<ParcelCategoryScreen> createState() => _ParcelCategoryScreenState();
}

class _ParcelCategoryScreenState extends State<ParcelCategoryScreen> {
  @override
  void initState() {
    super.initState();
    if (AuthHelper.isLoggedIn() && Get.find<ProfileController>().userInfoModel == null) {
      Get.find<ProfileController>().getUserInfo();
    }
    if (Get.find<ProfileController>().proStatus) {
      Get.find<ProController>().getProActiveOffer(
        moduleType: Get.find<SplashController>().module?.moduleType,
      );
    }
    Get.find<ParcelController>().getParcelCategoryList();
    Get.find<BannerController>().getParcelOtherBannerList(true);
    Get.find<ParcelController>().getWhyChooseDetails();
    Get.find<ParcelController>().getVideoContentDetails();
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);

    return Scaffold(
      appBar: isDesktop ? null : const ParcelAppBarWidget(),
      body: GetBuilder<ParcelController>(builder: (parcelController) {
        return GetBuilder<BannerController>(builder: (bannerController) {
          return RefreshIndicator(
            onRefresh: () async {
              await Get.find<ParcelController>().getParcelCategoryList();
              await Get.find<BannerController>().getParcelOtherBannerList(true);
              await Get.find<ParcelController>().getWhyChooseDetails();
              await Get.find<ParcelController>().getVideoContentDetails();
            },
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 0 : Dimensions.paddingSizeDefault,
                vertical: Dimensions.paddingSizeSmall,
              ),
              child: Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: Dimensions.webMaxWidth,
                  child: Column(
                    crossAxisAlignment:
                        isDesktop ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                    children: [
                      // Top banner slider
                      if (bannerController.parcelOtherBannerModel != null &&
                          (bannerController.parcelOtherBannerModel!.banners?.isNotEmpty ?? false))
                        Padding(
                          padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
                          child: BannerSliderWidget(
                            bannerList: bannerController.parcelOtherBannerModel!.banners!,
                          ),
                        ),

                      // Section header: Title and subtitle
                      Text(
                        'what_would_you_like_to_send'.tr,
                        style: robotoBold.copyWith(
                          fontSize: Dimensions.fontSizeExtraLarge,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ready_to_send_something_special'.tr,
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Theme.of(context).disabledColor,
                        ),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeDefault),

                        // Categories grid
                        parcelController.parcelCategoryList != null
                            ? parcelController.parcelCategoryList!.isNotEmpty
                                ? _ParcelCategoryGridView(
                                    categories: parcelController.parcelCategoryList!,
                                    isDesktop: isDesktop,
                                  )
                                : Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(Dimensions.paddingSizeExtraLarge),
                                      child: Text(
                                        'no_parcel_category_found'.tr,
                                        style: robotoMedium.copyWith(color: Theme.of(context).disabledColor),
                                      ),
                                    ),
                                  )
                            : const _ParcelCategoryShimmerGrid(),

                        const SizedBox(height: Dimensions.paddingSizeLarge),

                        // Need help getting started banner (clean, modern guide trigger)
                        const NeedHelpToGettingStartWidget(),

                        // Pro plan banner
                        const SizedBox(height: Dimensions.paddingSizeDefault),
                        const _ParcelProPlanBanner(),

                        const SizedBox(height: Dimensions.paddingSizeLarge),

                        // "Why choose us" Section
                        if (parcelController.whyChooseDetails != null &&
                            (parcelController.whyChooseDetails!.banners?.isNotEmpty ?? false)) ...[
                          _WhyChooseUsSection(
                            parcelController: parcelController,
                            isDesktop: isDesktop,
                          ),
                          const SizedBox(height: Dimensions.paddingSizeLarge),
                        ] else if (parcelController.whyChooseDetails == null) ...[
                          const _WhyChooseUsShimmer(),
                          const SizedBox(height: Dimensions.paddingSizeLarge),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          });
        }),
      );
  }
}

class _ParcelCategoryGridView extends StatelessWidget {
  final List<ParcelCategoryModel> categories;
  final bool isDesktop;

  const _ParcelCategoryGridView({required this.categories, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: ScrollController(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 3 : 2,
        crossAxisSpacing: Dimensions.paddingSizeSmall,
        mainAxisSpacing: Dimensions.paddingSizeSmall,
        mainAxisExtent: isDesktop ? 105 : 95,
      ),
      itemCount: categories.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        return ParcelCategoryCardWidget(
          image: '${categories[index].imageFullUrl ?? ''}',
          itemName: categories[index].name ?? '',
          description: categories[index].description ?? '',
          colorIndex: index,
          onTap: () {
            Get.toNamed(RouteHelper.getParcelLocationRoute(categories[index]));
          },
        );
      },
    );
  }
}

class _ParcelCategoryShimmerGrid extends StatelessWidget {
  const _ParcelCategoryShimmerGrid();

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = ResponsiveHelper.isDesktop(context);

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 3 : 2,
        crossAxisSpacing: Dimensions.paddingSizeSmall,
        mainAxisSpacing: Dimensions.paddingSizeSmall,
        mainAxisExtent: isDesktop ? 105 : 95,
      ),
      itemCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        return Shimmer(
          duration: const Duration(seconds: 2),
          enabled: true,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
            ),
          ),
        );
      },
    );
  }
}

class _WhyChooseUsSection extends StatelessWidget {
  final ParcelController parcelController;
  final bool isDesktop;

  const _WhyChooseUsSection({required this.parcelController, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: isDark
            ? Theme.of(context).cardColor
            : Theme.of(context).primaryColor.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        border: Border.all(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            ),
            child: Icon(
              Icons.verified_outlined,
              size: 20,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          Text(
            'why_choose_us'.tr,
            style: robotoBold.copyWith(
              fontSize: Dimensions.fontSizeLarge,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ]),
        const SizedBox(height: Dimensions.paddingSizeDefault),

        if (isDesktop)
          GridView.builder(
            controller: ScrollController(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: Dimensions.paddingSizeDefault,
              mainAxisSpacing: Dimensions.paddingSizeDefault,
              mainAxisExtent: 140,
            ),
            itemCount: parcelController.whyChooseDetails!.banners!.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final banner = parcelController.whyChooseDetails!.banners![index];
              return _ExperienceCard(
                image: '${banner.imageFullUrl ?? ''}',
                title: banner.title ?? '',
                description: banner.shortDescription ?? '',
              );
            },
          )
        else
          SizedBox(
            height: 140,
            child: ListView.separated(
              itemCount: parcelController.whyChooseDetails!.banners!.length,
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              separatorBuilder: (_, __) => const SizedBox(width: Dimensions.paddingSizeSmall),
              itemBuilder: (context, index) {
                final banner = parcelController.whyChooseDetails!.banners![index];
                return SizedBox(
                  width: context.width * 0.55,
                  child: _ExperienceCard(
                    image: '${banner.imageFullUrl ?? ''}',
                    title: banner.title ?? '',
                    description: banner.shortDescription ?? '',
                  ),
                );
              },
            ),
          ),
      ]),
    );
  }
}

class _ExperienceCard extends StatelessWidget {
  final String image;
  final String title;
  final String description;

  const _ExperienceCard({required this.image, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        border: Border.all(
          color: Theme.of(context).disabledColor.withValues(alpha: 0.15),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            child: CustomImage(
              image: image,
              height: 38,
              width: 38,
              cacheWidth: ImageCacheHelper.pixels(context, 38),
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall + 1),
          ),
          const SizedBox(height: 2),
          Text(
            description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeExtraSmall,
              color: Theme.of(context).disabledColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _WhyChooseUsShimmer extends StatelessWidget {
  const _WhyChooseUsShimmer();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        separatorBuilder: (_, __) => const SizedBox(width: Dimensions.paddingSizeSmall),
        itemBuilder: (context, index) {
          return Shimmer(
            duration: const Duration(seconds: 2),
            enabled: true,
            child: Container(
              width: 150,
              decoration: BoxDecoration(
                color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ParcelProPlanBanner extends StatelessWidget {
  const _ParcelProPlanBanner();

  @override
  Widget build(BuildContext context) {
    if (!Get.find<SplashController>().proStaus) return const SizedBox();
    return ProPlanBannerWidget(
      onSubscribe: () {
        Get.find<ProController>().saveCurrentPath(route: RouteHelper.getMainRoute('home'));
        SubscriptionPlanScreen.open();
      },
    );
  }
}
