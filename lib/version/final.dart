// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:uuid/uuid.dart';
// import 'package:screenshot/screenshot.dart';
// import 'dart:math' as math;
// import 'dart:convert';
// import 'dart:html' as html;

// void main() => runApp(
//   ChangeNotifierProvider(
//     create: (_) => FloorPlanProvider(),
//     child: MaterialApp(
//       title: 'Floor Plan Designer',
//       theme: ThemeData(
//         primarySwatch: Colors.grey,
//         useMaterial3: true,
//         scaffoldBackgroundColor: const Color(0xFFF5F5F5),
//         fontFamily: 'Inter',
//       ),
//       debugShowCheckedModeBanner: false,
//       home: const FloorPlanDesigner(),
//     ),
//   ),
// );

// const List<String> imageNames = [
//   "breaker_box.png",
//   "dd_9lite.png",
//   "door_lh.png",
//   "door_rh.png",
//   "flower_box.png",
//   "lh_9lite.png",
//   "light.png",
//   "loft.png",
//   "receptacle.png",
//   "rh_9lite.png",
//   "rud.png",
//   "switch.png",
//   "w_shutters.png",
//   "window_with_shutter.png",
//   "window.png",
//   "work_bench.png",
// ];

// class FloorPlanProvider extends ChangeNotifier {
//   double roomWidth = 20,
//       roomHeight = 15,
//       scale = 30,
//       zoomLevel = 0.6; // Set initial zoom to 60%
//   List<PlacedComponent> components = [];
//   PlacedComponent? selectedComponent;
//   bool showGrid = true, showDimensions = true;

//   void updateRoomDimensions(double w, double h) {
//     roomWidth = w;
//     roomHeight = h;
//     notifyListeners();
//   }

//   void updateZoom(double delta) => setZoom(zoomLevel + delta);

//   void setZoom(double z) {
//     zoomLevel = z.clamp(0.5, 2.0);
//     notifyListeners();
//   }

//   void addComponent(String imageName, Offset pos) {
//     components.add(
//       selectedComponent = PlacedComponent(
//         id: const Uuid().v4(),
//         imageName: imageName,
//         position: pos,
//         width: 3.0, // Default width
//         height: 3.0, // Default height
//         rotation: 0,
//       ),
//     );
//     updateComponentPosition(selectedComponent!.id, pos);
//     notifyListeners();
//   }

//   void addText(String text, Offset pos) {
//     components.add(
//       selectedComponent = PlacedComponent(
//         id: const Uuid().v4(),
//         position: pos,
//         width: 2.0,
//         height: 1.0,
//         rotation: 0,
//         text: text,
//         fontSize: 16.0,
//         color: Colors.black,
//       ),
//     );
//     updateComponentPosition(selectedComponent!.id, pos);
//     notifyListeners();
//   }

//   void updateComponentPosition(String id, Offset pos) {
//     final c = components.firstWhere((c) => c.id == id);
//     c.position = pos; // Allow unrestricted positioning
//     notifyListeners();
//   }

//   void updateComponentSize(String id, double w, double h) {
//     final c = components.firstWhere((c) => c.id == id);
//     c.width = w.clamp(0.5, roomWidth * 2);
//     c.height = h.clamp(0.5, roomHeight * 2);
//     updateComponentPosition(id, c.position);
//     notifyListeners();
//   }

//   void updateTextProperties(
//     String id, {
//     String? text,
//     double? fontSize,
//     Color? color,
//   }) {
//     final c = components.firstWhere((c) => c.id == id);
//     if (text != null) c.text = text;
//     if (fontSize != null) c.fontSize = fontSize.clamp(8.0, 48.0);
//     if (color != null) c.color = color;
//     notifyListeners();
//   }

//   void selectComponent(PlacedComponent? c) {
//     selectedComponent = c;
//     notifyListeners();
//   }

//   void deleteSelected() {
//     if (selectedComponent != null) {
//       components.remove(selectedComponent);
//       selectedComponent = null;
//       notifyListeners();
//     }
//   }

//   void duplicateSelected() {
//     if (selectedComponent != null) {
//       final s = selectedComponent!;
//       components.add(
//         selectedComponent = PlacedComponent(
//           id: const Uuid().v4(),
//           imageName: s.imageName,
//           position: s.position + const Offset(20, 20),
//           width: s.width,
//           height: s.height,
//           rotation: s.rotation,
//           text: s.text,
//           fontSize: s.fontSize,
//           color: s.color,
//         ),
//       );
//       updateComponentPosition(
//         selectedComponent!.id,
//         selectedComponent!.position,
//       );
//       notifyListeners();
//     }
//   }

//   void rotateSelected() {
//     if (selectedComponent != null) {
//       final s = selectedComponent!;
//       s.rotation = (s.rotation + 90) % 360;
//       if (s.imageName != null && (s.rotation == 90 || s.rotation == 270)) {
//         final temp = s.width;
//         s.width = s.height;
//         s.height = temp;
//       }
//       updateComponentPosition(s.id, s.position);
//       notifyListeners();
//     }
//   }

//   void clearAll() {
//     components.clear();
//     selectedComponent = null;
//     notifyListeners();
//   }

//   void toggleGrid() {
//     showGrid = !showGrid;
//     notifyListeners();
//   }

//   void toggleDimensions() {
//     showDimensions = !showDimensions;
//     notifyListeners();
//   }

//   Map<String, dynamic> toJson() => {
//     'roomWidth': roomWidth,
//     'roomHeight': roomHeight,
//     'scale': scale,
//     'components': components.map((c) => c.toJson(scale)).toList(),
//     'showGrid': showGrid,
//     'showDimensions': showDimensions,
//     'version': '2.0',
//   };

