import 'package:Oxygen_Mart/features/cart/controllers/cart_controller.dart';
import 'package:Oxygen_Mart/features/item/controllers/item_controller.dart';
import 'package:Oxygen_Mart/features/item/domain/models/item_model.dart';
import 'package:Oxygen_Mart/features/location/controllers/location_controller.dart';
import 'package:Oxygen_Mart/helper/address_helper.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/styles.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CartCountView extends StatefulWidget {
  final Item item;
  final Widget? child;
  final int? index;

  const CartCountView({
    super.key,
    required this.item,
    this.child,
    this.index = -1,
  });

  @override
  State<CartCountView> createState() => _CartCountViewState();
}

class _CartCountViewState extends State<CartCountView> {
  bool _isAdding = false;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CartController>(builder: (cartController) {
      int cartQty = cartController.cartQuantity(widget.item.id!);
      int cartIndex = cartController.isExistInCart(
          widget.item.id, cartController.cartVariant(widget.item.id!), false, null);

      return cartQty != 0
          ? Container(
              height: 36, // Matches the squircle height from our ItemCard
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(10), // Modern Squircle shape
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min, // Only take required space
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Minus Button
                  InkWell(
                    onTap: cartController.isLoading
                        ? null
                        : () {
                            if (cartIndex != -1 && cartIndex < cartController.cartList.length) {
                              if (cartController.cartList[cartIndex].quantity! > 1) {
                                cartController.setDirectlyAddToCartIndex(widget.index);
                                cartController.changeQuantity(
                                    false,
                                    cartIndex,
                                    cartController.cartList[cartIndex].stock,
                                    cartController.cartList[cartIndex].item?.quantityLimit);
                              } else {
                                cartController.removeFromCart(cartIndex);
                              }
                            }
                          },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      child: Icon(
                        Icons.remove_rounded,
                        size: 20,
                        color: Theme.of(context).cardColor, // White icon on Primary Background
                      ),
                    ),
                  ),
                  
                  // Quantity Text or Loader
                  SizedBox(
                    width: 20, // Keep a fixed small width so the buttons don't jump around
                    child: Center(
                      child: cartController.isLoading &&
                              cartController.directAddCartItemIndex == widget.index
                          ? SizedBox(
                              height: 14,
                              width: 14,
                              child: CircularProgressIndicator(
                                color: Theme.of(context).cardColor,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              cartQty.toString(),
                              style: robotoBold.copyWith(
                                fontSize: Dimensions.fontSizeDefault,
                                color: Theme.of(context).cardColor,
                              ),
                            ),
                    ),
                  ),
                  
                  // Plus Button
                  InkWell(
                    onTap: cartController.isLoading
                        ? null
                        : () {
                            if (cartIndex != -1 && cartIndex < cartController.cartList.length) {
                              cartController.setDirectlyAddToCartIndex(widget.index);
                              cartController.changeQuantity(
                                  true,
                                  cartIndex,
                                  cartController.cartList[cartIndex].stock,
                                  cartController.cartList[cartIndex].item?.quantityLimit);

                              try {
                                FirebaseAnalytics.instance.logEvent(
                                  name: 'add_to_cart',
                                  parameters: {
                                    'item_id': widget.item.id.toString(),
                                    'item_name': widget.item.name.toString(),
                                    'currency': 'EGP',
                                    'value': widget.item.price.toString(),
                                    'quantity': (widget.item.quantityLimit ?? 1).toString(),
                                  },
                                );
                              } catch (_) {}
                            }
                          },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      child: Icon(
                        Icons.add_rounded,
                        size: 20,
                        color: Theme.of(context).cardColor, // White icon on Primary Background
                      ),
                    ),
                  ),
                ],
              ),
            )
          // Add to Cart Initial Button (When quantity is 0)
          : InkWell(
              onTap: (_isAdding || cartController.isItemAdding(widget.item.id))
                  ? null
                  : () async {
                      if (AddressHelper.getUserAddressFromSharedPref() == null) {
                        Get.find<LocationController>().navigateToLocationScreen('home', canRoute: true);
                        return;
                      }
                      setState(() => _isAdding = true);
                      try {
                        await Get.find<ItemController>().itemDirectlyAddToCart(widget.item, context);
                      } finally {
                        if (mounted) setState(() => _isAdding = false);
                      }

                      try {
                        FirebaseAnalytics.instance.logAddToCart(
                          currency: 'EGP',
                          value: widget.item.price?.toDouble() ?? 0.0,
                          items: [
                            AnalyticsEventItem(
                              itemId: widget.item.id?.toString(),
                              itemName: widget.item.name,
                              price: widget.item.price?.toDouble(),
                              quantity: 1,
                            ),
                          ],
                        );
                      } catch (e) {
                        debugPrint('FirebaseAnalytics logAddToCart error: $e');
                      }
                    },
              child: (_isAdding || cartController.isItemAdding(widget.item.id))
                  ? Container(
                      height: 36,
                      width: 36,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Center(
                        child: SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            color: Theme.of(context).cardColor,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                    )
                  : (widget.child ??
                      Container(
                        height: 36,
                        width: 36,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            Icons.add_rounded,
                            size: 20,
                            color: Theme.of(context).cardColor,
                          ),
                        ),
                      )),
            );
    });
  }
}
