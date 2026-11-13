import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:get/get.dart';
import 'package:Oxygen_Mart/common/widgets/cart_snackbar.dart';
import 'package:Oxygen_Mart/common/widgets/confirmation_dialog.dart';
import 'package:Oxygen_Mart/common/widgets/custom_app_bar.dart';
import 'package:Oxygen_Mart/common/widgets/custom_asset_image_widget.dart';
import 'package:Oxygen_Mart/common/widgets/custom_snackbar.dart';
import 'package:Oxygen_Mart/common/widgets/custom_tool_tip_widget.dart';
import 'package:Oxygen_Mart/common/widgets/menu_drawer.dart';
import 'package:Oxygen_Mart/common/widgets/no_data_screen.dart';
import 'package:Oxygen_Mart/common/widgets/organic_tag.dart';
import 'package:Oxygen_Mart/common/widgets/product_share_button.dart';
import 'package:Oxygen_Mart/features/cart/controllers/cart_controller.dart';
import 'package:Oxygen_Mart/features/cart/domain/models/cart_model.dart';
import 'package:Oxygen_Mart/features/checkout/domain/models/place_order_body_model.dart';
import 'package:Oxygen_Mart/features/checkout/screens/checkout_screen.dart';
import 'package:Oxygen_Mart/features/favourite/controllers/favourite_controller.dart';
import 'package:Oxygen_Mart/features/item/controllers/item_controller.dart';
import 'package:Oxygen_Mart/features/item/domain/models/item_model.dart';
import 'package:Oxygen_Mart/features/item/widgets/details_app_bar_widget.dart';
import 'package:Oxygen_Mart/features/item/widgets/details_web_view_widget.dart';
import 'package:Oxygen_Mart/features/item/widgets/item_details_related_card_widget.dart';
import 'package:Oxygen_Mart/features/item/widgets/item_image_view_widget.dart';
import 'package:Oxygen_Mart/features/splash/controllers/splash_controller.dart';
import 'package:Oxygen_Mart/helper/auth_helper.dart';
import 'package:Oxygen_Mart/helper/price_converter.dart';
import 'package:Oxygen_Mart/helper/responsive_helper.dart';
import 'package:Oxygen_Mart/helper/route_helper.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/images.dart';
import 'package:Oxygen_Mart/util/styles.dart';
import 'package:universal_html/js.dart' as js;

class ItemDetailsScreen extends StatefulWidget {
  final Item? item;
  final bool inStorePage;
  final bool? isCampaign;

  const ItemDetailsScreen({super.key,
    required this.item, required this.inStorePage, this.isCampaign,
  });

