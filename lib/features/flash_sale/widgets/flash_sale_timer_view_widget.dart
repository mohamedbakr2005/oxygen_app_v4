import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Oxygen_Mart/features/flash_sale/widgets/timer_widget.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';

class FlashSaleTimerView extends StatelessWidget {
  final Duration? eventDuration;
  const FlashSaleTimerView({super.key, this.eventDuration});

  @override
  Widget build(BuildContext context) {
    int? days, hours, minutes, seconds;
    if (eventDuration != null) {
      days = eventDuration!.inDays;
      hours = eventDuration!.inHours - days * 24;
      minutes = eventDuration!.inMinutes - (24 * days * 60) - (hours * 60);
      seconds = eventDuration!.inSeconds -
          (24 * days * 60 * 60) -
          (hours * 60 * 60) -
          (minutes * 60);
    }
    
    return eventDuration != null
        ? Row(children: [
            TimerWidget(timeCount: days ?? 0, timeUnit: 'أيام'),
            _separator(),
            TimerWidget(timeCount: hours ?? 0, timeUnit: 'ساعات'),
            _separator(),
            TimerWidget(timeCount: minutes ?? 0, timeUnit: 'دقائق'),
            _separator(),
            TimerWidget(timeCount: seconds ?? 0, timeUnit: 'ثواني'),
          ])
        : const SizedBox();
  }

  Widget _separator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0).copyWith(bottom: 24),
      child: const Text(':', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3FE281), fontSize: 22)),
    );
  }
}

class FlashSaleTimerWebHomeView extends StatelessWidget {
  final Duration? eventDuration;
  const FlashSaleTimerWebHomeView({super.key, this.eventDuration});

  @override
  Widget build(BuildContext context) {
    int? days, hours, minutes, seconds;
    if (eventDuration != null) {
      days = eventDuration!.inDays;
      hours = eventDuration!.inHours - days * 24;
      minutes = eventDuration!.inMinutes - (24 * days * 60) - (hours * 60);
      seconds = eventDuration!.inSeconds -
          (24 * days * 60 * 60) -
          (hours * 60 * 60) -
          (minutes * 60);
    }
    return eventDuration != null
        ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            TimerWidget(
              timeCount: days ?? 0,
              timeUnit: 'days'.tr,
            ),
            TimerWidget(
              timeCount: hours ?? 0,
              timeUnit: 'hours'.tr,
            ),
            TimerWidget(
              timeCount: minutes ?? 0,
              timeUnit: 'mins'.tr,
            ),
            TimerWidget(
              timeCount: seconds ?? 0,
              timeUnit: 'sec'.tr,
            ),
          ])
        : const SizedBox();
  }
}
