
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stock_wise/core/constants/app_constants.dart';
import 'package:stock_wise/core/theme/app_textStyle.dart';
import 'package:stock_wise/data/datasource/scanner_api_service.dart';
import 'package:stock_wise/data/models/product_model.dart';
import 'package:stock_wise/presentation/screens/product/scann_screen.dart';
import 'package:stock_wise/presentation/viewmodels/stock_provider.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/category_icon.dart';
import '../../../core/navigation/app_router.dart';
import '../../../core/theme/app_colors.dart';

class AddProductScreen extends ConsumerStatefulWidget {
  final ProductModel? productEdit ;
  final bool fromShopping;
  const AddProductScreen({super.key, this.productEdit, this.fromShopping = false});

  @override
  ConsumerState<AddProductScreen> createState() => _AddProductScreenState();

}
 class _AddProductScreenState extends ConsumerState<AddProductScreen> {

   final _nameController = TextEditingController();
   final _quantityController = TextEditingController(text: '1');
   final _unitController = TextEditingController();
   final _priceController = TextEditingController(text: '0');
   final _thresholdController = TextEditingController(text: '3');


   String _selectedCategory = ProductCategory.alimentaire;
   String _selectedLocation = ProductLocation.frigo;
   DateTime? _expiryDate;
   bool _isLoading = false;

   bool get _isEditMode => widget.productEdit != null;

   @override
   void initState() {
     super.initState();
     if (_isEditMode) {
       final p = widget.productEdit!;
       _nameController.text = p.name;
       _quantityController.text = p.quantity.toString();
       _unitController.text = p.unity ?? '';
       _priceController.text = p.price.toStringAsFixed(2);
       _thresholdController.text = p.threshold.toString();
       _selectedCategory = p.category;
       _selectedLocation = p.location;
       _expiryDate = p.expiryDate;
     }
   }

   @override
   void dispose() {
     _nameController.dispose();
     _quantityController.dispose();
     _unitController.dispose();
     _priceController.dispose();
     _thresholdController.dispose();
     super.dispose();
   }

// scan
   Future<void> _scanBarcode() async {

     final String? barcode = await Navigator.of(context).push<String>(
       MaterialPageRoute(builder: (_) => const ScanScreen()),
     );


     if (barcode == null || !mounted) return;


     setState(() => _isLoading = true);
     final result = await ScannerApiService().getProductFromBarcode(barcode);
     setState(() => _isLoading = false);

     if (!mounted) return;

     if (result == null) {
       _snack('Le service de scan est indisponible (Erreur serveur)', err: true);
     } else if (result['error'] != null) {
       _snack('Erreur : ${result['error']}', err: true);
     } else if (result['notFound'] == true) {
       _snack('Produit inconnu - remplissez manuellement');
     } else {
       setState(() {
         _nameController.text = result['name'] ?? '';
         _selectedCategory = result['category'] ?? _selectedCategory;
       });
       _snack('Produit trouvé : ${result['name']}');
     }

   }
    //sauvegarde
   Future<void> _save() async {
     FocusScope.of(context).unfocus();

     final notifierId = ref.read(stockProvider.notifier).householdId;
     final currentHouseholdId = notifierId.isNotEmpty
         ? notifierId
         : (widget.productEdit?.householdId ?? '');

     if (currentHouseholdId.isEmpty) {
       _snack("Erreur : Aucun foyer détecté.", err: true);
       return;
     }

     if (_nameController.text.trim().isEmpty) {
       _snack('Nom obligatoire', err: true);
       return;
     }

     if (!_isEditMode) {
       final existing = ref.read(stockProvider).firstWhere(
             (p) => p.name.toLowerCase().trim() == _nameController.text.toLowerCase().trim(),
         orElse: () => ProductModel.empty(),
       );

       if (existing.id.isNotEmpty) {
         final shouldMerge = await showDialog<bool>(
           context: context,
           builder: (_) => AlertDialog(
             title: const Text('Produit existant'),
             content: Text('Voulez-vous ajouter la quantité à "${existing.name}" ?'),
             actions: [
               TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Non')),
               ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Oui')),
             ],
           ),
         );

         if (shouldMerge != true) return;

         final newQty = (double.tryParse(_quantityController.text) ?? 1.0);
         final merged = existing.copyWith(
           quantity: existing.quantity + newQty,
           updateAt: DateTime.now(),
         );

         setState(() => _isLoading = true);
         await ref.read(stockProvider.notifier).addOrUpdateProduct(merged);
         if (!mounted) return;
         setState(() => _isLoading = false);

         _snack('Quantité ajoutée ✓');

         ref.read(navIndexProvider.notifier).state = 1;
         return;
       }
     }

     final p = ProductModel(
       id: _isEditMode ? widget.productEdit!.id : const Uuid().v4(),
       name: _nameController.text.trim(),
       category: _selectedCategory,
       location: _selectedLocation,
       quantity: widget.fromShopping ? 0.0 : (double.tryParse(_quantityController.text) ?? 1.0),
       unity: _unitController.text.trim().isEmpty ? 'unités' : _unitController.text.trim(),
       price: double.tryParse(_priceController.text) ?? 0.0,
       threshold: double.tryParse(_thresholdController.text.replaceAll(',', '.'))?.toInt() ?? 3,
       expiryDate: _expiryDate,
       updateAt: DateTime.now(),
       idealQuantity: double.tryParse(_quantityController.text) ?? 1.0,
       householdId: currentHouseholdId,
     );

     setState(() => _isLoading = true);
     await ref.read(stockProvider.notifier).addOrUpdateProduct(p);
     if (!mounted) return;
     setState(() => _isLoading = false);

     _snack(_isEditMode ? 'Produit modifié ✓' : "Ajouté ✓");

     if (_isEditMode || widget.fromShopping) {
       Navigator.of(context).pop();
     } else {
       ref.read(navIndexProvider.notifier).state = 1;
     }
   }

   //date
   Future<void> _pickDate() async {
     final d = await showDatePicker(
       context: context,
       initialDate: _expiryDate ?? DateTime.now().add(const Duration(days: 30)),
       firstDate: DateTime.now(),
       lastDate: DateTime.now().add(const Duration(days: 3650)),
       builder: (c, child) => Theme(
         data: ThemeData.light().copyWith(
           colorScheme: const ColorScheme.light(primary: AppColors.indigo, onPrimary: AppColors.white),
         ),
         child: child!,
       ),
     );
     if (d != null) setState(() => _expiryDate = d);
   }

//snack
   void _snack(String msg, {bool err = false}) =>
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
         content: Text(msg, style: AppTextStyles.caption.copyWith(color: AppColors.white)),
         backgroundColor: err ? AppColors.errorRed : AppColors.successGreen,
         behavior: SnackBarBehavior.floating,
         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
         margin: const EdgeInsets.all(16),
         duration: const Duration(seconds: 2),
       ));


  //body

   @override
   Widget build(BuildContext context) {
     return Scaffold(
       backgroundColor: AppColors.background,
       body: CustomScrollView(
         slivers: [

           SliverToBoxAdapter(child: _topBar()),
           SliverPadding(
             padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
             sliver: SliverList(delegate: SliverChildListDelegate([
               const SizedBox(height: 76),
               _nameCard(),
               const SizedBox(height: 12),
               _categoriesCard(),
               const SizedBox(height: 12),
               _locationCard(),
               const SizedBox(height: 12),
               _qtyUnitCard(),
               const SizedBox(height: 12),
               _priceDateCard(),
               const SizedBox(height: 12),
               _thresholdBox(),
               const SizedBox(height: 24),
               _submitBtn(),
             ])),
           ),
         ],
       ),
     );
   }

   //topbar
   Widget _topBar() {
     final topPad = MediaQuery.of(context).padding.top;
     return SizedBox(
       height: 130 + topPad + 80,
       child: Stack(
         clipBehavior: Clip.none,
         children: [
           Container(
             height: 130 + topPad,
             decoration: const BoxDecoration(
               color: Color(0xFF1E293B),
               borderRadius: BorderRadius.only(
                 bottomLeft: Radius.circular(28),
                 bottomRight: Radius.circular(28),
               ),
             ),
             padding: EdgeInsets.only(
               top: topPad + 16,
               left: 20, right: 20, bottom: 16,
             ),
             child: Row(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 GestureDetector(
                   onTap: () {
                     ref.read(navIndexProvider.notifier).state = 0;

                     if (Navigator.of(context).canPop()) {
                       Navigator.of(context).pop();
                     }
                   },

                   child: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
                 ),
                 const SizedBox(width: 12),
                 Expanded(
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Text(
                         _isEditMode ? 'Modifier le Produit' : 'Ajouter un Produit',
                         style: AppTextStyles.h2.copyWith(
                           fontSize: 24,
                           fontWeight: FontWeight.w800,
                           color: Colors.white,
                         ),
                       ),
                       const SizedBox(height: 4),
                       Text(
                         'Ajoutez un nouvel article à votre stock',
                         style: AppTextStyles.subtitle.copyWith(
                           color: Colors.white.withOpacity(0.7),
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
                   child: const Icon(Icons.add,
                       color: Colors.white, size: 22),
                 ),
               ],
             ),
           ),

           //  card qui contient le scan
           Positioned(
             bottom: -50,
             left: 16,
             right: 16,
             child: Container(
               padding: const EdgeInsets.all(8),
               decoration: BoxDecoration(
                 color: Colors.white,
                 borderRadius: BorderRadius.circular(20),
                 boxShadow: [
                   BoxShadow(
                     color: Colors.black.withOpacity(0.08),
                     blurRadius: 16,
                     offset: const Offset(0, 4),
                   ),
                 ],
               ),
               child: _scanBox(),
             ),
           ),
         ],
       ),
     );
   }
   //scan
   Widget _scanBox() => GestureDetector(
     onTap: _isLoading ? null : _scanBarcode,
     child: CustomPaint(
       painter: DashedBorderPainter(
         color: AppColors.indigo.withOpacity(0.4),
         strokeWidth: 1.5,

       ),
       child: Container(
         width: double.infinity,
         padding: const EdgeInsets.all(24),
         decoration: BoxDecoration(
           color: const Color(0xFFF8F9FF),
           borderRadius: BorderRadius.circular(16),
         ),
         child: Column(children: [
           Container(
             width: 48, height: 48,
             decoration: BoxDecoration(
               color: const Color(0xFFEEF2FF),
               borderRadius: BorderRadius.circular(14),
             ),
             child: _isLoading
                 ? const Padding(
               padding: EdgeInsets.all(12),
               child: CircularProgressIndicator(
                   color: AppColors.indigo, strokeWidth: 2.5),
             )
                 : const Icon(Icons.qr_code_scanner_rounded,
                 color: AppColors.indigo, size: 28),
           ),
           const SizedBox(height: 14),
           Text(
             'Scanner un code-barres',
             style: AppTextStyles.fieldLabel.copyWith(
               color: AppColors.indigo,
               fontSize: 16,
               fontWeight: FontWeight.w800,
             ),
           ),
           const SizedBox(height: 4),
           Text('ou remplissez manuellement ci-dessous',
               style: AppTextStyles.subtitle),
         ]),
       ),
     ),
   );
   // Helper
   Widget _card({required Widget child}) => Container(
     width: double.infinity,
     padding: const EdgeInsets.all(16),
     decoration: BoxDecoration(
       color: AppColors.white,
       borderRadius: BorderRadius.circular(16),
       boxShadow: [BoxShadow(
         color: Colors.black.withOpacity(0.04),
         blurRadius: 8, offset: const Offset(0, 2),
       )],
     ),
     child: child,
   );

   //nom du produit
   Widget _nameCard() => _card(child: Column(
     crossAxisAlignment: CrossAxisAlignment.start,
     children: [
       Text('Nom du Produit *', style: AppTextStyles.fieldLabel),
       const SizedBox(height: 10),
       _InputField(ctrl: _nameController, hint: 'Ex: Lait Bio Entier'),
     ],
   ));

   //catégories
   Widget _categoriesCard() => _card(child: Column(
     crossAxisAlignment: CrossAxisAlignment.start,
     children: [
       Text('Catégorie *', style: AppTextStyles.fieldLabel),
       const SizedBox(height: 12),
       GridView.builder(
         shrinkWrap: true,
         physics: const NeverScrollableScrollPhysics(),
         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
           crossAxisCount: 3,
           crossAxisSpacing: 10,
           mainAxisSpacing: 10,
           childAspectRatio: 1.1,
         ),
         itemCount: ProductCategory.all.length,
         itemBuilder: (_, i) {
           final c  = ProductCategory.all[i];
           final on = _selectedCategory == c;
           final th = AppColors.getCategoryTheme(c);
           return GestureDetector(
             onTap: () => setState(() => _selectedCategory = c),
             child: AnimatedContainer(
               duration: const Duration(milliseconds: 180),
               decoration: BoxDecoration(
                 color: on ? th['bg'] : AppColors.background,
                 borderRadius: BorderRadius.circular(12),
                 border: Border.all(
                   color: on ? th['text']!.withOpacity(0.5) : AppColors.border,
                   width: on ? 1.5 : 1,
                 ),
               ),
               child: Column(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   CategoryIcon(path: ProductCategory.iconOf(c), size: 26),

                   const SizedBox(height: 6),
                   Text(c,
                     style: AppTextStyles.caption.copyWith(
                       color: on ? th['text'] : AppColors.textMuted,
                       fontWeight: FontWeight.w600,
                     ),
                     textAlign: TextAlign.center,
                   ),
                 ],
               ),
             ),
           );
         },
       ),
     ],
   ));

   //location
   Widget _locationCard() => _card(child: Column(
     crossAxisAlignment: CrossAxisAlignment.start,
     children: [
       Row(children: [
         Text('Emplacement *', style: AppTextStyles.fieldLabel),
       ]),
       const SizedBox(height: 12),
       GridView.builder(
         shrinkWrap: true,
         physics: const NeverScrollableScrollPhysics(),
         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
           crossAxisCount: 2,
           crossAxisSpacing: 10,
           mainAxisSpacing: 10,
           childAspectRatio: 3.2,
         ),
         itemCount: ProductLocation.all.length,
         itemBuilder: (_, i) {
           final loc = ProductLocation.all[i];
           final on  = _selectedLocation == loc;
           final color = AppColors.getLocationColor(loc);
           return GestureDetector(
             onTap: () => setState(() => _selectedLocation = loc),
             child: AnimatedContainer(
               duration: const Duration(milliseconds: 180),
               padding: const EdgeInsets.symmetric(horizontal: 12),
               decoration: BoxDecoration(
                 color: on ? color.withOpacity(0.12) : AppColors.background,
                 borderRadius: BorderRadius.circular(12),
                 border: Border.all(
                   color: on ? color : AppColors.border,
                   width: on ? 1.5 : 1,
                 ),
               ),
               child: Row(children: [
                 CategoryIcon(
                   path: ProductLocation.iconOf(loc),
                   size: 26,
                 ),
                 const SizedBox(width: 8),
                 Text(
                   loc,
                   style: AppTextStyles.caption.copyWith(
                     color: on ? color : AppColors.foreground,
                     fontWeight: FontWeight.w600,
                     fontSize: 12,
                   ),
                 ),
               ]),
             ),
           );
         },
       ),
     ],
   ));
