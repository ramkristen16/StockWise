import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stock_wise/presentation/viewmodels/stock_provider.dart';

import '../../../core/navigation/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_textStyle.dart';
import '../../../data/models/product_model.dart';
import '../product/add_product_screen.dart';

class DashboardScreen extends ConsumerWidget{
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(stockProvider);
    final notifier = ref.read(stockProvider.notifier);
    final topPad = MediaQuery.of(context).padding.top;

    //getion d'état vide
    if (products.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            _DashboardHeader(topPad: topPad),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('📦', style: TextStyle(fontSize: 56)),
                    const SizedBox(height: 16),
                    Text(
                      'Votre stock est vide',
                      style: AppTextStyles.h2.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ajoutez votre premier produit !',
                      style: AppTextStyles.subtitle,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const AddProductScreen()),
                      ),
                      icon: const Icon(Icons.add),
                      label: Text('Ajouter un produit',
                          style: AppTextStyles.button),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.indigo,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DashboardHeader(topPad: topPad),
            const SizedBox(height: 24),
            const _ConsommationChart(),
            const SizedBox(height: 24),
            const _CriticalSection(),
            const SizedBox(height: 24),
            const _ExpiringSection(),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const AddProductScreen()),
                  ),
                  icon: const Icon(Icons.add, size: 22),
                  label: Text('Ajouter un produit',
                      style: AppTextStyles.button),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.indigo,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}



