import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Oxygen_Mart/features/order/widgets/custom_stepper_widget.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';

class TrackingStepperWidget extends StatelessWidget {
  final String? status;
  final bool takeAway;
  const TrackingStepperWidget(
      {super.key, required this.status, required this.takeAway});

  /// Returns current step (1=Accepted, 2=Pickup, 3=On the way, 4=Completed).
  /// Returns 0 if pending/unknown.
  static int getState(String? status) {
    if (status == 'accepted' || status == 'confirmed') return 1;
    if (status == 'processing' || status == 'handover') return 2;
    if (status == 'picked_up') return 3;
    if (status == 'delivered') return 4;
    return 0; // pending
  }

  @override
  Widget build(BuildContext context) {
    final int state = getState(status);

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeSmall,
          vertical: Dimensions.paddingSizeExtraSmall),
      child: Row(children: [
        // Step 1: Accepted
        CustomStepperWidget(
          title: 'accepted'.tr,
          isCompleted: state > 1,
          isCurrent: state == 1,
          haveLeftBar: false,
          haveRightBar: true,
          leftBarActive: false,
          rightBarActive: state >= 2,
        ),
        // Step 2: Pickup
        CustomStepperWidget(
          title: 'pickup'.tr,
          isCompleted: state > 2,
          isCurrent: state == 2,
          haveLeftBar: true,
          haveRightBar: true,
          leftBarActive: state >= 2,
          rightBarActive: state >= 3,
        ),
        // Step 3: On the way
        CustomStepperWidget(
          title: 'on_the_way'.tr,
          isCompleted: state > 3,
          isCurrent: state == 3,
          haveLeftBar: true,
          haveRightBar: true,
          leftBarActive: state >= 3,
          rightBarActive: state >= 4,
        ),
        // Step 4: Completed
        CustomStepperWidget(
          title: 'completed'.tr,
          isCompleted: state >= 4,
          isCurrent: false,
          haveLeftBar: true,
          haveRightBar: false,
          leftBarActive: state >= 4,
          rightBarActive: false,
        ),
      ]),
    );
  }
}
