import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stock_wise/presentation/viewmodels/stock_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/category_icon.dart';
import '../../../core/navigation/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_textStyle.dart';
import '../../../data/models/product_model.dart';
import '../product/add_product_screen.dart';
import 'package:intl/intl.dart';


class StockScreen extends ConsumerWidget {
  const StockScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showCriticalOnly = ref.watch(showCriticalOnlyProvider);
    final allProducts = ref.watch(filteredProductsProvider);

    final products = showCriticalOnly
        ? allProducts.where((p) => p.isCritical).toList()
        : allProducts;

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
          if (showCriticalOnly)
            _CriticalFilterBanner(onClear: () {
              ref.read(showCriticalOnlyProvider.notifier).state = false;
              ref.read(stockProvider.notifier).updateCategory('Tout');
            }),
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
    final ruptures = products.where((p) => p.quantity == 0).length;

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
                onTap: () {
                  ref.read(navIndexProvider.notifier).state = 0;

                },
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

                      if (ruptures > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 6, height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.errorRed,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$ruptures vide',
                          style: AppTextStyles.subtitle.copyWith(
                            color: AppColors.errorRed,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],

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
                child: const Icon(Icons.inventory_2_rounded, color: Colors.white, size: 22),
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
    final selected = ref.watch(stockProvider.notifier).selectedCategory;
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
              onTap: () {
                notifier.updateCategory(cat == 'Tout' ? 'Tout' : cat);
                ref.read(showCriticalOnlyProvider.notifier).state = false;
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.indigo : Colors.white,
                  borderRadius: BorderRadius.circular(14),

                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : AppColors.border,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(children: [
                  CategoryIcon(
                    path: cat == 'Tout'
                        ? 'assets/Icon/tout.svg'
                        : ProductCategory.iconOf(cat),
                    size: 22,
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


  Widget _buildExpiryBadge() {
    if (product.expiryDate == null) return const SizedBox.shrink();

    final bool expired = product.isExpired;
    final bool soon    = product.isExpiringSoon && !expired;
    final now = DateTime.now();
    final diff = product.expiryDate!.difference(now);
    final daysLeft = diff.inHours > 0
        ? (diff.inHours / 24).ceil()
        : 0;

    if (!expired && !soon) return const SizedBox.shrink();
    return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              expired ? Icons.dangerous_rounded : Icons.access_time_rounded,
              size: 12,
              color: expired ? AppColors.errorRed : AppColors.alertOrange,
            ),
            const SizedBox(width: 3),
            Flexible(
              child: Text(
                expired
                    ? 'PÉRIMÉ'
                    : daysLeft == 0
                    ? 'Expire auj.'
                    : 'Dans ${daysLeft}j',

                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: expired ? AppColors.errorRed : AppColors.alertOrange,
                ),
                overflow: TextOverflow.ellipsis,
              ),

            ),
          ],
        ),
    );

  }


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(stockProvider.notifier);
    final bool outOfStock = product.quantity == 0;
    final bool isExpired = product.isExpired;
    final bool isSoon = product.isExpiringSoon;

    final bool isCritical = product.isCritical && !outOfStock;

    String alertLabel = '';
    bool showStatus = false;
    bool statusIsRupture = false;


    if (outOfStock) {
      alertLabel = 'Rupture';
      showStatus = true;
      statusIsRupture = true;
    } else if (isExpired) {
      alertLabel = 'Produit Périmé';
      showStatus = true;
      statusIsRupture = true;
    } else if (isSoon) {
      alertLabel = 'Périme Bientôt';
      showStatus = true;
      statusIsRupture = false;
    } else if (isCritical) {
      alertLabel = 'Stock Faible';
      showStatus = true;
      statusIsRupture = false;
    }




    Color borderColor = AppColors.border;
    if (outOfStock || isExpired) borderColor = AppColors.errorRed;
    else if (isCritical || isSoon) borderColor = AppColors.alertOrange;

    final categoryTheme = AppColors.getCategoryTheme(product.category);

