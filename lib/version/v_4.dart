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
//       theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
//       debugShowCheckedModeBanner: false,
//       home: const FloorPlanDesigner(),
//     ),
//   ),
// );

// class FloorPlanProvider extends ChangeNotifier {
//   double roomWidth = 20, roomHeight = 15, scale = 30, zoomLevel = 1;
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

//   void addComponent(ComponentType type, Offset pos, {String? text}) {
//     components.add(
//       selectedComponent = PlacedComponent(
//         id: const Uuid().v4(),
//         type: type,
//         position: pos,
//         width: type.defaultWidth,
//         height: type.defaultHeight,
//         rotation: 0,
//         text: type == ComponentType.text ? (text ?? 'Text') : null,
//         fontSize: type == ComponentType.text ? 16.0 : null,
//         color: type == ComponentType.text ? Colors.black : null,
//       ),
//     );
//     updateComponentPosition(selectedComponent!.id, pos);
//     notifyListeners();
//   }

//   void updateComponentPosition(String id, Offset pos) {
//     final c = components.firstWhere((c) => c.id == id);
//     c.position = pos; // Remove clamping to allow boundary and outside placement
//     debugPrint(
//       'Updated position for ${c.type.displayName}: (${c.position.dx}, ${c.position.dy})',
//     );
//     notifyListeners();
//   }

//   void updateComponentSize(String id, double w, double h) {
//     final c = components.firstWhere((c) => c.id == id);
//     c.width = w.clamp(
//       0.5,
//       roomWidth * 2,
//     ); // Allow larger sizes for outside placement
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
//           type: s.type,
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
//       if (s.type != ComponentType.text &&
//           (s.rotation == 90 || s.rotation == 270)) {
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
//                 final typeIndex = c['type'] as int?;
//                 if (typeIndex == null ||
//                     typeIndex < 0 ||
//                     typeIndex >= ComponentType.values.length) {
//                   debugPrint(
//                     'Invalid component type at index $index: $typeIndex',
//                   );
//                   return null;
//                 }
//                 final component = PlacedComponent.fromJson(c, scale, isLegacy);
//                 debugPrint(
//                   'Loaded component: ${component.type.displayName}, Raw Position: (${c['position']['x']}, ${c['position']['y']}), Scaled Position: (${component.position.dx}, ${component.position.dy})',
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

//   Widget _dimInput(
//     String label,
//     TextEditingController ctrl,
//     Function(double) onChange,
//   ) => Row(
//     children: [
//       Text(
//         label,
//         style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
//       ),
//       const SizedBox(width: 4),
//       SizedBox(
//         width: 60,
//         child: TextField(
//           controller: ctrl,
//           keyboardType: TextInputType.number,
//           style: const TextStyle(fontSize: 13),
//           decoration: const InputDecoration(
//             border: OutlineInputBorder(),
//             isDense: true,
//             contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
//             suffixText: 'ft',
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
//       backgroundColor: Colors.grey[100],
//       body: Row(
//         children: [
//           ComponentPropertiesPanel(screenshotController: screenshotController),
//           Expanded(
//             child: Column(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   color: Colors.white,
//                   child: SingleChildScrollView(
//                     scrollDirection: Axis.horizontal,
//                     child: Row(
//                       children: [
//                         _dimInput(
//                           'Width:',
//                           widthCtrl,
//                           (w) => p.updateRoomDimensions(w, p.roomHeight),
//                         ),
//                         const SizedBox(width: 12),
//                         _dimInput(
//                           'Height:',
//                           heightCtrl,
//                           (h) => p.updateRoomDimensions(p.roomWidth, h),
//                         ),
//                         const SizedBox(width: 20),
//                         const VerticalDivider(),
//                         const SizedBox(width: 20),
//                         Row(
//                           children: [
//                             const Text(
//                               'Zoom:',
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 13,
//                               ),
//                             ),
//                             IconButton(
//                               icon: const Icon(Icons.zoom_out, size: 20),
//                               onPressed: () => p.updateZoom(-0.1),
//                             ),
//                             Consumer<FloorPlanProvider>(
//                               builder:
//                                   (_, prov, __) => Text(
//                                     '${(prov.zoomLevel * 100).toInt()}%',
//                                     style: const TextStyle(fontSize: 13),
//                                   ),
//                             ),
//                             IconButton(
//                               icon: const Icon(Icons.zoom_in, size: 20),
//                               onPressed: () => p.updateZoom(0.1),
//                             ),
//                             TextButton(
//                               onPressed: () => p.setZoom(1.0),
//                               child: const Text(
//                                 'Reset',
//                                 style: TextStyle(fontSize: 13),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 Expanded(
//                   child: Container(
//                     margin: const EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(8),
//                       boxShadow: const [
//                         BoxShadow(
//                           color: Colors.black12,
//                           blurRadius: 10,
//                           offset: Offset(0, 4),
//                         ),
//                       ],
//                     ),
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(8),
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
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black12,
//                         blurRadius: 10,
//                         offset: Offset(0, -4),
//                       ),
//                     ],
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
//   const ComponentPropertiesPanel({
//     super.key,
//     required this.screenshotController,
//   });

