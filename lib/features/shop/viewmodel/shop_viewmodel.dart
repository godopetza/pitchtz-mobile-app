import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/utils/toast_controller.dart';
import '../../../domain/entities/shop_product.dart';
import '../../../domain/repositories/shop_repository.dart';

enum ViewState { loading, ready, error }

enum CheckoutState { idle, processing, polling, done, failed }

/// Drives the shop screen: product catalogue, cart management, mobile-money
/// checkout, and order-status polling.
class ShopViewModel extends ChangeNotifier {
  ShopViewModel(this._repo, this._toast);

  final ShopRepository _repo;
  final ToastController _toast;

  // ── State ─────────────────────────────────────────────────────────────────

  ViewState _state = ViewState.loading;
  String _error = '';

  List<ShopProduct> _products = [];

  /// productId → quantity
  final Map<String, int> _cart = {};

  CheckoutState _checkoutState = CheckoutState.idle;

  bool _checkoutOpen = false;
  String _phone = '';
  String _selectedOperator = 'MPESA_TZA';

  Timer? _pollTimer;
  int _pollCount = 0;
  static const int _maxPolls = 20;
  static const Duration _pollInterval = Duration(seconds: 5);

  // ── Getters ───────────────────────────────────────────────────────────────

  ViewState get state => _state;
  String get error => _error;

  List<ShopProduct> get products => List.unmodifiable(_products);

  /// Unmodifiable snapshot of the current cart.
  Map<String, int> get cart => Map.unmodifiable(_cart);

  CheckoutState get checkoutState => _checkoutState;

  bool get isCheckingOut =>
      _checkoutState == CheckoutState.processing ||
      _checkoutState == CheckoutState.polling;

  bool get hasCart => _cart.isNotEmpty;
  bool get checkoutOpen => _checkoutOpen;
  String get phone => _phone;
  // ignore: unnecessary_getters_setters — named 'selectedOperator' to avoid clash with Dart built-in
  String get selectedOperator => _selectedOperator;

  void openCheckout() {
    _checkoutOpen = true;
    notifyListeners();
  }

  void closeCheckout() {
    _checkoutOpen = false;
    notifyListeners();
  }

  void setPhone(String value) {
    _phone = value;
    notifyListeners();
  }

  void setOperator(String value) {
    _selectedOperator = value;
    notifyListeners();
  }

  int get cartItemCount =>
      _cart.values.fold(0, (sum, qty) => sum + qty);

  /// Total price of all items in the cart (in TZS).
  int get cartTotal {
    int total = 0;
    for (final entry in _cart.entries) {
      final product = _products.firstWhere(
        (p) => p.id == entry.key,
        orElse: () => const ShopProduct(
          id: '', name: '', description: '', priceTzs: 0,
          imageUrl: null, stock: 0,
        ),
      );
      total += product.priceTzs * entry.value;
    }
    return total;
  }

  List<ShopOrderItem> get _cartItems => _cart.entries
      .map((e) => ShopOrderItem(productId: e.key, quantity: e.value))
      .toList();

  // ── Catalogue ─────────────────────────────────────────────────────────────

  Future<void> load() async {
    _state = ViewState.loading;
    notifyListeners();

    try {
      _products = await _repo.getProducts();
      _state = ViewState.ready;
    } on ApiException catch (e) {
      _error = e.userMessage;
      _state = ViewState.error;
    } catch (e) {
      _error = 'Something went wrong. Please try again.';
      _state = ViewState.error;
    }

    notifyListeners();
  }

  // ── Cart ──────────────────────────────────────────────────────────────────

  void addToCart(String productId) {
    _cart[productId] = (_cart[productId] ?? 0) + 1;
    notifyListeners();
  }

  void removeFromCart(String productId) {
    final current = _cart[productId];
    if (current == null || current <= 1) {
      _cart.remove(productId);
    } else {
      _cart[productId] = current - 1;
    }
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  // ── Checkout ──────────────────────────────────────────────────────────────

  /// Creates an order from the current cart, then initiates a mobile-money
  /// payment prompt. On success the cart is cleared and a toast is shown.
  ///
  /// [phone] is the M-Pesa / Airtel number; [operator] is 'mpesa' | 'airtel'.
  Future<void> checkout({
    required String phone,
    required String operator,
  }) async {
    if (_cart.isEmpty) return;

    _checkoutState = CheckoutState.processing;
    notifyListeners();

    try {
      final orderId = await _repo.createOrder(_cartItems);

      await _repo.payOrder(
        orderId: orderId,
        phone: phone,
        operator: operator,
      );

      // Start polling — payment confirmation is asynchronous.
      await pollOrder(orderId);
    } on ApiException catch (e) {
      _checkoutState = CheckoutState.failed;
      _toast.show(e.userMessage);
      notifyListeners();
    } catch (e) {
      _checkoutState = CheckoutState.failed;
      _toast.show('Checkout failed. Please try again.');
      notifyListeners();
    }
  }

  // ── Order Polling ─────────────────────────────────────────────────────────

  /// Polls [getOrder] every 5 s for up to 20 times and resolves once the
  /// order status indicates success (status == 'paid' | 'confirmed').
  ///
  /// Called automatically by [checkout]; may also be called manually to resume
  /// polling a pending order after a restart.
  Future<void> pollOrder(String orderId) async {
    _pollCount = 0;
    _checkoutState = CheckoutState.polling;
    notifyListeners();

    final completer = Completer<void>();

    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(_pollInterval, (timer) async {
      _pollCount++;

      try {
        final order = await _repo.getOrder(orderId);
        final status = (order['status'] as String? ?? '').toLowerCase();

        if (status == 'paid' || status == 'confirmed') {
          timer.cancel();
          _pollTimer = null;
          clearCart();
          _checkoutState = CheckoutState.done;
          _toast.show('Payment confirmed! Your order is being prepared.');
          notifyListeners();
          if (!completer.isCompleted) completer.complete();
          return;
        }
      } on ApiException catch (e) {
        // Non-fatal poll failure — log and keep trying.
        debugPrint('pollOrder error: ${e.message}');
      } catch (e) {
        debugPrint('pollOrder unexpected error: $e');
      }

      if (_pollCount >= _maxPolls) {
        timer.cancel();
        _pollTimer = null;
        _checkoutState = CheckoutState.failed;
        _toast.show(
            'Payment confirmation timed out. Please check your order history.');
        notifyListeners();
        if (!completer.isCompleted) completer.complete();
      }
    });

    return completer.future;
  }

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }
}