//header
class _DashboardHeader extends ConsumerWidget {
  final double topPad;
  const _DashboardHeader({required this.topPad});
  String _formatAr(double value) {
    final int v = value.toInt();
    if (v >= 1000) {
      return '${(v ~/ 1000)} ${(v % 1000).toString().padLeft(3, '0')}';
    }
    return '$v';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(stockProvider.notifier);
    final products = ref.watch(stockProvider);
    final totalQty = products.length;
    final criticalCount = products.where((p) => p.isCritical).length;
    final totalValue = products.fold(0.0, (sum, p) => sum + (p.price * p.quantity));

    final monthlyExp = notifier.checkedShoppingList;

    return Container(
      padding: EdgeInsets.only(
        top: topPad + 16,
        left: 20, right: 20, bottom: 24,
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bonjour,',
                      style: AppTextStyles.subtitle.copyWith(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Famille Rakoto',
                      style: AppTextStyles.h2.copyWith(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.inventory_2_outlined,
                    color: Colors.white, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              // Total
              Expanded(
                child: _StatCard(
                  icon: Icons.inventory_2_outlined,
                  label: 'Total',
                  value: '$totalQty',
                  sub: '${_formatAr(totalValue)} Ar',
                  bgColor: const Color(0xFF2D3F55),
                  textColor: Colors.white,
                  iconColor: Colors.white70,
                ),
              ),
              const SizedBox(width: 10),
              // Critique
              Expanded(
                child: _StatCard(
                  icon: Icons.warning_amber_rounded,
                  label: 'Critique',
                  value: '$criticalCount',
                  bgColor: AppColors.alertOrange,
                  textColor: Colors.white,
                  iconColor: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              // Dépenses
              Expanded(
                child: _StatCard(
                  icon: Icons.attach_money_rounded,
                  label: 'Dépenses',
                  value: '${monthlyExp.toStringAsFixed(0)} Ar',
                  bgColor: AppColors.successGreen,
                  textColor: Colors.white,
                  iconColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Carte stat
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? sub;
  final Color bgColor;
  final Color textColor;
  final Color iconColor;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    this.sub,
    required this.bgColor,
    required this.textColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(icon, color: iconColor, size: 14),
          const SizedBox(width: 5),
          Text(label,
              style: AppTextStyles.caption.copyWith(
                color: textColor.withOpacity(0.85),
                fontSize: 11,
              )),
        ]),
        const SizedBox(height: 8),
        Text(value,
            style: AppTextStyles.h2.copyWith(
              color: textColor,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            )),
        if (sub != null)
          Text(sub!,
              style: AppTextStyles.caption.copyWith(
                color: textColor.withOpacity(0.7),
                fontSize: 10,
              )),
      ],
    ),
  );
}


//graphe de consommation par mois , affichage des 6 derniers mois
class _ConsommationChart extends ConsumerWidget {
  const _ConsommationChart();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(stockProvider.notifier);
    final percentages = notifier.last6MonthsPercentages;
    final labels = notifier.last6MonthsLabels;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CONSOMMATION',
            style: AppTextStyles.fieldLabel.copyWith(
              color: AppColors.indigo,
              fontSize: 14,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (i) {
                final barHeight =
                (percentages[i] * 120).clamp(4.0, 120.0);
                final isCurrentMonth = i == 5;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Barre dynamique
                        AnimatedContainer(
                          duration:
                          Duration(milliseconds: 300 + i * 80),
                          curve: Curves.easeOut,
                          height: barHeight,
                          decoration: BoxDecoration(
                            color: isCurrentMonth
                                ? const Color(0xFF1E293B)
                                : AppColors.indigo.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Label mois
                        Text(
                          labels[i],
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 12,
                            color: isCurrentMonth
                                ? AppColors.foreground
                                : AppColors.textMuted,
                            fontWeight: isCurrentMonth
                                ? FontWeight.w700
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// stock sous le seuil critique
class _CriticalSection extends ConsumerWidget {
  const _CriticalSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(stockProvider);
    final notifier = ref.read(stockProvider.notifier);
    final critical = notifier.shoppingList;


    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Container(
                width: 10, height: 10,
                decoration: const BoxDecoration(
                  color: AppColors.alertOrange,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Stock Critique',
                style: AppTextStyles.h2.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  ref.read(showCriticalOnlyProvider.notifier).state = true;
                  ref.read(navIndexProvider.notifier).state = 1;
                },

                child: Text(
                  'Voir tout',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.indigo,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (critical.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(' Aucun produit critique',
                style: AppTextStyles.subtitle),
          )
        else
          SizedBox(
            height: 200,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: critical.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) =>
                  _CriticalCard(product: critical[i]),
            ),
          ),
      ],
    );
  }
}
//carte pour les cartes en seuil critique
class _CriticalCard extends StatelessWidget {
  final ProductModel product;
  const _CriticalCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final isOut = product.quantity == 0;
    return Container(
      width: 150,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.alertOrange, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: AppColors.alertOrange.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.warning_amber_rounded,
                color: AppColors.alertOrange, size: 26),
          ),
          const SizedBox(height: 10),
          Text(
            product.name,
            style: AppTextStyles.fieldLabel.copyWith(
              fontSize: 14, fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            product.category,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textMuted, fontSize: 12,
            ),
          ),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${product.quantity.toInt()}',
                style: AppTextStyles.h2.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: isOut
                      ? AppColors.errorRed
                      : AppColors.alertOrange,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  ' /${product.threshold}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
          Text(
            product.unity ?? 'unités',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textMuted, fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
//expire bientot
class _ExpiringSection extends ConsumerWidget {
  const _ExpiringSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(stockProvider);
    final notifier = ref.read(stockProvider.notifier);
    final expiring = notifier.expiringSoonList;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.access_time_rounded,
                color: AppColors.alertOrange, size: 20),
            const SizedBox(width: 8),
            Text(
              'Expire bientôt',
              style: AppTextStyles.h2.copyWith(
                fontSize: 18, fontWeight: FontWeight.w800,
              ),
            ),
          ]),
          const SizedBox(height: 12),
          if (expiring.isEmpty)
            Text(' Aucun produit expirant bientôt',
                style: AppTextStyles.subtitle)
          else
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: expiring.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  color: AppColors.border,
                  indent: 16, endIndent: 16,
                ),
                itemBuilder: (_, i) =>
                    _ExpiringRow(product: expiring[i]),
              ),
            ),
        ],
      ),
    );
  }
}

// Ligne expiration
class _ExpiringRow extends StatelessWidget {
  final ProductModel product;
  const _ExpiringRow({required this.product});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final daysLeft = product.expiryDate != null
        ? ((product.expiryDate!.difference(now).inHours) / 24).ceil().clamp(0, 999)
        : 0;
    final isUrgent = daysLeft <= 2;

    const monthNames = [
      'Jan','Fév','Mar','Avr','Mai','Jun',
      'Jul','Aoû','Sep','Oct','Nov','Déc'
    ];
    final dateStr = product.expiryDate != null
        ? 'Expire le ${product.expiryDate!.day.toString().padLeft(2,'0')} '
        '${monthNames[product.expiryDate!.month - 1]}'
        : 'Date inconnue';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: isUrgent
                  ? AppColors.errorRed.withOpacity(0.12)
                  : AppColors.alertOrange.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.access_time_rounded,
              color: isUrgent ? AppColors.errorRed : AppColors.alertOrange,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name,
                    style: AppTextStyles.fieldLabel.copyWith(
                      fontSize: 14, fontWeight: FontWeight.w700,
                    )),
                Text(dateStr,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textMuted, fontSize: 12,
                    )),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: isUrgent ? AppColors.errorRed : AppColors.alertOrange,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              daysLeft == 0 ? 'Auj.' : '${daysLeft}j',
              style: AppTextStyles.caption.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}




