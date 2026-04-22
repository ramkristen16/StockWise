import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_textStyle.dart';
import '../../viewmodels/stock_provider.dart';
import '../../../data/models/product_model.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(stockProvider);
    final notifier  = ref.read(stockProvider.notifier);
    final topPad    = MediaQuery.of(context).padding.top;
    final allProducts = ref.watch(stockProvider);

    final List<_NotifItem> items = [];


    for (final p in allProducts.where((p) => p.isExpired || p.isExpiringSoon)) {
      final expiry = p.expiryDate;
      if (expiry != null) {
        final days = expiry.difference(DateTime.now()).inDays;
        final bool isExpired = p.isExpired;

        items.add(_NotifItem(
          icon: isExpired ? Icons.dangerous : Icons.access_time_rounded,
          color: isExpired ? AppColors.errorRed : AppColors.alertOrange,
          title: isExpired ? 'PÉRIMÉ — ${p.name}' : 'Expire bientôt — ${p.name}',
          subtitle: isExpired ? 'À jeter immédiatement' : (days == 0 ? 'Expire aujourd\'hui !' : 'Expire dans $days jour(s)'),
          product: p,
        ));
      }
    }



    for (final p in allProducts.where((p) => p.quantity == 0 || p.isCritical)) {
      final bool outOfStock = p.quantity == 0;
      items.add(_NotifItem(
        icon: outOfStock ? Icons.close_rounded : Icons.warning_amber_rounded,
        color: outOfStock ? AppColors.errorRed : AppColors.alertOrange,
        title: outOfStock ? 'Rupture — ${p.name}' : 'Stock faible — ${p.name}',
        subtitle: outOfStock ? 'Stock épuisé' : '${p.quantity.toInt()} ${p
            .unity} restant(s)',
        product: p,
      ));
    }


      return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(children: [
        Container(
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
          child: Row(children: [
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Notifications',
                    style: AppTextStyles.h2.copyWith(
                      fontSize: 22, fontWeight: FontWeight.w800,
                      color: Colors.white,
                    )),
                Text('${items.length} alerte(s) active(s)',
                    style: AppTextStyles.subtitle.copyWith(
                      color: Colors.white.withOpacity(0.7),
                    )),
              ],
            )),
            // Badge count
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: items.isEmpty
                    ? Colors.white.withOpacity(0.18)
                    : AppColors.errorRed,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${items.length}',
                style: AppTextStyles.fieldLabel.copyWith(
                  color: Colors.white, fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ]),
        ),

        Expanded(
          child: items.isEmpty
              ? _buildEmpty()
              : ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _NotifCard(item: items[i]),
          ),
        ),
      ]),
    );
  }

  Widget _buildEmpty() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('✅', style: TextStyle(fontSize: 48)),
        const SizedBox(height: 16),
        Text('Tout est sous contrôle !',
            style: AppTextStyles.fieldLabel.copyWith(
                color: AppColors.textMuted)),
        const SizedBox(height: 4),
        Text('Aucune alerte pour le moment.',
            style: AppTextStyles.subtitle.copyWith(
                color: AppColors.textMuted, fontSize: 13)),
      ],
    ),
  );
}

class _NotifItem {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final ProductModel product;
  _NotifItem({
    required this.icon, required this.color,
    required this.title, required this.subtitle,
    required this.product,
  });
}

class _NotifCard extends StatelessWidget {
  final _NotifItem item;
  const _NotifCard({required this.item});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: item.color.withOpacity(0.3)),
      boxShadow: [BoxShadow(
        color: Colors.black.withOpacity(0.04),
        blurRadius: 8, offset: const Offset(0, 2),
      )],
    ),
    child: Row(children: [
      // Icône colorée
      Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          color: item.color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(item.icon, color: item.color, size: 22),
      ),
      const SizedBox(width: 12),

      Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.title,
              style: AppTextStyles.fieldLabel.copyWith(
                  fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(item.subtitle,
              style: AppTextStyles.caption.copyWith(
                  color: AppColors.textMuted, fontSize: 12)),
        ],
      )),
      Container(
        width: 10, height: 10,
        decoration: BoxDecoration(
          color: item.color, shape: BoxShape.circle,
        ),
      ),
    ]),
  );
}