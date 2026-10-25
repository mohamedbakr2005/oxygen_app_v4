import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Oxygen_Mart/common/models/transaction_model.dart';
import 'package:Oxygen_Mart/helper/date_converter.dart';
import 'package:Oxygen_Mart/helper/price_converter.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/styles.dart';

class HistoryItemWidget extends StatelessWidget {
  final int index;
  final bool fromWallet;
  final List<Transaction>? data;
  const HistoryItemWidget({
    super.key,
    required this.index,
    required this.fromWallet,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    if (data == null || index >= data!.length) {
      return const SizedBox();
    }

    final item = data![index];
    final bool isDebit = fromWallet
        ? (item.transactionType == 'order_place' ||
            item.transactionType == 'partial_payment' ||
            (item.debit != null && item.debit! > 0))
        : (item.transactionType == 'point_to_wallet' ||
            (item.debit != null && item.debit! > 0));

    final Color mainColor = isDebit ? const Color(0xFFD32F2F) : const Color(0xFF0F7A42);
    final Color badgeBg = isDebit ? const Color(0xFFFDEEEC) : const Color(0xFFE8F8F0);

    String title = '';
    if (fromWallet) {
      if (item.transactionType == 'add_fund') {
        title = '${'added_via'.tr} ${item.reference?.replaceAll('_', ' ') ?? ''}';
      } else if (item.transactionType == 'partial_payment') {
        title = '${'spend_on_order'.tr} #${item.reference ?? ''}';
      } else if (item.transactionType == 'loyalty_point') {
        title = 'converted_from_loyalty_point'.tr;
      } else if (item.transactionType == 'referrer') {
        title = 'earned_by_referral'.tr;
      } else if (item.transactionType == 'order_place') {
        title = '${'order_place'.tr} #${item.reference ?? ''}';
      } else {
        title = item.transactionType?.tr ?? '';
      }
    } else {
      if (item.transactionType == 'point_to_wallet') {
        title = 'convert_to_wallet_money'.tr;
      } else if (item.transactionType == 'order_place') {
        title = '${'order_place'.tr} #${item.reference ?? ''}';
      } else if (item.transactionType == 'loyalty_point') {
        title = 'loyalty_points'.tr;
      } else {
        title = item.transactionType?.tr ?? '';
      }
    }

    String amountStr = '';
    if (fromWallet) {
      double amount = isDebit
          ? ((item.debit ?? 0) + (item.adminBonus ?? 0))
          : ((item.credit ?? 0) + (item.adminBonus ?? 0));
      amountStr = '${isDebit ? '-' : '+'} ${PriceConverter.convertPrice(amount)}';
    } else {
      double points = isDebit ? (item.debit ?? 0) : (item.credit ?? 0);
      amountStr = '${isDebit ? '-' : '+'} ${points.toStringAsFixed(0)} ${'points'.tr}';
    }

    String timeStr = '';
    if (item.createdAt != null) {
      timeStr = DateConverter.dateToDateAndTime(item.createdAt!);
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).disabledColor.withOpacity(0.12),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          // Squircle icon container
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: mainColor.withOpacity(0.25), width: 1),
            ),
            child: Icon(
              isDebit ? Icons.north_east_rounded : Icons.south_west_rounded,
              color: mainColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          // Transaction details (title & timestamp)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeDefault - 0.5,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 12,
                      color: Theme.of(context).hintColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      timeStr,
                      style: robotoRegular.copyWith(
                        fontSize: 11,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                    if (item.adminBonus != null && item.adminBonus! > 0) ...[
                      const SizedBox(width: 6),
                      Text(
                        '(${'bonus'.tr} +${item.adminBonus})',
                        style: robotoMedium.copyWith(
                          fontSize: 10,
                          color: const Color(0xFF0F7A42),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Amount & Status Badge
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                amountStr,
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: mainColor,
                  letterSpacing: 0.2,
                ),
                textDirection: TextDirection.ltr,
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isDebit ? 'debit'.tr : 'credit'.tr,
                  style: robotoBold.copyWith(
                    fontSize: 10,
                    color: mainColor,
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

