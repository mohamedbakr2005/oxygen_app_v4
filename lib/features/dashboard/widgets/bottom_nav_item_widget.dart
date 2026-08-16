import 'package:flutter/material.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/styles.dart';

class BottomNavItemWidget extends StatelessWidget {
  final String selectedIcon;
  final String unSelectedIcon;
  final String title;
  final VoidCallback? onTap;
  final bool isSelected;

  const BottomNavItemWidget({
    super.key,
    this.onTap,
    this.isSelected = false,
    required this.title,
    required this.selectedIcon,
    required this.unSelectedIcon,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color inactiveColor = Theme.of(context).disabledColor;

    return Flexible(
      flex: isSelected ? 2 : 1,
      fit: FlexFit.tight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double selectedWidth = (constraints.maxWidth - 6).clamp(88.0, 155.0).toDouble();
          final double labelFontSize = constraints.maxWidth < 95 ? 11.5 : 13.5;

          return InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(28),
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                width: isSelected ? selectedWidth : 44,
                height: 48,
                padding: EdgeInsets.symmetric(
                  horizontal: isSelected ? 16 : 0,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? primaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.28),
                            blurRadius: 12,
                            spreadRadius: 0,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : null,
                ),
                child: isSelected
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            selectedIcon,
                            height: 22,
                            width: 22,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: AlignmentDirectional.centerStart,
                              child: Text(
                                title,
                                maxLines: 1,
                                textAlign: TextAlign.start,
                                style: robotoMedium.copyWith(
                                  color: Colors.white,
                                  fontSize: labelFontSize,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Center(
                        child: Image.asset(
                          unSelectedIcon,
                          height: 22,
                          width: 22,
                          color: inactiveColor,
                        ),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}
