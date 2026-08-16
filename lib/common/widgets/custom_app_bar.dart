import 'package:Oxygen_Mart/common/widgets/custom_snackbar.dart';
import 'package:Oxygen_Mart/features/cart/controllers/cart_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Oxygen_Mart/common/widgets/cart_widget.dart';
import 'package:Oxygen_Mart/common/widgets/veg_filter_widget.dart';
import 'package:Oxygen_Mart/common/widgets/web_menu_bar.dart';
import 'package:Oxygen_Mart/helper/responsive_helper.dart';
import 'package:Oxygen_Mart/helper/route_helper.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/styles.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool backButton;
  final Function? onBackPressed;
  final bool showCart;
  final bool clearCart;
  final Function(String value)? onVegFilterTap;
  final String? type;
  final String? leadingIcon;
  const CustomAppBar(
      {super.key,
      required this.title,
      this.backButton = true,
      this.onBackPressed,
      this.showCart = false,
      this.clearCart = false,
      this.leadingIcon,
      this.onVegFilterTap,
      this.type});

  @override
  Widget build(BuildContext context) {
    return ResponsiveHelper.isDesktop(context)
        ? const WebMenuBar()
        : AppBar(
            title: Text(title,
                style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeLarge,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge!.color)),
            centerTitle: true,
            leading: backButton
                ? IconButton(
                    icon: leadingIcon != null
                        ? Image.asset(leadingIcon!, height: 22, width: 22)
                        : const Icon(Icons.arrow_back_ios),
                    color: Theme.of(context).textTheme.bodyLarge!.color,
                    onPressed: () => onBackPressed != null
                        ? onBackPressed!()
                        : Get.back(),
                  )
                : const SizedBox(),
            backgroundColor: Theme.of(context).cardColor,
            surfaceTintColor: Theme.of(context).cardColor,
            shadowColor: Theme.of(context).disabledColor.withOpacity(0.5),
            elevation: 2,
            actions: [
              // Clear Cart Button
              clearCart
                  ? IconButton(
                      onPressed: () {
                        // ارجع هنا تتعامل مع الكارت
                        Get.find<CartController>().clearCartList();
                        showCustomSnackBar("cart_cleared_successfully".tr,
                            isError: false);
                      },
                      icon: Icon(Icons.delete_forever,
                          color: Theme.of(context).primaryColor, size: 26),
                    )
                  : const SizedBox(),

              // Show Cart Button
              showCart
                  ? IconButton(
                      onPressed: () => Get.toNamed(RouteHelper.getCartRoute()),
                      icon: CartWidget(
                          color: Theme.of(context).textTheme.bodyLarge!.color,
                          size: 25),
                    )
                  : const SizedBox(),

              // Veg Filter
              onVegFilterTap != null
                  ? VegFilterWidget(
                      type: type,
                      onSelected: onVegFilterTap,
                      fromAppBar: true,
                    )
                  : const SizedBox(),
            ],
          );
  }

  @override
  Size get preferredSize => Size(Get.width, GetPlatform.isDesktop ? 100 : 50);
}
