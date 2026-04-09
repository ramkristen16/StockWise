import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_textStyle.dart';
import '../../../data/models/product_model.dart';
import '../../viewmodels/stock_provider.dart';

// Helper formatage Ar
String _formatAr(double value) {
  final v = value.toInt();
  if (v >= 1000) return '${v ~/ 1000} ${(v % 1000).toString().padLeft(3,'0')}';
  return '$v';
}


class ShoppingListScreen extends ConsumerWidget {
  const ShoppingListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(stockProvider);
    final notifier = ref.watch(stockProvider.notifier);
    final list = notifier.shoppingList;
    final checkedCount = list.where((p) => p.isChecked).length;
    final estimatedTotal = notifier.estimatedShoppingTotal;
    final checkedTotal   = notifier.checkedShoppingList;
    final topPad         = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(children: [
        _ShoppingHeader(
          topPad: topPad,
          checkedCount: checkedCount,
          total: list.length,
        ),
        // ... (ton code précédent)
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 160),
            itemCount: list.length + 1,
            itemBuilder: (context, i) {
              if (i == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: _AddProductButton(
                    onTap: () => _showQuickAddDialog(context, ref),
                  ),
                );
              }

              final product = list[i - 1];
              return _ShoppingItem(
                product: product,
                onEdit: () => _showEditBottomSheet(context, ref, product),
              );
            },
          ),
        ),


      ]),
      bottomSheet: _ShoppingFooter(
        estimatedTotal:  estimatedTotal,
        checkedTotal:    checkedTotal,
        checkedCount:    checkedCount,
        onValidate: checkedCount == 0 ? null : () async {
          await ref.read(stockProvider.notifier).validateAllChecked();
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('$checkedCount article(s) achetés — pensez à les ranger !'),
              backgroundColor: AppColors.successGreen,
              behavior: SnackBarBehavior.floating,
            ));
          }
        },
      ),
    );
  }

}

  void _showEditBottomSheet(
      BuildContext context, WidgetRef ref, ProductModel product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditBottomSheet(product: product, ref: ref),
    );
  }

void _showQuickAddDialog(BuildContext context, WidgetRef ref) {
  final nameCtrl = TextEditingController();
  final priceCtrl = TextEditingController();

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Ajout rapide au panier'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nom du produit')),
          TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: 'Prix estimé (Ar)'), keyboardType: TextInputType.number),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
        ElevatedButton(
          onPressed: () {
            if (nameCtrl.text.isNotEmpty) {
              final price = double.tryParse(priceCtrl.text) ?? 0.0;
              ref.read(stockProvider.notifier).addNewProductToShoppingList(nameCtrl.text, price);
              Navigator.pop(ctx);
            }
          },
          child: const Text('Ajouter'),
        ),
      ],
    ),
  );
}



  //header
class _ShoppingHeader extends StatelessWidget {
  final double topPad;
  final int checkedCount;
  final int total;

  const _ShoppingHeader({
    required this.topPad,
    required this.checkedCount,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
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
      child: Row(
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
                  'Liste des Courses',
                  style: AppTextStyles.h2.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$checkedCount sur $total articles cochés',
                  style: AppTextStyles.subtitle.copyWith(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.shopping_cart_outlined,
              color: Colors.white, size: 22,
            ),
          ),
        ],
      ),
    );
  }
}

//bouton ajouter un produit
class _AddProductButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddProductButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Text(
          'Ajouter un produit',
          style: AppTextStyles.fieldHint.copyWith(fontSize: 15),
        ),
        trailing: Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: AppColors.indigo,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

//item
class _ShoppingItem extends ConsumerWidget {
  final ProductModel product;
  final VoidCallback onEdit;

