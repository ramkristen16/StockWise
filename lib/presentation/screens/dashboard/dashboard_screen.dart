import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stock_wise/presentation/viewmodels/stock_provider.dart';

import '../../../core/navigation/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_textStyle.dart';
import '../../../data/models/product_model.dart';
import '../../viewmodels/auth_provider.dart';
import '../../viewmodels/family_provider.dart';
import '../product/add_product_screen.dart';
import '../shopping/shopping_list_screen.dart';
import 'expiring_all_screen.dart';
import 'notification_screen.dart';

class DashboardScreen extends ConsumerWidget{
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(stockProvider);
    final notifier = ref.read(stockProvider.notifier);
    final topPad = MediaQuery.of(context).padding.top;

    //gestion d'état vide
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
            const _InboxSection(),
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


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final householdAsync = ref.watch(householdDetailsProvider);
    final familyName = householdAsync.value?.name ?? "Mon Foyer";
    final authState = ref.watch(authStateProvider);
    final userName = authState.value?.displayName ?? "Utilisateur";
    final allProducts = ref.watch(stockProvider);
    final notifier = ref.read(stockProvider.notifier);

    final alertCount = notifier.shoppingList.length + notifier.expiringSoonList.length;


    final int totalQty = allProducts.fold(0, (sum, p) => sum + p.quantity.toInt());
    final double totalValue = allProducts.fold(0.0, (total, item) => total + (item.price * item.quantity));

    final int expiredCount = allProducts.where((p) => p.isExpired).length;
    final int soonCount = notifier.expiringSoonList.length;
    final int criticalCount = allProducts.where((p) => p.isCritical && p.quantity > 0).length;
    final int ruptureCount = allProducts.where((p) => p.quantity == 0).length;


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
                       familyName,
                      style: AppTextStyles.h2.copyWith(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

    GestureDetector(
        onTap: () => Navigator.of(context).push(
         MaterialPageRoute(builder: (_) => const NotificationScreen()),
    ),
        child: Stack(
        clipBehavior: Clip.none,
    children: [
    Container(
        width: 48, height: 48,
        decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(16),
    ),
       child: const Icon(
          Icons.notifications_outlined,
          color: Colors.white,
          size: 24
    ),
    ),

    if (alertCount > 0)
        Positioned(
          top: -4,
          right: -4,
          child: Container(
               padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                color: AppColors.errorRed, shape: BoxShape.circle,

    ),
        constraints: const BoxConstraints(
        minWidth: 20,
         minHeight: 20,
    ),
        child: Center(
            child: Text(
              alertCount > 9 ? '9+' : '$alertCount',
          style: const TextStyle(
         color: Colors.white,   fontSize: 10,
            fontWeight: FontWeight.w900,
            ),
        ),
      ),
      ),
       ),
       ],
        ),
    )

    ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.inventory_2_outlined,
                  label: 'Total',
                  value: '$totalQty',
                  sub: '${_formatAr(totalValue)} Ar',
                  bgColor: const Color(0xFF2D3F55),
                  textColor: Colors.white,
                  iconColor: Colors.white.withOpacity(0.6),
                ),
              ),
              const SizedBox(width: 10),

              Expanded(
                child: _StatCard(
                  icon: Icons.warning_amber_rounded,
                  label: 'Critique',
                  value: '${ruptureCount + criticalCount}',
                  sub: ruptureCount > 0 ? '$ruptureCount en rupture' : 'À racheter',
                  bgColor: AppColors.alertOrange,
                  textColor: Colors.white,
                  iconColor: Colors.white,
                ),
              ),
              const SizedBox(width: 10),

              Expanded(
                child: _StatCard(
                  icon: Icons.timer_outlined,
                  label: 'Dates',
                  value: '${expiredCount + soonCount}',
                  sub: expiredCount > 0 ? '$expiredCount périmé(s) !' : 'À consommer',
                  bgColor: expiredCount > 0 ? AppColors.errorRed : AppColors.successGreen,
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
    final monthlyExp = ref.watch(stockProvider.notifier).monthlyExpenses;



    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,

            children: [
              Column(
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
                  const SizedBox(height: 4),
                  Text(
                    'Tendance des 6 mois',
                    style: AppTextStyles.subtitle.copyWith(fontSize: 12),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(

                    '${_formatAr(monthlyExp)} Ar',
                    style: AppTextStyles.h2.copyWith(
                      fontSize: 18,
                      color: AppColors.successGreen,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    'ce mois',
                    style: AppTextStyles.caption.copyWith(fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (i) {
                final barHeight = (percentages[i] * 120).clamp(6.0, 120.0);
                final isCurrentMonth = i == 5;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AnimatedContainer(
                          duration:
                          Duration(milliseconds:500),
                          curve: Curves.easeOut,
                          height: barHeight,
                          decoration: BoxDecoration(
                            color: isCurrentMonth
                                ? const Color(0xFF1E293B)
                                : AppColors.indigo.withOpacity(0.5),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),

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
                            fontWeight: isCurrentMonth ? FontWeight.w700 : FontWeight.normal,
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

// stock sous le seuil critique et rupture
class _CriticalSection extends ConsumerWidget {
  const _CriticalSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(stockProvider);
    final notifier = ref.read(stockProvider.notifier);
    final critical = notifier.shoppingList;

    final sortedCritical = List<ProductModel>.from(critical)
      ..sort((a, b) => a.quantity.compareTo(b.quantity));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, right:24),
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
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryNavy,
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
                    decorationColor: const Color(0xFF4C4DDC).withOpacity(0.4),

                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (sortedCritical.isEmpty)
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
                  _CriticalCard(product: sortedCritical[i]),
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

    final cardColor = isOut ? const Color(0xFFDC2626) : AppColors.alertOrange;

    return Container(
      width: 150,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isOut ? AppColors.errorRed : AppColors.alertOrange,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: isOut
                  ? AppColors.errorRed.withOpacity(0.12)
                  : AppColors.alertOrange.withOpacity(0.15),
              shape: BoxShape.circle,
            ),

            child: Icon(
                isOut ? Icons.close_rounded : Icons.warning_amber_rounded,
                color:cardColor,
                size: 26),
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
    final expiring = ref.watch(stockProvider.notifier).expiringSoonList;
    if (expiring.isEmpty) return const SizedBox.shrink();

    final displayList = expiring.take(3).toList();
    final hasMore = expiring.length > 3;


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
                color: AppColors.primaryNavy
              ),
            ),
          ]),
          if (hasMore)
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ExpiringAllScreen()),
              ),
              child: Text('Voir tout (${expiring.length})',
                  style: TextStyle(color: AppColors.indigo, fontWeight: FontWeight.bold)),
            ),
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
                itemCount: displayList.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  color: AppColors.border,
                  indent: 16, endIndent: 16,
                ),
                itemBuilder: (_, i) =>
                    ExpiringRow(product: displayList[i]),
              ),
            ),
        ],
      ),
    );
  }
}

