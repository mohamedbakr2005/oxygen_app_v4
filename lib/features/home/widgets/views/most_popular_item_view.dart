import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Oxygen_Mart/common/widgets/custom_image.dart';
import 'package:Oxygen_Mart/features/cart/controllers/cart_controller.dart';
import 'package:Oxygen_Mart/features/favourite/controllers/favourite_controller.dart';
import 'package:Oxygen_Mart/features/item/controllers/item_controller.dart';
import 'package:Oxygen_Mart/features/item/domain/models/item_model.dart';
import 'package:Oxygen_Mart/features/location/controllers/location_controller.dart';
import 'package:Oxygen_Mart/features/splash/controllers/splash_controller.dart';
import 'package:Oxygen_Mart/helper/address_helper.dart';
import 'package:Oxygen_Mart/helper/auth_helper.dart';
import 'package:Oxygen_Mart/helper/price_converter.dart';
import 'package:Oxygen_Mart/helper/route_helper.dart';
import 'package:Oxygen_Mart/util/app_constants.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/styles.dart';
import 'package:Oxygen_Mart/common/widgets/custom_snackbar.dart';

class MostPopularItemView extends StatelessWidget {
  final bool isFood;
  final bool isShop;
  const MostPopularItemView(
      {super.key, required this.isFood, required this.isShop});