//   void loadFromJson(Map<String, dynamic> json) {
//     try {
//       roomWidth = (json['roomWidth'] as num?)?.toDouble() ?? 20.0;
//       roomHeight = (json['roomHeight'] as num?)?.toDouble() ?? 15.0;
//       scale = (json['scale'] as num?)?.toDouble() ?? 30.0;
//       showGrid = json['showGrid'] as bool? ?? true;
//       showDimensions = json['showDimensions'] as bool? ?? true;
//       final version = json['version'] as String? ?? '1.0';
//       final isLegacy = version == '1.0';
//       components =
//           (json['components'] as List? ?? [])
//               .asMap()
//               .entries
//               .map((entry) {
//                 final index = entry.key;
//                 final c = entry.value as Map<String, dynamic>;
//                 final component = PlacedComponent.fromJson(c, scale, isLegacy);
//                 debugPrint(
//                   'Loaded component: ${component.imageName ?? 'Text'}, Scaled Position: (${component.position.dx}, ${component.position.dy})',
//                 );
//                 return component;
//               })
//               .whereType<PlacedComponent>()
//               .toList();
//       selectedComponent = null;
//       for (var c in components) {
//         updateComponentPosition(c.id, c.position);
//       }
//       notifyListeners();
//     } catch (e) {
//       debugPrint('Error loading JSON: $e');
//       throw Exception('Invalid JSON format: $e');
//     }
//   }
// }

// class FloorPlanDesigner extends StatefulWidget {
//   const FloorPlanDesigner({super.key});

//   @override
//   _FloorPlanDesignerState createState() => _FloorPlanDesignerState();
// }

// class _FloorPlanDesignerState extends State<FloorPlanDesigner> {
//   final screenshotController = ScreenshotController();
//   final widthCtrl = TextEditingController(text: '20');
//   final heightCtrl = TextEditingController(text: '15');
//   final textCtrl = TextEditingController();

//   Widget _dimInput(
//     String label,
//     TextEditingController ctrl,
//     Function(double) onChange,
//   ) => Row(
//     children: [
//       Text(
//         label,
//         style: const TextStyle(
//           fontWeight: FontWeight.w600,
//           fontSize: 12,
//           color: Color(0xFF2C2C2C),
//         ),
//       ),
//       const SizedBox(width: 8),
//       Container(
//         width: 70,
//         height: 32,
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(6),
//           border: Border.all(color: const Color(0xFFE0E0E0)),
//         ),
//         child: TextField(
//           controller: ctrl,
//           keyboardType: TextInputType.number,
//           style: const TextStyle(fontSize: 12, color: Color(0xFF2C2C2C)),
//           decoration: const InputDecoration(
//             border: InputBorder.none,
//             isDense: true,
//             contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//             suffixText: 'ft',
//             suffixStyle: TextStyle(color: Color(0xFF9E9E9E), fontSize: 11),
//           ),
//           onChanged: (v) => onChange(double.tryParse(v) ?? 20),
//         ),
//       ),
//     ],
//   );

