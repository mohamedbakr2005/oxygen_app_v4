import 'package:Oxygen_Mart/features/cart/domain/models/cart_model.dart';
import 'package:Oxygen_Mart/features/cart/domain/models/online_cart_model.dart';

class BundleAmountHelper {
  /// What one product-bundle row saves against its members' own prices, and 0 when it
  /// saves nothing or the payload carries no base to compare against.
  static double savingOf(BundleCartDetails details) {
    final double saving = details.totalBasePrice - details.totalFinalPrice;
    return saving > 0 ? saving : 0;
  }

  /// What every product bundle in [cartList] saves, for the bill's discount line.
  static double bundleSaving(List<CartModel?>? cartList) {
    double amount = 0;
    for(final CartModel? cart in cartList ?? const <CartModel?>[]) {
      if(cart != null && cart.isBundle) {
        amount += savingOf(cart.bundleDetails!);
      }
    }
    return amount;
  }

  static double netAmount(List<CartModel?>? cartList) {
    double amount = 0;
    for(final CartModel? cart in cartList ?? const <CartModel?>[]) {
      if(cart == null) {
        continue;
      }
      if(cart.isBogoBundle) {
        final BogoCartDetails details = cart.bogoDetails!;
        amount += details.totalFinalPrice ?? (details.totalPrice - details.totalDiscountAmount);
      } else if(cart.isBundle) {
        amount += cart.bundleDetails!.totalFinalPrice;
      }
    }
    return amount;
  }
}