//Quantités ; unités
   Widget _qtyUnitCard() => _card(child: Column(
     crossAxisAlignment: CrossAxisAlignment.start,
     children: [
       Text('Quantité & Unité *', style: AppTextStyles.fieldLabel),
       const SizedBox(height: 12),
       Row(children: [
         Expanded(child: _FormField(label: 'Quantité',
             child: _InputField(ctrl: _quantityController, hint: '0',
                 kb: TextInputType.number, align: TextAlign.center))),
         const SizedBox(width: 12),
         Expanded(child: _FormField(label: 'Unité',
           child: _UnitDropdown(controller: _unitController),
         )),
       ]),
     ],
   ));

   //prix ; date d'expiration
   Widget _priceDateCard() => _card(child: Row(children: [

     Expanded(child: Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
         Row(children: [
           const Icon(Icons.attach_money_rounded, color: AppColors.textMuted, size: 16),
           const SizedBox(width: 4),
           Text('Prix', style: AppTextStyles.fieldLabel),
         ]),
         const SizedBox(height: 8),
         _InputField(ctrl: _priceController, hint: '0',
             kb: const TextInputType.numberWithOptions(decimal: true), prefix:'Ar '),
       ],
     )),
     const SizedBox(width: 12),
     // Date : calendrier
     Expanded(child: Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
         Row(children: [
           const Icon(Icons.calendar_today_rounded, color: AppColors.textMuted, size: 14),
           const SizedBox(width: 4),
           Text('Expiration', style: AppTextStyles.fieldLabel),
         ]),
         const SizedBox(height: 8),
         GestureDetector(
           onTap: _pickDate,
           child: Container(
             padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
             decoration: BoxDecoration(
               color: AppColors.white,
               borderRadius: BorderRadius.circular(10),
               border: Border.all(color: AppColors.border),
             ),
             child: Text(
               _expiryDate == null ? 'mm/dd/yyyy'
                   : '${_expiryDate!.month.toString().padLeft(2,'0')}/'
                   '${_expiryDate!.day.toString().padLeft(2,'0')}/'
                   '${_expiryDate!.year}',
               style: _expiryDate == null
                   ? AppTextStyles.fieldHint
                   : AppTextStyles.fieldValue,
             ),
           ),
         ),
       ],
     )),
   ]));
   //seuil critique
   Widget _thresholdBox() => Container(

     padding: const EdgeInsets.all(14),
     decoration: BoxDecoration(
       color: AppColors.white,
       borderRadius: BorderRadius.circular(12),
       border: Border.all(color: AppColors.border),
     ),
     child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
       Row(children: [
         const Icon(Icons.trending_up_rounded, color: AppColors.alertOrange, size: 20),
         const SizedBox(width: 8),
         Expanded(child: Text("Seuil d'alerte", style: AppTextStyles.fieldLabel)),
         SizedBox(width: 60,
             child: _InputField(ctrl: _thresholdController, hint: '3',
                 kb: TextInputType.number, align: TextAlign.center)),
       ]),
       const SizedBox(height: 8),
       Row(children: [
         const Icon(Icons.warning_amber_rounded, color: AppColors.alertOrange, size: 13),
         const SizedBox(width: 5),
         Expanded(child: Text(
           'Vous serez alerté quand le stock sera en dessous de ${_thresholdController.text} ${_unitController.text}',
           style: AppTextStyles.caption.copyWith(color: AppColors.alertOrange),
         )),
       ]),
     ]),
   );



   //button
   Widget _submitBtn() => SizedBox(
     width: double.infinity, height: 52,
     child: ElevatedButton(
       onPressed: _isLoading ? null : _save,
       style: ElevatedButton.styleFrom(
         backgroundColor: AppColors.successGreen,
         foregroundColor: AppColors.white,
         disabledBackgroundColor: AppColors.successGreen.withOpacity(0.6),
         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
         elevation: 0,
       ),
       child: _isLoading
           ? const SizedBox(width: 22, height: 22,
           child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2))
           : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
         const Icon(Icons.inventory_2_outlined, size: 20),
         const SizedBox(width: 10),
         Text("Ajouter à l'inventaire", style: AppTextStyles.button),
       ]),
     ),
   );
 }

