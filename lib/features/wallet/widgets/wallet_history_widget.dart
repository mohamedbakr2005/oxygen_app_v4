import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:Oxygen_Mart/common/widgets/no_data_screen.dart';
import 'package:Oxygen_Mart/features/wallet/controllers/wallet_controller.dart';
import 'package:Oxygen_Mart/helper/responsive_helper.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/styles.dart';

import '../../../common/widgets/history_item_widget.dart';

class WalletHistoryWidget extends StatelessWidget {
  const WalletHistoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<WalletController>(builder: (walletController) {
      List<PopupMenuEntry> entryList = [];
      String filterName = '';

      for (int i = 0; i < walletController.walletFilterList.length; i++) {
        bool isSelected = walletController.walletFilterList[i].value ==
            walletController.type;
        entryList.add(
          PopupMenuItem<int>(
            value: i,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  walletController.walletFilterList[i].title!.tr,
                  style: robotoMedium.copyWith(
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).textTheme.bodyMedium!.color,
                    fontSize: Dimensions.fontSizeDefault,
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_rounded,
                    color: Theme.of(context).primaryColor,
                    size: 18,
                  ),
              ],
            ),
          ),
        );
        if (isSelected) {
          filterName = walletController.walletFilterList[i].title!.tr;
        } else if (walletController.type == 'all') {
          filterName = '';
        }
      }

      int count = walletController.transactionList?.length ?? 0;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: ResponsiveHelper.isDesktop(context)
                  ? Dimensions.paddingSizeExtraSmall
                  : Dimensions.paddingSizeLarge,
              bottom: Dimensions.paddingSizeDefault,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'wallet_history'.tr,
                      style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeLarge + 2,
                        color: Theme.of(context).textTheme.bodyLarge!.color,
                      ),
                    ),
                    if (count > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$count',
                          style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                PopupMenuButton<dynamic>(
                  offset: const Offset(0, 40),
                  itemBuilder: (BuildContext context) => entryList,
                  onSelected: (dynamic value) {
                    walletController.setWalletFilerType(
                        walletController.walletFilterList[value].value!);
                    walletController.getWalletTransactionList(
                        '1', false, walletController.type);
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(Dimensions.radiusDefault),
                  ),
                  elevation: 4,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: walletController.type != 'all'
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).disabledColor.withOpacity(0.35),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.tune_rounded,
                          size: 16,
                          color: walletController.type != 'all'
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).hintColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          filterName.isNotEmpty ? filterName : 'filter'.tr,
                          style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: walletController.type != 'all'
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 18,
                          color: Theme.of(context).hintColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          walletController.transactionList != null
              ? walletController.transactionList!.isNotEmpty
                  ? ListView.separated(
                      key: UniqueKey(),
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: walletController.transactionList!.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return HistoryItemWidget(
                          index: index,
                          fromWallet: true,
                          data: walletController.transactionList,
                        );
                      },
                    )
                  : NoDataScreen(text: 'no_data_found'.tr)
              : WalletShimmer(walletController: walletController),
          if (walletController.isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(Dimensions.paddingSizeLarge),
                child: CircularProgressIndicator(),
              ),
            ),
          const SizedBox(height: Dimensions.paddingSizeLarge),
        ],
      );
    });
  }
}

class WalletShimmer extends StatelessWidget {
  final WalletController walletController;
  const WalletShimmer({super.key, required this.walletController});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      key: UniqueKey(),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: 5,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 14,
                        width: 140,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 11,
                        width: 90,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      height: 14,
                      width: 65,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 18,
                      width: 45,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

