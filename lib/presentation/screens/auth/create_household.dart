import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/app_colors.dart';
import '../../viewmodels/auth_provider.dart';
//créer un foyer
class CreateHousehold  extends ConsumerStatefulWidget{

  const CreateHousehold({super.key});
  @override
  ConsumerState<CreateHousehold> createState() => _CreateHouseholdViewState();
}


class _CreateHouseholdViewState extends ConsumerState<CreateHousehold> {
  final _nameController = TextEditingController(text: "Famille Jean");
  final String _generatedCode = const Uuid().v4().substring(0, 6).toUpperCase();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.indigo),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
            'Retour', style: TextStyle(color: AppColors.indigo, fontSize: 16)),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.indigo.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                        Icons.home_filled, color: AppColors.indigo, size: 40),
                  ),
                  const SizedBox(height: 24),
                  const Text('Créer un Ménage',
                      style: TextStyle(fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1E293B))),
                  const SizedBox(height: 8),
                  const Text('Donnez un nom à votre foyer',
                      style: TextStyle(color: AppColors.textMuted)),
                  const SizedBox(height: 32),


                  _buildLabel('Nom du Ménage'),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.indigo,
                            width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  const SizedBox(height: 24),

                  // Code d'invitation
                  _buildCodeBox(),

                  const SizedBox(height: 32),


                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_nameController.text.isNotEmpty) {
                          await ref
                              .read(authStateProvider.notifier)
                              .createHousehold(_nameController.text);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.indigo,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius
                            .circular(16)),
                        elevation: 0,
                      ),
                      child: const Text('Créer et Continuer',
                          style: TextStyle(color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0, left: 4),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ),
    );
  }
  Widget _buildCodeBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F3FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.indigo.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_upload_outlined, size: 16, color: AppColors.textMuted),
              const SizedBox(width: 8),
              const Text('Code d\'invitation à partager :',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 60,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(_generatedCode,
                      style: const TextStyle(fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppColors.indigo,
                          letterSpacing: 2)),
                ),
              ),
              const SizedBox(width: 12),
              // Bouton Partager
              GestureDetector(
                onTap: () {
                  Share.share(
                    'Rejoins mon foyer StockWise ! Voici le code : $_generatedCode',
                    subject: 'Code d\'invitation',
                  );
                },
                child: Container(
                  width: 60, height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.indigo,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: AppColors.indigo.withOpacity(0.3),
                                           blurRadius: 8,
                                            offset: const Offset(0, 4))],
                  ),
                  child: const Icon(Icons.share, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

