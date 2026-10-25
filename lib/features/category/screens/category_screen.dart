import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Oxygen_Mart/common/widgets/custom_app_bar.dart';
import 'package:Oxygen_Mart/common/widgets/custom_image.dart';
import 'package:Oxygen_Mart/common/widgets/footer_view.dart';
import 'package:Oxygen_Mart/common/widgets/menu_drawer.dart';
import 'package:Oxygen_Mart/common/widgets/no_data_screen.dart';
import 'package:Oxygen_Mart/features/category/controllers/category_controller.dart';
import 'package:Oxygen_Mart/helper/responsive_helper.dart';
import 'package:Oxygen_Mart/helper/route_helper.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/styles.dart';
import 'package:shimmer/shimmer.dart';

class CategoryScreen extends StatefulWidget {
  final bool fromNav;
  const CategoryScreen({super.key, this.fromNav = false});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Get.find<CategoryController>().getCategoryList(false);
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = ResponsiveHelper.isDesktop(context);
    final bool isTab = ResponsiveHelper.isTab(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: widget.fromNav
          ? null
          : (isDesktop ? null : CustomAppBar(title: 'categories'.tr)),
      endDrawer: const MenuDrawer(),
      endDrawerEnableOpenDragGesture: false,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Get.find<CategoryController>().getCategoryList(true);
          },
          child: CustomScrollView(
            controller: scrollController,
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              // Search Bar & Header
              SliverToBoxAdapter(
                child: Center(
                  child: Container(
                    width: Dimensions.webMaxWidth,
                    padding: EdgeInsets.only(
                      top: widget.fromNav ? 16 : 8,
                      bottom: 12,
                      left: Dimensions.paddingSizeDefault,
                      right: Dimensions.paddingSizeDefault,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.fromNav || isDesktop)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              'categories'.tr,
                              style: robotoBold.copyWith(
                                fontSize: 18,
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),

                        // Search Bar
                        InkWell(
                          onTap: () => Get.toNamed(RouteHelper.getSearchRoute()),
                          borderRadius: BorderRadius.circular(30),
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.paddingSizeDefault,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.search_rounded,
                                  color: Theme.of(context).hintColor.withValues(alpha: 0.6),
                                  size: 22,
                                ),
                                const SizedBox(width: Dimensions.paddingSizeSmall),
                                Expanded(
                                  child: Text(
                                    'search_item_or_store'.tr,
                                    style: robotoRegular.copyWith(
                                      fontSize: Dimensions.fontSizeDefault,
                                      color: Theme.of(context)
                                          .hintColor
                                          .withValues(alpha: 0.6),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Categories Grid matching Grocery screen design
              SliverToBoxAdapter(
                child: Center(
                  child: SizedBox(
                    width: Dimensions.webMaxWidth,
                    child: GetBuilder<CategoryController>(
                      builder: (catController) {
                        if (catController.categoryList == null) {
                          return _buildShimmerGrid(context);
                        }

                        if (catController.categoryList!.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 60),
                            child: NoDataScreen(text: 'no_category_found'.tr),
                          );
                        }

                        final categories = catController.categoryList!;
                        final int crossAxisCount = isDesktop
                            ? 6
                            : isTab
                                ? 4
                                : 3;

                        return GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          padding: const EdgeInsets.fromLTRB(
                            Dimensions.paddingSizeSmall,
                            Dimensions.paddingSizeSmall,
                            Dimensions.paddingSizeSmall,
                            120,
                          ),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            childAspectRatio: 0.7,
                            mainAxisSpacing: Dimensions.paddingSizeSmall,
                            crossAxisSpacing: Dimensions.paddingSizeSmall,
                          ),
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            final category = categories[index];

                            return InkWell(
                              onTap: () => Get.toNamed(
                                RouteHelper.getCategoryItemRoute(
                                  category.id,
                                  category.name ?? '',
                                ),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(
                                    Dimensions.radiusSmall,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 5,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    // 1. الصورة (في الخلفية)
                                    Positioned.fill(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          Dimensions.radiusSmall,
                                        ),
                                        child: CustomImage(
                                          image: '${category.imageFullUrl}',
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: double.infinity,
                                        ),
                                      ),
                                    ),

                                    // 2. النص (فوق الصورة باستخدام Positioned)
                                    Positioned(
                                      top: 10,
                                      left: 5,
                                      right: 5,
                                      child: Text(
                                        category.name ?? '',
                                        style: robotoBold.copyWith(
                                          fontSize: 14,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w900,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),

              if (isDesktop)
                const SliverToBoxAdapter(
                  child: FooterView(child: SizedBox()),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerGrid(BuildContext context) {
    final bool isDesktop = ResponsiveHelper.isDesktop(context);
    final bool isTab = ResponsiveHelper.isTab(context);
    final int crossAxisCount = isDesktop
        ? 6
        : isTab
            ? 4
            : 3;

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(
        Dimensions.paddingSizeSmall,
        Dimensions.paddingSizeSmall,
        Dimensions.paddingSizeSmall,
        120,
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.7,
        mainAxisSpacing: Dimensions.paddingSizeSmall,
        crossAxisSpacing: Dimensions.paddingSizeSmall,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[200]!,
          highlightColor: Colors.grey[50]!,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            ),
          ),
        );
      },
    );
  }
}
