import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:Oxygen_Mart/common/widgets/paginated_list_view.dart';
import 'package:Oxygen_Mart/features/home/widgets/modern_food_restaurant_card.dart';
import 'package:Oxygen_Mart/features/store/controllers/store_controller.dart';
import 'package:Oxygen_Mart/features/store/domain/models/store_model.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/styles.dart';

class FoodHomeScreen extends StatefulWidget {
  final ScrollController? scrollController;

  const FoodHomeScreen({super.key, this.scrollController});

  @override
  State<FoodHomeScreen> createState() => _FoodHomeScreenState();
}

class _FoodHomeScreenState extends State<FoodHomeScreen> {
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    // Ensure stores are loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final storeController = Get.find<StoreController>();
      if (storeController.storeModel == null) {
        storeController.getStoreList(1, true);
      }
    });
  }

  List<Store> _filterStores(List<Store?>? rawStores) {
    if (rawStores == null) return [];
    List<Store> stores = rawStores.whereType<Store>().toList();

    switch (_selectedFilter) {
      case 'open':
        return stores.where((s) => Get.find<StoreController>().isOpenNow(s)).toList();
      case 'top_rated':
        final list = stores.where((s) => (s.avgRating ?? 0) >= 4.0).toList();
        list.sort((a, b) => (b.avgRating ?? 0).compareTo(a.avgRating ?? 0));
        return list;
      case 'free_delivery':
        return stores.where((s) => s.freeDelivery == true).toList();
      case 'offers':
        return stores
            .where((s) =>
                (s.discount?.discount ?? 0) > 0 ||
                (s.offerLabel != null && s.offerLabel!.isNotEmpty))
            .toList();
      default:
        return stores;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return GetBuilder<StoreController>(
      builder: (storeController) {
        final rawStores = storeController.storeModel?.stores;
        final bool isLoading = storeController.storeModel == null;
        final filteredStores = _filterStores(rawStores);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),

            // ── Section Header & Counter ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 20,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'all_restaurants'.tr.isNotEmpty && 'all_restaurants'.tr != 'all_restaurants'
                            ? 'all_restaurants'.tr
                            : 'المطاعم المتاحة',
                        style: robotoBold.copyWith(
                          fontSize: 18,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                    ],
                  ),
                  if (!isLoading && rawStores != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${rawStores.length} ${'restaurants'.tr.isNotEmpty && 'restaurants'.tr != 'restaurants' ? 'restaurants'.tr : 'مطعم'}',
                        style: robotoBold.copyWith(
                          fontSize: 12,
                          color: primaryColor,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Filter Chips Bar ──
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
              child: Row(
                children: [
                  _buildFilterChip(id: 'all', label: 'all'.tr, icon: Icons.restaurant_rounded),
                  const SizedBox(width: 8),
                  _buildFilterChip(id: 'open', label: 'open_now'.tr, icon: Icons.access_time_filled_rounded),
                  const SizedBox(width: 8),
                  _buildFilterChip(id: 'top_rated', label: 'top_rated'.tr, icon: Icons.star_rounded),
                  const SizedBox(width: 8),
                  _buildFilterChip(id: 'free_delivery', label: 'free_delivery'.tr, icon: Icons.electric_bolt_rounded),
                  const SizedBox(width: 8),
                  _buildFilterChip(id: 'offers', label: 'special_offer'.tr, icon: Icons.local_offer_rounded),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Stores List / Shimmer / Empty State ──
            isLoading
                ? const _FoodRestaurantListShimmer()
                : filteredStores.isEmpty
                    ? _buildEmptyState(context)
                    : widget.scrollController != null
                        ? PaginatedListView(
                            scrollController: widget.scrollController!,
                            totalSize: storeController.storeModel?.totalSize,
                            offset: storeController.storeModel?.offset,
                            onPaginate: (int? offset) async =>
                                await storeController.getStoreList(offset!, false),
                            itemView: ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.only(bottom: 120),
                              itemCount: filteredStores.length,
                              itemBuilder: (context, index) {
                                return ModernFoodRestaurantCard(store: filteredStores[index]);
                              },
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.only(bottom: 120),
                            itemCount: filteredStores.length,
                            itemBuilder: (context, index) {
                              return ModernFoodRestaurantCard(store: filteredStores[index]);
                            },
                          ),
          ],
        );
      },
    );
  }

  Widget _buildFilterChip({
    required String id,
    required String label,
    required IconData icon,
  }) {
    final bool isSelected = _selectedFilter == id;
    final primaryColor = Theme.of(context).primaryColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedFilter = id;
          });
        },
        borderRadius: BorderRadius.circular(30),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? primaryColor : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: isSelected
                  ? primaryColor
                  : Theme.of(context).disabledColor.withValues(alpha: 0.15),
              width: 1.2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    )
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 15,
                color: isSelected ? Colors.white : Theme.of(context).disabledColor,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: robotoMedium.copyWith(
                  fontSize: 12.5,
                  color: isSelected
                      ? Colors.white
                      : Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.restaurant_rounded,
              size: 48,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'no_restaurant_available'.tr.isNotEmpty &&
                    'no_restaurant_available'.tr != 'no_restaurant_available'
                ? 'no_restaurant_available'.tr
                : 'لا توجد مطاعم متاحة حالياً',
            style: robotoBold.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'جرب تغيير الفلتر أو تفقد الموقع المحدد',
            style: robotoRegular.copyWith(
              color: Theme.of(context).hintColor,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _FoodRestaurantListShimmer extends StatelessWidget {
  const _FoodRestaurantListShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        padding: const EdgeInsets.only(bottom: 120),
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 175,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(width: 140, height: 16, color: Colors.white),
                            const SizedBox(height: 6),
                            Container(width: 90, height: 12, color: Colors.white),
                          ],
                        ),
                      ),
                      Container(width: 48, height: 24, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
