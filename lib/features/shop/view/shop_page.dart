import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/status_views.dart';
import '../../../domain/entities/shop_product.dart';
import '../viewmodel/shop_viewmodel.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShopViewModel>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ShopViewModel>();

    return Container(
      color: AppColors.cream,
      child: Stack(
        children: [
          Column(
            children: [
              _Header(vm: vm),
              Expanded(child: _Body(vm: vm)),
            ],
          ),
          if (vm.hasCart) _CartBar(vm: vm),
          if (vm.checkoutOpen) _CheckoutSheet(vm: vm),
        ],
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.vm});
  final ShopViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.cream,
      padding: const EdgeInsets.fromLTRB(
          20, AppSpacing.statusBar, 20, 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pitch Store', style: AppText.h2),
                Text(
                  'Gear, kits & matchday essentials',
                  style: AppText.small,
                ),
              ],
            ),
          ),
          if (vm.hasCart)
            CircleIconButton(
              background: AppColors.primary,
              onTap: vm.openCheckout,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.shopping_bag_outlined,
                      size: 18, color: AppColors.cream),
                  Positioned(
                    top: -6,
                    right: -6,
                    child: Container(
                      width: 16,
                      height: 16,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: AppColors.lime,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${vm.cartItemCount}',
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Body ─────────────────────────────────────────────────────────────────────

class _Body extends StatelessWidget {
  const _Body({required this.vm});
  final ShopViewModel vm;

  @override
  Widget build(BuildContext context) {
    switch (vm.state) {
      case ViewState.loading:
        return const LoadingView(label: 'Loading products…');
      case ViewState.error:
        return StatusView(
          glyph: '🛒',
          title: 'Could not load products',
          message: vm.error,
          actionLabel: 'Try again',
          onAction: vm.load,
        );
      case ViewState.ready:
        if (vm.products.isEmpty) {
          return const StatusView(
            glyph: '📦',
            title: 'No products yet',
            message: 'Check back soon — we\'re stocking up.',
          );
        }
        return _ProductGrid(vm: vm);
    }
  }
}

class _ProductGrid extends StatelessWidget {
  const _ProductGrid({required this.vm});
  final ShopViewModel vm;

  @override
  Widget build(BuildContext context) {
    final bottomPad = vm.hasCart ? 96.0 : 24.0;

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: vm.load,
      child: GridView.builder(
        padding: EdgeInsets.fromLTRB(16, 8, 16, bottomPad),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.72,
        ),
        itemCount: vm.products.length,
        itemBuilder: (_, i) => _ProductCard(
          product: vm.products[i],
          qty: vm.cart[vm.products[i].id] ?? 0,
          onAdd: () => vm.addToCart(vm.products[i].id),
          onRemove: () => vm.removeFromCart(vm.products[i].id),
        ),
      ),
    );
  }
}

// ─── Product Card ──────────────────────────────────────────────────────────────

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.qty,
    required this.onAdd,
    required this.onRemove,
  });

  final ShopProduct product;
  final int qty;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.rCard),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image / fallback
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppSpacing.rCard)),
            child: AspectRatio(
              aspectRatio: 1.1,
              child: _ProductImage(
                imageUrl: product.imageUrl,
                name: product.name,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.cardTitle.copyWith(fontSize: 13),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      Formatters.tsh(product.priceTzs),
                      style: AppText.label.copyWith(
                          fontSize: 12.5, color: AppColors.primary),
                    ),
                    const Spacer(),
                    _StockBadge(stock: product.stock),
                  ],
                ),
                const SizedBox(height: 8),
                _CartControl(
                  inStock: product.inStock,
                  qty: qty,
                  onAdd: onAdd,
                  onRemove: onRemove,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({this.imageUrl, required this.name});
  final String? imageUrl;
  final String name;

  @override
  Widget build(BuildContext context) {
    final hasPhoto = imageUrl != null && imageUrl!.isNotEmpty;
    if (hasPhoto) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallback(),
        frameBuilder: (context, child, frame, wasSync) {
          if (wasSync) return child;
          return AnimatedOpacity(
            opacity: frame == null ? 0 : 1,
            duration: const Duration(milliseconds: 300),
            child: child,
          );
        },
      );
    }
    return _fallback();
  }

  Widget _fallback() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryGradientEnd],
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: AppColors.lime,
        ),
      ),
    );
  }
}

class _StockBadge extends StatelessWidget {
  const _StockBadge({required this.stock});
  final int stock;

  @override
  Widget build(BuildContext context) {
    if (stock <= 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.orangeBg,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          'Out',
          style: AppText.tiny.copyWith(
              color: AppColors.orange, fontWeight: FontWeight.w700),
        ),
      );
    }
    if (stock <= 5) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.orangeBg,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          '$stock left',
          style: AppText.tiny.copyWith(
              color: AppColors.orange, fontWeight: FontWeight.w700),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

class _CartControl extends StatelessWidget {
  const _CartControl({
    required this.inStock,
    required this.qty,
    required this.onAdd,
    required this.onRemove,
  });