  const _ShoppingItem({required this.product, required this.onEdit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(stockProvider.notifier);
    final bool isRupture = product.quantity == 0;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: product.isChecked ? Colors.grey.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: product.isChecked
              ? Colors.transparent
              : (isRupture ? AppColors.errorRed.withOpacity(0.3) : AppColors.alertOrange.withOpacity(0.3)),
          width: 1,
        ),
      ),
      child: ListTile(
        onTap: () => notifier.toggleCheck(product),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 26, height: 26,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: product.isChecked ? AppColors.indigo : Colors.transparent,
            border: Border.all(
              color: product.isChecked ? AppColors.indigo : AppColors.textMuted,
              width: 2,
            ),
          ),
          child: product.isChecked
              ? const Icon(Icons.check, color: Colors.white, size: 16)
              : null,
        ),
        title: Row(
          children: [
            Text(
              ProductCategory.iconOf(product.category),
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                product.name,
                style: AppTextStyles.fieldLabel.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  decoration: product.isChecked ? TextDecoration.lineThrough : TextDecoration.none,
                  color: product.isChecked ? AppColors.textMuted : AppColors.foreground,
                ),
              ),
            ),
            Text(
              '${_formatAr(product.price)} Ar',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: product.isChecked ? AppColors.textMuted : AppColors.indigo
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(left: 28, top: 2),
          child: Text(
            'Objectif: ${product.idealQuantity} ${product.unity} • ${product.category}',
            style: AppTextStyles.subtitle.copyWith(
              fontSize: 12,
              color: AppColors.textMuted,
            ),
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit_outlined, size: 18),
          color: AppColors.indigo,
          onPressed: onEdit,
        ),
      ),
    );
  }
}

//bottom sheet edit pour les produits présents à cocher
class EditBottomSheet extends StatefulWidget {
  final ProductModel product;
  final WidgetRef ref;

  const EditBottomSheet({required this.product, required this.ref});

  @override
  State<EditBottomSheet> createState() => _EditBottomSheetState();
}

class _EditBottomSheetState extends State<EditBottomSheet> {
  late TextEditingController _qtyController;
  late String _selectedUnit;
  late TextEditingController _priceController;
  late String _selectedLocation;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _qtyController = TextEditingController(
      text: (widget.product.idealQuantity > 0
          ? widget.product.idealQuantity
          : widget.product.threshold.toDouble())
          .toStringAsFixed(0),
    );
    _selectedUnit = widget.product.unity;
    _priceController = TextEditingController(
      text: widget.product.price.toStringAsFixed(0),
    );
    _selectedLocation = widget.product.location.isEmpty
        ? ProductLocation.define
        : widget.product.location;

