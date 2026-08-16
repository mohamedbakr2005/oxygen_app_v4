import 'dart:convert';

import 'package:Oxygen_Mart/helper/facebook_pixel_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Oxygen_Mart/common/widgets/custom_snackbar.dart';
import 'package:Oxygen_Mart/features/favourite/controllers/favourite_controller.dart';
import 'package:Oxygen_Mart/features/item/domain/models/item_model.dart';
import 'package:Oxygen_Mart/features/store/domain/models/store_model.dart';
import 'package:Oxygen_Mart/helper/auth_helper.dart';
import 'package:universal_html/js.dart' as js;

class CustomFavouriteWidget extends StatefulWidget {
  final Store? store;
  final Item? item;
  final bool isStore;
  final bool isWished;
  final double? size;
  final int? storeId;

  const CustomFavouriteWidget(
      {super.key,
      this.store,
      this.item,
      this.isStore = false,
      required this.isWished,
      this.size = 25,
      this.storeId});

  @override
  State<CustomFavouriteWidget> createState() => _CustomFavouriteWidgetState();
}

class _CustomFavouriteWidgetState extends State<CustomFavouriteWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      onTap: Get.find<FavouriteController>().isRemoving
          ? null
          : () {
              if (AuthHelper.isLoggedIn()) {
                _decideWished(widget.isWished, Get.find<FavouriteController>());
              } else {
                showCustomSnackBar('you_are_not_logged_in'.tr,
                    getXSnackBar: true);
              }
              _controller.reverse().then((value) => _controller.forward());
            },
      child: ScaleTransition(
        scale: Tween(begin: 0.7, end: 1.0).animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeOut)),
        child: Icon(
            widget.isWished ? Icons.favorite : Icons.favorite_border_rounded,
            color: Theme.of(context).primaryColor,
            size: widget.size),
        // child: CustomAssetImageWidget(widget.isWished ? Images.favouriteIcon : Images.unFavouriteIcon, height: widget.size, width: widget.size),
      ),
    );
  }

  _decideWished(bool isWished, FavouriteController favouriteController) {
    if (widget.isStore) {
      isWished
          ? favouriteController.removeFromFavouriteList(
              widget.storeId ?? widget.store?.id, true)
          : favouriteController
              .addToFavouriteList(
                  null, widget.storeId ?? widget.store?.id, true)
              .then((value) {
              if (GetPlatform.isAndroid || GetPlatform.isIOS) {
              }

              if (GetPlatform.isWeb) {
                // FacebookEvents.addToWishlist(
                //     productId: widget.item!.id.toString(),
                //     name: widget.item!.name.toString(),
                //     price: widget.item!.price ?? 0.0);
              }

              // fbAddToWishlistWeb(widget.item!);
            });
    } else {
      isWished
          ? favouriteController.removeFromFavouriteList(widget.item?.id, false)
          : favouriteController.addToFavouriteList(widget.item, null, false);
    }
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
                : "General",
        'value': (item.discount != null && item.discount! > 0)
            ? item.discount!.toDouble()
            : item.price!.toDouble(),
        'currency': "EGP",
      }
    ]);
  }
}
