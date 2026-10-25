import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Oxygen_Mart/features/cart/controllers/cart_controller.dart';
import 'package:Oxygen_Mart/features/splash/controllers/splash_controller.dart';
import 'package:Oxygen_Mart/features/service_module/service_cart/controllers/service_cart_controller.dart';
import 'package:Oxygen_Mart/util/app_constants.dart';
import 'package:Oxygen_Mart/util/images.dart';
import 'package:Oxygen_Mart/util/styles.dart';

class CartWidget extends StatelessWidget {
  final Color? color;
  final double size;
  final bool fromStore;
  final String? moduleType;
  const CartWidget({
    super.key,
    required this.color,
    required this.size,
    this.fromStore = false,
    this.moduleType,
  });

  @override
  Widget build(BuildContext context) {
    final bool shouldShowCart = moduleType == null || (moduleType != AppConstants.ride && moduleType != AppConstants.taxi && moduleType != AppConstants.parcel);

    if (!shouldShowCart) {
      return const SizedBox();
    }

    return GetBuilder<SplashController>(builder: (splashController) {
      final effectiveModule = splashController.module ?? splashController.cacheModule;
      final bool isServiceModule = effectiveModule?.moduleType == AppConstants.service;

      return Stack(clipBehavior: Clip.none, children: [
        Image.asset(Images.shoppingCart, height: size, width: size, color: color),

        isServiceModule && Get.isRegistered<ServiceCartController>()
            ? GetBuilder<ServiceCartController>(builder: (serviceCartController) {
                final int count = serviceCartController.serviceCartItemCount;
                return count > 0 ? _CartCountBadge(count: count, size: size, fromStore: fromStore) : const SizedBox();
              })
            : GetBuilder<CartController>(builder: (cartController) {
                final int itemCount = cartController.allCartsItemCount > 0 ? cartController.allCartsItemCount : cartController.cartList.length;
                return cartController.isLoading
                    ? const SizedBox.shrink()
                    : itemCount > 0
                        ? _CartCountBadge(count: itemCount, size: size, fromStore: fromStore)
                        : const SizedBox();
              }),
      ]);
    });
  }
}

class _CartCountBadge extends StatelessWidget {
  final int count;
  final double size;
  final bool fromStore;
  const _CartCountBadge({required this.count, required this.size, required this.fromStore});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -5,
      right: -5,
      child: Container(
        height: size < 20 ? 10 : size / 2,
        width: size < 20 ? 10 : size / 2,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: fromStore
              ? Theme.of(context).cardColor
              : Theme.of(context).colorScheme.error,
          border: Border.all(
            width: size < 20 ? 0.7 : 1,
            color: fromStore
                ? Theme.of(context).primaryColor
                : Theme.of(context).cardColor,
          ),
        ),
        child: Text(
          count.toString(),
          style: robotoRegular.copyWith(
            fontSize: size < 20 ? size / 3 : size / 3.8,
            color: fromStore
                ? Theme.of(context).primaryColor
                : Theme.of(context).cardColor,
          ),
        ),
      ),
    );
  }
}