    _selectedDate = widget.product.expiryDate;
  }

  @override
  void dispose() {
    _qtyController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomPad),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.product.name,
            style: AppTextStyles.h2.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Modifier avant validation',
            style: AppTextStyles.subtitle.copyWith(
              color: AppColors.textMuted,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              // quantité
              Expanded(
                flex: 2, // Plus large
                child: _InputField(
                  label: 'Quantité',
                  controller: _qtyController,
                  keyboardType: TextInputType.number,
                  suffix: _selectedUnit,
                ),
              ),
              const SizedBox(width: 12),
              // unité
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Unité', style: AppTextStyles.fieldLabel.copyWith(fontSize: 13)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedUnit,
                          isExpanded: true,
                          items: ['pcs', 'kg', 'L', 'sac', 'paquet, boite'].map((u) =>
                              DropdownMenuItem(value: u, child: Text(u, style: const TextStyle(fontSize: 13)))
                          ).toList(),
                          onChanged: (v) => setState(() => _selectedUnit = v!),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _InputField(
            label: 'Prix unitaire',
            controller: _priceController,
            keyboardType: TextInputType.number,
            suffix: 'Ar / $_selectedUnit',
          ),

          const SizedBox(height: 16),
          Text(
            'Emplacement',
            style: AppTextStyles.fieldLabel.copyWith(fontSize: 13),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedLocation,
                isExpanded: true,
                style: AppTextStyles.fieldValue,
                items: ProductLocation.all.map((loc) {
                  return DropdownMenuItem(
                    value: loc,
                    child: Row(
                      children: [
                        Text(ProductLocation.iconOf(loc)),
                        const SizedBox(width: 8),
                        Text(loc),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedLocation = val);
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate ?? DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2030),
                builder: (context, child) => Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: AppColors.indigo,
                    ),
                  ),
                  child: child!,
                ),
              );
              if (picked != null) setState(() => _selectedDate = picked);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_outlined,
                      color: AppColors.indigo, size: 18),
                  const SizedBox(width: 10),
                  Text(
                    _selectedDate == null
                        ? 'Date d\'expiration (optionnel)'
                        : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                    style: AppTextStyles.fieldValue.copyWith(
                      color: _selectedDate == null
                          ? AppColors.textMuted
                          : AppColors.foreground,
                    ),
                  ),
                  const Spacer(),
                  if (_selectedDate != null)
                    GestureDetector(
                      onTap: () => setState(() => _selectedDate = null),
                      child: Icon(Icons.close,
                          color: AppColors.textMuted, size: 16),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.indigo,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () async {
                try {
                  final qty = double.tryParse(_qtyController.text) ?? widget.product.idealQuantity;
                  print("Prix saisi dans le champ : ${_priceController.text}");
                  final price = double.tryParse(_priceController.text) ?? widget.product.price;
                  print("DEBUG: Prix converti en nombre = $price");

                  final updated = widget.product.copyWith(
                    idealQuantity: qty,
                    unity: _selectedUnit,
                    price: price,
                    location: _selectedLocation,
                    expiryDate: _selectedDate,
                    status: _selectedLocation == ProductLocation.define
                        ? StockStatus.pending
                        : StockStatus.active,
                  );

                  await widget.ref
                      .read(stockProvider.notifier)
                      .addOrUpdateProduct(updated);

                  if (context.mounted) {
                    Navigator.of(context).pop(); // Ferme le BottomSheet
                  }
                } catch (e) {
                  debugPrint("Erreur lors de la confirmation : $e");
                }
              },
              child: const Text(
                'Confirmer',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }
}
//input
class _InputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String suffix;

  const _InputField({
    required this.label,
    required this.controller,
    required this.keyboardType,
    required this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTextStyles.fieldLabel.copyWith(fontSize: 13)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child:
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: AppTextStyles.fieldValue,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              suffixText: suffix,
              suffixStyle: AppTextStyles.subtitle.copyWith(
                color: AppColors.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

        ),
      ],
    );
  }
}
//estimation prix de stocks existants dans shooping et estimation pour seulement cochés
class _ShoppingFooter extends StatelessWidget {
  final double estimatedTotal;
  final double checkedTotal;
  final int checkedCount;
  final VoidCallback? onValidate;

  const _ShoppingFooter({
    required this.estimatedTotal,
    required this.checkedTotal,
    required this.checkedCount,
    required this.onValidate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20, 16, 20,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          //estimation de tous les stocks présents dans shopping list
        Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Estimation stock actuel',
              style: AppTextStyles.caption.copyWith(color: AppColors.textMuted)),
          Text(
            '${_formatAr(estimatedTotal)} Ar',
            style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
        const SizedBox(height: 4),
      // Panier sélectionné (gros, visible)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Panier ($checkedCount articles)',
                style: AppTextStyles.fieldLabel.copyWith(fontWeight: FontWeight.w700)),
            Text(
              '${_formatAr(checkedTotal)} Ar',
              style: AppTextStyles.h2.copyWith(
                fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.indigo,
              ),
            ),
          ],
        ),
          const SizedBox(height: 12),
          //bouton valider

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: onValidate == null
                    ? Colors.grey[300]
                    : const Color(0xFF22C55E),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: onValidate,
              icon: const Icon(Icons.check_rounded,
                  color: Colors.white, size: 20),
              label: Text(
                checkedCount > 0
                    ? 'Valider les achats ($checkedCount)'
                    : 'Valider les achats',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ]
      ),

    );
  }
}

// état vide

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) =>
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🛒', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(
              'Aucun article à acheter',
              style: AppTextStyles.fieldLabel.copyWith(
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tous vos stocks sont bons !',
              style: AppTextStyles.subtitle.copyWith(
                color: AppColors.textMuted,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
}



