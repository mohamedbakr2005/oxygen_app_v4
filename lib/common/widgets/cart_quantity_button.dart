import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Oxygen_Mart/common/widgets/quantity_decrement_icon.dart';
import 'package:Oxygen_Mart/features/location/controllers/location_controller.dart';
import 'package:Oxygen_Mart/helper/address_helper.dart';
import 'package:Oxygen_Mart/util/dimensions.dart';
import 'package:Oxygen_Mart/util/styles.dart';

/// The shared cart control for product and bundle cards.
class CartQuantityButton extends StatefulWidget {
  final int quantity;
  final Future<void> Function()? onAdd;
  final Future<void> Function()? onIncrement;
  final Future<void> Function()? onDecrement;
  final VoidCallback? onBeforeAdd;
  final bool isLoading;
  final Widget Function(BuildContext context, bool isAdding)? addBuilder;

  const CartQuantityButton({super.key,
    required this.quantity, required this.onAdd, required this.onIncrement, required this.onDecrement, this.onBeforeAdd,
    this.isLoading = false, this.addBuilder,
  });

  @override
  State<CartQuantityButton> createState() => _CartQuantityButtonState();
}

class _CartQuantityButtonState extends State<CartQuantityButton> {
  static const Duration _autoCollapseDelay = Duration(seconds: 3);
  static const double _controlHeight = 32;

  bool _isExpanded = false;
  bool _isAdding = false;
  bool _isBusy = false;
  Timer? _collapseTimer;

  void _keepExpanded() {
    _collapseTimer?.cancel();
    if(!_isExpanded) {
      setState(() => _isExpanded = true);
    }
    _collapseTimer = Timer(_autoCollapseDelay, () {
      if(mounted) {
        setState(() => _isExpanded = false);
      }
    });
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _isBusy = true);
    try {
      await action();
    } finally {
      if(mounted) setState(() => _isBusy = false);
    }
  }

  @override
  void dispose() {
    _collapseTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int qty = widget.quantity;
    final String stateKey = qty == 0 ? 'add' : (_isExpanded ? 'expanded' : 'chip');
    final Widget content = qty == 0
        ? _buildAddButton(context)
        : _isExpanded
            ? _buildExpanded(context, qty)
            : _buildCountChip(context, qty);

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      alignment: Alignment.centerRight,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (Widget child, Animation<double> animation) => FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.85, end: 1.0).animate(animation),
            alignment: Alignment.centerRight,
            child: child,
          ),
        ),
        layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) => Stack(
          alignment: Alignment.centerRight,
          children: [
            ...previousChildren,
            if (currentChild != null) currentChild,
          ],
        ),
        child: KeyedSubtree(key: ValueKey<String>('cart-quantity-$stateKey'), child: content),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return InkWell(
      onTap: widget.onAdd == null || _isAdding ? null : () async {
        if(AddressHelper.getUserAddressFromSharedPref() == null) {
          Get.find<LocationController>().navigateToLocationScreen('home', canRoute: true);
          return;
        }
        widget.onBeforeAdd?.call();
        _keepExpanded();
        setState(() => _isAdding = true);
        try {
          await widget.onAdd!();
        } finally {
          if(mounted) setState(() => _isAdding = false);
        }
      },
      child: widget.addBuilder?.call(context, _isAdding) ?? Container(
        height: 25, width: 25,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          color: Theme.of(context).cardColor,
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
        ),
        child: _isAdding
            ? const Padding(
                padding: EdgeInsets.all(4),
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(Icons.add, size: 20, color: Theme.of(context).primaryColor),
      ),
    );
  }

  Widget _buildCountChip(BuildContext context, int qty) {
    final bool loading = widget.isLoading || _isBusy;
    return InkWell(
      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      onTap: _keepExpanded,
      child: Container(
        height: _controlHeight,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall + 2),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 0)],
        ),
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
        child: loading
            ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
            : _animatedCount(qty, robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault)),
      ),
    );
  }

  Widget _buildExpanded(BuildContext context, int qty) {
    return Container(
      height: _controlHeight,
      width: 100,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        InkWell(
          onTap: widget.onDecrement == null ? null : () {
            if(qty > 1) {
              _keepExpanded();
            } else {
              _collapseTimer?.cancel();
            }
            _run(widget.onDecrement!);
          },
          child: Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
            child: QuantityDecrementIcon(quantity: qty, size: 16),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
          child: _animatedCount(qty, robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
        ),
        InkWell(
          onTap: widget.onIncrement == null ? null : () {
            _keepExpanded();
            _run(widget.onIncrement!);
          },
          child: const Padding(
            padding: EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
            child: Icon(Icons.add, size: 16),
          ),
        ),
      ]),
    );
  }

  Widget _animatedCount(int qty, TextStyle style) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 240),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (Widget child, Animation<double> animation) => ClipRect(
        child: FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 0.35), end: Offset.zero).animate(animation),
            child: child,
          ),
        ),
      ),
      child: Text(qty.toString(), key: ValueKey<int>(qty), style: style),
    );
  }
}