// Ligne expiration
class ExpiringRow extends StatelessWidget {
  final ProductModel product;
  const ExpiringRow({required this.product});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final expiry = product.expiryDate;

    final bool isExpired = product.isExpired;
    final int daysLeft = expiry != null
        ? (expiry.difference(now).inHours / 24).ceil().clamp(0, 999)
        : 0;

    final Color statusColor = isExpired ? AppColors.errorRed : AppColors.alertOrange;

    String badgeText;
    if (isExpired) {
      badgeText = 'PÉRIMÉ';
    } else if (daysLeft == 0) {
      badgeText = 'AUJOURD\'HUI';
    } else {
      badgeText = '${daysLeft}J';
    }

    const monthNames = [
      'Jan','Fév','Mar','Avr','Mai','Jun',
      'Jul','Aoû','Sep','Oct','Nov','Déc'
    ];

    String dateStr = 'Date inconnue';
    if (expiry != null) {
      dateStr = 'Expire le ${expiry.day.toString().padLeft(2, '0')} ${monthNames[expiry.month - 1]}';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          // Icône avec cercle de couleur
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isExpired ? Icons.dangerous : Icons.access_time_rounded,
              color: statusColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          // Nom et Date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: AppTextStyles.fieldLabel.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isExpired ? AppColors.errorRed : AppColors.primaryNavy,
                  ),
                ),
                Text(dateStr,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textMuted, fontSize: 12,
                    )),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: statusColor.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Text(
              badgeText,
              style: AppTextStyles.caption.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 10,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InboxSection extends ConsumerWidget {
const _InboxSection();

@override
Widget build(BuildContext context, WidgetRef ref) {
  final allProducts = ref.watch(stockProvider);

  final pending = allProducts.where((p) => p.status == 'pending').toList();


  if (pending.isEmpty) return const SizedBox.shrink();

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(

            children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.indigo,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${pending.length}',
              style: AppTextStyles.caption.copyWith(
                color: Colors.white, fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Produits à ranger',
            style: AppTextStyles.h2.copyWith(
              fontSize: 18, fontWeight: FontWeight.w800,
              color: AppColors.primaryNavy
            ),
          ),
        ]),
        const SizedBox(height: 4),
        Text(
          'Achetés mais pas encore rangés dans un emplacement',
          style: AppTextStyles.subtitle.copyWith(fontSize: 12),
        ),
        const SizedBox(height: 12),
        // Liste des produits pending
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.indigo.withOpacity(0.3)),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: pending.length,
            separatorBuilder: (_, __) => Divider(
              height: 1, color: AppColors.border, indent: 16, endIndent: 16,
            ),
            itemBuilder: (_, i) => _PendingRow(product: pending[i]),
          ),
        ),
      ],
    ),
  );
}
}

class _PendingRow extends ConsumerWidget {
  final ProductModel product;
  const _PendingRow({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(

      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      leading: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: AppColors.indigo.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.inventory_2_outlined,
            color: AppColors.indigo, size: 20),
      ),
      title: Text(product.name,
          style: AppTextStyles.fieldLabel.copyWith(fontSize: 14)),
      subtitle: Text(
        'À ranger : ${product.quantity > 0 ? product.quantity.toInt() : product.idealQuantity.toInt()} ${product.unity}',
        style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
      ),

      // Bouton "Ranger" → ouvre EditBottomSheet
      trailing: GestureDetector(
        onTap: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => EditBottomSheet(product: product, ref: ref),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.indigo,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            'Ranger',
            style: AppTextStyles.caption.copyWith(
              color: Colors.white, fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
String _formatAr(double value) {
  final int v = value.toInt();
  return v.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} '
  );
}





