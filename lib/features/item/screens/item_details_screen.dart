import 'dart:convert';
import 'package:Oxygen_Mart/helper/facebook_pixel_helper.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Oxygen_Mart/common/widgets/cart_snackbar.dart';
import 'package:Oxygen_Mart/common/widgets/confirmation_dialog.dart';
import 'package:Oxygen_Mart/common/widgets/custom_app_bar.dart';
import 'package:Oxygen_Mart/common/widgets/custom_button.dart';
import 'package:Oxygen_Mart/common/widgets/custom_snackbar.dart';
import 'package:Oxygen_Mart/common/widgets/menu_drawer.dart';
import 'package:Oxygen_Mart/features/cart/controllers/cart_controller.dart';
import 'package:Oxygen_Mart/features/cart/domain/models/cart_model.dart';
import 'package:Oxygen_Mart/features/checkout/domain/models/place_order_body_model.dart';
import 'package:Oxygen_Mart/features/checkout/screens/checkout_screen.dart';
import 'package:Oxygen_Mart/features/item/controllers/item_controller.dart';
import 'package:Oxygen_Mart/features/item/domain/models/item_model.dart';
import 'package:Oxygen_Mart/features/item/widgets/details_app_bar_widget.dart';
import 'package:Oxygen_Mart/features/item/widgets/details_web_view_widget.dart';
import 'package:Oxygen_Mart/features/item/widgets/item_image_view_widget.dart';
import 'package:Oxygen_Mart/features/item/widgets/item_title_view_widget.dart';
import 'package:Oxygen_Mart/features/splash/controllers/splash_controller.dart';
import 'package:Oxygen_Mart/helper/price_converter.dart';
import 'package:Oxygen_Mart/helper/responsive_helper.dart';
import 'package:Oxygen_Mart/helper/route_helper.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/images.dart';
import 'package:Oxygen_Mart/util/styles.dart';
import 'package:Oxygen_Mart/features/home/widgets/views/best_reviewed_item_view.dart';
import 'package:universal_html/js.dart' as js;

class ItemDetailsScreen extends StatefulWidget {
  final Item? item;
  final bool inStorePage;
  final bool? isCampaign;

