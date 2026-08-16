import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:Oxygen_Mart/common/widgets/address_widget.dart';
import 'package:Oxygen_Mart/common/widgets/custom_image.dart';
import 'package:Oxygen_Mart/common/widgets/custom_loader.dart';
import 'package:Oxygen_Mart/common/widgets/title_widget.dart';
import 'package:Oxygen_Mart/features/address/controllers/address_controller.dart';
import 'package:Oxygen_Mart/features/address/domain/models/address_model.dart';
import 'package:Oxygen_Mart/features/banner/controllers/banner_controller.dart';
import 'package:Oxygen_Mart/features/home/widgets/banner_view.dart';
import 'package:Oxygen_Mart/features/home/widgets/popular_store_view.dart';
import 'package:Oxygen_Mart/features/location/controllers/location_controller.dart';
import 'package:Oxygen_Mart/features/splash/controllers/splash_controller.dart';
import 'package:Oxygen_Mart/helper/address_helper.dart';
import 'package:Oxygen_Mart/helper/auth_helper.dart';
import 'package:Oxygen_Mart/helper/responsive_helper.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/styles.dart';

const List<List<Color>> _kModuleGradients = [
  [Color(0xFFE8F5EE), Color(0xFFD0EBD9)],
  [Color(0xFFEEF3FF), Color(0xFFDCE6FF)],
  [Color(0xFFFFF3E8), Color(0xFFFFE5CC)],
  [Color(0xFFF3EEFF), Color(0xFFE6D8FF)],
  [Color(0xFFE8F8FF), Color(0xFFCCECFF)],
  [Color(0xFFFFF0F0), Color(0xFFFFDDD8)],
];

class ModuleView extends StatelessWidget {
  final SplashController splashController;
  const ModuleView({super.key, required this.splashController});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      GetBuilder<BannerController>(builder: (bannerController) {
        return const BannerView(isFeatured: true);
      }),
      if (splashController.moduleList != null &&
          splashController.moduleList!.isNotEmpty)
        _ModulesBentoSection(splashController: splashController)
      else if (splashController.moduleList == null)
        ModuleShimmer(isEnabled: true)
      else
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
            child: Text('no_module_found'.tr),
          ),
        ),
      GetBuilder<AddressController>(builder: (locationController) {
        List<AddressModel?> addressList = [];
        if (AuthHelper.isLoggedIn() && locationController.addressList != null) {
          addressList = [];
          bool contain = false;
          if (AddressHelper.getUserAddressFromSharedPref()!.id != null) {
            for (int index = 0; index < locationController.addressList!.length; index++) {
              if (locationController.addressList![index].id == AddressHelper.getUserAddressFromSharedPref()!.id) {
                contain = true;
                break;
              }
            }
          }
          if (!contain) { addressList.add(AddressHelper.getUserAddressFromSharedPref()); }
          addressList.addAll(locationController.addressList!);
        }
        return (!AuthHelper.isLoggedIn() || locationController.addressList != null)
            ? addressList.isNotEmpty
                ? Column(children: [
                    const SizedBox(height: Dimensions.paddingSizeLarge),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                      child: TitleWidget(title: 'deliver_to'.tr),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                    SizedBox(
                      height: 80,
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: addressList.length,
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall, right: Dimensions.paddingSizeSmall, top: Dimensions.paddingSizeExtraSmall),
                        itemBuilder: (context, index) {
                          return Container(
                            width: 280,
                            margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall, bottom: Dimensions.paddingSizeSmall),
                            decoration: BoxDecoration(boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, spreadRadius: 1, offset: const Offset(0, 2))]),
                            child: AddressWidget(
                              address: addressList[index],
                              fromAddress: false,
                              onTap: () {
                                if (AddressHelper.getUserAddressFromSharedPref()!.id != addressList[index]!.id) {
                                  Get.dialog(const CustomLoaderWidget(), barrierDismissible: false);
                                  Get.find<LocationController>().saveAddressAndNavigate(addressList[index], false, null, false, ResponsiveHelper.isDesktop(context));
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ])
                : const SizedBox()
            : AddressShimmer(isEnabled: AuthHelper.isLoggedIn() && locationController.addressList == null);
      }),
      const PopularStoreView(isPopular: false, isFeatured: true),
      const SizedBox(height: 120),
    ]);
  }
}

