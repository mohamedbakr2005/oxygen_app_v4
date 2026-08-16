import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Oxygen_Mart/common/models/module_model.dart';
import 'package:Oxygen_Mart/common/widgets/custom_image.dart';
import 'package:Oxygen_Mart/common/widgets/custom_ink_well.dart';
import 'package:Oxygen_Mart/features/splash/controllers/splash_controller.dart';
import 'package:Oxygen_Mart/features/store/domain/models/store_model.dart';
import 'package:Oxygen_Mart/features/store/screens/store_screen.dart';
import 'package:Oxygen_Mart/helper/route_helper.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/styles.dart';

class FoodStoreCircularCardWidget extends StatelessWidget {
  final Store? store;
  const FoodStoreCircularCardWidget({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return CustomInkWell(
      onTap: () {
        if (store != null) {
          if (Get.find<SplashController>().moduleList != null) {
            for (ModuleModel module in Get.find<SplashController>().moduleList!) {
              if (module.id == store!.moduleId) {
                Get.find<SplashController>().setModule(module);
                break;
              }
            }
          }
          Get.toNamed(
            RouteHelper.getStoreRoute(id: store!.id, page: 'item'),
            arguments: StoreScreen(store: store, fromModule: false),
          );
        }
      },
      radius: 100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 115,
            height: 115,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).cardColor,
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: ClipOval(
              child: store?.active == false
                  ? ColorFiltered(
                      colorFilter: const ColorFilter.mode(
                        Colors.grey,
                        BlendMode.saturation,
                      ),
                      child: CustomImage(
                        image: store?.logoFullUrl ?? '',
                        fit: BoxFit.cover,
                      ),
                    )
                  : CustomImage(
                      image: store?.logoFullUrl ?? '',
                      fit: BoxFit.cover,
                    ),
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              store?.name ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: robotoMedium.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: Theme.of(context).textTheme.bodyLarge!.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
