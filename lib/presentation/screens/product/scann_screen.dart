import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_textStyle.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});
  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  bool _hasScanned = false;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose(); }


  // detecte le code barre
  void _onBarcodeDetected(BarcodeCapture capture) {
    if (_hasScanned) return;
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null || raw.isEmpty) return;
    _hasScanned = true;
    _scannerController.stop();
    Navigator.of(context).pop(raw);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(children: [
        MobileScanner(
            controller: _scannerController,
            onDetect:_onBarcodeDetected ),

        _TopBar(
            onBack: () => Navigator.of(context).pop(null),
            onFlash: () => _scannerController.toggleTorch()
        ),

        Center(child: _ScanFrame()),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 80),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('Placez le code-barres dans le cadre',
                  style: AppTextStyles.body.copyWith(color: Colors.white)),
              const SizedBox(height: 4),
              Text('Détection automatique',
                  style: AppTextStyles.caption.copyWith(color: Colors.white54)),
            ]),
          ),
        ),
      ]),
    );
  }
  }

 //barrre supérieure avce retour et flash
class _TopBar extends StatelessWidget {
  final VoidCallback onBack, onFlash;
  const _TopBar({required this.onBack, required this.onFlash});


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(children: [
          _IconButton(icon: Icons.arrow_back, onTap: onBack),
          const SizedBox(width: 12),
          Expanded(child: Text('Scanner un produit',
              style: AppTextStyles.h2)),
        _IconButton(icon: Icons.flash_on_outlined, onTap: onFlash),
        ]),
      ),
    );
  }
}
//Iconbutton
class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 40, height: 40,
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: Colors.white, size: 22),
    ),
  );
}

//cadre de scan
class _ScanFrame extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: 260, height: 175,
    decoration: BoxDecoration(
      border: Border.all(color: AppColors.indigo, width: 2),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Stack(children: [
      _FrameCorner(top: 0, left: 0),
      _FrameCorner(top: 0, right: 0),
      _FrameCorner(bottom: 0, left: 0),
      _FrameCorner(bottom: 0, right: 0),
    ]),
  );
}

//coin du cadre de scan
class _FrameCorner extends StatelessWidget {
  final double? top, bottom, left, right;

  const _FrameCorner({this.top,
                      this.bottom,
                      this.left,
                      this.right}
                    );

  @override
  Widget build(BuildContext context) => Positioned(
    top: top, bottom: bottom, left: left, right: right,
    child: Container(width: 22, height: 22,
        decoration: BoxDecoration(border: Border(
          top:    top    != null ? const BorderSide(color: AppColors.indigo, width: 3) : BorderSide.none,
          bottom: bottom != null ? const BorderSide(color: AppColors.indigo, width: 3) : BorderSide.none,
          left:   left   != null ? const BorderSide(color: AppColors.indigo, width: 3) : BorderSide.none,
          right:  right  != null ? const BorderSide(color: AppColors.indigo, width: 3) : BorderSide.none,
        ))
    ),
  );
}