//   Widget _btn(
//     IconData icon,
//     String label,
//     VoidCallback onPressed, [
//     Color? color,
//   ]) => ElevatedButton.icon(
//     icon: Icon(icon, size: 18),
//     label: Text(label, style: const TextStyle(fontSize: 13)),
//     style: ElevatedButton.styleFrom(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//       backgroundColor: color,
//       minimumSize: const Size(double.infinity, 36),
//     ),
//     onPressed: onPressed,
//   );

//   Widget _iconBtn(
//     IconData icon,
//     String tooltip,
//     VoidCallback onPressed,
//     bool active,
//   ) => IconButton(
//     icon: Icon(icon, size: 20),
//     tooltip: tooltip,
//     padding: const EdgeInsets.all(4),
//     constraints: const BoxConstraints(),
//     onPressed: onPressed,
//     color: active ? Colors.blue : Colors.grey,
//   );

//   Widget _slider(String label, double val, Function(double) onChange) => Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
//       const SizedBox(height: 8),
//       Row(
//         children: [
//           Expanded(
//             child: Slider(
//               value: val,
//               min: 0.5,
//               max: 10,
//               divisions: 19,
//               label: val.toStringAsFixed(1),
//               onChanged: onChange,
//             ),
//           ),
//           const SizedBox(width: 8),
//           Text('${val.toStringAsFixed(1)} ft'),
//         ],
//       ),
//       const SizedBox(height: 16),
//     ],
//   );

