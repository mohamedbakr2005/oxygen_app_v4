import 'dart:convert';

import 'package:Oxygen_Mart/features/cart/controllers/cart_controller.dart';
import 'package:Oxygen_Mart/features/item/controllers/item_controller.dart';
import 'package:Oxygen_Mart/features/item/domain/models/item_model.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/styles.dart';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

SharedPreferences sharedPreferences = Get.find<SharedPreferences>();
final facebookAppEvents = FacebookAppEvents();

class _CartCountViewState extends State<CartCountView> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<CartController>(builder: (cartController) {
      int cartQty = cartController.cartQuantity(widget.item.id!);
      int cartIndex = cartController.isExistInCart(
          widget.item.id, cartController.cartVariant(widget.item.id!), false, null);

      return cartQty != 0
          ? Container(
              height: 36, // Matches the squircle height from our ItemCard
              // MODERN TWEAK: Removed 'width: 120' so it sizes itself dynamically
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
                mainAxisSize: MainAxisSize.min, // THE FIX: Only take required space
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Minus Button
                  InkWell(
                    onTap: cartController.isLoading
                        ? null
                        : () {
                            if (cartController.cartList[cartIndex].quantity! > 1) {
                              cartController.setDirectlyAddToCartIndex(widget.index);
                              cartController.setQuantity(
                                  false,
                                  cartIndex,
                                  cartController.cartList[cartIndex].stock,
                                  cartController.cartList[cartIndex].item!.quantityLimit);
                            } else {
                              cartController.removeFromCart(cartIndex);
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
                            cartController.setDirectlyAddToCartIndex(widget.index);
                            cartController.setQuantity(
                                true,
                                cartIndex,
                                cartController.cartList[cartIndex].stock,
                                cartController.cartList[cartIndex].quantityLimit);

                            if (GetPlatform.isAndroid || GetPlatform.isIOS) {
                              _facebookEvent(widget.item, cartQty);
                            }

                            FirebaseAnalytics.instance.logEvent(
                              name: 'add_to_cart',
                              parameters: {
                                'item_id': widget.item.id.toString(),
                                'item_name': widget.item.name.toString(),
                                'currency': 'EGP',
                                'value': widget.item.price.toString(),
                                'quantity': widget.item.quantityLimit!.toString(),
                              },
                            );
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
              onTap: () {
                Get.find<ItemController>().itemDirectlyAddToCart(widget.item, context);

                if (GetPlatform.isAndroid || GetPlatform.isIOS) {
                  _facebookEvent(widget.item, cartQty);
                }

                FirebaseAnalytics.instance.logEvent(
                  name: 'add_to_cart',
                  parameters: {
                    'currency': 'EGP',
                    'value': widget.item.price!,
                    'items': [
                      {
                        'item_id': widget.item.id.toString(),
                        'item_name': widget.item.name,
                        'price': widget.item.price!,
                        'quantity': 1,
                      }
                    ]
                  },
                );
              },
              child: widget.child ??
                  Container(
                    height: 36,
                    width: 36,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(10), // Matches squircle
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).primaryColor.withOpacity(0.2),
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
                  ),
            );
    });
  }

  void _facebookEvent(Item item, num cartQty) {
  }
}