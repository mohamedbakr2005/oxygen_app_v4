import 'dart:convert';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Oxygen_Mart/common/widgets/custom_image.dart';
import 'package:Oxygen_Mart/features/cart/controllers/cart_controller.dart';
import 'package:Oxygen_Mart/features/cart/domain/models/cart_model.dart';
import 'package:Oxygen_Mart/features/favourite/controllers/favourite_controller.dart';
import 'package:Oxygen_Mart/features/item/controllers/item_controller.dart';
import 'package:Oxygen_Mart/features/item/domain/models/item_model.dart';
import 'package:Oxygen_Mart/features/splash/controllers/splash_controller.dart';
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
  int _quantity = 1;

  void _increment() {
    if (_quantity < (widget.item.stock ?? 100)) {
      setState(() => _quantity++);
    }
  }

  void _decrement() {
    if (_quantity > 1) {
      setState(() => _quantity--);
    }
  }

  void _addToCart() {
    double price = widget.item.price!;
    double discount = widget.item.discount!;
    double discountPrice = PriceConverter.convertWithDiscount(
        price, discount, widget.item.discountType)!;

    CartModel cartModel = CartModel(
      null,
      price,
      discount,
      [],
      [],
      (price - discountPrice),
      _quantity,
      [],
      [],
      false,
      widget.item.stock,
      widget.item,
      widget.item.quantityLimit,
    );
    print(widget.item.quantityLimit);
    print(widget.item.price);
    print(widget.item.discount);
    print(widget.item.discountType);
    int cartIndex = Get.find<CartController>().isExistInCart(widget.item.id,
        Get.find<CartController>().cartVariant(widget.item.id!), false, null);
    if (cartIndex != -1) {
      Get.find<CartController>().setQuantity(
          true, cartIndex, widget.item.stock, widget.item.quantityLimit);
    } else {
      Get.find<CartController>().addToCart(cartModel, null);
    }

    showCustomSnackBar('item_added_to_cart'.tr, isError: false);
  }

  @override
  Widget build(BuildContext context) {
    bool isSoldOut = (widget.item.stock ?? 0) <= 0;

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
                  (widget.item.discount != null && widget.item.discount! > 0)
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
                                widget.item.discountType == 'percent'
                                    ? '${widget.item.discount!.toStringAsFixed(0)}% ${'discount'.tr}'
                                    : '${PriceConverter.convertPrice(widget.item.discount)} ${'discount'.tr}',
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
                    const SizedBox(height: 20),

                    // Bottom Action Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Price
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F9F4),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            PriceConverter.convertPrice(widget.item.price),
                            style: robotoBold.copyWith(
                                color: const Color(0xFF2EAA60), fontSize: 14),
                          ),
                        ),

                        // Quantity Selector (Neumorphic)
                        Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FBF9),
                            borderRadius: BorderRadius.circular(100),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3)),
                              const BoxShadow(
                                  color: Colors.white,
                                  blurRadius: 6,
                                  offset: Offset(-3, -3)),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                onTap: isSoldOut ? null : _decrement,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Icon(Icons.remove,
                                      color: Colors.grey.shade600, size: 16),
                                ),
                              ),
                              SizedBox(
                                width: 20,
                                child: Text("$_quantity",
                                    textAlign: TextAlign.center,
                                    style: robotoBold.copyWith(fontSize: 14)),
                              ),
                              InkWell(
                                onTap: isSoldOut ? null : _increment,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Icon(Icons.add,
                                      color: const Color(0xFF2EAA60), size: 16),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Add to Cart Button (Glossy Circular)
                        InkWell(
                          onTap: isSoldOut ? null : _addToCart,
                          child: Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: isSoldOut
                                    ? const LinearGradient(
                                        colors: [Colors.grey, Colors.grey])
                                    : const LinearGradient(
                                        colors: [
                                            Color(0xFF3FE281),
                                            Color(0xFF1B6E3A)
                                          ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight),
                                boxShadow: isSoldOut
                                    ? []
                                    : [
                                        BoxShadow(
                                            color: const Color(0xFF2EAA60)
                                                .withOpacity(0.4),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4)),
                                        BoxShadow(
                                            color:
                                                Colors.white.withOpacity(0.3),
                                            blurRadius: 4,
                                            spreadRadius: -2,
                                            offset: const Offset(0, -2))
                                      ]),
                            child: const Icon(Icons.add_shopping_cart,
                                color: Colors.white, size: 20),
                          ),
                        )
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