class _FormField extends StatelessWidget {

  final String label; final Widget child;
  const _FormField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [Text(label, style: AppTextStyles.fieldLabel),
                const SizedBox(height: 8), child],
  );
}

class _InputField extends StatelessWidget {
  final TextEditingController ctrl;
  final String hint;
  final TextInputType kb;
  final TextAlign align;
  final String? prefix;
  const _InputField({required this.ctrl, required this.hint,
    this.kb = TextInputType.text, this.align = TextAlign.start, this.prefix});
  @override
  Widget build(BuildContext context) => TextField(
    controller: ctrl, keyboardType: kb, textAlign: align,
    style: AppTextStyles.fieldValue,
    decoration: InputDecoration(
      hintText: hint, hintStyle: AppTextStyles.fieldHint,
      prefixText: prefix, prefixStyle: AppTextStyles.fieldHint,
      filled: true, fillColor: AppColors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      border:         OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                                          borderSide: const BorderSide(color: AppColors.border)),
      enabledBorder:  OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(color: AppColors.border)),
      focusedBorder:  OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                                          borderSide: const BorderSide(color: AppColors.indigo, width: 1.5)),

    ),
  );
}
class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double borderRadius;
  final double dashWidth;
  final double dashSpace;
  final double strokeWidth;

  DashedBorderPainter({
    required this.color,
    this.borderRadius = 20,
    this.dashWidth = 4,
    this.dashSpace = 4,
    this.strokeWidth = 1.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final RRect rRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(borderRadius),
    );

    final Path path = Path()..addRRect(rRect);
    final PathMetrics pathMetrics = path.computeMetrics();

    for (final PathMetric metric in pathMetrics) {
      double distance = 0;
      bool draw = true;
      while (distance < metric.length) {
        final double len = draw ? dashWidth : dashSpace;
        if (draw) {
          canvas.drawPath(
            metric.extractPath(distance, distance + len),
            paint,
          );
        }
        distance += len;
        draw = !draw;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
//classe pour la dropdrown de unités
class _UnitDropdown extends StatefulWidget {
  final TextEditingController controller;
  const _UnitDropdown({required this.controller});

  @override
  State<_UnitDropdown> createState() => _UnitDropdownState();
}

class _UnitDropdownState extends State<_UnitDropdown> {
  //les unités
  final List<String> _units = ProductUnits.units;

  @override
  Widget build(BuildContext context) {
    final current = widget.controller.text.isEmpty || !_units.contains(widget.controller.text)
        ? 'unités'
        : widget.controller.text;
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _units.contains(current) ? current : 'unités',
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: AppColors.textMuted, size: 20),
          style: AppTextStyles.fieldValue,
          items: _units.map((u) => DropdownMenuItem(
            value: u,
            child: Text(u),
          )).toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() => widget.controller.text = val);
            }
          },
        ),
      ),
    );
  }
}