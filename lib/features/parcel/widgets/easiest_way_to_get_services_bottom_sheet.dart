import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Oxygen_Mart/common/widgets/custom_image.dart';
import 'package:Oxygen_Mart/features/language/controllers/language_controller.dart';
import 'package:Oxygen_Mart/features/parcel/controllers/parcel_controller.dart';
import 'package:Oxygen_Mart/features/parcel/widgets/bottom_sheet_header_widget.dart';
import 'package:Oxygen_Mart/features/parcel/widgets/get_service_video_widget.dart';
import 'package:Oxygen_Mart/helper/image_cache_helper.dart';
import 'package:Oxygen_Mart/helper/responsive_helper.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/styles.dart';

class EasiestWayToGetServicesBottomSheet extends StatelessWidget {
  const EasiestWayToGetServicesBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);

    return Container(
      width: 550,
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusExtraLarge)),
      ),
      child: GetBuilder<ParcelController>(builder: (parcelController) {
        final bool hasMedia = parcelController.videoContentDetails != null &&
            ((parcelController.videoContentDetails!.bannerVideo != null &&
                    parcelController.videoContentDetails!.bannerVideo!.isNotEmpty) ||
                (parcelController.videoContentDetails!.bannerImageFullUrl != null &&
                    parcelController.videoContentDetails!.bannerImageFullUrl!.isNotEmpty));

        return Column(mainAxisSize: MainAxisSize.min, children: [
          BottomSheetHeaderWidget(title: 'easiest_way_to_get_services'.tr),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (hasMedia) ...[
                  _MediaContentWidget(parcelController: parcelController, isDesktop: isDesktop),
                  const SizedBox(height: Dimensions.paddingSizeLarge),
                ],

                _NumberedServiceInfoListWidget(parcelController: parcelController),
                const SizedBox(height: Dimensions.paddingSizeDefault),
              ]),
            ),
          ),
        ]);
      }),
    );
  }
}

class _MediaContentWidget extends StatelessWidget {
  final ParcelController parcelController;
  final bool isDesktop;

  const _MediaContentWidget({required this.parcelController, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    final details = parcelController.videoContentDetails!;

    if (details.bannerType == 'image') {
      return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          child: CustomImage(
            image: details.bannerImageFullUrl ?? '',
            width: constraints.maxWidth,
            cacheWidth: ImageCacheHelper.pixels(context, constraints.maxWidth),
          ),
        );
      });
    }
    if (details.bannerType == 'video') {
      return GetServiceVideoWidget(youtubeVideoUrl: details.bannerVideo ?? '', fileVideoUrl: '');
    }
    return GetServiceVideoWidget(
      youtubeVideoUrl: '',
      fileVideoUrl: '${details.bannerVideoContentFullUrl ?? ''}',
    );
  }
}

class _NumberedServiceInfoListWidget extends StatelessWidget {
  final ParcelController parcelController;

  const _NumberedServiceInfoListWidget({required this.parcelController});

  @override
  Widget build(BuildContext context) {
    final List<String> titles = [];
    final List<String> subTitles = [];
    final contents = parcelController.videoContentDetails?.bannerContents ?? [];

    for (int i = 0; i < contents.length; i++) {
      if (i % 2 == 0) {
        titles.add(contents[i].value ?? '');
      } else {
        subTitles.add(contents[i].value ?? '');
      }
    }

    // Fallback to high quality default steps if admin hasn't configured custom steps
    if (titles.isEmpty) {
      titles.addAll([
        'how_parcel_works_step_1_title'.tr,
        'how_parcel_works_step_2_title'.tr,
        'how_parcel_works_step_3_title'.tr,
      ]);
      subTitles.addAll([
        'how_parcel_works_step_1_desc'.tr,
        'how_parcel_works_step_2_desc'.tr,
        'how_parcel_works_step_3_desc'.tr,
      ]);
    }

    final bool isLtr = Get.find<LocalizationController>().isLtr;

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: titles.length,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        final bool isLast = index == titles.length - 1;
        final String? subTitle = index < subTitles.length ? subTitles[index] : null;

        return IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Column(children: [
              Container(
                height: 32,
                width: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.12),
                  border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  '${index + 1}',
                  style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                  ),
                ),
            ]),
            const SizedBox(width: Dimensions.paddingSizeDefault),

            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: isLast ? Dimensions.paddingSizeSmall : Dimensions.paddingSizeLarge),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    titles[index],
                    style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault),
                    textAlign: isLtr ? TextAlign.left : TextAlign.right,
                  ),
                  if (subTitle != null && subTitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      subTitle,
                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(context).disabledColor,
                      ),
                    ),
                  ],
                ]),
              ),
            ),
          ]),
        );
      },
    );
  }
}