//   Widget _fontSizeSlider(String label, double val, Function(double) onChange) =>
//       Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
//           const SizedBox(height: 8),
//           Row(
//             children: [
//               Expanded(
//                 child: Slider(
//                   value: val,
//                   min: 8,
//                   max: 48,
//                   divisions: 40,
//                   label: val.toStringAsFixed(0),
//                   onChanged: onChange,
//                 ),
//               ),
//               const SizedBox(width: 8),
//               Text('${val.toStringAsFixed(0)} pt'),
//             ],
//           ),
//           const SizedBox(height: 16),
//         ],
//       );

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
//         const SnackBar(
//           content: Text('Floor plan saved as JSON!'),
//           backgroundColor: Colors.green,
//           duration: Duration(seconds: 2),
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
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(
//                 content: Text('Floor plan loaded from file!'),
//                 backgroundColor: Colors.green,
//                 duration: Duration(seconds: 2),
//               ),
//             );
//           } catch (e) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text('Error loading JSON: $e'),
//                 backgroundColor: Colors.red,
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
//           const SnackBar(
//             content: Text('Floor plan image exported!'),
//             backgroundColor: Colors.orange,
//             duration: Duration(seconds: 2),
//           ),
//         );
//       }
//     }

//     return Container(
//       width: 250,
//       color: Colors.white,
//       child: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 'Component Properties',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 20),
//               Consumer<FloorPlanProvider>(
//                 builder: (_, p, __) {
//                   final c = p.selectedComponent;
//                   if (c == null) {
//                     return const Text(
//                       'Select a component to edit properties',
//                       style: TextStyle(color: Colors.grey),
//                     );
//                   }
//                   return Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text('Type: ${c.type.displayName}'),
//                       const SizedBox(height: 16),
//                       if (c.type == ComponentType.text) ...[
//                         TextField(
//                           decoration: const InputDecoration(
//                             labelText: 'Text Content',
//                             border: OutlineInputBorder(),
//                             isDense: true,
//                           ),
//                           controller: TextEditingController(text: c.text),
//                           onChanged:
//                               (value) =>
//                                   p.updateTextProperties(c.id, text: value),
//                         ),
//                         const SizedBox(height: 16),
//                         _fontSizeSlider(
//                           'Font Size:',
//                           c.fontSize ?? 16.0,
//                           (v) => p.updateTextProperties(c.id, fontSize: v),
//                         ),
//                         const Text(
//                           'Color:',
//                           style: TextStyle(fontWeight: FontWeight.w500),
//                         ),
//                         const SizedBox(height: 8),
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
//                               Colors.red,
//                               c.color,
//                               (color) =>
//                                   p.updateTextProperties(c.id, color: color),
//                             ),
//                             const SizedBox(width: 8),
//                             _colorButton(
//                               Colors.blue,
//                               c.color,
//                               (color) =>
//                                   p.updateTextProperties(c.id, color: color),
//                             ),
//                             const SizedBox(width: 8),
//                             _colorButton(
//                               Colors.green,
//                               c.color,
//                               (color) =>
//                                   p.updateTextProperties(c.id, color: color),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 16),
//                       ] else ...[
//                         _slider(
//                           'Width (ft):',
//                           c.width,
//                           (v) => p.updateComponentSize(c.id, v, c.height),
//                         ),
//                         _slider(
//                           'Height (ft):',
//                           c.height,
//                           (v) => p.updateComponentSize(c.id, c.width, v),
//                         ),
//                       ],
//                       const Divider(),
//                       const SizedBox(height: 16),
//                       const Text(
//                         'Position:',
//                         style: TextStyle(fontWeight: FontWeight.w500),
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         'X: ${(c.position.dx / (p.scale * p.zoomLevel)).toStringAsFixed(1)} ft',
//                       ),
//                       Text(
//                         'Y: ${(c.position.dy / (p.scale * p.zoomLevel)).toStringAsFixed(1)} ft',
//                       ),
//                       const SizedBox(height: 16),
//                       Text('Rotation: ${c.rotation}°'),
//                     ],
//                   );
//                 },
//               ),
//               const Divider(),
//               const SizedBox(height: 16),
//               const Text(
//                 'Actions',
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 12),
//               _btn(Icons.rotate_right, 'Rotate', p.rotateSelected),
//               const SizedBox(height: 8),
//               _btn(Icons.copy, 'Duplicate', p.duplicateSelected),
//               const SizedBox(height: 8),
//               _btn(Icons.delete, 'Delete', p.deleteSelected, Colors.red),
//               const SizedBox(height: 8),
//               _btn(Icons.clear, 'Clear All', p.clearAll, Colors.red[300]),
//               const SizedBox(height: 8),
//               Consumer<FloorPlanProvider>(
//                 builder:
//                     (_, prov, __) => _iconBtn(
//                       Icons.grid_on,
//                       'Toggle Grid',
//                       prov.toggleGrid,
//                       prov.showGrid,
//                     ),
//               ),
//               const SizedBox(height: 8),
//               Consumer<FloorPlanProvider>(
//                 builder:
//                     (_, prov, __) => _iconBtn(
//                       Icons.straighten,
//                       'Toggle Dimensions',
//                       prov.toggleDimensions,
//                       prov.showDimensions,
//                     ),
//               ),
//               const SizedBox(height: 12),
//               _btn(Icons.download, 'Save JSON', saveToJson, Colors.green),
//               const SizedBox(height: 8),
//               _btn(Icons.upload, 'Load JSON', loadFromJson, Colors.blue),
//               const SizedBox(height: 8),
//               _btn(Icons.image, 'Export PNG', exportImage, Colors.orange),
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
//       width: 24,
//       height: 24,
//       decoration: BoxDecoration(
//         color: color,
//         border: Border.all(
//           color: selectedColor == color ? Colors.white : Colors.grey,
//           width: 2,
//         ),
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 2)],
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
//         return DragTarget<ComponentType>(
//           onAcceptWithDetails: (d) {
//             final box = context.findRenderObject() as RenderBox;
//             final local = box.globalToLocal(d.offset);
//             final rect = Rect.fromCenter(
//               center: box.size.center(Offset.zero),
//               width: w,
//               height: h,
//             );
//             p.addComponent(d.data, local - rect.topLeft);
//           },
//           builder:
//               (_, __, ___) => Screenshot(
//                 controller: screenshotController,
//                 child: InteractiveViewer(
//                   minScale: 0.5,
//                   maxScale: 2.0,
//                   boundaryMargin: const EdgeInsets.all(
//                     1000,
//                   ), // Increased for outside placement
//                   child: Center(
//                     child: SizedBox(
//                       width: w,
//                       height: h,
//                       child: Stack(
//                         clipBehavior: Clip.none, // Allow components to overflow
//                         children: [
//                           CustomPaint(
//                             size: Size(w, h),
//                             painter: FloorPlanPainter(
//                               roomWidth: p.roomWidth,
//                               roomHeight: p.roomHeight,
//                               scale: p.scale * p.zoomLevel,
//                               showGrid: p.showGrid,
//                               showDimensions: p.showDimensions,
//                             ),
//                           ),
//                           ...p.components.map(
//                             (c) => Positioned(
//                               left: c.position.dx,
//                               top: c.position.dy,
//                               child: GestureDetector(
//                                 onTap: () => p.selectComponent(c),
//                                 onPanUpdate:
//                                     (d) => p.updateComponentPosition(
//                                       c.id,
//                                       c.position + d.delta,
//                                     ),
//                                 child: Transform.rotate(
//                                   angle: c.rotation * math.pi / 180,
//                                   child: Container(
//                                     width: c.width * p.scale * p.zoomLevel,
//                                     height: c.height * p.scale * p.zoomLevel,
//                                     decoration: BoxDecoration(
//                                       border:
//                                           p.selectedComponent?.id == c.id
//                                               ? Border.all(
//                                                 color: Colors.blue,
//                                                 width: 2,
//                                               )
//                                               : null,
//                                     ),
//                                     child: CustomPaint(
//                                       painter: ComponentPainter(
//                                         type: c.type,
//                                         isSelected:
//                                             p.selectedComponent?.id == c.id,
//                                         text: c.text,
//                                         fontSize: c.fontSize,
//                                         color: c.color,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//         );
//       },
//     );
//   }
// }

