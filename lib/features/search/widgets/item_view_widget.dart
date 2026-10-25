import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Oxygen_Mart/common/widgets/footer_view.dart';
import 'package:Oxygen_Mart/common/widgets/item_view.dart';
import 'package:Oxygen_Mart/features/search/controllers/search_controller.dart'
    as search;
import 'package:Oxygen_Mart/util/dimensions.dart';

class ItemViewWidget extends StatelessWidget {
  final bool isItem;
  const ItemViewWidget({super.key, required this.isItem});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<search.SearchController>(builder: (searchController) {
        return SingleChildScrollView(
          child: FooterView(
            child: SizedBox(
              width: Dimensions.webMaxWidth,
              child: ItemsView(
                isStore: isItem,
                items: searchController.searchItemList,
                stores: searchController.searchStoreList,
              ),
            ),
          ),
        );
      }),
    );
  }
}
