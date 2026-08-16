import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:Oxygen_Mart/features/store/controllers/store_controller.dart';
import 'package:Oxygen_Mart/features/home/widgets/store_card_widget.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/styles.dart';
import 'package:Oxygen_Mart/features/splash/controllers/splash_controller.dart';
import 'package:Oxygen_Mart/util/app_constants.dart';
import 'package:Oxygen_Mart/common/widgets/card_design/food_store_circular_card_widget.dart';

class ModuleStoreListView extends StatelessWidget {
  const ModuleStoreListView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StoreController>(builder: (storeController) {
      final stores = storeController.storeModel?.stores;
      final bool isFoodModule = Get.find<SplashController>().module?.moduleType.toString() == AppConstants.food;

      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: Dimensions.paddingSizeDefault),

        // Back button to return to modules
        if (Get.find<SplashController>().module != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
            child: InkWell(
              onTap: () {
                var splashCtrl = Get.find<SplashController>();
                if (splashCtrl.moduleList != null) {
                  try {
                    var groceryModule = splashCtrl.moduleList!.firstWhere((m) => m.moduleType == AppConstants.grocery);
                    splashCtrl.switchModule(groceryModule);
                  } catch (e) {
                    splashCtrl.removeModule();
                  }
                } else {
                  splashCtrl.removeModule();
                }
                Get.find<StoreController>().resetStoreData();
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.grey[Get.isDarkMode ? 800 : 200]!, spreadRadius: 1, blurRadius: 5)
                  ],
                ),
                child: Icon(Icons.arrow_back_ios_new, size: 20, color: Theme.of(context).primaryColor),
              ),
            ),
          ),

        if (Get.find<SplashController>().module != null)
          const SizedBox(height: Dimensions.paddingSizeDefault),

        stores == null
            ? (isFoodModule ? const _FoodStoreGridSkeleton() : const _StoreListSkeleton())
            : stores.isNotEmpty
                ? (isFoodModule
                    ? GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: Dimensions.paddingSizeSmall,
                          crossAxisSpacing: Dimensions.paddingSizeSmall,
                          childAspectRatio: 0.7,
                        ),
                        itemCount: stores.length,
                        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                        itemBuilder: (context, index) {
                          return FoodStoreCircularCardWidget(store: stores[index]);
                        },
                      )
                    : ListView.builder(
                        itemCount: stores.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                        itemBuilder: (context, index) {
                          return StoreCardWidget(store: stores[index]);
                        },
                      ))
                : Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 50),
                      child: Text('no_store_available'.tr, style: robotoMedium),
                    ),
                  ),
        const SizedBox(height: 100),
      ]);
    });
  }
}

class _StoreListSkeleton extends StatelessWidget {
  const _StoreListSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      child: Column(
        children: List.generate(
          3,
          (_) => Padding(
            padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
            child: _StoreCardSkeleton(),
          ),
        ),
      ),
    );
  }
}

class _StoreCardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final baseColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[700]!
        : Colors.grey[300]!;
    final highlightColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[600]!
        : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      period: const Duration(milliseconds: 1200),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cover image placeholder
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(Dimensions.radiusDefault)),
                  child: Container(
                    height: 180,
                    width: double.infinity,
                    color: baseColor,
                  ),
                ),
                // Space to compensate overlapping logo
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                      Dimensions.paddingSizeDefault,
                      0,
                      Dimensions.paddingSizeDefault,
                      Dimensions.paddingSizeDefault),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 16,
                        width: 160,
                        decoration: BoxDecoration(
                          color: baseColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 12,
                        width: 220,
                        decoration: BoxDecoration(
                          color: baseColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Circular logo placeholder
            Positioned(
              bottom: 52,
              right: 15,
              child: Container(
                height: 66,
                width: 66,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: baseColor,
                  border: Border.all(
                      color: Theme.of(context).cardColor, width: 3),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FoodStoreGridSkeleton extends StatelessWidget {
  const _FoodStoreGridSkeleton();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: Dimensions.paddingSizeSmall,
        crossAxisSpacing: Dimensions.paddingSizeSmall,
        childAspectRatio: 0.7,
      ),
      itemCount: 6,
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      itemBuilder: (context, index) {
        return const _FoodStoreCircularCardSkeleton();
      },
    );
  }
}

class _FoodStoreCircularCardSkeleton extends StatelessWidget {
  const _FoodStoreCircularCardSkeleton();

  @override
  Widget build(BuildContext context) {
    final baseColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[700]!
        : Colors.grey[300]!;
    final highlightColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[600]!
        : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      period: const Duration(milliseconds: 1200),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 115,
            height: 115,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: baseColor,
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
          Container(
            height: 12,
            width: 60,
            color: baseColor,
          ),
        ],
      ),
    );
  }
}