//   @override
//   Widget build(BuildContext context) {
//     final p = context.read<FloorPlanProvider>();
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F5F5),
//       body: Row(
//         children: [
//           ComponentPropertiesPanel(
//             screenshotController: screenshotController,
//             widthCtrl: widthCtrl,
//             heightCtrl: heightCtrl,
//           ),
//           Expanded(
//             child: Column(
//               children: [
//                 Container(
//                   height: 60,
//                   decoration: const BoxDecoration(
//                     color: Colors.white,
//                     border: Border(
//                       bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1),
//                     ),
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 20),
//                     child: SingleChildScrollView(
//                       scrollDirection: Axis.horizontal,
//                       child: Row(
//                         children: [
//                           _dimInput(
//                             'Width',
//                             widthCtrl,
//                             (w) => p.updateRoomDimensions(w, p.roomHeight),
//                           ),
//                           const SizedBox(width: 20),
//                           _dimInput(
//                             'Length',
//                             heightCtrl,
//                             (h) => p.updateRoomDimensions(p.roomWidth, h),
//                           ),
//                           Container(
//                             margin: const EdgeInsets.symmetric(horizontal: 20),
//                             width: 1,
//                             height: 30,
//                             color: const Color(0xFFE0E0E0),
//                           ),
//                           Row(
//                             children: [
//                               const Text(
//                                 'Zoom',
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.w600,
//                                   fontSize: 12,
//                                   color: Color(0xFF2C2C2C),
//                                 ),
//                               ),
//                               const SizedBox(width: 12),
//                               Container(
//                                 decoration: BoxDecoration(
//                                   color: const Color(0xFFF8F8F8),
//                                   borderRadius: BorderRadius.circular(20),
//                                   border: Border.all(
//                                     color: const Color(0xFFE0E0E0),
//                                   ),
//                                 ),
//                                 child: Row(
//                                   children: [
//                                     IconButton(
//                                       icon: const Icon(Icons.remove, size: 16),
//                                       onPressed: () => p.updateZoom(-0.1),
//                                       padding: const EdgeInsets.all(6),
//                                       constraints: const BoxConstraints(),
//                                       color: const Color(0xFF666666),
//                                     ),
//                                     Consumer<FloorPlanProvider>(
//                                       builder:
//                                           (_, prov, __) => Container(
//                                             padding: const EdgeInsets.symmetric(
//                                               horizontal: 12,
//                                             ),
//                                             child: Text(
//                                               '${(prov.zoomLevel * 100).toInt()}%',
//                                               style: const TextStyle(
//                                                 fontSize: 12,
//                                                 fontWeight: FontWeight.w600,
//                                                 color: Color(0xFF2C2C2C),
//                                               ),
//                                             ),
//                                           ),
//                                     ),
//                                     IconButton(
//                                       icon: const Icon(Icons.add, size: 16),
//                                       onPressed: () => p.updateZoom(0.1),
//                                       padding: const EdgeInsets.all(6),
//                                       constraints: const BoxConstraints(),
//                                       color: const Color(0xFF666666),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               const SizedBox(width: 8),
//                               TextButton(
//                                 onPressed: () => p.setZoom(1.0),
//                                 style: TextButton.styleFrom(
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: 12,
//                                     vertical: 6,
//                                   ),
//                                   backgroundColor: const Color(0xFF2C2C2C),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(6),
//                                   ),
//                                 ),
//                                 child: const Text(
//                                   'Reset',
//                                   style: TextStyle(
//                                     fontSize: 11,
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           Container(
//                             margin: const EdgeInsets.symmetric(horizontal: 20),
//                             width: 1,
//                             height: 30,
//                             color: const Color(0xFFE0E0E0),
//                           ),
//                           Container(
//                             width: 180,
//                             height: 32,
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(6),
//                               border: Border.all(
//                                 color: const Color(0xFFE0E0E0),
//                               ),
//                             ),
//                             child: TextField(
//                               controller: textCtrl,
//                               decoration: const InputDecoration(
//                                 hintText: 'Enter text label',
//                                 hintStyle: TextStyle(
//                                   color: Color(0xFFBDBDBD),
//                                   fontSize: 12,
//                                 ),
//                                 border: InputBorder.none,
//                                 isDense: true,
//                                 contentPadding: EdgeInsets.symmetric(
//                                   horizontal: 12,
//                                   vertical: 8,
//                                 ),
//                               ),
//                               style: const TextStyle(
//                                 fontSize: 12,
//                                 color: Color(0xFF2C2C2C),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 8),
//                           ElevatedButton.icon(
//                             onPressed: () {
//                               final p = context.read<FloorPlanProvider>();
//                               p.addText(
//                                 textCtrl.text.isEmpty ? 'Text' : textCtrl.text,
//                                 Offset(
//                                   p.roomWidth * p.scale / 2,
//                                   p.roomHeight * p.scale / 2,
//                                 ),
//                               );
//                               textCtrl.clear();
//                             },
//                             icon: const Icon(Icons.text_fields, size: 16),
//                             label: const Text(
//                               'Add Text',
//                               style: TextStyle(fontSize: 11),
//                             ),
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: const Color(0xFF2C2C2C),
//                               foregroundColor: Colors.white,
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 12,
//                                 vertical: 8,
//                               ),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(6),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//                 Expanded(
//                   child: Container(
//                     margin: const EdgeInsets.all(20),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(12),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.05),
//                           blurRadius: 20,
//                           offset: const Offset(0, 4),
//                         ),
//                       ],
//                     ),
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(12),
//                       child: CanvasArea(
//                         screenshotController: screenshotController,
//                       ),
//                     ),
//                   ),
//                 ),
//                 Container(
//                   height: 120,
//                   decoration: const BoxDecoration(
//                     color: Colors.white,
//                     border: Border(
//                       top: BorderSide(color: Color(0xFFE0E0E0), width: 1),
//                     ),
//                   ),
//                   child: const ComponentToolbar(),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class ComponentPropertiesPanel extends StatelessWidget {
//   final ScreenshotController screenshotController;
//   final TextEditingController widthCtrl;
//   final TextEditingController heightCtrl;

//   const ComponentPropertiesPanel({
//     super.key,
//     required this.screenshotController,
//     required this.widthCtrl,
//     required this.heightCtrl,
//   });

//   Widget _modernButton({
//     required IconData icon,
//     required String label,
//     required VoidCallback onPressed,
//     Color backgroundColor = const Color(0xFF2C2C2C),
//     Color iconColor = Colors.white,
//   }) => Container(
//     margin: const EdgeInsets.only(bottom: 8),
//     child: Material(
//       color: backgroundColor,
//       borderRadius: BorderRadius.circular(8),
//       child: InkWell(
//         onTap: onPressed,
//         borderRadius: BorderRadius.circular(8),
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//           child: Row(
//             children: [
//               Icon(icon, size: 18, color: iconColor),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Text(
//                   label,
//                   style: TextStyle(
//                     fontSize: 13,
//                     fontWeight: FontWeight.w500,
//                     color: iconColor,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     ),
//   );

//   Widget _iconToggle(
//     IconData icon,
//     String tooltip,
//     VoidCallback onPressed,
//     bool active,
//   ) => Container(
//     margin: const EdgeInsets.only(right: 8),
//     child: Material(
//       color: active ? const Color(0xFF2C2C2C) : const Color(0xFFF8F8F8),
//       borderRadius: BorderRadius.circular(8),
//       child: InkWell(
//         onTap: onPressed,
//         borderRadius: BorderRadius.circular(8),
//         child: Container(
//           width: 36,
//           height: 36,
//           alignment: Alignment.center,
//           child: Icon(
//             icon,
//             size: 18,
//             color: active ? Colors.white : const Color(0xFF666666),
//           ),
//         ),
//       ),
//     ),
//   );

//   Widget _modernSlider(
//     String label,
//     double val,
//     Function(double) onChange,
//   ) => Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Text(
//         label,
//         style: const TextStyle(
//           fontWeight: FontWeight.w600,
//           fontSize: 12,
//           color: Color(0xFF2C2C2C),
//         ),
//       ),
//       const SizedBox(height: 12),
//       Row(
//         children: [
//           Expanded(
//             child: SliderTheme(
//               data: SliderThemeData(
//                 activeTrackColor: const Color(0xFF2C2C2C),
//                 inactiveTrackColor: const Color(0xFFE0E0E0),
//                 thumbColor: const Color(0xFF2C2C2C),
//                 overlayColor: const Color(0xFF2C2C2C).withOpacity(0.1),
//                 trackHeight: 4,
//                 thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
//               ),
//               child: Slider(
//                 value: val,
//                 min: 0.5,
//                 max: 10,
//                 divisions: 19,
//                 onChanged: onChange,
//               ),
//             ),
//           ),
//           const SizedBox(width: 12),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//             decoration: BoxDecoration(
//               color: const Color(0xFFF8F8F8),
//               borderRadius: BorderRadius.circular(4),
//             ),
//             child: Text(
//               '${val.toStringAsFixed(1)} ft',
//               style: const TextStyle(fontSize: 11, color: Color(0xFF666666)),
//             ),
//           ),
//         ],
//       ),
//       const SizedBox(height: 16),
//     ],
//   );

//   Widget _fontSizeSlider(
//     String label,
//     double val,
//     Function(double) onChange,
//   ) => Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Text(
//         label,
//         style: const TextStyle(
//           fontWeight: FontWeight.w600,
//           fontSize: 12,
//           color: Color(0xFF2C2C2C),
//         ),
//       ),
//       const SizedBox(height: 12),
//       Row(
//         children: [
//           Expanded(
//             child: SliderTheme(
//               data: SliderThemeData(
//                 activeTrackColor: const Color(0xFF2C2C2C),
//                 inactiveTrackColor: const Color(0xFFE0E0E0),
//                 thumbColor: const Color(0xFF2C2C2C),
//                 overlayColor: const Color(0xFF2C2C2C).withOpacity(0.1),
//                 trackHeight: 4,
//                 thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
//               ),
//               child: Slider(
//                 value: val,
//                 min: 8,
//                 max: 48,
//                 divisions: 40,
//                 onChanged: onChange,
//               ),
//             ),
//           ),
//           const SizedBox(width: 12),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//             decoration: BoxDecoration(
//               color: const Color(0xFFF8F8F8),
//               borderRadius: BorderRadius.circular(4),
//             ),
//             child: Text(
//               '${val.toStringAsFixed(0)} pt',
//               style: const TextStyle(fontSize: 11, color: Color(0xFF666666)),
//             ),
//           ),
//         ],
//       ),
//       const SizedBox(height: 16),
//     ],
//   );

//   @override
//   Widget build(BuildContext context) {
//     final p = context.read<FloorPlanProvider>();

//     void saveToJson() {
//       final json = jsonEncode(p.toJson());
//       final blob = html.Blob([utf8.encode(json)]);
//       final url = html.Url.createObjectUrlFromBlob(blob);
//       final fileName =
//           'floor_plan_${DateTime.now().millisecondsSinceEpoch}.json';
//       html.AnchorElement()
//         ..href = url
//         ..download = fileName
//         ..click();
//       html.Url.revokeObjectUrl(url);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: const Text('Floor plan saved as JSON!'),
//           backgroundColor: const Color(0xFF2C2C2C),
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//           duration: const Duration(seconds: 2),
//         ),
//       );
//     }

//     void loadFromJson() {
//       final input = html.FileUploadInputElement()..accept = '.json';
//       input.click();
//       input.onChange.listen((e) {
//         final files = input.files;
//         if (files!.isEmpty) return;
//         final file = files[0];
//         final reader = html.FileReader();
//         reader.onLoadEnd.listen((e) {
//           try {
//             final content = reader.result as String;
//             final jsonData = jsonDecode(content) as Map<String, dynamic>;
//             p.loadFromJson(jsonData);
//             widthCtrl.text = p.roomWidth.toString();
//             heightCtrl.text = p.roomHeight.toString();
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: const Text('Floor plan loaded from file!'),
//                 backgroundColor: const Color(0xFF2C2C2C),
//                 behavior: SnackBarBehavior.floating,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 duration: const Duration(seconds: 2),
//               ),
//             );
//           } catch (e) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text('Error loading JSON: $e'),
//                 backgroundColor: const Color(0xFF666666),
//                 behavior: SnackBarBehavior.floating,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 duration: const Duration(seconds: 3),
//               ),
//             );
//           }
//         });
//         reader.readAsText(file);
//       });
//     }

//     void exportImage() async {
//       final image = await screenshotController.capture();
//       if (image != null) {
//         final blob = html.Blob([image]);
//         final url = html.Url.createObjectUrlFromBlob(blob);
//         final fileName =
//             'floor_plan_${DateTime.now().millisecondsSinceEpoch}.png';
//         html.AnchorElement()
//           ..href = url
//           ..download = fileName
//           ..click();
//         html.Url.revokeObjectUrl(url);
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: const Text('Floor plan image exported!'),
//             backgroundColor: const Color(0xFF2C2C2C),
//             behavior: SnackBarBehavior.floating,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(8),
//             ),
//             duration: const Duration(seconds: 2),
//           ),
//         );
//       }
//     }

//     return Container(
//       width: 280,
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         border: Border(right: BorderSide(color: Color(0xFFE0E0E0), width: 1)),
//       ),
//       child: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 'Properties',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.w700,
//                   color: Color(0xFF2C2C2C),
//                 ),
//               ),
//               const SizedBox(height: 24),
//               Consumer<FloorPlanProvider>(
//                 builder: (_, p, __) {
//                   final c = p.selectedComponent;
//                   if (c == null) {
//                     return Container(
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: const Color(0xFFF8F8F8),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: const Text(
//                         'Select a component to edit properties',
//                         style: TextStyle(
//                           color: Color(0xFF9E9E9E),
//                           fontSize: 13,
//                         ),
//                       ),
//                     );
//                   }
//                   return Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 12,
//                           vertical: 8,
//                         ),
//                         decoration: BoxDecoration(
//                           color: const Color(0xFFF8F8F8),
//                           borderRadius: BorderRadius.circular(6),
//                         ),
//                         child: Row(
//                           children: [
//                             const Icon(
//                               Icons.layers,
//                               size: 16,
//                               color: Color(0xFF666666),
//                             ),
//                             const SizedBox(width: 8),
//                             Text(
//                               c.imageName ?? 'Text Element',
//                               style: const TextStyle(
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.w600,
//                                 color: Color(0xFF2C2C2C),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//                       if (c.text != null) ...[
//                         Container(
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(8),
//                             border: Border.all(color: const Color(0xFFE0E0E0)),
//                           ),
//                           child: TextField(
//                             decoration: const InputDecoration(
//                               labelText: 'Text Content',
//                               labelStyle: TextStyle(
//                                 color: Color(0xFF9E9E9E),
//                                 fontSize: 12,
//                               ),
//                               border: InputBorder.none,
//                               contentPadding: EdgeInsets.all(12),
//                             ),
//                             controller: TextEditingController(text: c.text),
//                             style: const TextStyle(
//                               fontSize: 13,
//                               color: Color(0xFF2C2C2C),
//                             ),
//                             onChanged:
//                                 (value) =>
//                                     p.updateTextProperties(c.id, text: value),
//                           ),
//                         ),
//                         const SizedBox(height: 20),
//                         _fontSizeSlider(
//                           'Font Size',
//                           c.fontSize ?? 16.0,
//                           (v) => p.updateTextProperties(c.id, fontSize: v),
//                         ),
//                         const Text(
//                           'Text Color',
//                           style: TextStyle(
//                             fontWeight: FontWeight.w600,
//                             fontSize: 12,
//                             color: Color(0xFF2C2C2C),
//                           ),
//                         ),
//                         const SizedBox(height: 12),
//                         Row(
//                           children: [
//                             _colorButton(
//                               Colors.black,
//                               c.color,
//                               (color) =>
//                                   p.updateTextProperties(c.id, color: color),
//                             ),
//                             const SizedBox(width: 8),
//                             _colorButton(
//                               const Color(0xFF666666),
//                               c.color,
//                               (color) =>
//                                   p.updateTextProperties(c.id, color: color),
//                             ),
//                             const SizedBox(width: 8),
//                             _colorButton(
//                               const Color(0xFF9E9E9E),
//                               c.color,
//                               (color) =>
//                                   p.updateTextProperties(c.id, color: color),
//                             ),
//                             const SizedBox(width: 8),
//                             _colorButton(
//                               const Color(0xFFBDBDBD),
//                               c.color,
//                               (color) =>
//                                   p.updateTextProperties(c.id, color: color),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 20),
//                       ] else ...[
//                         _modernSlider(
//                           'Width',
//                           c.width,
//                           (v) => p.updateComponentSize(c.id, v, c.height),
//                         ),
//                         _modernSlider(
//                           'Height',
//                           c.height,
//                           (v) => p.updateComponentSize(c.id, c.width, v),
//                         ),
//                       ],
//                       Container(
//                         padding: const EdgeInsets.all(12),
//                         decoration: BoxDecoration(
//                           color: const Color(0xFFF8F8F8),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             const Text(
//                               'Position',
//                               style: TextStyle(
//                                 fontWeight: FontWeight.w600,
//                                 fontSize: 12,
//                                 color: Color(0xFF2C2C2C),
//                               ),
//                             ),
//                             const SizedBox(height: 8),
//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: Row(
//                                     children: [
//                                       const Text(
//                                         'X: ',
//                                         style: TextStyle(
//                                           fontSize: 11,
//                                           color: Color(0xFF666666),
//                                         ),
//                                       ),
//                                       Text(
//                                         '${(c.position.dx / (p.scale * p.zoomLevel)).toStringAsFixed(1)} ft',
//                                         style: const TextStyle(
//                                           fontSize: 11,
//                                           fontWeight: FontWeight.w600,
//                                           color: Color(0xFF2C2C2C),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 Expanded(
//                                   child: Row(
//                                     children: [
//                                       const Text(
//                                         'Y: ',
//                                         style: TextStyle(
//                                           fontSize: 11,
//                                           color: Color(0xFF666666),
//                                         ),
//                                       ),
//                                       Text(
//                                         '${(c.position.dy / (p.scale * p.zoomLevel)).toStringAsFixed(1)} ft',
//                                         style: const TextStyle(
//                                           fontSize: 11,
//                                           fontWeight: FontWeight.w600,
//                                           color: Color(0xFF2C2C2C),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 8),
//                             Row(
//                               children: [
//                                 const Icon(
//                                   Icons.rotate_right,
//                                   size: 14,
//                                   color: Color(0xFF666666),
//                                 ),
//                                 const SizedBox(width: 4),
//                                 Text(
//                                   'Rotation: ${c.rotation}°',
//                                   style: const TextStyle(
//                                     fontSize: 11,
//                                     color: Color(0xFF666666),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   );
//                 },
//               ),
//               const SizedBox(height: 24),
//               Container(
//                 padding: const EdgeInsets.only(bottom: 16),
//                 decoration: const BoxDecoration(
//                   border: Border(
//                     bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1),
//                   ),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Actions',
//                       style: TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w700,
//                         color: Color(0xFF2C2C2C),
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     _modernButton(
//                       icon: Icons.rotate_right,
//                       label: 'Rotate',
//                       onPressed: p.rotateSelected,
//                     ),
//                     _modernButton(
//                       icon: Icons.copy,
//                       label: 'Duplicate',
//                       onPressed: p.duplicateSelected,
//                     ),
//                     _modernButton(
//                       icon: Icons.delete_outline,
//                       label: 'Delete',
//                       onPressed: p.deleteSelected,
//                       backgroundColor: const Color(0xFF666666),
//                     ),
//                     _modernButton(
//                       icon: Icons.clear_all,
//                       label: 'Clear All',
//                       onPressed: p.clearAll,
//                       backgroundColor: const Color(0xFF9E9E9E),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 20),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'View Options',
//                     style: TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w700,
//                       color: Color(0xFF2C2C2C),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   Row(
//                     children: [
//                       Consumer<FloorPlanProvider>(
//                         builder:
//                             (_, prov, __) => _iconToggle(
//                               Icons.grid_on,
//                               'Toggle Grid',
//                               prov.toggleGrid,
//                               prov.showGrid,
//                             ),
//                       ),
//                       Consumer<FloorPlanProvider>(
//                         builder:
//                             (_, prov, __) => _iconToggle(
//                               Icons.straighten,
//                               'Toggle Dimensions',
//                               prov.toggleDimensions,
//                               prov.showDimensions,
//                             ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 24),
//               Container(
//                 padding: const EdgeInsets.only(top: 20),
//                 decoration: const BoxDecoration(
//                   border: Border(
//                     top: BorderSide(color: Color(0xFFE0E0E0), width: 1),
//                   ),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'File Operations',
//                       style: TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w700,
//                         color: Color(0xFF2C2C2C),
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     _modernButton(
//                       icon: Icons.save_alt,
//                       label: 'Save as JSON',
//                       onPressed: saveToJson,
//                     ),
//                     _modernButton(
//                       icon: Icons.folder_open,
//                       label: 'Load JSON',
//                       onPressed: loadFromJson,
//                     ),
//                     _modernButton(
//                       icon: Icons.image,
//                       label: 'Export as PNG',
//                       onPressed: exportImage,
//                       backgroundColor: const Color(0xFF4A4A4A),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _colorButton(
//     Color color,
//     Color? selectedColor,
//     Function(Color) onSelect,
//   ) => GestureDetector(
//     onTap: () => onSelect(color),
//     child: Container(
//       width: 32,
//       height: 32,
//       decoration: BoxDecoration(
//         color: color,
//         border: Border.all(
//           color:
//               selectedColor == color
//                   ? const Color(0xFF2C2C2C)
//                   : const Color(0xFFE0E0E0),
//           width: selectedColor == color ? 2 : 1,
//         ),
//         borderRadius: BorderRadius.circular(6),
//       ),
//     ),
//   );
// }

// class CanvasArea extends StatelessWidget {
//   final ScreenshotController screenshotController;
//   const CanvasArea({super.key, required this.screenshotController});

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<FloorPlanProvider>(
//       builder: (_, p, __) {
//         final w = p.roomWidth * p.scale * p.zoomLevel;
//         final h = p.roomHeight * p.scale * p.zoomLevel;
//         return GestureDetector(
//           behavior: HitTestBehavior.translucent,
//           onTapUp: (details) {
//             final box = context.findRenderObject() as RenderBox?;
//             if (box == null) return;
//             final local = box.globalToLocal(details.globalPosition);
//             final adjustedLocal =
//                 local - const Offset(16, 16); // Account for margin
//             for (var c in p.components.reversed) {
//               final rect = Rect.fromLTWH(
//                 c.position.dx,
//                 c.position.dy,
//                 c.width * p.scale * p.zoomLevel,
//                 c.height * p.scale * p.zoomLevel,
//               );
//               if (rect.contains(adjustedLocal)) {
//                 p.selectComponent(c);
//                 break;
//               }
//             }
//           },
//           onPanStart: (_) {},
//           onPanUpdate: (_) {},
//           child: DragTarget<String>(
//             builder:
//                 (_, candidateData, rejectedData) => Screenshot(
//                   controller: screenshotController,
//                   child: Container(
//                     width: double.infinity,
//                     height: double.infinity,
//                     color: const Color(0xFFFAFAFA),
//                     child: Stack(
//                       clipBehavior: Clip.none,
//                       children: [
//                         Center(
//                           child: SizedBox(
//                             width: w,
//                             height: h,
//                             child: CustomPaint(
//                               size: Size(w, h),
//                               painter: FloorPlanPainter(
//                                 roomWidth: p.roomWidth,
//                                 roomHeight: p.roomHeight,
//                                 scale: p.scale * p.zoomLevel,
//                                 showGrid: p.showGrid,
//                                 showDimensions: p.showDimensions,
//                               ),
//                             ),
//                           ),
//                         ),
//                         ...p.components.map(
//                           (c) => Positioned(
//                             left: c.position.dx,
//                             top: c.position.dy,
//                             child: GestureDetector(
//                               behavior: HitTestBehavior.translucent,
//                               onTap: () => p.selectComponent(c),
//                               onPanStart: (_) => p.selectComponent(c),
//                               onPanUpdate:
//                                   (d) => p.updateComponentPosition(
//                                     c.id,
//                                     c.position + d.delta,
//                                   ),
//                               child: Transform.rotate(
//                                 angle: c.rotation * math.pi / 180,
//                                 child: Container(
//                                   width: c.width * p.scale * p.zoomLevel,
//                                   height: c.height * p.scale * p.zoomLevel,
//                                   decoration: BoxDecoration(
//                                     border:
//                                         p.selectedComponent?.id == c.id
//                                             ? Border.all(
//                                               color: const Color(0xFFD3D3D3),
//                                               width: 1,
//                                             )
//                                             : null,
//                                     borderRadius: BorderRadius.circular(2),
//                                   ),
//                                   child: CustomPaint(
//                                     painter: ComponentPainter(
//                                       imageName: c.imageName,
//                                       isSelected:
//                                           p.selectedComponent?.id == c.id,
//                                       text: c.text,
//                                       fontSize: c.fontSize,
//                                       color: c.color,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//             onWillAccept: (data) => true,
//             onAcceptWithDetails: (details) {
//               final box = context.findRenderObject() as RenderBox?;
//               if (box == null) return;
//               final local = box.globalToLocal(details.offset);
//               final adjustedLocal =
//                   local - const Offset(16, 16); // Account for margin
//               p.addComponent(details.data, adjustedLocal);
//             },
//           ),
//         );
//       },
//     );
//   }
// }

// class ComponentPainter extends CustomPainter {
//   final String? imageName;
//   final bool isSelected;
//   final String? text;
//   final double? fontSize;
//   final Color? color;

//   ComponentPainter({
//     this.imageName,
//     required this.isSelected,
//     this.text,
//     this.fontSize,
//     this.color,
//   });

//   @override
//   void paint(Canvas canvas, Size s) {
//     if (text != null) {
//       final tp = TextPainter(
//         text: TextSpan(
//           text: text ?? 'Text',
//           style: TextStyle(
//             color: color ?? Colors.black,
//             fontSize: fontSize ?? 16.0,
//             fontWeight: FontWeight.normal,
//           ),
//         ),
//         textDirection: TextDirection.ltr,
//       )..layout();
//       final offset = Offset(
//         (s.width - tp.width) / 2,
//         (s.height - tp.height) / 2,
//       );
//       tp.paint(canvas, offset);
//       if (isSelected) {
//         canvas.drawRect(
//           Rect.fromLTWH(0, 0, s.width, s.height),
//           Paint()
//             ..color = const Color(0xFFD3D3D3)
//             ..strokeWidth = 1
//             ..style = PaintingStyle.stroke,
//         );
//       }
//     } else if (imageName != null) {
//       final imageProvider = AssetImage('assets/images/$imageName');
//       final paint = Paint()..filterQuality = FilterQuality.high;
//       final picture = imageProvider.resolve(ImageConfiguration());
//       picture.addListener(
//         ImageStreamListener((info, synchronousCall) {
//           final img = info.image;
//           final srcSize = Size(img.width.toDouble(), img.height.toDouble());
//           final dstSize = Size(s.width, s.height);
//           final srcRect = Rect.fromLTWH(0, 0, srcSize.width, srcSize.height);
//           final dstRect = Rect.fromLTWH(0, 0, dstSize.width, dstSize.height);
//           canvas.drawImageRect(img, srcRect, dstRect, paint);
//           if (isSelected) {
//             canvas.drawRect(
//               Rect.fromLTWH(0, 0, s.width, s.height),
//               Paint()
//                 ..color = const Color(0xFFD3D3D3)
//                 ..strokeWidth = 1
//                 ..style = PaintingStyle.stroke,
//             );
//           }
//         }),
//       );
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter old) => true;
// }

// class ComponentToolbar extends StatefulWidget {
//   const ComponentToolbar({super.key});

//   @override
//   _ComponentToolbarState createState() => _ComponentToolbarState();
// }

// class _ComponentToolbarState extends State<ComponentToolbar> {
//   final ScrollController _scrollController = ScrollController();

//   void _scrollLeft() {
//     _scrollController.animateTo(
//       _scrollController.offset - 200,
//       duration: const Duration(milliseconds: 300),
//       curve: Curves.easeInOut,
//     );
//   }

//   void _scrollRight() {
//     _scrollController.animateTo(
//       _scrollController.offset + 200,
//       duration: const Duration(milliseconds: 300),
//       curve: Curves.easeInOut,
//     );
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
//       child: Row(
//         children: [
//           Container(
//             decoration: BoxDecoration(
//               color: const Color(0xFFF8F8F8),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: IconButton(
//               icon: const Icon(Icons.chevron_left, size: 20),
//               onPressed: _scrollLeft,
//               color: const Color(0xFF666666),
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: SingleChildScrollView(
//               controller: _scrollController,
//               scrollDirection: Axis.horizontal,
//               child: Row(
//                 children:
//                     imageNames
//                         .map(
//                           (imageName) => Padding(
//                             padding: const EdgeInsets.symmetric(horizontal: 6),
//                             child: Draggable<String>(
//                               data: imageName,
//                               feedback: Material(
//                                 elevation: 12,
//                                 borderRadius: BorderRadius.circular(10),
//                                 child: Container(
//                                   padding: const EdgeInsets.all(16),
//                                   decoration: BoxDecoration(
//                                     color: const Color(0xFF2C2C2C),
//                                     borderRadius: BorderRadius.circular(10),
//                                   ),
//                                   child: Text(
//                                     imageName
//                                         .replaceAll('.png', '')
//                                         .replaceAll('_', ' ')
//                                         .toUpperCase(),
//                                     style: const TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 10,
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               child: Container(
//                                 width: 100,
//                                 height: 80,
//                                 decoration: BoxDecoration(
//                                   border: Border.all(
//                                     color: const Color(0xFFE0E0E0),
//                                   ),
//                                   borderRadius: BorderRadius.circular(10),
//                                   color: Colors.white,
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: Colors.black.withOpacity(0.04),
//                                       blurRadius: 8,
//                                       offset: const Offset(0, 2),
//                                     ),
//                                   ],
//                                 ),
//                                 child: Column(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     SizedBox(
//                                       width: 80,
//                                       height: 50,
//                                       child: Image.asset(
//                                         'assets/images/$imageName',
//                                         fit: BoxFit.contain,
//                                         errorBuilder:
//                                             (
//                                               context,
//                                               error,
//                                               stackTrace,
//                                             ) => Container(
//                                               decoration: BoxDecoration(
//                                                 color: const Color(0xFFF8F8F8),
//                                                 borderRadius:
//                                                     BorderRadius.circular(4),
//                                               ),
//                                               child: const Center(
//                                                 child: Icon(
//                                                   Icons.image_not_supported,
//                                                   size: 20,
//                                                   color: Color(0xFF9E9E9E),
//                                                 ),
//                                               ),
//                                             ),
//                                       ),
//                                     ),
//                                     const SizedBox(height: 6),
//                                     Text(
//                                       imageName
//                                           .replaceAll('.png', '')
//                                           .replaceAll('_', ' ')
//                                           .toUpperCase(),
//                                       style: const TextStyle(
//                                         fontSize: 9,
//                                         fontWeight: FontWeight.w600,
//                                         color: Color(0xFF666666),
//                                         letterSpacing: 0.5,
//                                       ),
//                                       textAlign: TextAlign.center,
//                                       maxLines: 1,
//                                       overflow: TextOverflow.ellipsis,
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                         )
//                         .toList(),
//               ),
//             ),
//           ),
//           const SizedBox(width: 12),
//           Container(
//             decoration: BoxDecoration(
//               color: const Color(0xFFF8F8F8),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: IconButton(
//               icon: const Icon(Icons.chevron_right, size: 20),
//               onPressed: _scrollRight,
//               color: const Color(0xFF666666),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class FloorPlanPainter extends CustomPainter {
//   final double roomWidth, roomHeight, scale;
//   final bool showGrid, showDimensions;

//   FloorPlanPainter({
//     required this.roomWidth,
//     required this.roomHeight,
//     required this.scale,
//     required this.showGrid,
//     required this.showDimensions,
//   });

//   void _drawDashed(Canvas c, Offset s, Offset e, Paint p) {
//     const dw = 10.0, ds = 5.0;
//     final d = (e - s).distance;
//     for (var i = 0; i < d / (dw + ds); i++) {
//       final f = i * (dw + ds) / d;
//       final f2 = (i * (dw + ds) + dw) / d;
//       c.drawLine(s + (e - s) * f, s + (e - s) * f2, p);
//     }
//   }

//   void _drawDimLine(Canvas c, Offset s, Offset e, String t, Paint p, bool v) {
//     c.drawLine(s, e, p);
//     c.drawLine(
//       s + (v ? const Offset(-3, 0) : const Offset(0, -3)),
//       s + (v ? const Offset(3, 0) : const Offset(0, 3)),
//       p,
//     );
//     c.drawLine(
//       e + (v ? const Offset(-3, 0) : const Offset(0, -3)),
//       e + (v ? const Offset(3, 0) : const Offset(0, 3)),
//       p,
//     );
//     final tp = TextPainter(
//       text: TextSpan(
//         text: t,
//         style: const TextStyle(
//           color: Color(0xFF666666),
//           fontSize: 11,
//           fontWeight: FontWeight.w500,
//         ),
//       ),
//       textDirection: TextDirection.ltr,
//     )..layout();
//     final center = Offset((s.dx + e.dx) / 2, (s.dy + e.dy) / 2);
//     if (v) {
//       c.save();
//       c.translate(center.dx, center.dy);
//       c.rotate(-math.pi / 2);
//       tp.paint(c, Offset(-tp.width / 2, -tp.height / 2));
//       c.restore();
//     } else {
//       tp.paint(c, center - Offset(tp.width / 2, tp.height / 2));
//     }
//   }

//   @override
//   void paint(Canvas canvas, Size size) {
//     canvas.drawRect(
//       Rect.fromLTWH(0, 0, size.width, size.height),
//       Paint()..color = Colors.white,
//     );
//     if (showGrid) {
//       final gp =
//           Paint()
//             ..color = const Color(0xFFE8E8E8)
//             ..strokeWidth = 0.5
//             ..style = PaintingStyle.stroke;
//       for (var x = 0.0; x <= size.width; x += scale) {
//         canvas.drawLine(Offset(x, 0), Offset(x, size.height), gp);
//       }
//       for (var y = 0.0; y <= size.height; y += scale) {
//         canvas.drawLine(Offset(0, y), Offset(size.width, y), gp);
//       }
//     }
//     final wp =
//         Paint()
//           ..color = const Color(0xFF2C2C2C)
//           ..strokeWidth = 2.5
//           ..style = PaintingStyle.stroke;
//     canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), wp);
//     if (roomWidth >= 12) {
//       final dp =
//           Paint()
//             ..color = const Color(0xFF666666)
//             ..strokeWidth = 1.5
//             ..style = PaintingStyle.stroke;
//       final lw = size.width / 3;
//       _drawDashed(canvas, Offset(lw, 0), Offset(lw, size.height), dp);
//       _drawDashed(canvas, Offset(lw * 2, 0), Offset(lw * 2, size.height), dp);
//       if (showDimensions) {
//         final tp = TextPainter(
//           text: const TextSpan(
//             text: '4 FT LOFT',
//             style: TextStyle(
//               color: Color(0xFF666666),
//               fontSize: 10,
//               fontWeight: FontWeight.w600,
//               letterSpacing: 0.5,
//             ),
//           ),
//           textDirection: TextDirection.ltr,
//         )..layout();
//         tp.paint(canvas, Offset(lw / 2 - tp.width / 2, 30));
//         tp.paint(canvas, Offset(lw * 1.5 - tp.width / 2, 30));
//         tp.paint(canvas, Offset(lw * 2.5 - tp.width / 2, 30));
//       }
//     }
//     if (showDimensions) {
//       final dp =
//           Paint()
//             ..color = const Color(0xFF9E9E9E)
//             ..strokeWidth = 1
//             ..style = PaintingStyle.stroke;
//       _drawDimLine(
//         canvas,
//         Offset(0, -20),
//         Offset(size.width, -20),
//         '${roomWidth.toInt()} ft',
//         dp,
//         false,
//       );
//       _drawDimLine(
//         canvas,
//         Offset(-20, 0),
//         Offset(-20, size.height),
//         '${roomHeight.toInt()} ft',
//         dp,
//         true,
//       );
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter old) => true;
// }

// class PlacedComponent {
//   String id;
//   Offset position;
//   double width, height, rotation;
//   String? imageName;
//   String? text;
//   double? fontSize;
//   Color? color;

//   PlacedComponent({
//     required this.id,
//     required this.position,
//     required this.width,
//     required this.height,
//     required this.rotation,
//     this.imageName,
//     this.text,
//     this.fontSize,
//     this.color,
//   });

//   Map<String, dynamic> toJson(double scale) => {
//     'id': id,
//     'position': {'x': position.dx / scale, 'y': position.dy / scale},
//     'width': width,
//     'height': height,
//     'rotation': rotation,
//     if (imageName != null) 'imageName': imageName,
//     if (text != null) 'text': text,
//     if (fontSize != null) 'fontSize': fontSize,
//     if (color != null) 'color': color?.value,
//     'frame': {'width': width, 'height': height},
//   };

//   static PlacedComponent fromJson(
//     Map<String, dynamic> j,
//     double scale,
//     bool isLegacy,
//   ) => PlacedComponent(
//     id: j['id'] as String,
//     position:
//         isLegacy
//             ? Offset(
//               (j['position']['x'] as num).toDouble(),
//               (j['position']['y'] as num).toDouble(),
//             )
//             : Offset(
//               (j['position']['x'] as num).toDouble() * scale,
//               (j['position']['y'] as num).toDouble() * scale,
//             ),
//     width:
//         (j['frame'] != null
//             ? (j['frame']['width'] as num).toDouble()
//             : (j['width'] as num).toDouble()) ??
//         20.0,
//     height:
//         (j['frame'] != null
//             ? (j['frame']['height'] as num).toDouble()
//             : (j['height'] as num).toDouble()) ??
//         15.0,
//     rotation: (j['rotation'] as num).toDouble(),
//     imageName: j['imageName'] as String?,
//     text: j['text'] as String?,
//     fontSize: (j['fontSize'] as num?)?.toDouble(),
//     color: j['color'] != null ? Color(j['color'] as int) : null,
//   );
// }
