import 'dart:convert';

import 'package:Oxygen_Mart/helper/facebook_pixel_helper.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Oxygen_Mart/common/widgets/custom_snackbar.dart';
import 'package:Oxygen_Mart/features/favourite/controllers/favourite_controller.dart';
import 'package:Oxygen_Mart/features/item/domain/models/item_model.dart';
import 'package:Oxygen_Mart/helper/auth_helper.dart';
import 'package:universal_html/js.dart' as js;

class AddFavouriteView extends StatelessWidget {
  final Item? item;
  final double? top, right;
  final double? left;
  final int? storeId;

  const AddFavouriteView(
      {super.key,
      required this.item,
      this.top = 15,
      this.right = 15,
      this.left,
      this.storeId});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      right: right,
      left: left,
      child: GetBuilder<FavouriteController>(builder: (favouriteController) {
        bool isWished;
        if (storeId != null) {
          isWished = favouriteController.wishStoreIdList.contains(storeId);
        } else {
          isWished = favouriteController.wishItemIdList.contains(item!.id);
        }
        return InkWell(
          onTap: () {
            if (AuthHelper.isLoggedIn()) {
              if (storeId != null) {
                isWished
                    ? favouriteController.removeFromFavouriteList(storeId, true)
                    : favouriteController.addToFavouriteList(
                        null, storeId, true);
              } else {
                isWished
                    ? favouriteController.removeFromFavouriteList(
                        item!.id, false)
                    : favouriteController
                        .addToFavouriteList(item, null, false)
                        .then((value) {
                        if (GetPlatform.isAndroid || GetPlatform.isIOS) {
                        }

                        if (GetPlatform.isWeb) {
                          // FacebookEvents.addToWishlist(
                          //   productId: item!.id.toString(),
                          //   name: item!.name.toString(),
                          //   price: item!.price!.toDouble(),
                          // );
                        }

                        FirebaseAnalytics.instance.logEvent(
                          name: "add_to_wishlist",
                          parameters: {
                            "item_id": item!.id.toString(),
                            "item_name": item!.name!,
                            "item_category": (item!.categoryIds != null &&
                                    item!.categoryIds!.isNotEmpty)
                                ? item!.categoryIds![0].id.toString()
                                : "General",
                            "price": item!.price!.toDouble() ?? 0,
                            "currency": "EGP",
                          },
                        );
                      });
              }
            } else {
              showCustomSnackBar('you_are_not_logged_in'.tr);
            }
          },
          child: Icon(isWished ? Icons.favorite : Icons.favorite_border,
              color: Theme.of(context).primaryColor, size: 20),
        );
      }),
    );
  }

  void fbAddToWishlistWeb(Item item) {
    js.context.callMethod('fbq', [
      'track',
      'AddToWishlist',
      {
        'content_ids': [item.id.toString()],
        'content_type': 'product',
        'content_name': item.name,
        'content_category':
            (item.categoryIds != null && item.categoryIds!.isNotEmpty)
                ? item.categoryIds![0].id.toString()
                : 'General',
        'value': item.price!.toDouble(),
        'currency': 'EGP',
      }
    ]);
  }
}


//5078086701425295
//06/28
//youssef