class _ModulesBentoSection extends StatelessWidget {
  final SplashController splashController;
  const _ModulesBentoSection({required this.splashController});

  @override
  Widget build(BuildContext context) {
    final modules = splashController.moduleList!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: Dimensions.paddingSizeLarge),
          Row(children: [
            Expanded(
              child: Text(
                'explore_categories'.tr,
                style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge, color: Theme.of(context).textTheme.bodyLarge!.color),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(0.08), borderRadius: BorderRadius.circular(20)),
              child: Text('${modules.length} ${'categories'.tr}', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor)),
            ),
          ]),
          const SizedBox(height: 14),
          if (modules.isNotEmpty) _HeroModuleCard(module: modules[0], onTap: () => splashController.switchModule(modules[0])),
          if (modules.length > 1) ...[
            const SizedBox(height: 12),
            GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: ResponsiveHelper.isDesktop(context) ? 4 : 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.0,
              ),
              padding: EdgeInsets.zero,
              itemCount: modules.length - 1,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, idx) {
                final module = modules[idx + 1];
                final gradientColors = _kModuleGradients[idx % _kModuleGradients.length];
                return _GridModuleCard(
                  moduleName: module.moduleName ?? '',
                  iconUrl: module.iconFullUrl ?? '',
                  gradientColors: gradientColors,
                  onTap: () => splashController.switchModule(module),
                );
              },
            ),
          ],
          const SizedBox(height: Dimensions.paddingSizeLarge),
        ],
      ),
    );
  }
}

class _HeroModuleCard extends StatefulWidget {
  final dynamic module;
  final VoidCallback onTap;
  const _HeroModuleCard({required this.module, required this.onTap});
  @override
  State<_HeroModuleCard> createState() => _HeroModuleCardState();
}

class _HeroModuleCardState extends State<_HeroModuleCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final String? thumbUrl = widget.module.thumbnailFullUrl;
    final String? iconUrl = widget.module.iconFullUrl;
    final String name = widget.module.moduleName ?? '';

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          height: 175,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: Theme.of(context).primaryColor.withOpacity(0.12),
            boxShadow: [
              BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.18), blurRadius: 24, spreadRadius: 0, offset: const Offset(0, 8)),
              BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, spreadRadius: 0, offset: const Offset(0, 2)),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(fit: StackFit.expand, children: [
              if (thumbUrl != null && thumbUrl.isNotEmpty)
                CustomImage(image: thumbUrl, fit: BoxFit.cover)
              else if (iconUrl != null && iconUrl.isNotEmpty)
                Positioned(
                  right: -20, bottom: -20,
                  child: Opacity(opacity: 0.18, child: CustomImage(image: iconUrl, height: 160, width: 160, fit: BoxFit.contain)),
                ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.55)],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (iconUrl != null && iconUrl.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                        ),
                        child: CustomImage(image: iconUrl, height: 28, width: 28, fit: BoxFit.contain),
                      ),
                    Text(
                      name,
                      style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeExtraLarge,
                        color: Colors.white,
                        shadows: [Shadow(color: Colors.black.withOpacity(0.3), blurRadius: 8)],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(20)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Text('shop_now'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor)),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_forward_ios_rounded, size: 11, color: Theme.of(context).primaryColor),
                      ]),
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

class _GridModuleCard extends StatefulWidget {
  final String moduleName;
  final String iconUrl;
  final List<Color> gradientColors;
  final VoidCallback onTap;
  const _GridModuleCard({required this.moduleName, required this.iconUrl, required this.gradientColors, required this.onTap});
  @override
  State<_GridModuleCard> createState() => _GridModuleCardState();
}

