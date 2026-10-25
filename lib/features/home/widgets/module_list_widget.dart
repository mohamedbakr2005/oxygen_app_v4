import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Oxygen_Mart/features/splash/controllers/splash_controller.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/styles.dart';
import 'package:Oxygen_Mart/helper/responsive_helper.dart';
import 'package:Oxygen_Mart/common/widgets/custom_ink_well.dart';
import 'package:Oxygen_Mart/common/widgets/custom_image.dart';
import 'package:Oxygen_Mart/util/app_constants.dart';

class ModuleListWidget extends StatelessWidget {
  const ModuleListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashController>(builder: (splashController) {
      if (splashController.moduleList == null || splashController.moduleList!.isEmpty) {
        return const SizedBox();
      }

      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
              child: Text(
                '${'explore'.tr} اوكسجين مارت',
                style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: ResponsiveHelper.isDesktop(context) ? 4 : 2,
                crossAxisSpacing: Dimensions.paddingSizeDefault,
                mainAxisSpacing: Dimensions.paddingSizeDefault,
                mainAxisExtent: 65, // Adjusted to match the pill height in the image
              ),
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: splashController.moduleList!.length,
              itemBuilder: (context, index) {
                var module = splashController.moduleList![index];
                bool isSelected = splashController.module != null && splashController.module!.id == module.id;
        
                String iconPath = module.iconFullUrl ?? '';
                String moduleName = module.moduleName ?? '';
        
        
                return Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(100), // Pill shape
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        spreadRadius: 1,
                        offset: const Offset(0, 3),
                      )
                    ],
                    border: isSelected 
                      ? Border.all(color: Theme.of(context).primaryColor.withOpacity(0.5), width: 1.5)
                      : Border.all(color: Theme.of(context).disabledColor.withOpacity(0.1), width: 1),
                  ),
                  child: CustomInkWell(
                    onTap: () {
                      if (!isSelected) {
                        splashController.switchModule(module);
                      }
                    },
                    radius: 100,
                    child: Row(
                      children: [
                        const SizedBox(width: Dimensions.paddingSizeSmall),
                        Expanded(
                          child: Text(
                            moduleName,
                            textAlign: TextAlign.start,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: robotoBold.copyWith(
                              fontSize: 14,
                              color: isSelected 
                                ? Theme.of(context).primaryColor 
                                : Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: CustomImage(
                            image: iconPath,
                            width: 50,
                            height: 50,
                            fit: BoxFit.contain,
                          ),
                        ),
        
                        const SizedBox(width: 4),
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
    });
  }
}
