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
  final Widget? menuWidget;
  final String? subtitle;
  final String? cartSubtitle;
  final bool isCart;
  final VoidCallback? onSearchTap;
  final bool isSearchActive;

  const CustomAppBar({super.key,
    required this.title, this.backButton = true, this.onBackPressed, this.showCart = false, this.clearCart = false,
    this.onVegFilterTap, this.type, this.leadingIcon, this.menuWidget, this.subtitle,
    this.cartSubtitle, this.isCart = false, this.onSearchTap, this.isSearchActive = false,
  });

  @override
  Widget build(BuildContext context) {
    if (ResponsiveHelper.isDesktop(context)) return const WebMenuBar();

    final Color textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    final Color iconBg = Theme.of(context).disabledColor.withValues(alpha: 0.1);

    return AppBar(
      title: Column(crossAxisAlignment: onSearchTap != null ? CrossAxisAlignment.start : CrossAxisAlignment.center, children: [
        Text(
          title,
          maxLines: 1, overflow: TextOverflow.ellipsis,
          style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: textColor),
        ),
        if (isCart && cartSubtitle != null) Text(
          cartSubtitle!,
          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault),
        ),
      ]),
      centerTitle: onSearchTap == null,
      titleSpacing: onSearchTap != null ? 0 : NavigationToolbar.kMiddleSpacing,
      leadingWidth: backButton ? (onSearchTap != null ? 70 : null) : 0,
      leading: backButton
          ? (onSearchTap != null
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                  child: GestureDetector(
                    onTap: () => onBackPressed != null ? onBackPressed!() : Navigator.pop(context),
                    child: Container(
                      height: 40, width: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
                      child: leadingIcon != null
                          ? Image.asset(leadingIcon!, height: 22, width: 22)
                          : Icon(Icons.arrow_back, color: textColor, size: 20),
                    ),
                  ),
                )
              : IconButton(
                  icon: leadingIcon != null
                      ? Image.asset(leadingIcon!, height: 22, width: 22)
                      : const Icon(Icons.arrow_back_ios),
                  color: textColor,
                  onPressed: () => onBackPressed != null ? onBackPressed!() : Get.back(),
                ))
          : const SizedBox(),
      bottom: subtitle != null ? PreferredSize(
        preferredSize: const Size.fromHeight(50.0),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 5.0),
          child: Text(subtitle!, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault)),
        ),
      ) : null,
      backgroundColor: Theme.of(context).cardColor,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      actions: (showCart || onVegFilterTap != null || onSearchTap != null || clearCart) ? [
        if (onSearchTap != null)
          IconButton(
            onPressed: onSearchTap,
            icon: Icon(isSearchActive ? Icons.close : Icons.search, color: textColor),
          ),

        if (clearCart)
          IconButton(
            onPressed: () {
              Get.find<CartController>().clearCartList();
              showCustomSnackBar("cart_cleared_successfully".tr, isError: false);
            },
            icon: Icon(Icons.delete_forever, color: Theme.of(context).primaryColor, size: 26),
          ),

        if (showCart)
          IconButton(
            onPressed: () => Get.toNamed(RouteHelper.getCartRoute()),
            icon: CartWidget(color: textColor, size: 25),
          ),

        if (onVegFilterTap != null)
          VegFilterWidget(
            type: type,
            onSelected: onVegFilterTap,
            fromAppBar: true,
          ),
        const SizedBox(width: Dimensions.paddingSizeSmall),
      ] : [menuWidget ?? const SizedBox(), const SizedBox(width: Dimensions.paddingSizeDefault)],
    );
  }

  @override
  Size get preferredSize => Size(Get.width, GetPlatform.isDesktop ? 100 : subtitle != null ? 60 : 50);
}
