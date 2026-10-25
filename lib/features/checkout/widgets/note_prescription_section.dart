import 'package:Oxygen_Mart/common/widgets/custom_text_field.dart';
import 'package:Oxygen_Mart/features/checkout/controllers/checkout_controller.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NoteAndPrescriptionSection extends StatelessWidget {
  final CheckoutController checkoutController;
  final int? storeId;
  const NoteAndPrescriptionSection({
    super.key,
    required this.checkoutController,
    this.storeId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.edit_note_rounded,
                size: 18,
                color: theme.primaryColor,
              ),
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Text(
              'additional_note'.tr,
              style: robotoBold.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
        const SizedBox(height: Dimensions.paddingSizeSmall),
        CustomTextField(
          controller: checkoutController.noteController,
          titleText: 'write_any_additional_note_or_instructions'.tr,
          showLabelText: false,
          maxLines: 3,
          inputType: TextInputType.multiline,
          inputAction: TextInputAction.done,
          capitalization: TextCapitalization.sentences,
          prefixIcon: Icons.edit_outlined,
        ),
        const SizedBox(height: Dimensions.paddingSizeLarge),
      ],
    );
  }
}