  @override
  State<ItemDetailsScreen> createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen> {
  final Size size = Get.size;
  final GlobalKey<ScaffoldMessengerState> _globalKey = GlobalKey();
  final GlobalKey<DetailsAppBarWidgetState> _key = GlobalKey();

  void fbqViewContent(Item item) {
    js.context.callMethod('fbq', [
      'track',
      'ViewContent',
      {
        "content_ids": [item.id.toString()],
        "content_type": "product",
        "content_name": item.name,
        "content_category":
            item.categoryIds != null && item.categoryIds!.isNotEmpty
                ? item.categoryIds![0].id.toString()
                : "General",
        "value": item.price?.toDouble() ?? 0.0,
        "currency": "EGP",
      }
    ]);
  }

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      final itemController = Get.find<ItemController>();
      itemController.resetItemDetails(widget.item!, notify: false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          itemController.getProductDetails(widget.item!, notify: false);
          itemController.setSelect(0, false);
          itemController.getDiscountedItemList(false, false, 'all');
        }
      });
    }
  }

  @override
  void dispose() {
    if (Get.isRegistered<ItemController>()) {
      Get.find<ItemController>().clearItemDetails(notify: false);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isLoggedIn = AuthHelper.isLoggedIn();

    return GetBuilder<CartController>(builder: (cartController) {
      return GetBuilder<ItemController>(
        builder: (itemController) {
          int? stock = 0;
          CartModel? cartModel;
          OnlineCart? cart;
          double priceWithAddons = 0;
          int? cartId = cartController.getCartId(itemController.cartIndex);
          double? price = itemController.item?.price;
          double? discount = (itemController.item?.availableDateStarts != null || (itemController.item?.storeDiscount ?? 0) == 0)
              ? itemController.item?.discount
              : itemController.item?.storeDiscount;
          String? discountType = (itemController.item?.availableDateStarts != null || (itemController.item?.storeDiscount ?? 0) == 0)
              ? itemController.item?.discountType
              : 'percent';
          double priceWithDiscount = PriceConverter.convertWithDiscount(price, discount, discountType) ?? price ?? 0;

          if (itemController.item != null && itemController.variationIndex != null) {
            List<String> variationList = [];
            if (itemController.item!.choiceOptions != null) {
              for (int index = 0; index < itemController.item!.choiceOptions!.length; index++) {
                if (index < itemController.variationIndex!.length &&
                    itemController.item!.choiceOptions![index].options != null &&
                    itemController.variationIndex![index] < itemController.item!.choiceOptions![index].options!.length) {
                  variationList.add(itemController.item!.choiceOptions![index]
                      .options![itemController.variationIndex![index]]
                      .replaceAll(' ', ''));
                }
              }
            }
            String variationType = '';
            bool isFirst = true;
            for (var variation in variationList) {
              if (isFirst) {
                variationType = '$variationType$variation';
                isFirst = false;
              } else {
                variationType = '$variationType-$variation';
              }
            }

            price = itemController.item!.price;
            Variation? variation;
            stock = itemController.item!.stock ?? 0;
            if (itemController.item!.variations != null) {
              for (Variation v in itemController.item!.variations!) {
                if (v.type == variationType) {
                  price = v.price;
                  variation = v;
                  stock = v.stock;
                  break;
                }
              }
            }

            discount = (itemController.item!.availableDateStarts != null || (itemController.item!.storeDiscount ?? 0) == 0)
                ? itemController.item!.discount
                : itemController.item!.storeDiscount;
            discountType = (itemController.item!.availableDateStarts != null || (itemController.item!.storeDiscount ?? 0) == 0)
                ? itemController.item!.discountType
                : 'percent';
            priceWithDiscount = PriceConverter.convertWithDiscount(price, discount, discountType) ?? price ?? 0;
            double priceWithQuantity = priceWithDiscount * (itemController.quantity ?? 1);
            
            double addonsCost = 0;
            List<AddOn> addOnIdList = [];
            List<AddOns> addOnsList = [];
            if (itemController.item!.addOns != null) {
              for (int index = 0; index < itemController.item!.addOns!.length; index++) {
                if (index < itemController.addOnActiveList.length && itemController.addOnActiveList[index]) {
                  addonsCost = addonsCost + ((itemController.item!.addOns![index].price ?? 0) * (index < itemController.addOnQtyList.length ? (itemController.addOnQtyList[index] ?? 1) : 1));
                  addOnIdList.add(AddOn(id: itemController.item!.addOns![index].id, quantity: index < itemController.addOnQtyList.length ? itemController.addOnQtyList[index] : 1));
                  addOnsList.add(itemController.item!.addOns![index]);
                }
              }
            }

            cartModel = CartModel(
                null, price, priceWithDiscount, variation != null ? [variation] : [], [],
                ((price ?? 0) - (PriceConverter.convertWithDiscount(price, discount, discountType) ?? 0)),
                itemController.quantity, addOnIdList, addOnsList, itemController.item!.availableDateStarts != null,
                stock, itemController.item, itemController.item?.quantityLimit);

            List<int?> listOfAddOnId = _getSelectedAddonIds(addOnIdList: addOnIdList);
            List<int?> listOfAddOnQty = _getSelectedAddonQtnList(addOnIdList: addOnIdList);

            bool isCartIndexValid = itemController.cartIndex != -1 && itemController.cartIndex < cartController.cartList.length;

            cart = OnlineCart(
                cartId, widget.item!.id, null, priceWithDiscount.toString(), '', variation != null ? [variation] : [],
                null, isCartIndexValid ? cartController.cartList[itemController.cartIndex].quantity : itemController.quantity,
                listOfAddOnId, addOnsList, listOfAddOnQty, 'Item',
                storeId: widget.item?.storeId);
                
            priceWithAddons = priceWithQuantity + ((Get.find<SplashController>().configModel?.moduleConfig?.module?.addOn ?? false) ? addonsCost : 0);
          }

          return Scaffold(
            key: _globalKey,
            backgroundColor: Theme.of(context).cardColor,
            endDrawer: const MenuDrawer(),
            endDrawerEnableOpenDragGesture: false,
            appBar: ResponsiveHelper.isDesktop(context)
                ? const CustomAppBar(title: '')
                : DetailsAppBarWidget(key: _key),
            body: SafeArea(
              child: (itemController.item != null && (itemController.item!.name != null || itemController.item!.price != null))
                  ? Stack(
                      children: [
                        ResponsiveHelper.isDesktop(context)
                            ? DetailsWebViewWidget(
                                cartModel: cartModel,
                                stock: stock,
                                priceWithAddOns: priceWithAddons,
                                cart: cart,
                              )
                            : SingleChildScrollView(
                                padding: const EdgeInsets.only(
                                  bottom: 110, // space for floating bar
                                ),
                                physics: const BouncingScrollPhysics(),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 1. Product Image Slider with fit contain
                                    ItemImageViewWidget(
                                      item: itemController.item,
                                      isCampaign: widget.isCampaign ?? false,
                                    ),

                                    // 2. Product Information Card
                                    Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).cardColor,
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: Dimensions.paddingSizeDefault,
                                        vertical: Dimensions.paddingSizeSmall,
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Title & Action Icons (Share + Wishlist)
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  itemController.item?.name ?? '',
                                                  style: robotoBold.copyWith(
                                                    fontSize: 18,
                                                    color: Theme.of(context).textTheme.bodyLarge?.color,
                                                  ),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const SizedBox(width: Dimensions.paddingSizeSmall),
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  ProductShareButton(
                                                    productId: itemController.item?.id,
                                                    backgroundColor: Theme.of(context).disabledColor.withOpacity(0.06),
                                                  ),
                                                  const SizedBox(width: Dimensions.paddingSizeSmall),
                                                  GetBuilder<FavouriteController>(builder: (favouriteController) {
                                                    final bool isFav = favouriteController.wishItemIdList.contains(itemController.item!.id);
                                                    return InkWell(
                                                      onTap: () {
                                                        if (isLoggedIn) {
                                                          if (isFav) {
                                                            favouriteController.removeFromFavouriteList(itemController.item!.id, false);
                                                          } else {
                                                            favouriteController.addToFavouriteList(itemController.item, null, false);
                                                          }
                                                        } else {
                                                          showCustomSnackBar('you_are_not_logged_in'.tr);
                                                        }
                                                      },
                                                      borderRadius: BorderRadius.circular(20),
                                                      child: Container(
                                                        padding: const EdgeInsets.all(8),
                                                        decoration: BoxDecoration(
                                                          color: Theme.of(context).disabledColor.withOpacity(0.06),
                                                          shape: BoxShape.circle,
                                                        ),
                                                        child: Icon(
                                                          isFav ? Icons.favorite : Icons.favorite_border_rounded,
                                                          color: isFav ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
                                                          size: 22,
                                                        ),
                                                      ),
                                                    );
                                                  }),
                                                ],
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),

                                          // Store Name
                                          if (itemController.item?.storeName != null && itemController.item!.storeName!.isNotEmpty)
                                            InkWell(
                                              onTap: () {
                                                if (widget.inStorePage) {
                                                  Get.back();
                                                } else {
                                                  Get.offNamed(RouteHelper.getStoreRoute(
                                                    id: itemController.item!.storeId,
                                                    page: 'item',
                                                  ));
                                                }
                                              },
                                              child: Text(
                                                itemController.item!.storeName!,
                                                style: robotoMedium.copyWith(
                                                  fontSize: Dimensions.fontSizeDefault,
                                                  color: Theme.of(context).primaryColor,
                                                ),
                                              ),
                                            ),

                                          // Modern Price Box
                                          _ItemPriceWidget(
                                            price: price,
                                            priceWithDiscount: priceWithDiscount,
                                            discount: discount,
                                            discountType: discountType,
                                            unitType: itemController.item?.unitType,
                                          ),
                                          // Badges: Halal, Veg, Organic
                                          if ((itemController.item?.isStoreHalalActive == true && itemController.item?.isHalalItem == true) ||
                                              (itemController.item?.organic == 1) ||
                                              (Get.find<SplashController>().configModel?.moduleConfig?.module?.vegNonVeg == true))
                                            Padding(
                                              padding: const EdgeInsets.only(top: 8),
                                              child: Row(
                                                children: [
                                                  if (itemController.item?.isStoreHalalActive == true && itemController.item?.isHalalItem == true) ...[
                                                    CustomToolTip(
                                                      message: 'this_is_a_halal_food'.tr,
                                                      preferredDirection: AxisDirection.up,
                                                      child: const CustomAssetImageWidget(Images.halalTag, height: 24, width: 24),
                                                    ),
                                                    const SizedBox(width: Dimensions.paddingSizeSmall),
                                                  ],
                                                  if (itemController.item != null)
                                                    OrganicTag(item: itemController.item!, fromDetails: true),
                                                ],
                                              ),
                                            ),

                                          // 3. Variations / Choice Options
                                          if (itemController.item?.choiceOptions != null && itemController.item!.choiceOptions!.isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(top: 14),
                                              child: ListView.builder(
                                                shrinkWrap: true,
                                                itemCount: itemController.item!.choiceOptions!.length,
                                                physics: const NeverScrollableScrollPhysics(),
                                                itemBuilder: (context, index) {
                                                  if (itemController.item!.choiceOptions![index].options == null ||
                                                      itemController.item!.choiceOptions![index].options!.isEmpty) {
                                                    return const SizedBox();
                                                  }
                                                  return Padding(
                                                    padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          itemController.item!.choiceOptions![index].title ?? '',
                                                          style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
                                                        ),
                                                        const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                                                        Wrap(
                                                          spacing: 8,
                                                          runSpacing: 8,
                                                          children: List.generate(
                                                            itemController.item!.choiceOptions![index].options!.length,
                                                            (i) {
                                                              bool isSelected = (itemController.variationIndex != null &&
                                                                  index < itemController.variationIndex!.length &&
                                                                  itemController.variationIndex![index] == i);
                                                              return InkWell(
                                                                borderRadius: BorderRadius.circular(20),
                                                                onTap: () {
                                                                  itemController.setCartVariationIndex(index, i, itemController.item);
                                                                },
                                                                child: AnimatedContainer(
                                                                  duration: const Duration(milliseconds: 200),
                                                                  curve: Curves.easeInOut,
                                                                  padding: const EdgeInsets.symmetric(
                                                                    horizontal: Dimensions.paddingSizeDefault,
                                                                    vertical: Dimensions.paddingSizeExtraSmall,
                                                                  ),
                                                                  decoration: BoxDecoration(
                                                                    color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
                                                                    borderRadius: BorderRadius.circular(20),
                                                                    border: Border.all(
                                                                      color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).disabledColor.withOpacity(0.3),
                                                                      width: 1.2,
                                                                    ),
                                                                  ),
                                                                  child: Text(
                                                                    itemController.item!.choiceOptions![index].options![i].trim(),
                                                                    style: robotoMedium.copyWith(
                                                                      fontSize: Dimensions.fontSizeSmall,
                                                                      color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyLarge!.color,
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),

                                           // 4. Product Details Section (Only shown when description exists)
                                           if (itemController.item?.description != null && itemController.item!.description!.trim().isNotEmpty) ...[
                                             Container(
                                               height: 1,
                                               width: double.infinity,
                                               color: Theme.of(context).disabledColor.withOpacity(0.12),
                                               margin: const EdgeInsets.symmetric(vertical: 14),
                                             ),
                                             Row(
                                               children: [
                                                 Container(
                                                   width: 14,
                                                   height: 3,
                                                   decoration: BoxDecoration(
                                                     color: Theme.of(context).primaryColor,
                                                     borderRadius: BorderRadius.circular(2),
                                                   ),
                                                 ),
                                                 const SizedBox(width: 8),
                                                 Text(
                                                   'product_details'.tr,
                                                   style: robotoBold.copyWith(
                                                     fontSize: Dimensions.fontSizeLarge,
                                                     color: Theme.of(context).textTheme.bodyLarge?.color,
                                                   ),
                                                 ),
                                               ],
                                             ),
                                             const SizedBox(height: 8),
                                             HtmlWidget(
                                               itemController.item!.description!,
                                               textStyle: robotoRegular.copyWith(
                                                 fontSize: Dimensions.fontSizeSmall,
                                                 height: 1.6,
                                                 color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.85),
                                               ),
                                             ),
                                           ],

                                          // Prescription Alert
                                          if (itemController.item?.isPrescriptionRequired == true)
                                            Container(
                                              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                                              margin: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
                                              decoration: BoxDecoration(
                                                color: Theme.of(context).colorScheme.error.withOpacity(0.08),
                                                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                                border: Border.all(color: Theme.of(context).colorScheme.error.withOpacity(0.3)),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(Icons.warning_amber_rounded, color: Theme.of(context).colorScheme.error, size: 20),
                                                  const SizedBox(width: Dimensions.paddingSizeSmall),
                                                  Expanded(
                                                    child: Text(
                                                      'prescription_required'.tr,
                                                      style: robotoMedium.copyWith(
                                                        fontSize: Dimensions.fontSizeSmall,
                                                        color: Theme.of(context).colorScheme.error,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                          // Nutrition Details
                                          if (itemController.item?.nutritionsName != null && itemController.item!.nutritionsName!.isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(top: 14),
                                              child: _buildInfoChipSection(context, 'nutrition_details'.tr, itemController.item!.nutritionsName!),
                                            ),

                                          // Allergies Details
                                          if (itemController.item?.allergiesName != null && itemController.item!.allergiesName!.isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(top: 14),
                                              child: _buildInfoChipSection(context, 'allergic_ingredients'.tr, itemController.item!.allergiesName!),
                                            ),

                                          const SizedBox(height: 24),

                                          // 6. Related Products ("منتجات ذات الصلة")
                                          _RelatedProductsSection(
                                            itemController: itemController,
                                            inStorePage: widget.inStorePage,
                                          ),

                                          const SizedBox(height: 24),

                                          // 7. Special Offers ("عروض مميزة 🔥")
                                          _SpecialOffersSection(
                                            itemController: itemController,
                                            inStorePage: widget.inStorePage,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                        // 🚀 Modern Floating Bottom Action Bar
                        if (!ResponsiveHelper.isDesktop(context))
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: _buildFloatingCartBar(context, cartController, itemController, stock, cart, cartModel, priceWithAddons),
                          ),
                      ],
                    )
                  : itemController.detailsError
                      ? Center(child: NoDataScreen(text: 'item_not_found'.tr))
                      : const Center(child: CircularProgressIndicator()),
            ),
          );
        },
      );
    });
  }

  // 🪄 Helper method for clean Chips (Nutrition/Allergies)
  Widget _buildInfoChipSection(BuildContext context, String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault)),
        const SizedBox(height: Dimensions.paddingSizeSmall),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((item) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).disabledColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                item,
                style: robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeExtraSmall,
                  color: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.7),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // 🚀 The Floating Action Bar UI
  Widget _buildFloatingCartBar(
      BuildContext context, CartController cartController, ItemController itemController, 
      int? stock, OnlineCart? cart, CartModel? cartModel, double priceWithAddons) {
    
    bool isOutOfStock = (Get.find<SplashController>().configModel?.moduleConfig?.module?.stock ?? false) && (stock ?? 0) <= 0;

    return Container(
      margin: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          // Quantity Pill
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                _buildModernIconButton(
                  context,
                  icon: Icons.remove,
                  onTap: cartController.isLoading ? null : () {
                    if (itemController.cartIndex != -1 && itemController.cartIndex < cartController.cartList.length) {
                      if ((cartController.cartList[itemController.cartIndex].quantity ?? 0) > 1) {
                        cartController.setQuantity(false, itemController.cartIndex, stock, cartController.cartList[itemController.cartIndex].quantityLimit);
                      }
                    } else {
                      if ((itemController.quantity ?? 1) > 1) {
                        itemController.setQuantity(false, stock, itemController.item?.quantityLimit);
                      }
                    }
                  },
                ),
                SizedBox(
                  width: 30,
                  child: Center(
                    child: Text(
                      (itemController.cartIndex != -1 && itemController.cartIndex < cartController.cartList.length)
                          ? cartController.cartList[itemController.cartIndex].quantity.toString()
                          : (itemController.quantity ?? 1).toString(),
                      style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                    ),
                  ),
                ),
                _buildModernIconButton(
                  context,
                  icon: Icons.add,
                  color: Theme.of(context).primaryColor,
                  onTap: cartController.isLoading ? null : () {
                    if (itemController.cartIndex != -1 && itemController.cartIndex < cartController.cartList.length) {
                      cartController.setQuantity(true, itemController.cartIndex, stock, cartController.cartList[itemController.cartIndex].quantityLimit);
                    } else {
                      itemController.setQuantity(true, stock, itemController.item?.quantityLimit);
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          
          // The Main "Add to Cart" Button
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: (cartController.isLoading || cartController.isItemAdding(widget.item?.id) || ((Get.find<SplashController>().configModel?.moduleConfig?.module?.stock ?? false) && (stock ?? 0) <= 0)) ? null : (!(Get.find<SplashController>().configModel?.moduleConfig?.module?.stock ?? false) || (stock ?? 0) > 0)
                  ? () async {
                      if (!(Get.find<SplashController>().configModel?.moduleConfig?.module?.stock ?? false) || (stock ?? 0) > 0) {
                        if (itemController.item?.availableDateStarts != null) {
                          Get.toNamed(
                              RouteHelper.getCheckoutRoute('campaign'),
                              arguments: CheckoutScreen(
                                storeId: null,
                                fromCart: false,
                                cartList: [cartModel],
                              ));
                        } else {
                          if (cartController.existAnotherStoreItem(
                              cartModel?.item?.storeId,
                              Get.find<SplashController>().module == null
                                  ? Get.find<SplashController>().cacheModule?.id
                                  : Get.find<SplashController>().module?.id)) {
                            Get.dialog(
                                ConfirmationDialog(
                                  icon: Images.warning,
                                  title: 'are_you_sure_to_reset'.tr,
                                  description: (Get.find<SplashController>().configModel?.moduleConfig?.module?.showRestaurantText ?? false)
                                      ? 'if_you_continue'.tr
                                      : 'if_you_continue_without_another_store'.tr,
                                  onYesPressed: () {
                                    Get.back();
                                    cartController.clearCartOnline().then((success) async {
                                      if (success) {
                                        await cartController.addToCartOnline(cart!, storeId: widget.item?.storeId ?? cart.storeId);
                                        itemController.setExistInCart(widget.item, null);
                                        showCartSnackBar(success ? 'item_added_to_cart'.tr : 'failed_to_add_to_cart'.tr, isError: false);
                                      }
                                    });
                                  },
                                ),
                                barrierDismissible: false);
                          } else {
                            if (itemController.cartIndex == -1) {
                              await cartController.addToCartOnline(cart!, storeId: widget.item?.storeId ?? cart.storeId).then((success) {
                                if (success) {
                                  itemController.setExistInCart(widget.item, null);
                                  showCartSnackBar(success ? 'item_added_to_cart'.tr : 'failed_to_add_to_cart'.tr, isError: false);
                                  _key.currentState?.shake();
                                }
                              });
                            } else {
                              await cartController.updateCartOnline(cart!, storeId: widget.item?.storeId ?? cart.storeId).then((success) {
                                if (success) {
                                  showCartSnackBar(success ? 'item_added_to_cart'.tr : 'failed_to_add_to_cart'.tr, isError: false);
                                  _key.currentState?.shake();
                                }
                              });
                            }
                            if (widget.item != null) {
                              FirebaseAnalytics.instance.logEvent(
                                name: 'add_to_cart',
                                parameters: {
                                  'currency': 'EGP',
                                  'value': widget.item!.price ?? 0.0,
                                  'items': [
                                    {
                                      'item_id': widget.item!.id.toString(),
                                      'item_name': widget.item!.name ?? '',
                                      'price': widget.item!.price ?? 0.0,
                                      'quantity': widget.item!.quantityLimit ?? 1,
                                      'item_category': widget.item!.storeName ?? '',
                                    }
                                  ]
                                },
                              );
                            }
                          }
                        }
                      }
                    }
                  : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 50,
                decoration: BoxDecoration(
                  color: (!(Get.find<SplashController>().configModel?.moduleConfig?.module?.stock ?? false) || (stock ?? 0) > 0)
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).disabledColor,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: (!isOutOfStock) ? [
                    BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))
                  ] : [],
                ),
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                child: cartController.isLoading
                    ? const Center(
                        child: SizedBox(
                          height: 24, width: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        ))
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              isOutOfStock
                                  ? 'out_of_stock'.tr
                                  : itemController.item?.availableDateStarts != null
                                      ? 'order_now'.tr
                                      : (itemController.cartIndex != -1 && itemController.cartIndex < cartController.cartList.length)
                                          ? 'update_in_cart'.tr
                                          : 'add_to_cart'.tr,
                              style: robotoMedium.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeLarge),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              PriceConverter.convertPrice((itemController.cartIndex != -1 && itemController.cartIndex < cartController.cartList.length)
                                  ? _getItemDetailsDiscountPrice(cart: cartController.cartList[itemController.cartIndex])
                                  : priceWithAddons),
                              style: robotoBold.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeDefault),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernIconButton(BuildContext context, {required IconData icon, required void Function()? onTap, Color? color}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(icon, color: color ?? Theme.of(context).disabledColor, size: 24),
      ),
    );
  }

  List<int?> _getSelectedAddonIds({required List<AddOn> addOnIdList}) {
    List<int?> listOfAddOnId = [];
    for (var addOn in addOnIdList) {
      listOfAddOnId.add(addOn.id);
    }
    return listOfAddOnId;
  }

  List<int?> _getSelectedAddonQtnList({required List<AddOn> addOnIdList}) {
    List<int?> listOfAddOnQty = [];
    for (var addOn in addOnIdList) {
      listOfAddOnQty.add(addOn.quantity);
    }
    return listOfAddOnQty;
  }

  double _getItemDetailsDiscountPrice({required CartModel cart}) {
    double discountedPrice = 0;
    double? discount = (cart.item?.storeDiscount ?? 0) == 0 ? cart.item?.discount : cart.item?.storeDiscount;
    String? discountType = ((cart.item?.storeDiscount ?? 0) == 0) ? cart.item?.discountType : 'percent';
    String variationType = cart.variation != null && cart.variation!.isNotEmpty ? (cart.variation![0].type ?? '') : '';

    if (cart.variation != null && cart.variation!.isNotEmpty && cart.item?.variations != null) {
      for (Variation variation in cart.item!.variations!) {
        if (variation.type == variationType) {
          discountedPrice = ((PriceConverter.convertWithDiscount(variation.price ?? 0, discount, discountType) ?? variation.price ?? 0) * (cart.quantity ?? 1));
          break;
        }
      }
    } else {
      discountedPrice = ((PriceConverter.convertWithDiscount(cart.item?.price ?? 0, discount, discountType) ?? cart.item?.price ?? 0) * (cart.quantity ?? 1));
    }
    return discountedPrice;
  }
}

class _RelatedProductsSection extends StatelessWidget {
  final ItemController itemController;
  final bool inStorePage;

  const _RelatedProductsSection({required this.itemController, required this.inStorePage});

  @override
  Widget build(BuildContext context) {
    final List<Item>? relatedList = itemController.relatedItemList;

    if (relatedList != null && relatedList.isEmpty) {
      return const SizedBox();
    }

    final String title = ('related_products'.tr == 'related_products') ? 'منتجات ذات الصلة' : 'related_products'.tr;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: robotoBold.copyWith(
            fontSize: Dimensions.fontSizeLarge,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 12),
        if (relatedList == null)
          const _HorizontalItemShimmer()
        else
          SizedBox(
            height: 245,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: relatedList.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) => ItemDetailsRelatedCardWidget(
                item: relatedList[index],
                inStorePage: inStorePage,
              ),
            ),
          ),
      ],
    );
  }
}

class _SpecialOffersSection extends StatelessWidget {
  final ItemController itemController;
  final bool inStorePage;

  const _SpecialOffersSection({required this.itemController, required this.inStorePage});

  @override
  Widget build(BuildContext context) {
    final List<Item>? discountedList = itemController.discountedItemList;

    if (discountedList != null && discountedList.isEmpty) {
      return const SizedBox();
    }

    final int itemCount = discountedList == null
        ? 4
        : (discountedList.length > 10 ? 10 : discountedList.length);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  'special_offer'.tr,
                  style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeLarge,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(width: 6),
                const Text('🔥', style: TextStyle(fontSize: 18)),
              ],
            ),
            InkWell(
              onTap: () => Get.toNamed(RouteHelper.getPopularItemRoute(false, true)),
              child: Row(
                children: [
                  Text(
                    'see_all'.tr,
                    style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(width: 3),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 11,
                    color: Theme.of(context).primaryColor,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (discountedList == null)
          const _HorizontalItemShimmer()
        else
          SizedBox(
            height: 245,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: itemCount,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) => ItemDetailsRelatedCardWidget(
                item: discountedList[index],
                inStorePage: inStorePage,
              ),
            ),
          ),
      ],
    );
  }
}

