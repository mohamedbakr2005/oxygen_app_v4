import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Oxygen_Mart/features/language/controllers/language_controller.dart';
import 'package:Oxygen_Mart/features/parcel/controllers/parcel_controller.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/styles.dart';

class ServiceInfoListWidget extends StatelessWidget {
  final ParcelController parcelController;
  const ServiceInfoListWidget({super.key, required this.parcelController});

  @override
  Widget build(BuildContext context) {
    List<String> title = [];
    List<String> subTitle = [];
    final contents = parcelController.videoContentDetails?.bannerContents;
    if (contents != null && contents.isNotEmpty) {
      for (int i = 0; i < contents.length; i++) {
        if (i % 2 == 0) {
          title.add(contents[i].value ?? '');
        } else {
          subTitle.add(contents[i].value ?? '');
        }
      }
    }
    if (title.isEmpty) {
      return const SizedBox();
    }
    return ListView.builder(
      physics: const ScrollPhysics(),
      shrinkWrap: true,
      itemCount: title.length,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        final sub = index < subTitle.length ? subTitle[index] : '';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Row(children: [
                Container(
                  height: 14,
                  width: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeDefault),
                Flexible(
                    child: Text(title[index],
                        style: robotoBold,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis)),
              ]),
            ),
            if (sub.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                    vertical: Dimensions.paddingSizeSmall,
                    horizontal: 22.5),
                margin: EdgeInsets.only(
                    left:
                        Get.find<LocalizationController>().isLtr ? 15 : 0,
                    right:
                        Get.find<LocalizationController>().isLtr ? 0 : 7),
                decoration: BoxDecoration(
                  border: index == title.length - 1
                      ? null
                      : Border(
                          left: Get.find<LocalizationController>().isLtr
                              ? BorderSide(
                                  width: 1,
                                  color: Theme.of(context).disabledColor)
                              : BorderSide.none,
                          right: Get.find<LocalizationController>().isLtr
                              ? BorderSide.none
                              : BorderSide(
                                  width: 1,
                                  color:
                                      Theme.of(context).disabledColor)),
                ),
                child: Text(
                  sub,
                  style: robotoRegular.copyWith(
                      color: Theme.of(context).disabledColor),
                  textAlign: TextAlign.justify,
                ),
              ),
          ],
        );
      },
    );
  }
}