  @override
  Widget build(BuildContext context) {
    bool isShop = Get.find<SplashController>().module != null &&
        Get.find<SplashController>().module!.moduleType.toString() ==
            AppConstants.ecommerce;

    return Padding(
      padding:
          const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeLarge),
      child: GetBuilder<ItemController>(builder: (itemController) {
        List<Item>? itemList = itemController.popularItemList;
        final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

        if (itemList == null) return const ItemShimmerView(isPopularItem: true);
        if (itemList.isEmpty) return const SizedBox();

        analytics.logEvent(
          name: 'view_item_list',
          parameters: {
            'list_name':
                isShop ? 'most_popular_products' : 'most_popular_items',
            'items_count': itemList.length,
            'source': 'home_most_popular_section',
          },
        );

        return Column(
          children: [
            // Section Header
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Right (Title + Subtitle in RTL)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              "الأكثر رواجاً",
                              style: robotoBold.copyWith(
                                  fontSize: 24, color: const Color(0xFF1E2D24)),
                            ),
                            const SizedBox(width: 8),
                            const Text("🔥", style: TextStyle(fontSize: 24)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "منتجات يحبها عملاؤنا",
                          style: robotoRegular.copyWith(
                              fontSize: 14, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ),
                  // Left (View All Button)
                  InkWell(
                    onTap: () {
                      analytics.logEvent(
                          name: 'open_product_list',
                          parameters: {'source': 'most_popular_view_all'});
                      Get.toNamed(RouteHelper.getPopularItemRoute(true, false));
                    },
                    borderRadius: BorderRadius.circular(100),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                            color: const Color(0xFF2EAA60).withOpacity(0.2),
                            width: 1.5),
                        boxShadow: [
                          BoxShadow(
                              color: const Color(0xFF2EAA60).withOpacity(0.08),
                              blurRadius: 10,
                              offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "عرض الكل",
                            style: robotoMedium.copyWith(
                                color: const Color(0xFF2EAA60), fontSize: 14),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.arrow_back_ios_new,
                              color: Color(0xFF2EAA60), size: 12),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Product List
            SizedBox(
              height: 380, // Generous height for the detailed premium card
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeDefault),
                itemCount: itemList.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(
                        right: 16.0,
                        bottom:
                            20), // Spacing between cards and for bottom shadow
                    child: MostPopularItemCard(item: itemList[index]),
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}

class MostPopularItemCard extends StatefulWidget {
  final Item item;
  const MostPopularItemCard({super.key, required this.item});

  @override
  State<MostPopularItemCard> createState() => _MostPopularItemCardState();
}

class _MostPopularItemCardState extends State<MostPopularItemCard> {
  bool _isAdding = false;

  Future<void> _handleAddToCart(CartController cartController) async {
    if (_isAdding || cartController.isItemAdding(widget.item.id)) return;
    if (AddressHelper.getUserAddressFromSharedPref() == null) {
      Get.find<LocationController>()
          .navigateToLocationScreen('home', canRoute: true);
      return;
    }

    setState(() => _isAdding = true);
    try {
      await Get.find<ItemController>()
          .itemDirectlyAddToCart(widget.item, context);
    } finally {
      if (mounted) {
        setState(() => _isAdding = false);
      }
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
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    bool isSoldOut = (widget.item.stock ?? 0) <= 0;
    final double originalPrice = widget.item.price ?? 0;
    final double? effectiveDiscount =
        (widget.item.availableDateStarts != null ||
                (widget.item.storeDiscount ?? 0) == 0)
            ? widget.item.discount
            : widget.item.storeDiscount;
    final String? effectiveDiscountType =
        (widget.item.availableDateStarts != null ||
                (widget.item.storeDiscount ?? 0) == 0)
            ? widget.item.discountType
            : 'percent';
    final double discountedPrice = PriceConverter.convertWithDiscount(
          originalPrice,
          effectiveDiscount,
          effectiveDiscountType,
        ) ??
        originalPrice;
    final bool hasDiscount = effectiveDiscount != null &&
        effectiveDiscount > 0 &&
        discountedPrice < originalPrice;

    return Container(
      width: 260, // Wide enough to show off the image and bottom controls
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 24,
            spreadRadius: 2,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          children: [
            // TOP SECTION: Hero Image Area
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Circular Mint Backdrop
                  Container(
                    width: 180,
                    height: 180,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFFFFFFF),
                    ),
                  ),
                  // Floating leaves
                  Positioned(
                      top: 40,
                      right: 20,
                      child: Icon(Icons.eco,
                          color: const Color(0xFF3FE281).withOpacity(0.7),
                          size: 20)),
                  Positioned(
                      bottom: 50,
                      left: 20,
                      child: Icon(Icons.eco,
                          color: const Color(0xFF3FE281).withOpacity(0.7),
                          size: 24)),
                  // Product Image
                  InkWell(
                    onTap: () => Get.find<ItemController>()
                        .navigateToItemPage(widget.item, context),
                    child: Hero(
                      tag: 'popular_img_${widget.item.id}',
                      child: CustomImage(
                        image: '${widget.item.imageFullUrl}',
                        fit: BoxFit.contain,
                        width: 160,
                        height: 160,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Top Badges
            Positioned(
              top: 16,
              right: 16,
              left: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Discount Badge
                  (effectiveDiscount != null && effectiveDiscount > 0)
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF8B94), Color(0xFFFF4E5B)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.redAccent.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4)),
                            ],
                            border: Border.all(
                                color: Colors.white.withOpacity(0.6),
                                width: 1.5),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(0.3)),
                                child: const Icon(Icons.percent,
                                    color: Colors.white, size: 10),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                effectiveDiscountType == 'percent'
                                    ? '${effectiveDiscount.toStringAsFixed(0)}% ${'discount'.tr}'
                                    : '${PriceConverter.convertPrice(effectiveDiscount)} ${'discount'.tr}',
                                style: robotoBold.copyWith(
                                    color: Colors.white, fontSize: 11),
                              ),
                            ],
                          ))
                      : const SizedBox(),
                  // Wishlist Button
                  GetBuilder<FavouriteController>(
                      builder: (favouriteController) {
                    bool isWished = favouriteController.wishItemIdList
                        .contains(widget.item.id);
                    return InkWell(
                      onTap: () {
                        if (AuthHelper.isLoggedIn()) {
                          if (isWished) {
                            favouriteController.removeFromFavouriteList(
                                widget.item.id, false);
                          } else {
                            favouriteController
                                .addToFavouriteList(widget.item, null, false)
                                .then((value) {
                              if (GetPlatform.isAndroid || GetPlatform.isIOS) {
                              }
                              FirebaseAnalytics.instance.logEvent(
                                name: "add_to_wishlist",
                                parameters: {
                                  "item_id": widget.item.id.toString(),
                                  "item_name": widget.item.name ?? '',
                                  "item_category": (widget.item.categoryIds !=
                                              null &&
                                          widget.item.categoryIds!.isNotEmpty)
                                      ? widget.item.categoryIds![0].id
                                          .toString()
                                      : "General",
                                  "price": widget.item.price!.toDouble(),
                                  "currency": "EGP",
                                },
                              );
                            });
                          }
                        } else {
                          showCustomSnackBar('you_are_not_logged_in'.tr);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4)),
                            ]),
                        child: Icon(
                          isWished ? Icons.favorite : Icons.favorite_border,
                          color: const Color(0xFF2EAA60),
                          size: 20,
                        ),
                      ),
                    );
                  })
                ],
              ),
            ),

            // Wave overlay connecting image area to text area
            Positioned(
              top: 160,
              left: 0,
              right: 0,
              height: 40,
              child: CustomPaint(
                painter: _WavePainter(),
              ),
            ),

            // BOTTOM SECTION: Info & Actions
            Positioned(
              bottom: 0, left: 0, right: 0,
              top: 190, // Start right above the wave curve
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Product Title
                    Text(
                      widget.item.name ?? '',
                      style: robotoBold.copyWith(
                          fontSize: 20, color: const Color(0xFF1E2D24)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    // Subtitle
                    Text(
                      widget.item.storeName ?? "خبز طازج يومياً",
                      style: robotoRegular.copyWith(
                          fontSize: 13, color: Colors.grey.shade500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 14),

                    // Bottom Action Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Price (discounted price + strikethrough original price when discounted)
                        Flexible(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 9, vertical: hasDiscount ? 5 : 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F9F4),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: AlignmentDirectional.centerStart,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    PriceConverter.convertPrice(
                                      hasDiscount
                                          ? discountedPrice
                                          : originalPrice,
                                    ),
                                    style: robotoBold.copyWith(
                                      color: const Color(0xFF2EAA60),
                                      fontSize: 14,
                                      height: 1.15,
                                    ),
                                    maxLines: 1,
                                  ),
                                  if (hasDiscount) ...[
                                    const SizedBox(height: 1),
                                    Text(
                                      PriceConverter.convertPrice(
                                          originalPrice),
                                      style: robotoRegular.copyWith(
                                        color: Colors.grey.shade500,
                                        fontSize: 11,
                                        height: 1.1,
                                        decoration: TextDecoration.lineThrough,
                                        decorationColor: Colors.grey.shade500,
                                        decorationThickness: 1.6,
                                      ),
                                      maxLines: 1,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Cart Action: Add button when not in cart -> replaces with live - qty + stepper once added
                        GetBuilder<CartController>(builder: (cartController) {
                          final int? itemId = widget.item.id;
                          final int cartQty = itemId != null
                              ? cartController.cartQuantity(itemId)
                              : 0;
                          final int cartIndex = itemId != null
                              ? cartController.isExistInCart(
                                  itemId,
                                  cartController.cartVariant(itemId),
                                  false,
                                  null,
                                )
                              : -1;
                          final bool isAddingNow =
                              _isAdding || cartController.isItemAdding(itemId);

                          return AnimatedSwitcher(
                            duration: const Duration(milliseconds: 220),
                            transitionBuilder: (child, animation) =>
                                ScaleTransition(
                              scale: animation,
                              child: FadeTransition(
                                opacity: animation,
                                child: child,
                              ),
                            ),
                            child: cartQty > 0
                                ? Container(
                                    key: const ValueKey('cart_stepper'),
                                    height: 40,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(100),
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF3FE281),
                                          Color(0xFF1B6E3A),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF2EAA60)
                                              .withValues(alpha: 0.35),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        InkWell(
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          onTap: cartController.isLoading
                                              ? null
                                              : () {
                                                  if (cartIndex != -1 &&
                                                      cartIndex <
                                                          cartController
                                                              .cartList
                                                              .length) {
                                                    final cartItem =
                                                        cartController
                                                            .cartList[cartIndex];
                                                    if ((cartItem.quantity ??
                                                            1) >
                                                        1) {
                                                      cartController
                                                          .changeQuantity(
                                                        false,
                                                        cartIndex,
                                                        cartItem.stock,
                                                        cartItem
                                                            .item?.quantityLimit,
                                                      );
                                                    } else {
                                                      cartController
                                                          .removeFromCart(
                                                        cartIndex,
                                                        item: widget.item,
                                                      );
                                                    }
                                                  }
                                                },
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 8),
                                            child: Icon(
                                              cartQty == 1
                                                  ? Icons.delete_outline_rounded
                                                  : Icons.remove_rounded,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 24,
                                          child: Text(
                                            '$cartQty',
                                            textAlign: TextAlign.center,
                                            style: robotoBold.copyWith(
                                              fontSize: 15,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          onTap: cartController.isLoading
                                              ? null
                                              : () {
                                                  if (cartIndex != -1 &&
                                                      cartIndex <
                                                          cartController
                                                              .cartList
                                                              .length) {
                                                    final cartItem =
                                                        cartController
                                                            .cartList[cartIndex];
                                                    cartController
                                                        .changeQuantity(
                                                      true,
                                                      cartIndex,
                                                      cartItem.stock,
                                                      cartItem
                                                          .item?.quantityLimit,
                                                    );
                                                  }
                                                },
                                          child: const Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 8),
                                            child: Icon(
                                              Icons.add_rounded,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : InkWell(
                                    key: const ValueKey('add_to_cart_btn'),
                                    borderRadius: BorderRadius.circular(100),
                                    onTap: (isSoldOut || isAddingNow)
                                        ? null
                                        : () =>
                                            _handleAddToCart(cartController),
                                    child: Container(
                                      width: 45,
                                      height: 45,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: isSoldOut
                                            ? const LinearGradient(colors: [
                                                Colors.grey,
                                                Colors.grey
                                              ])
                                            : const LinearGradient(
                                                colors: [
                                                  Color(0xFF3FE281),
                                                  Color(0xFF1B6E3A),
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                        boxShadow: isSoldOut
                                            ? []
                                            : [
                                                BoxShadow(
                                                  color:
                                                      const Color(0xFF2EAA60)
                                                          .withValues(
                                                              alpha: 0.4),
                                                  blurRadius: 10,
                                                  offset: const Offset(0, 4),
                                                ),
                                                BoxShadow(
                                                  color: Colors.white
                                                      .withValues(alpha: 0.3),
                                                  blurRadius: 4,
                                                  spreadRadius: -2,
                                                  offset: const Offset(0, -2),
                                                ),
                                              ],
                                      ),
                                      child: Center(
                                        child: isAddingNow
                                            ? const SizedBox(
                                                width: 18,
                                                height: 18,
                                                child:
                                                    CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2,
                                                ),
                                              )
                                            : const Icon(
                                                Icons.add_shopping_cart,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                      ),
                                    ),
                                  ),
                          );
                        }),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom painter to draw the white wave that transitions the image area to the text area
class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Fill paint
    final fillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Stroke paint for the green border
    final strokePaint = Paint()
      ..color = const Color(0xFF2EAA60).withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final path = Path();

    // Start slightly down on the left
    path.moveTo(0, size.height * 0.4);
    // Swoop down to the middle
    path.quadraticBezierTo(size.width * 0.25, size.height * 0.9,
        size.width * 0.5, size.height * 0.5);
    // Swoop up to the right
    path.quadraticBezierTo(
        size.width * 0.75, size.height * 0.1, size.width, size.height * 0.6);

    // Store the curve alone so we can draw the top border without drawing edges
    final curvePath = Path.from(path);

    // Draw to bottom corners to fill the rest with white
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    // Draw the solid white background
    canvas.drawPath(path, fillPaint);

    // Draw the green wave border on top
    canvas.drawPath(curvePath, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Keep a simple shimmer view fallback for loading states
class ItemShimmerView extends StatelessWidget {
  final bool isPopularItem;
  const ItemShimmerView({super.key, required this.isPopularItem});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(); // For brevity, reuse existing shimmer implementation if desired or blank
  }
}
