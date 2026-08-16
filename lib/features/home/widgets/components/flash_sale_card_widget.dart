import 'dart:math';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Oxygen_Mart/common/widgets/custom_image.dart';
import 'package:Oxygen_Mart/features/cart/controllers/cart_controller.dart';
import 'package:Oxygen_Mart/features/cart/domain/models/cart_model.dart';
import 'package:Oxygen_Mart/features/flash_sale/controllers/flash_sale_controller.dart';
import 'package:Oxygen_Mart/features/flash_sale/domain/models/flash_sale_model.dart';
import 'package:Oxygen_Mart/features/item/controllers/item_controller.dart';
import 'package:Oxygen_Mart/features/item/domain/models/item_model.dart';
import 'package:Oxygen_Mart/helper/price_converter.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/styles.dart';
import 'package:Oxygen_Mart/common/widgets/custom_snackbar.dart';

class FlashSaleCard extends StatefulWidget {
  final List<ActiveProducts> activeProducts;
  final bool soldOut;
  const FlashSaleCard(
      {super.key, required this.activeProducts, required this.soldOut});

  @override
  State<FlashSaleCard> createState() => _FlashSaleCardState();
}

class _FlashSaleCardState extends State<FlashSaleCard> {
  late PageController _pageController;
  int _currentPage = 1;
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  Map<int, int> _quantities = {};