  const ItemDetailsScreen({
    super.key,
    required this.item,
    required this.inStorePage,
    this.isCampaign,
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
    Get.find<ItemController>().getProductDetails(widget.item!);
    Get.find<ItemController>().setSelect(0, false);

  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CartController>(builder: (cartController) {
      return GetBuilder<ItemController>(
        builder: (itemController) {
          int? stock = 0;
          CartModel? cartModel;
          OnlineCart? cart;
          double priceWithAddons = 0;
          int? cartId = cartController.getCartId(itemController.cartIndex);

          if (itemController.item != null && itemController.variationIndex != null) {
            List<String> variationList = [];
            for (int index = 0; index < itemController.item!.choiceOptions!.length; index++) {
              variationList.add(itemController.item!.choiceOptions![index]
                  .options![itemController.variationIndex![index]]
                  .replaceAll(' ', ''));
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

            double? price = itemController.item!.price;
            Variation? variation;
            stock = itemController.item!.stock ?? 0;
            for (Variation v in itemController.item!.variations!) {
              if (v.type == variationType) {
                price = v.price;
                variation = v;
                stock = v.stock;
                break;
              }
            }

            double? discount = (itemController.item!.availableDateStarts != null || itemController.item!.storeDiscount == 0)
                ? itemController.item!.discount
                : itemController.item!.storeDiscount;
            String? discountType = (itemController.item!.availableDateStarts != null || itemController.item!.storeDiscount == 0)
                ? itemController.item!.discountType
                : 'percent';
            double priceWithDiscount = PriceConverter.convertWithDiscount(price, discount, discountType)!;
            double priceWithQuantity = priceWithDiscount * itemController.quantity!;
            
            double addonsCost = 0;
            List<AddOn> addOnIdList = [];
            List<AddOns> addOnsList = [];
            for (int index = 0; index < itemController.item!.addOns!.length; index++) {
              if (itemController.addOnActiveList[index]) {
                addonsCost = addonsCost + (itemController.item!.addOns![index].price! * itemController.addOnQtyList[index]!);
                addOnIdList.add(AddOn(id: itemController.item!.addOns![index].id, quantity: itemController.addOnQtyList[index]));
                addOnsList.add(itemController.item!.addOns![index]);
              }
            }

            cartModel = CartModel(
                null, price, priceWithDiscount, variation != null ? [variation] : [], [],
                (price! - PriceConverter.convertWithDiscount(price, discount, discountType)!),
                itemController.quantity, addOnIdList, addOnsList, itemController.item!.availableDateStarts != null,
                stock, itemController.item, itemController.item?.quantityLimit);

            List<int?> listOfAddOnId = _getSelectedAddonIds(addOnIdList: addOnIdList);
            List<int?> listOfAddOnQty = _getSelectedAddonQtnList(addOnIdList: addOnIdList);

            cart = OnlineCart(
                cartId, widget.item!.id, null, priceWithDiscount.toString(), '', variation != null ? [variation] : [],
                null, itemController.cartIndex != -1 ? cartController.cartList[itemController.cartIndex].quantity : itemController.quantity,
                listOfAddOnId, addOnsList, listOfAddOnQty, 'Item');
                
            priceWithAddons = priceWithQuantity + (Get.find<SplashController>().configModel!.moduleConfig!.module!.addOn! ? addonsCost : 0);
          }

          return Scaffold(
            key: _globalKey,
            backgroundColor: Theme.of(context).cardColor,
            endDrawer: const MenuDrawer(),
            endDrawerEnableOpenDragGesture: false,
            appBar: ResponsiveHelper.isDesktop(context)
                ? const CustomAppBar(title: '')
                : DetailsAppBarWidget(key: _key),
            // نستخدم Stack عشان نخلي الـ Bottom Bar يعوم فوق المحتوى
            body: SafeArea(
              child: (itemController.item != null)
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
                                  left: Dimensions.paddingSizeDefault,
                                  right: Dimensions.paddingSizeDefault,
                                  top: Dimensions.paddingSizeSmall,
                                  bottom: 100, // مساحة للـ floating bar
                                ),
                                physics: const BouncingScrollPhysics(),
                                child: Center(
                                  child: SizedBox(
                                    width: Dimensions.webMaxWidth,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Item Image
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                                          child: ItemImageViewWidget(
                                            item: itemController.item,
                                            isCampaign: widget.isCampaign ?? false,
                                          ),
                                        ),
                                        const SizedBox(height: 24),

                                        // Title & Info
                                        ItemTitleViewWidget(
                                          item: itemController.item,
                                          inStorePage: widget.inStorePage,
                                          isCampaign: itemController.item!.availableDateStarts != null,
                                          inStock: (Get.find<SplashController>().configModel!.moduleConfig!.module!.stock! && stock! <= 0),
                                        ),
                                        const SizedBox(height: 20),
                                        
                                        // Modern Divider
                                        Container(
                                          height: 1,
                                          width: double.infinity,
                                          color: Theme.of(context).disabledColor.withOpacity(0.2),
                                        ),
                                        const SizedBox(height: 20),

                                        // 🎨 Modern Variations (Animated Wrap)
                                        ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: itemController.item!.choiceOptions!.length,
                                          physics: const NeverScrollableScrollPhysics(),
                                          itemBuilder: (context, index) {
                                            return Padding(
                                              padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeLarge),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    itemController.item!.choiceOptions![index].title!,
                                                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
                                                  ),
                                                  const SizedBox(height: Dimensions.paddingSizeSmall),
                                                  Wrap(
                                                    spacing: 10,
                                                    runSpacing: 10,
                                                    children: List.generate(
                                                      itemController.item!.choiceOptions![index].options!.length,
                                                      (i) {
                                                        bool isSelected = itemController.variationIndex![index] == i;
                                                        return InkWell(
                                                          borderRadius: BorderRadius.circular(20),
                                                          onTap: () {
                                                            itemController.setCartVariationIndex(index, i, itemController.item);
                                                          },
                                                          child: AnimatedContainer(
                                                            duration: const Duration(milliseconds: 200),
                                                            curve: Curves.easeInOut,
                                                            padding: const EdgeInsets.symmetric(
                                                              horizontal: Dimensions.paddingSizeLarge,
                                                              vertical: Dimensions.paddingSizeSmall,
                                                            ),
                                                            decoration: BoxDecoration(
                                                              color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
                                                              borderRadius: BorderRadius.circular(30), // Pill Shape
                                                              border: Border.all(
                                                                color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).disabledColor.withOpacity(0.3),
                                                                width: 1.5,
                                                              ),
                                                              boxShadow: isSelected ? [
                                                                BoxShadow(
                                                                  color: Theme.of(context).primaryColor.withOpacity(0.2),
                                                                  blurRadius: 8,
                                                                  offset: const Offset(0, 4),
                                                                )
                                                              ] : [],
                                                            ),
                                                            child: Text(
                                                              itemController.item!.choiceOptions![index].options![i].trim(),
                                                              style: robotoMedium.copyWith(
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

                                        // Prescription Alert
                                        if (itemController.item!.isPrescriptionRequired!)
                                          Container(
                                            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                                            margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeLarge),
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

                                        // Description Section
                                        if (itemController.item!.description != null && itemController.item!.description!.isNotEmpty)
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('description'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                                              const SizedBox(height: Dimensions.paddingSizeSmall),
                                              Text(
                                                itemController.item!.description!,
                                                style: robotoRegular.copyWith(height: 1.5, color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.8)),
                                              ),
                                              const SizedBox(height: Dimensions.paddingSizeLarge),
                                            ],
                                          ),

                                        // Best Reviews Section
                                        if (Get.find<SplashController>().module?.moduleType == 'grocery')
                                          const BestReviewItemView(),
                                        const SizedBox(height: Dimensions.paddingSizeLarge),

                                        // Nutrition Details
                                        if (widget.item!.nutritionsName != null && widget.item!.nutritionsName!.isNotEmpty)
                                          _buildInfoChipSection(context, 'nutrition_details'.tr, widget.item!.nutritionsName!),

                                        // Allergies Details
                                        if (widget.item!.allergiesName != null && widget.item!.allergiesName!.isNotEmpty)
                                          _buildInfoChipSection(context, 'allergic_ingredients'.tr, widget.item!.allergiesName!),
                                          
                                        const SizedBox(height: 40), // Extra space for safe scrolling
                                      ],
                                    ),
                                  ),
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
        Text(title, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
        const SizedBox(height: Dimensions.paddingSizeSmall),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((item) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).disabledColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                item,
                style: robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.7),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: Dimensions.paddingSizeLarge),
      ],
    );
  }

  // 🚀 The Floating Action Bar UI
  Widget _buildFloatingCartBar(
      BuildContext context, CartController cartController, ItemController itemController, 
      int? stock, OnlineCart? cart, CartModel? cartModel, double priceWithAddons) {
    
    bool isOutOfStock = Get.find<SplashController>().configModel!.moduleConfig!.module!.stock! && stock! <= 0;

    return Container(
      margin: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(40), // Full Pill Shape
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
          // Elegant Quantity Pill
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
                    if (itemController.cartIndex != -1) {
                      if (cartController.cartList[itemController.cartIndex].quantity! > 1) {
                        cartController.setQuantity(false, itemController.cartIndex, stock, cartController.cartList[itemController.cartIndex].quantityLimit);
                      }
                    } else {
                      if (itemController.quantity! > 1) {
                        itemController.setQuantity(false, stock, itemController.item!.quantityLimit);
                      }
                    }
                  },
                ),
                SizedBox(
                  width: 30,
                  child: Center(
                    child: Text(
                      itemController.cartIndex != -1
                          ? cartController.cartList[itemController.cartIndex].quantity.toString()
                          : itemController.quantity.toString(),
                      style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                    ),
                  ),
                ),
                _buildModernIconButton(
                  context,
                  icon: Icons.add,
                  color: Theme.of(context).primaryColor,
                  onTap: cartController.isLoading ? null : () {
                    if (itemController.cartIndex != -1) {
                      cartController.setQuantity(true, itemController.cartIndex, stock, cartController.cartList[itemController.cartIndex].quantityLimit);
                    } else {
                      itemController.setQuantity(true, stock, itemController.item!.quantityLimit);
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
              onTap: (!Get.find<SplashController>().configModel!.moduleConfig!.module!.stock! || stock! > 0)
                  ? () async {
                      if (!Get.find<SplashController>().configModel!.moduleConfig!.module!.stock! || stock! > 0) {
                        if (itemController.item!.availableDateStarts != null) {
                          Get.toNamed(
                              RouteHelper.getCheckoutRoute('campaign'),
                              arguments: CheckoutScreen(
                                storeId: null,
                                fromCart: false,
                                cartList: [cartModel],
                              ));
                        } else {
                          if (cartController.existAnotherStoreItem(
                              cartModel!.item!.storeId,
                              Get.find<SplashController>().module == null
                                  ? Get.find<SplashController>().cacheModule!.id
                                  : Get.find<SplashController>().module!.id)) {
                            Get.dialog(
                                ConfirmationDialog(
                                  icon: Images.warning,
                                  title: 'are_you_sure_to_reset'.tr,
                                  description: Get.find<SplashController>().configModel!.moduleConfig!.module!.showRestaurantText!
                                      ? 'if_you_continue'.tr
                                      : 'if_you_continue_without_another_store'.tr,
                                  onYesPressed: () {
                                    Get.back();
                                    cartController.clearCartOnline().then((success) async {
                                      if (success) {
                                        await cartController.addToCartOnline(cart!);
                                        itemController.setExistInCart(widget.item, null);
                                        showCartSnackBar(success ? 'item_added_to_cart'.tr : 'failed_to_add_to_cart'.tr, isError: false);
                                      }
                                    });
                                  },
                                ),
                                barrierDismissible: false);
                          } else {
                            if (itemController.cartIndex == -1) {
                              await cartController.addToCartOnline(cart!).then((success) {
                                if (success) {
                                  itemController.setExistInCart(widget.item, null);
                                  showCartSnackBar(success ? 'item_added_to_cart'.tr : 'failed_to_add_to_cart'.tr, isError: false);
                                  _key.currentState!.shake();
                                }
                              });
                            } else {
                              await cartController.updateCartOnline(cart!).then((success) {
                                if (success) {
                                  showCartSnackBar(success ? 'item_added_to_cart'.tr : 'failed_to_add_to_cart'.tr, isError: false);
                                  _key.currentState!.shake();
                                }
                              });
                            }
                            if (GetPlatform.isIOS || !GetPlatform.isWeb) {
                              _faceBookEvent(widget.item!);
                            }
                            FirebaseAnalytics.instance.logEvent(
                              name: 'add_to_cart',
                              parameters: {
                                'currency': 'EGP',
                                'value': widget.item!.price!,
                                'items': [
                                  {
                                    'item_id': widget.item!.id.toString(),
                                    'item_name': widget.item!.name,
                                    'price': widget.item!.price!,
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
                  : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 50,
                decoration: BoxDecoration(
                  color: (!Get.find<SplashController>().configModel!.moduleConfig!.module!.stock! || stock! > 0)
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
                                  : itemController.item!.availableDateStarts != null
                                      ? 'order_now'.tr
                                      : itemController.cartIndex != -1
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
                              PriceConverter.convertPrice(itemController.cartIndex != -1
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

  // --- Helpers Below Remain Unchanged ---
  
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
    double? discount = cart.item!.storeDiscount == 0 ? cart.item!.discount! : cart.item!.storeDiscount!;
    String? discountType = (cart.item!.storeDiscount == 0) ? cart.item!.discountType : 'percent';
    String variationType = cart.variation != null && cart.variation!.isNotEmpty ? cart.variation![0].type! : '';

    if (cart.variation != null && cart.variation!.isNotEmpty) {
      for (Variation variation in cart.item!.variations!) {
        if (variation.type == variationType) {
          discountedPrice = (PriceConverter.convertWithDiscount(variation.price!, discount, discountType)! * cart.quantity!);
          break;
        }
      }
    } else {
      discountedPrice = (PriceConverter.convertWithDiscount(cart.item!.price!, discount, discountType)! * cart.quantity!);
    }
    return discountedPrice;
  }
}

void _faceBookEvent(Item item) {
}

void fbqAddToCart(Item item) {
  js.context.callMethod('fbq', [
    'track',
    'AddToCart',
    {
      "content_ids": [item.id.toString()],
      "content_type": "product",
      "content_name": item.name,
      "value": item.price?.toDouble() ?? 0.0,
      "currency": "EGP",
    }
  ]);
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

  const QuantityButton({
    super.key,
    required this.isIncrement,
    required this.quantity,
    required this.stock,
    required this.isExistInCart,
    required this.cartIndex,
    this.isCartWidget = false,
    this.quantityLimit,
    required this.cartController,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: cartController.isLoading
          ? null
          : () {
              if (isExistInCart) {
                if (!isIncrement && quantity! > 1) {
                  Get.find<CartController>()
                      .setQuantity(false, cartIndex, stock, quantityLimit);
                } else if (isIncrement && quantity! > 0) {
                  if (quantity! < stock! ||
                      !Get.find<SplashController>()
                          .configModel!
                          .moduleConfig!
                          .module!
                          .stock!) {
                    Get.find<CartController>()
                        .setQuantity(true, cartIndex, stock, quantityLimit);
                  } else {
                    showCustomSnackBar('out_of_stock'.tr);
                  }
                }
              } else {
                if (!isIncrement && quantity! > 1) {
                  Get.find<ItemController>()
                      .setQuantity(false, stock, quantityLimit);
                } else if (isIncrement && quantity! > 0) {
                  if (quantity! < stock! ||
                      !Get.find<SplashController>()
                          .configModel!
                          .moduleConfig!
                          .module!
                          .stock!) {
                    Get.find<ItemController>()
                        .setQuantity(true, stock, quantityLimit);
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
            color: isIncrement
                ? Colors.white
                : quantity! == 1
                    ? Colors.black
                    : Colors.white,
            size: isCartWidget ? 26 : 20,
          ),
        ),
      ),
    );
  }
}