// class ComponentPainter extends CustomPainter {
//   final ComponentType type;
//   final bool isSelected;
//   final String? text;
//   final double? fontSize;
//   final Color? color;

//   static const Map<ComponentType, String> imageAsset = {
//     ComponentType.doorLeft: 'assets/images/Door_LH.png',
//     ComponentType.doorRight: 'assets/images/Door_RH.png',
//     ComponentType.window: 'assets/images/Window.png',
//     ComponentType.windowWithShutters: 'assets/images/W_Shutters.png',
//     ComponentType.flowerBox: 'assets/images/Flower_Box.png',
//     ComponentType.workbench: 'assets/images/Workbench.png',
//     ComponentType.rud: 'assets/images/RUD.png',
//     ComponentType.text: '', // Text uses TextPainter, no image
//   };

//   ComponentPainter({
//     required this.type,
//     required this.isSelected,
//     this.text,
//     this.fontSize,
//     this.color,
//   });

//   @override
//   void paint(Canvas canvas, Size s) {
//     if (type == ComponentType.text) {
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
//             ..color = Colors.blue
//             ..strokeWidth = 2
//             ..style = PaintingStyle.stroke,
//         );
//       }
//     } else {
//       final imageProvider = AssetImage(imageAsset[type]!);
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
//                 ..color = Colors.blue
//                 ..strokeWidth = 2
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