class _HorizontalItemShimmer extends StatelessWidget {
  const _HorizontalItemShimmer();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 245,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return Container(
            width: 160,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Theme.of(context).disabledColor.withOpacity(0.1)),
            ),
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(height: 18, width: 18, decoration: BoxDecoration(color: Colors.grey[200], shape: BoxShape.circle)),
                    Container(height: 14, width: 36, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(6))),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Center(
                    child: Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                Container(height: 28, width: 28, decoration: BoxDecoration(color: Colors.grey[200], shape: BoxShape.circle)),
                const SizedBox(height: 6),
                Container(height: 12, width: 120, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(4))),
                const SizedBox(height: 4),
                Container(height: 12, width: 80, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(4))),
                const SizedBox(height: 6),
                Container(height: 14, width: 70, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(4))),
              ],
            ),
          );
        },
      ),
    );
  }
}

class QuantityButton extends StatelessWidget {
  final bool isIncrement;
  final int? quantity;
  final bool isCartWidget;
  final int? stock;
  final bool isExistInCart;
  final int cartIndex;
  final int? quantityLimit;
  final CartController cartController;

  const QuantityButton({super.key,
    required this.isIncrement, required this.quantity, required this.stock, required this.isExistInCart, required this.cartIndex,
    this.isCartWidget = false, this.quantityLimit, required this.cartController,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: cartController.isLoading ? null : () {
        if (isExistInCart) {
          if (!isIncrement && quantity! > 1) {
            Get.find<CartController>().setQuantity(false, cartIndex, stock, quantityLimit);
          } else if (isIncrement && quantity! > 0) {
            if (quantity! < stock! || !(Get.find<SplashController>().configModel?.moduleConfig?.module?.stock ?? false)) {
              Get.find<CartController>().setQuantity(true, cartIndex, stock, quantityLimit);
            } else {
              showCustomSnackBar('out_of_stock'.tr);
            }
          }
        } else {
          if (!isIncrement && quantity! > 1) {
            Get.find<ItemController>().setQuantity(false, stock, quantityLimit);
          } else if (isIncrement && quantity! > 0) {
            if (quantity! < stock! || !(Get.find<SplashController>().configModel?.moduleConfig?.module?.stock ?? false)) {
              Get.find<ItemController>().setQuantity(true, stock, quantityLimit);
            } else {
              showCustomSnackBar('out_of_stock'.tr);
            }
          }
        }
      },
      child: Container(
        height: 30,
        width: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: (quantity! == 1 && !isIncrement) || cartController.isLoading
              ? Theme.of(context).disabledColor
              : Theme.of(context).primaryColor,
        ),
        child: Center(
          child: Icon(
            isIncrement ? Icons.add : Icons.remove,
            color: isIncrement ? Colors.white : (quantity! == 1 ? Colors.black : Colors.white),
            size: isCartWidget ? 26 : 20,
          ),
        ),
      ),
    );
  }
}