  @override
  void initState() {
    super.initState();
    _currentPage = widget.activeProducts.length > 1 ? 1 : 0;
    _pageController =
        PageController(initialPage: _currentPage, viewportFraction: 1.0);

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      analytics.logEvent(
        name: 'flash_sale_opened',
        parameters: {
          'products_count': widget.activeProducts.length,
        },
      );
    });
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  int getQuantity(int index) => _quantities[index] ?? 1;

  void incrementQuantity(int index, int stock, int? limit) {
    int maxLimit = limit ?? stock;
    if (getQuantity(index) < maxLimit) {
      setState(() {
        _quantities[index] = getQuantity(index) + 1;
      });
    }
  }

  void decrementQuantity(int index) {
    if (getQuantity(index) > 1) {
      setState(() {
        _quantities[index] = getQuantity(index) - 1;
      });
    }
  }

  void addToCart(Item item, int quantity) {
    double price = item.price!;
    double discount = item.discount!;
    double discountPrice = PriceConverter.convertWithDiscount(
        price, discount, item.discountType)!;

    CartModel cartModel = CartModel(
      null,
      price,
      discount,
      [],
      [],
      (price - discountPrice),
      quantity,
      [],
      [],
      false,
      item.stock,
      item,
      item.quantityLimit,
    );

    int cartIndex = Get.find<CartController>()
        .isExistInCart(item.id, Get.find<CartController>().cartVariant(item.id!), false, null);
    if (cartIndex != -1) {
      Get.find<CartController>().setQuantity(
          true, cartIndex, item.stock, item.quantityLimit);
    } else {
      Get.find<CartController>().addToCart(cartModel, null);
    }

    showCustomSnackBar('item_added_to_cart'.tr, isError: false);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 650, // Increased height to accommodate the detailed showcase
      child: PageView.builder(
          itemCount: widget.activeProducts.length,
          allowImplicitScrolling: true,
          physics: const ClampingScrollPhysics(),
          controller: _pageController,
          onPageChanged: (int pageIndex) {
            Get.find<FlashSaleController>().setPageIndex(pageIndex);
          },
          itemBuilder: (context, index) {
            final product = widget.activeProducts[index].item;
            analytics.logEvent(
              name: 'view_flash_sale_item',
              parameters: {
                'item_id': product!.id!,
                'item_name': product.name!,
                'index': index,
                'flash_sale_price': product.price!,
              },
            );
            return carouselCard(index, widget.activeProducts[index]);
          }),
    );
  }

  Widget carouselCard(int index, ActiveProducts activeProduct) {
    double? discount = activeProduct.item!.storeDiscount == 0
        ? activeProduct.item!.discount
        : activeProduct.item!.storeDiscount;
    String? discountType = activeProduct.item!.storeDiscount == 0
        ? activeProduct.item!.discountType
        : 'percent';

    int stock = activeProduct.stock ?? 0;
    int sold = activeProduct.sold ?? 0;
    int remaining = stock - sold;
    bool isSoldOut = remaining == 0;
    
    double percentLeft = stock > 0 ? (remaining / stock) : 0;
    int percentLeftInt = (percentLeft * 100).toInt();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: 8),
      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 25,
            spreadRadius: 2,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        children: [
          // Top Badges Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Discount Badge (Pink Glossy)
              if (discount != null && discount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF8B94), Color(0xFFFF4E5B)],
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(color: Colors.redAccent.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                    border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.3)),
                        child: const Icon(Icons.percent, color: Colors.white, size: 14),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        discountType == 'percent'
                            ? '${discount.toStringAsFixed(0)}% ${'discount'.tr}'
                            : '${PriceConverter.convertPrice(discount)} ${'discount'.tr}',
                        style: robotoBold.copyWith(color: Colors.white, fontSize: 13),
                      ),
                    ],
                  )
                )
              else const SizedBox(),
              
              // Removed Best Seller Badge
              const SizedBox(),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Product Image Showcase
          Expanded(
            child: InkWell(
              onTap: isSoldOut
                  ? null
                  : () {
                      final item = activeProduct.item!;
                      analytics.logEvent(
                        name: 'open_item_from_flash_sale',
                        parameters: {
                          'item_id': item.id!,
                          'item_name': item.name!,
                          'discount': item.discount ?? 0,
                          'flash_sale_price': item.price!,
                        },
                      );
                      Get.find<ItemController>().navigateToItemPage(activeProduct.item, context);
                    },
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  // Circular Mint Backdrop
                  Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFffffff),
                      border: Border.all(color: const Color(0xFF2EAA60).withOpacity(0.1), width: 2),
                    )
                  ),
                  
                  // Decorative sparkles & leaves
                  Positioned(top: 20, right: 20, child: Icon(Icons.auto_awesome, color: const Color(0xFF2EAA60).withOpacity(0.5), size: 24)),
                  Positioned(bottom: 50, left: 10, child: Icon(Icons.eco, color: const Color(0xFF3FE281).withOpacity(0.8), size: 28)),
                  Positioned(top: 40, left: 30, child: Icon(Icons.star_border, color: Colors.yellow.shade700.withOpacity(0.6), size: 20)),
                  
                  // Marble Podium (Pseudo-3D)
                  Positioned(
                    bottom: 0,
                    child: Container(
                      width: 200,
                      height: 35,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(Radius.elliptical(100, 25)),
                        gradient: LinearGradient(
                          colors: [Colors.white, Colors.grey.shade300],
                          begin: Alignment.topCenter, end: Alignment.bottomCenter,
                        ),
                        boxShadow: [
                          BoxShadow(color: const Color(0xFF3FE281).withOpacity(0.6), blurRadius: 15, spreadRadius: -2), // Mint glowing ring
                          const BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 10)) // Podium shadow
                        ]
                      )
                    ),
                  ),

                  // Actual Product Image
                  Positioned(
                    bottom: 20,
                    child: CustomImage(
                      image: '${activeProduct.item!.imageFullUrl}',
                      fit: BoxFit.contain,
                      width: 150  ,
                      height: 130,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Product Info
          Text(
            activeProduct.item!.name!,
            style: robotoBold.copyWith(fontSize: 24, color: const Color(0xFF1E2D24)),
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          if (activeProduct.item!.unitType != null)
            Text(
              '(${activeProduct.item!.unitType})',
              style: robotoRegular.copyWith(fontSize: 14, color: Colors.grey.shade600),
            ),
            
          const SizedBox(height: 12),
          
          // Decorative Divider
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 40, height: 1, color: Colors.grey.shade300),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.favorite, color: const Color(0xFF3FE281), size: 14),
              ),
              Container(width: 40, height: 1, color: Colors.grey.shade300),
            ]
          ),
          
          const SizedBox(height: 12),
          
          // Pricing
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (discount != null && discount > 0)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: Text(
                    PriceConverter.convertPrice(activeProduct.item!.price),
                    style: robotoMedium.copyWith(
                      fontSize: 18,
                      color: Colors.grey.shade500,
                      decoration: TextDecoration.lineThrough,
                      decorationColor: Colors.redAccent,
                      decorationThickness: 2,
                    ),
                  ),
                ),
              if (discount != null && discount > 0) const SizedBox(width: 12),
              Text(
                PriceConverter.convertPrice(
                  activeProduct.item!.price,
                  discount: discount,
                  discountType: discountType,
                ),
                style: robotoBold.copyWith(
                  fontSize: 34,
                  color: const Color(0xFF1B6E3A),
                  shadows: [
                    Shadow(color: const Color(0xFF3FE281).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 2))
                  ]
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Quantity & Add to Cart
          Row(
            children: [
              // Quantity Selector (Neumorphic)
              Container(
                height: 55,
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FBF9),
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                    const BoxShadow(color: Colors.white, blurRadius: 10, offset: Offset(-5, -5)) // Top-left highlight
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove, color: Colors.grey.shade600),
                      onPressed: isSoldOut ? null : () => decrementQuantity(index),
                    ),
                    SizedBox(
                      width: 25,
                      child: Text(
                        "${getQuantity(index)}",
                        textAlign: TextAlign.center,
                        style: robotoBold.copyWith(fontSize: 18, color: const Color(0xFF1E2D24)),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, color: Color(0xFF1B6E3A)),
                      onPressed: isSoldOut ? null : () => incrementQuantity(index, stock, activeProduct.item!.quantityLimit),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Add to Cart Button (Glossy Green CTA)
              Expanded(
                child: InkWell(
                  onTap: isSoldOut
                      ? null
                      : () => addToCart(activeProduct.item!, getQuantity(index)),
                  child: Container(
                    height: 55,
                    decoration: BoxDecoration(
                      gradient: isSoldOut
                          ? const LinearGradient(colors: [Colors.grey, Colors.grey])
                          : const LinearGradient(
                              colors: [Color(0xFF3FE281), Color(0xFF1B6E3A)],
                              begin: Alignment.topLeft, end: Alignment.bottomRight,
                            ),
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: isSoldOut
                          ? []
                          : [
                              BoxShadow(color: const Color(0xFF2EAA60).withOpacity(0.5), blurRadius: 15, offset: const Offset(0, 5)),
                              BoxShadow(color: Colors.white.withOpacity(0.3), blurRadius: 5, spreadRadius: -2, offset: const Offset(0, -2)) // Inner glossy shine
                            ]
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!isSoldOut) 
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.2)),
                            child: const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 20),
                          ),
                        if (!isSoldOut) const SizedBox(width: 8),
                        Text(
                          isSoldOut ? 'sold_out'.tr : 'إضافة',
                          style: robotoBold.copyWith(color: Colors.white, fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Stock Section removed
        ],
      ),
    );
  }
}