// class ComponentToolbar extends StatelessWidget {
//   const ComponentToolbar({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final textCtrl = TextEditingController();
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
//       child: SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         child: Row(
//           children: [
//             ...ComponentType.values
//                 .where((t) => t != ComponentType.text)
//                 .map(
//                   (t) => Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 8),
//                     child: Draggable<ComponentType>(
//                       data: t,
//                       feedback: Material(
//                         elevation: 8,
//                         borderRadius: BorderRadius.circular(8),
//                         child: Container(
//                           padding: const EdgeInsets.all(12),
//                           decoration: BoxDecoration(
//                             color: Colors.blue.withOpacity(0.8),
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: Text(
//                             t.displayName,
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 12,
//                             ),
//                           ),
//                         ),
//                       ),
//                       child: Container(
//                         width: 100,
//                         height: 80,
//                         decoration: BoxDecoration(
//                           border: Border.all(color: Colors.grey[300]!),
//                           borderRadius: BorderRadius.circular(8),
//                           color: Colors.white,
//                           boxShadow: const [
//                             BoxShadow(
//                               color: Colors.black12,
//                               blurRadius: 4,
//                               offset: Offset(0, 2),
//                             ),
//                           ],
//                         ),
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             SizedBox(
//                               width: 50,
//                               height: 40,
//                               child: CustomPaint(
//                                 painter: SimpleComponentPainter(type: t),
//                               ),
//                             ),
//                             const SizedBox(height: 8),
//                             Text(
//                               t.displayName,
//                               style: const TextStyle(
//                                 fontSize: 11,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 8),
//               child: Container(
//                 width: 200,
//                 height: 80,
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.grey[300]!),
//                   borderRadius: BorderRadius.circular(8),
//                   color: Colors.white,
//                   boxShadow: const [
//                     BoxShadow(
//                       color: Colors.black12,
//                       blurRadius: 4,
//                       offset: Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     SizedBox(
//                       width: 180,
//                       child: TextField(
//                         controller: textCtrl,
//                         decoration: const InputDecoration(
//                           hintText: 'Enter text',
//                           border: OutlineInputBorder(),
//                           isDense: true,
//                           contentPadding: EdgeInsets.symmetric(
//                             horizontal: 8,
//                             vertical: 4,
//                           ),
//                         ),
//                         style: const TextStyle(fontSize: 12),
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     ElevatedButton(
//                       onPressed: () {
//                         final p = context.read<FloorPlanProvider>();
//                         p.addComponent(
//                           ComponentType.text,
//                           Offset(
//                             p.roomWidth * p.scale / 2,
//                             p.roomHeight * p.scale / 2,
//                           ),
//                           text: textCtrl.text.isEmpty ? 'Text' : textCtrl.text,
//                         );
//                         textCtrl.clear();
//                       },
//                       child: const Text(
//                         'Add Text',
//                         style: TextStyle(fontSize: 11),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class SimpleComponentPainter extends CustomPainter {
//   final ComponentType type;
//   SimpleComponentPainter({required this.type});

//   @override
//   void paint(Canvas canvas, Size s) {
//     final p =
//         Paint()
//           ..color = Colors.black
//           ..strokeWidth = 1
//           ..style = PaintingStyle.stroke;
//     final r = Rect.fromLTWH(2, 2, s.width - 4, s.height - 4);

//     switch (type) {
//       case ComponentType.doorLeft:
//       case ComponentType.doorRight:
//         canvas.drawLine(Offset(0, s.height), Offset(s.width, s.height), p);
//         canvas.drawArc(
//           Rect.fromCircle(
//             center: Offset(
//               type == ComponentType.doorLeft ? 0 : s.width,
//               s.height,
//             ),
//             radius: s.width * 0.7,
//           ),
//           type == ComponentType.doorLeft ? -math.pi / 2 : math.pi,
//           math.pi / 2,
//           false,
//           p,
//         );
//         break;
//       case ComponentType.window:
//         canvas.drawRect(r, p);
//         canvas.drawLine(
//           Offset(s.width / 2, 2),
//           Offset(s.width / 2, s.height - 2),
//           p,
//         );
//         canvas.drawLine(
//           Offset(2, s.height / 2),
//           Offset(s.width - 2, s.height / 2),
//           p,
//         );
//         break;
//       case ComponentType.windowWithShutters:
//         canvas.drawRect(Rect.fromLTWH(0, 2, 8, s.height - 4), p);
//         canvas.drawRect(Rect.fromLTWH(s.width - 8, 2, 8, s.height - 4), p);
//         canvas.drawRect(Rect.fromLTWH(10, 2, s.width - 20, s.height - 4), p);
//         break;
//       case ComponentType.flowerBox:
//         canvas.drawRect(
//           Rect.fromLTWH(2, s.height / 2, s.width - 4, s.height / 2 - 2),
//           p,
//         );
//         for (var i = 1; i < 4; i++) {
//           canvas.drawCircle(Offset(s.width * (i / 4), s.height * 0.3), 3, p);
//         }
//         break;
//       case ComponentType.workbench:
//         canvas.drawRect(r, p);
//         canvas.drawLine(
//           Offset(s.width / 3, 2),
//           Offset(s.width / 3, s.height - 2),
//           p,
//         );
//         canvas.drawLine(
//           Offset(2 * s.width / 3, 2),
//           Offset(2 * s.width / 3, s.height - 2),
//           p,
//         );
//         break;
//       case ComponentType.rud:
//         canvas.drawRect(r, p);
//         for (var i = 1; i < 4; i++) {
//           canvas.drawLine(
//             Offset(2, 2 + (s.height - 4) * i / 4),
//             Offset(s.width - 2, 2 + (s.height - 4) * i / 4),
//             p,
//           );
//         }
//         break;
//       case ComponentType.text:
//         final tp = TextPainter(
//           text: const TextSpan(
//             text: 'Text',
//             style: TextStyle(color: Colors.black, fontSize: 12),
//           ),
//           textDirection: TextDirection.ltr,
//         )..layout();
//         tp.paint(
//           canvas,
//           Offset((s.width - tp.width) / 2, (s.height - tp.height) / 2),
//         );
//         break;
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter old) => false;
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
//         style: TextStyle(
//           color: Colors.grey[600],
//           fontSize: 12,
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
//             ..color = Colors.grey.withOpacity(0.2)
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
//           ..color = Colors.black
//           ..strokeWidth = 3
//           ..style = PaintingStyle.stroke;
//     canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), wp);
//     if (roomWidth >= 12) {
//       final dp =
//           Paint()
//             ..color = Colors.black
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
//               color: Colors.black,
//               fontSize: 11,
//               fontWeight: FontWeight.w500,
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
//             ..color = Colors.grey[600]!
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

// enum ComponentType {
//   doorLeft,
//   doorRight,
//   window,
//   windowWithShutters,
//   flowerBox,
//   workbench,
//   rud,
//   text,
// }

// extension ComponentTypeExt on ComponentType {
//   String get displayName =>
//       [
//         'Door LH',
//         'Door RH',
//         'Window',
//         'W/Shutters',
//         'Flower Box',
//         'Workbench',
//         'RUD',
//         'Text',
//       ][index];
//   double get defaultWidth => [3.0, 3.0, 2.0, 3.0, 3.0, 4.0, 2.0, 2.0][index];
//   double get defaultHeight => [6.5, 6.5, 3.0, 3.0, 1.0, 2.5, 4.0, 1.0][index];
// }

// class PlacedComponent {
//   String id;
//   ComponentType type;
//   Offset position;
//   double width, height, rotation;
//   String? text;
//   double? fontSize;
//   Color? color;

//   PlacedComponent({
//     required this.id,
//     required this.type,
//     required this.position,
//     required this.width,
//     required this.height,
//     required this.rotation,
//     this.text,
//     this.fontSize,
//     this.color,
//   });

//   Map<String, dynamic> toJson(double scale) => {
//     'id': id,
//     'type': type.index,
//     'position': {'x': position.dx / scale, 'y': position.dy / scale},
//     'width': width,
//     'height': height,
//     'rotation': rotation,
//     if (type == ComponentType.text) 'text': text,
//     if (type == ComponentType.text) 'fontSize': fontSize,
//     if (type == ComponentType.text) 'color': color?.value,
//   };

//   static PlacedComponent fromJson(
//     Map<String, dynamic> j,
//     double scale,
//     bool isLegacy,
//   ) => PlacedComponent(
//     id: j['id'] as String,
//     type: ComponentType.values[j['type'] as int],
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
//     width: (j['width'] as num).toDouble(),
//     height: (j['height'] as num).toDouble(),
//     rotation: (j['rotation'] as num).toDouble(),
//     text: j['text'] as String?,
//     fontSize: (j['fontSize'] as num?)?.toDouble(),
//     color: j['color'] != null ? Color(j['color'] as int) : null,
//   );
// }