  final bool inStock;
  final int qty;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    if (!inStock) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.neutralFill,
          borderRadius: BorderRadius.circular(AppSpacing.rMd),
        ),
        child: Text('Out of stock',
            style:
                AppText.tiny.copyWith(color: AppColors.faint)),
      );
    }

    if (qty == 0) {
      return GestureDetector(
        onTap: onAdd,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppSpacing.rMd),
          ),
          child: Text(
            'Add to cart',
            style: AppText.tiny.copyWith(
                color: AppColors.cream, fontWeight: FontWeight.w700),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppSpacing.rMd),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              child: const Icon(Icons.remove,
                  size: 14, color: AppColors.cream),
            ),
          ),
          Expanded(
            child: Text(
              '$qty',
              textAlign: TextAlign.center,
              style: AppText.label
                  .copyWith(color: AppColors.cream, fontSize: 13),
            ),
          ),
          GestureDetector(
            onTap: onAdd,
            child: Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              child: const Icon(Icons.add,
                  size: 14, color: AppColors.lime),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Cart Summary Bar ─────────────────────────────────────────────────────────

class _CartBar extends StatelessWidget {
  const _CartBar({required this.vm});
  final ShopViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 16,
      right: 16,
      bottom: 24,
      child: GestureDetector(
        onTap: vm.openCheckout,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppSpacing.rCard),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.lime.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${vm.cartItemCount}',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.lime),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'View cart',
                  style: AppText.label
                      .copyWith(color: AppColors.cream, fontSize: 14),
                ),
              ),
              Text(
                Formatters.tsh(vm.cartTotal),
                style: AppText.label.copyWith(
                    color: AppColors.lime, fontSize: 14),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.arrow_forward_ios,
                  size: 12, color: AppColors.lime),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Checkout Sheet ───────────────────────────────────────────────────────────

class _CheckoutSheet extends StatefulWidget {
  const _CheckoutSheet({required this.vm});
  final ShopViewModel vm;

  @override
  State<_CheckoutSheet> createState() => _CheckoutSheetState();
}

class _CheckoutSheetState extends State<_CheckoutSheet> {
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _phoneController.text = widget.vm.phone;
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.vm;

    return GestureDetector(
      onTap: vm.closeCheckout,
      child: Container(
        color: Colors.black.withValues(alpha: 0.45),
        child: GestureDetector(
          onTap: () {}, // Prevent dismissal on sheet tap
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                  20, 24, 20, MediaQuery.of(context).viewInsets.bottom + 32),
              decoration: const BoxDecoration(
                color: AppColors.cream,
                borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppSpacing.rSheet)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.handle,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Checkout', style: AppText.h3),
                  const SizedBox(height: 4),
                  Text(
                    '${vm.cartItemCount} item${vm.cartItemCount == 1 ? '' : 's'} · ${Formatters.tsh(vm.cartTotal)}',
                    style: AppText.bodyMuted,
                  ),
                  const SizedBox(height: 20),
                  // Phone field
                  Text('Mobile number', style: AppText.label),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppSpacing.rLg),
                      border: Border.all(color: AppColors.inputBorder),
                    ),
                    child: TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(12),
                      ],
                      onChanged: vm.setPhone,
                      style: AppText.body,
                      decoration: InputDecoration(
                        hintText: '0712 345 678',
                        hintStyle: AppText.body
                            .copyWith(color: AppColors.faint),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        border: InputBorder.none,
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(left: 12, right: 8),
                          child: Icon(Icons.phone_outlined,
                              size: 18, color: AppColors.muted),
                        ),
                        prefixIconConstraints:
                            const BoxConstraints(minWidth: 0, minHeight: 0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Operator chips
                  Text('Payment via', style: AppText.label),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _OperatorChip(
                          label: 'M-Pesa',
                          color: AppColors.mpesa,
                          selected: vm.selectedOperator == 'mpesa',
                          onTap: () => vm.setOperator('mpesa'),
                        ),
                        const SizedBox(width: 8),
                        _OperatorChip(
                          label: 'Airtel',
                          color: AppColors.airtel,
                          selected: vm.selectedOperator == 'airtel',
                          onTap: () => vm.setOperator('airtel'),
                        ),
                        const SizedBox(width: 8),
                        _OperatorChip(
                          label: 'HaloPesa',
                          color: AppColors.halo,
                          selected: vm.selectedOperator == 'halopesa',
                          onTap: () => vm.setOperator('halopesa'),
                        ),
                        const SizedBox(width: 8),
                        _OperatorChip(
                          label: 'TigoPesa',
                          color: AppColors.mixx,
                          selected: vm.selectedOperator == 'tigopesa',
                          onTap: () => vm.setOperator('tigopesa'),
                        ),
                      ],
                    ),
                  ),
                  if (vm.checkoutState == CheckoutState.failed) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.orangeBg,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.rMd),
                      ),
                      child: Text(
                        'Payment failed. Please check your number and try again.',
                        style: AppText.small
                            .copyWith(color: AppColors.orange),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  PrimaryButton(
                    label: vm.isCheckingOut
                        ? 'Processing…'
                        : 'Pay ${Formatters.tsh(vm.cartTotal)}',
                    enabled: !vm.isCheckingOut &&
                        vm.phone.trim().isNotEmpty,
                    onTap: () => vm.checkout(
                        phone: vm.phone, operator: vm.selectedOperator),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OperatorChip extends StatelessWidget {
  const _OperatorChip({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.12) : AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.pill),
          border: Border.all(
            color: selected ? color : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: AppText.label.copyWith(
            fontSize: 12.5,
            color: selected ? color : AppColors.bodyText,
          ),
        ),
      ),
    );
  }
}
