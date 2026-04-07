import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/legacy.dart';
import 'package:stock_wise/core/theme/app_colors.dart';
import 'package:stock_wise/core/theme/app_textStyle.dart';
import 'package:stock_wise/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:stock_wise/presentation/screens/family/family_screen.dart';
import 'package:stock_wise/presentation/screens/product/add_product_screen.dart';
import 'package:stock_wise/presentation/screens/shopping/shopping_list_screen.dart';
import 'package:stock_wise/presentation/screens/stock/stock_screen.dart';

final navIndexProvider = StateProvider<int>((ref) => 0);

//capable d'écouter Riverpod
class MainScaffold extends ConsumerWidget {
  const MainScaffold({super.key});
  static const List<Widget> _screens = [
    DashboardScreen(),
    StockScreen(),
    ShoppingListScreen(),
    AddProductScreen(),
    FamilyScreen(),
  ];
  @override

  Widget build(BuildContext context, WidgetRef ref) {
    //rebuild automatique quand il change
    final currentIndex = ref.watch(navIndexProvider);

    return Scaffold(
     backgroundColor: AppColors.background,

      body: IndexedStack(
        index: currentIndex,
        children: _screens,
      ),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.white,

          boxShadow:[
            BoxShadow(
              color: Colors.black.withOpacity(0.006),
              blurRadius : 12,
              offset: const Offset(0, -2),
            )
          ] ,
        ),
        child: SafeArea(
            child: Padding(
                padding: const EdgeInsetsGeometry.symmetric(vertical: 12),
                child: Row(
                  children: [
                    _NavItem(
                      index: 0,
                      currentIndex: currentIndex,
                      icon: Icons.home_rounded,
                      label: 'Accueil',
                      onTap: (i) => ref.read(navIndexProvider.notifier).state = i,
                    ),

                    _NavItem(
                      index: 1,
                      currentIndex: currentIndex,
                      icon: Icons.inventory_2_rounded,
                      label: 'Stock',
                      onTap: (i) => ref.read(navIndexProvider.notifier).state = i,
                    ),

                    _NavItem(
                      index: 2,
                      currentIndex: currentIndex,
                      icon: Icons.shopping_cart_outlined,
                      label: 'Course',
                      onTap: (i) => ref.read(navIndexProvider.notifier).state = i,
                    ),

                    _NavItem(
                      index: 3,
                      currentIndex: currentIndex,
                      icon: Icons.add,
                      label: 'Ajouter',
                      onTap: (i) => ref.read(navIndexProvider.notifier).state = i,
                    ),
                    _NavItem(
                      index: 4,
                      currentIndex: currentIndex,
                      icon: Icons.family_restroom_rounded,
                      label: 'Famille',
                      onTap: (i) => ref.read(navIndexProvider.notifier).state = i,
                    ),
                  ],
                ),
              ),
            ),

        ),

      );
  }
}

class _NavItem extends StatelessWidget {
  final int index;
  final int currentIndex;
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final void Function(int) onTap;

  const _NavItem({
    required this.index,
    required this.currentIndex,
    required this.icon,
    this.activeIcon,
    required this.label,
    required this.onTap,
    });

  @override
  Widget build(BuildContext context) {
    // pour vérifier l'icone actif
    final bool isActive = index == currentIndex;

    //couleur active
    final Color color = isActive ? AppColors.indigo : AppColors.warningYellow;


    return Expanded(
        child: GestureDetector(
          onTap: () => onTap(index),
          behavior: HitTestBehavior.opaque,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(

                isActive && activeIcon != null ? activeIcon! :icon,
                color: color,
                size: 24,
              ),
              const SizedBox(height: 4),

              Text(
                label,
                style: AppTextStyles.navLabel.copyWith(color: color),
              )
            ],
          ),
        )
    );
  }



}