class _GridModuleCardState extends State<_GridModuleCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: widget.gradientColors),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(color: widget.gradientColors.last.withOpacity(0.5), blurRadius: 16, spreadRadius: 0, offset: const Offset(0, 6)),
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, spreadRadius: 0, offset: const Offset(0, 2)),
            ],
          ),
          child: Stack(clipBehavior: Clip.hardEdge, children: [
            Positioned(
              bottom: -18, right: -18,
              child: Opacity(
                opacity: 0.08,
                child: widget.iconUrl.isNotEmpty ? CustomImage(image: widget.iconUrl, height: 100, width: 100, fit: BoxFit.contain) : const SizedBox(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, spreadRadius: 0, offset: const Offset(0, 3))],
                    ),
                    child: widget.iconUrl.isNotEmpty
                        ? CustomImage(image: widget.iconUrl, height: 30, width: 30, fit: BoxFit.contain)
                        : Icon(Icons.storefront_rounded, size: 30, color: Theme.of(context).primaryColor),
                  ),
                  Row(children: [
                    Expanded(
                      child: Text(
                        widget.moduleName,
                        style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge!.color),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.6), shape: BoxShape.circle),
                      child: Icon(Icons.arrow_forward_ios_rounded, size: 10, color: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.5)),
                    ),
                  ]),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class ModuleShimmer extends StatelessWidget {
  final bool isEnabled;
  const ModuleShimmer({super.key, required this.isEnabled});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: Dimensions.paddingSizeLarge),
          Shimmer.fromColors(
            period: const Duration(milliseconds: 1800),
            baseColor: Colors.grey[200]!,
            highlightColor: Colors.white,
            enabled: isEnabled,
            child: Container(height: 20, width: 160, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
          ),
          const SizedBox(height: 14),
          Shimmer.fromColors(
            period: const Duration(milliseconds: 1800),
            baseColor: Colors.grey[200]!,
            highlightColor: Colors.white,
            enabled: isEnabled,
            child: Container(height: 175, width: double.infinity, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(24))),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.0),
            padding: EdgeInsets.zero,
            itemCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return Shimmer.fromColors(
                period: const Duration(milliseconds: 1800),
                baseColor: Colors.grey[200]!,
                highlightColor: Colors.white,
                enabled: isEnabled,
                child: Container(
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(22)),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(height: 54, width: 54, decoration: BoxDecoration(color: Colors.grey[300], shape: BoxShape.circle)),
                      Container(height: 14, width: 80, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(7))),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),
        ],
      ),
    );
  }
}

class AddressShimmer extends StatelessWidget {
  final bool isEnabled;
  const AddressShimmer({super.key, required this.isEnabled});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const SizedBox(height: Dimensions.paddingSizeLarge),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
        child: TitleWidget(title: 'deliver_to'.tr),
      ),
      const SizedBox(height: Dimensions.paddingSizeExtraSmall),
      SizedBox(
        height: 70,
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: 5,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
          itemBuilder: (context, index) {
            return Container(
              width: 300,
              padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
              child: Container(
                padding: EdgeInsets.all(ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeDefault : Dimensions.paddingSizeSmall),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.location_on, size: ResponsiveHelper.isDesktop(context) ? 50 : 40, color: Theme.of(context).primaryColor),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Expanded(
                    child: Shimmer.fromColors(
                      period: const Duration(milliseconds: 2000),
                      baseColor: Colors.grey,
                      highlightColor: Colors.white,
                      enabled: isEnabled,
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                        Container(height: 15, width: 100, color: Colors.grey[300]),
                        const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                        Container(height: 10, width: 150, color: Colors.grey[300]),
                      ]),
                    ),
                  ),
                ]),
              ),
            );
          },
        ),
      ),
    ]);
  }
}
