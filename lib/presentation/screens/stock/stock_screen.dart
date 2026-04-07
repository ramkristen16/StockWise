import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stock_wise/presentation/viewmodels/stock_provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_textStyle.dart';
import '../../../data/models/product_model.dart';

class StockScreen extends ConsumerWidget {
  const StockScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(filteredProductsProvider);
    final notifier = ref.read(stockProvider.notifier);
    final topPad = MediaQuery
        .of(context)
        .padding
        .top;



    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _StockHeader(notifier: notifier, topPad: topPad),
          _CategoryBar(notifier: notifier),
          Expanded(
            child: products.isEmpty
                ? const _EmptyState()
                : GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.72,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: products.length,
              itemBuilder: (_, i) => _ProductCard(product: products[i]),
            ),
          ),
        ],
      ),
    );
  }
}

//Header
class _StockHeader extends ConsumerWidget {
  final dynamic notifier;
  final double topPad;
  const _StockHeader({required this.notifier, required this.topPad});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(filteredProductsProvider);
    final total = products.length;
    final faibles = products.where((p) => p.isCritical && p.quantity > 0).length;

    return Container(
      padding: EdgeInsets.only(
        top: topPad + 16,
        left: 20, right: 20, bottom: 20,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mon Stock',
                      style: AppTextStyles.h2.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(children: [
                      Text(
                        '$total produits',
                        style: AppTextStyles.subtitle.copyWith(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 13,
                        ),
                      ),
                      if (faibles > 0) ...[
                        const SizedBox(width: 6),
                        Container(
                          width: 6, height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.alertOrange,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$faibles faibles',
                          style: AppTextStyles.subtitle.copyWith(
                            color: AppColors.alertOrange,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ]),
                  ],
                ),
              ),
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.tune_rounded, color: Colors.white, size: 22),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Barre de recherche
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              onChanged: notifier.updateSearchQuery,
              style: AppTextStyles.fieldValue,
              decoration: InputDecoration(
                hintText: 'Rechercher un produit...',
                hintStyle: AppTextStyles.fieldHint,
                prefixIcon: const Icon(Icons.search_rounded,
                    color: AppColors.textMuted, size: 20),
                border: InputBorder.none,
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


//categories scrollables horizontales fixés
class _CategoryBar extends ConsumerWidget {
  final dynamic notifier;
  const _CategoryBar({required this.notifier});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(stockProvider);
    final selected = ref.read(stockProvider.notifier).selectedCategory;
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: ['Tout', ...ProductCategory.all].map((cat) {
            final isSelected = (cat == selected);
            return GestureDetector(

              onTap: () => notifier.updateCategory(cat == 'Tout' ? 'Tout' : cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.indigo : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(children: [
                  Text(
                    cat == 'Tout' ? '🏠' : ProductCategory.iconOf(cat),
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    cat,
                    style: AppTextStyles.caption.copyWith(
                      color: isSelected ? Colors.white : AppColors.foreground,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ]),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

//container produit
class _ProductCard extends ConsumerWidget {
  final ProductModel product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(stockProvider.notifier);
    final bool outOfStock = product.quantity == 0;
    final bool isCritical = product.isCritical && !outOfStock;

    Color borderColor = Colors.transparent;
    if (outOfStock) borderColor = AppColors.errorRed;
    else if (isCritical) borderColor = AppColors.alertOrange;

    final categoryTheme = AppColors.getCategoryTheme(product.category);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderColor,
          width: borderColor == Colors.transparent ? 0 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge catégorie
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: categoryTheme['bg'],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${ProductCategory.iconOf(product.category)} ${product.category}',
                style: AppTextStyles.caption.copyWith(
                  color: categoryTheme['text'],
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Nom
            Text(
              product.name,
              style: AppTextStyles.fieldLabel.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),

            // Emplacement avec icône
            Text(
              '${ProductLocation.iconOf(product.location)} ${product.location}',
              style: AppTextStyles.subtitle.copyWith(
                color: AppColors.indigo,
                fontSize: 12,
              ),
            ),

            const Spacer(),

            // Quantité
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${product.quantity.toStringAsFixed(product.quantity % 1 == 0 ? 0 : 1)}',
                  style: AppTextStyles.h2.copyWith(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: outOfStock
                        ? AppColors.errorRed
                        : isCritical
                        ? AppColors.alertOrange
                        : AppColors.foreground,
                  ),
                ),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '/${product.threshold}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textMuted,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              product.unity ?? 'unités',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textMuted,
                fontSize: 11,
              ),
            ),

            const SizedBox(height: 10),

            // Boutons +/-
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _QtyButton(
                  icon: Icons.remove,
                  onTap: () => notifier.consumeOne(product),
                ),
                _QtyButton(
                  icon: Icons.add,
                  isAdd: true,
                  onTap: () => notifier.incrementOne(product),
                ),
              ],
            ),

            // Badge statut
            if (outOfStock || isCritical) ...[
              const SizedBox(height: 8),
              _StatusBadge(isRupture: outOfStock),
            ],
          ],
        ),
      ),
    );
  }
}

// Bouton quantité +/-
class _QtyButton extends StatelessWidget {
  final IconData icon;
  final bool isAdd;
  final VoidCallback onTap;
  const _QtyButton({
    required this.icon,
    this.isAdd = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isAdd ? AppColors.indigo : AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: isAdd ? Colors.white : AppColors.foreground,
        size: 18,
      ),
    ),
  );
}

// Badge rupture ; stock faible
class _StatusBadge extends StatelessWidget {
  final bool isRupture;
  const _StatusBadge({required this.isRupture});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 5),
    decoration: BoxDecoration(
      color: isRupture
          ? AppColors.errorRed
          : AppColors.alertOrange.withOpacity(0.15),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          isRupture ? Icons.close_rounded : Icons.warning_amber_rounded,
          color: isRupture ? Colors.white : AppColors.alertOrange,
          size: 13,
        ),
        const SizedBox(width: 4),
        Text(
          isRupture ? 'Rupture' : 'Stock Faible',
          style: AppTextStyles.caption.copyWith(
            color: isRupture ? Colors.white : AppColors.alertOrange,
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
        ),
      ],
    ),
  );
}

// État vide
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('📦', style: TextStyle(fontSize: 48)),
        const SizedBox(height: 16),
        Text(
          'Aucun produit trouvé',
          style: AppTextStyles.fieldLabel.copyWith(
            color: AppColors.textMuted,
          ),
        ),
      ],
    ),
  );
}


