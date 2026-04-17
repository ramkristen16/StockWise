import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_textStyle.dart';
import 'create_household.dart';
import 'join_household.dart';
//creer ou rejoindre un foyer
class SetupHouseholdScreen  extends StatelessWidget{
  const SetupHouseholdScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
        body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                  children: [
                  const SizedBox(height: 80),

              const Icon(Icons.house_siding_rounded, size: 80, color: AppColors.indigo),
              const SizedBox(height: 32),
              Text('Bienvenue !', style: AppTextStyles.h1),
              const SizedBox(height: 12),
              const Text(
                'Pour commencer, configurez votre foyer familial.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMuted),
              ),
              const SizedBox(height: 60),
            //boutton creer
              _BigButton(
                title: 'Créer un Ménage',
                icon: Icons.add_home_rounded,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CreateHousehold()),
                ),
              ),

              const SizedBox(height: 20),
              //bouton rejoindre
              _BigButton(
                title: 'Rejoindre un Ménage',
                icon: Icons.login_rounded,
                isOutlined: true,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const JoinHousehold()),
                ),
              ),
            ],

            ),
            ),
        )
    );
  }


}

class _BigButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool isOutlined;

  const _BigButton({
    required this.title,
    required this.icon,
    required this.onTap,
    this.isOutlined = false,
  });
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 70,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: isOutlined ? AppColors.indigo : Colors.white),
        label: Text(title, style: TextStyle(
          color: isOutlined ? AppColors.indigo : Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        )),
        style: ElevatedButton.styleFrom(
          backgroundColor: isOutlined ? Colors.white : AppColors.indigo,
          side: isOutlined ? const BorderSide(color: AppColors.indigo, width: 2) : null,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: isOutlined ? 0 : 4,
        ),
      ),
    );
  }
}