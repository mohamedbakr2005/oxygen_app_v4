import 'package:flutter/material.dart';
import 'package:Oxygen_Mart/helper/responsive_helper.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';

class ItemShimmer extends StatelessWidget {
  final bool isEnabled;
  final bool isStore;
  final bool hasDivider;
  final bool inStore;
  const ItemShimmer(
      {super.key,
      required this.isEnabled,
      required this.hasDivider,
      this.isStore = false,
      this.inStore = false});

  @override
  Widget build(BuildContext context) {
    bool desktop = ResponsiveHelper.isDesktop(context);

    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        color: Theme.of(context).cardColor,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                  vertical: desktop ? 0 : Dimensions.paddingSizeExtraSmall),
              child: Flex(
                direction: (inStore && !desktop) ? Axis.horizontal : Axis.vertical,
                children: [
                Container(
                  height: desktop ? 120 : 80,
                  width: desktop ? 120 : 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    color: Theme.of(context).shadowColor,
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall, height: Dimensions.paddingSizeSmall),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            height: desktop ? 20 : 10,
                            width: (inStore && !desktop) ? 150 : double.maxFinite,
                            color: Theme.of(context).shadowColor),
                        const SizedBox(height: Dimensions.paddingSizeSmall),
                        Container(
                          height: desktop ? 15 : 10,
                          width: (inStore && !desktop) ? 100 : double.maxFinite,
                          color: Theme.of(context).shadowColor,
                          margin: const EdgeInsets.only(
                              right: Dimensions.paddingSizeLarge),
                        ),
                        SizedBox(
                            height: isStore ? Dimensions.paddingSizeSmall : 0),
                        const SizedBox(),
                      ]),
                ),
                Column(
                    mainAxisAlignment: isStore
                        ? MainAxisAlignment.center
                        : MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            vertical:
                                desktop ? Dimensions.paddingSizeSmall : 0),
                        child: Icon(
                          Icons.favorite_border,
                          size: desktop ? 30 : 25,
                          color: Theme.of(context).shadowColor,
                        ),
                      ),
                    ]),
              ]),
            ),
          ),
          desktop
              ? const SizedBox()
              : Padding(
                  padding: EdgeInsets.only(left: desktop ? 130 : 90),
                  child: Divider(
                      color: hasDivider
                          ? Theme.of(context).shadowColor
                          : Colors.transparent),
                ),
        ],
      ),
    );
  }
}