    return GestureDetector(
      onLongPress: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => AddProductScreen(productEdit: product),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: borderColor,
            width: (borderColor == AppColors.errorRed || borderColor == AppColors.alertOrange) ? 2 : 1,
      
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: categoryTheme['bg'],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CategoryIcon(path: ProductCategory.iconOf(product.category), size: 16),
                        const SizedBox(width: 4),
                        Text(
                          product.category,
                          style: AppTextStyles.caption.copyWith(
                            color: categoryTheme['text'],
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),

                  ),
                  GestureDetector(
                    onTap: () => _showDeleteDialog(context, ref),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.errorRed.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.delete_outline,
                        size: 16,
                        color: AppColors.errorRed,
                      ),
                    ),
                  ),
                ],
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
              const SizedBox(height: 1),

              _buildExpiryBadge(),

              const SizedBox(height: 2),


              // Emplacement avec icône
              Row(
                children: [
                  CategoryIcon(
                    path: ProductLocation.iconOf(product.location),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    product.location,
                    style: AppTextStyles.subtitle.copyWith(
                      color: AppColors.indigo, fontSize: 12,
                    ),
                  ),
                ],
              ),
      
              const Spacer(),
      
              // Quantité
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${product.quantity.toStringAsFixed(product.quantity % 1 == 0 ? 0 : 1)}',
                    style: AppTextStyles.h2.copyWith(
                      fontSize: 24,
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
      
              const SizedBox(height: 8),
      
              // Boutons +/-
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                
                  _QtyButton(
                    icon: Icons.add,
                    onTap: () => notifier.incrementOne(product),
                  ),
                  _QtyButton(
                    icon: Icons.remove,
                    isMin: true,
                    onTap: () =>_showConsumeDialog(context, ref,product),
                  ),
      
                ],
              ),


              // Badge statut
              if (showStatus) ...[
                const SizedBox(height: 4),
                _StatusBadge(
                  isRupture: statusIsRupture,
                  label: alertLabel,
                ),
              ],

            ],
          ),
        ),
      ),
    );
  }
  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer ?'),
        content: Text('Voulez-vous vraiment retirer "${product.name}" de votre stock ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              ref.read(stockProvider.notifier).removeProduct(product.id);
              Navigator.pop(context);
            },
            child: Text('Supprimer', style: TextStyle(color: AppColors.errorRed)),
          ),
        ],
      ),
    );
  }

}

// Bouton quantité +/-
class _QtyButton extends StatelessWidget {
  final IconData icon;
  final bool isMin;
  final VoidCallback onTap;
  const _QtyButton({
    required this.icon,
    this.isMin = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isMin ? AppColors.indigo : AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: isMin ? Colors.white : AppColors.foreground,
        size: 18,
      ),
    ),
  );
}


//pour le popUp si c'est pas 1 que retire
void _showConsumeDialog(BuildContext context, WidgetRef ref, ProductModel product) {
  final TextEditingController _amountController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text("Consommer ${product.name}"),
      content: TextField(
        controller: _amountController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        autofocus: true,
        decoration: InputDecoration(
          hintText: "Quantité à retirer",

          suffixText: product.unity ?? 'unités',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler", style: TextStyle(color: AppColors.primaryNavy),)),
        ElevatedButton(
          onPressed: () {
            final val = double.tryParse(_amountController.text) ?? 0;
            if (val > 0) {
              ref.read(stockProvider.notifier).consumeAmount(product, val);
              Navigator.pop(context);
            }
          },
          child: const Text("Valider",style: TextStyle(color: AppColors.indigo),),
        ),
      ],
    ),
  );
}

// Badge rupture ; stock faible
class _StatusBadge extends StatelessWidget {
  final bool isRupture;
  final String label;
  const _StatusBadge({required this.isRupture,   required this.label,});

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
          label,
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
//pour voir seulement les stocks critiques depuis dashboard
class _CriticalFilterBanner extends StatelessWidget {
  final VoidCallback onClear;
  const _CriticalFilterBanner({required this.onClear});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: AppColors.alertOrange.withOpacity(0.12),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.alertOrange.withOpacity(0.4)),
    ),
    child: Row(children: [
      const Icon(Icons.filter_list_rounded,
          color: AppColors.successGreen, size: 16),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          'Filtre actif : Stock critique uniquement',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.alertOrange,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      // Bouton pour effacer le filtre
      GestureDetector(
        onTap: onClear,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.successGreen,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Tout voir',
            style: AppTextStyles.caption.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    ]),
  );
}


