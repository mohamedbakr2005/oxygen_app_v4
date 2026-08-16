import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Oxygen_Mart/common/widgets/custom_image.dart';
import 'package:Oxygen_Mart/common/widgets/custom_snackbar.dart';
import 'package:Oxygen_Mart/features/favourite/controllers/favourite_controller.dart';
import 'package:Oxygen_Mart/features/language/controllers/language_controller.dart';
import 'package:Oxygen_Mart/features/store/domain/models/store_model.dart';
import 'package:Oxygen_Mart/helper/auth_helper.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';

class StoreHeroWidget extends StatelessWidget {
  final Store? store;
  const StoreHeroWidget({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    if (store == null) return const SizedBox();
    return Container(
      height: 245, // 220 + 25 (margin for overlapping logo)
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Cover Image
          Container(
            height: 220,
            width: double.infinity,
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            child: CustomImage(
              fit: BoxFit.cover,
              image: store!.coverPhotoFullUrl ?? '',
            ),
          ),
          
          // Back Button
          Positioned(
            top: 40,
            left: Get.find<LocalizationController>().isLtr ? 15 : null,
            right: Get.find<LocalizationController>().isLtr ? null : 15,
            child: InkWell(
              onTap: () => Get.back(),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.only(
                      left: Get.find<LocalizationController>().isLtr ? 5 : 0, 
                      right: Get.find<LocalizationController>().isLtr ? 0 : 5),
                  child: Icon(Icons.arrow_back_ios, color: Theme.of(context).primaryColor, size: 20),
                ),
              ),
            ),
          ),

          // Favorite Button (acting as top right action)
          Positioned(
            top: 40,
            right: Get.find<LocalizationController>().isLtr ? 15 : null,
            left: Get.find<LocalizationController>().isLtr ? null : 15,
            child: GetBuilder<FavouriteController>(builder: (favouriteController) {
              bool isWished =
                  favouriteController.wishStoreIdList.contains(store!.id);
              return InkWell(
                onTap: () {
                  if (AuthHelper.isLoggedIn()) {
                    isWished
                        ? favouriteController.removeFromFavouriteList(store!.id, true)
                        : favouriteController.addToFavouriteList(null, store?.id, true);
                  } else {
                    showCustomSnackBar('you_are_not_logged_in'.tr);
                  }
                },
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))
                    ],
                  ),
                  child: Icon(
                    isWished ? Icons.favorite : Icons.favorite_border,
                    color: isWished ? Theme.of(context).primaryColor : Theme.of(context).primaryColor,
                    size: 20,
                  ),
                ),
              );
            }),
          ),
          
          // Store Logo
          Positioned(
            bottom: 0,
            left: Get.find<LocalizationController>().isLtr ? 20 : null,
            right: Get.find<LocalizationController>().isLtr ? null : 20,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))
                ],
              ),
              padding: const EdgeInsets.all(2), // tiny padding so border looks nice
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: CustomImage(
                  fit: BoxFit.cover,
                  image: store!.logoFullUrl ?? '',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