class _ItemPriceWidget extends StatelessWidget {
  final double? price;
  final double priceWithDiscount;
  final double? discount;
  final String? discountType;
  final String? unitType;

  const _ItemPriceWidget({
    required this.price, required this.priceWithDiscount, required this.discount, required this.discountType, this.unitType,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasDiscount = (discount ?? 0) > 0 && price != null && price! > priceWithDiscount;

    return Container(
      margin: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Current Price + Unit (e.g. 40.37 ج.م / كجم)
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                PriceConverter.convertPrice(priceWithDiscount),
                style: robotoBold.copyWith(
                  fontSize: 22,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              if (unitType != null && unitType!.trim().isNotEmpty) ...[
                const SizedBox(width: 4),
                Text(
                  '/ ${unitType!.trim()}',
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context).disabledColor,
                  ),
                ),
              ],
            ],
          ),

          // Strikethrough Old Price + Discount Badge
          if (hasDiscount)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  PriceConverter.convertPrice(price),
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context).disabledColor,
                    decoration: TextDecoration.lineThrough,
                    decorationColor: Theme.of(context).disabledColor,
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF4B4B),
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  ),
                  child: Text(
                    discountType == 'percent'
                        ? '-$discount%'
                        : '-${PriceConverter.convertPrice(discount)}',
                    style: robotoBold.copyWith(
                      color: Colors.white,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}