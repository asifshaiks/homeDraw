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
//                         const SizedBox(width: 20),
//                         const VerticalDivider(),
//                         const SizedBox(width: 20),
//                         SizedBox(
//                           width: 200,
//                           child: TextField(
//                             controller: textCtrl,
//                             decoration: const InputDecoration(
//                               hintText: 'Enter text',
//                               border: OutlineInputBorder(),
//                               isDense: true,
//                               contentPadding: EdgeInsets.symmetric(
//                                 horizontal: 8,
//                                 vertical: 4,
//                               ),
//                             ),
//                             style: const TextStyle(fontSize: 12),
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         ElevatedButton(
//                           onPressed: () {
//                             final p = context.read<FloorPlanProvider>();
//                             p.addText(
//                               textCtrl.text.isEmpty ? 'Text' : textCtrl.text,
//                               Offset(
//                                 p.roomWidth * p.scale / 2,
//                                 p.roomHeight * p.scale / 2,
//                               ),
//                             );
//                             textCtrl.clear();
//                           },
//                           child: const Text(
//                             'Add Text',
//                             style: TextStyle(fontSize: 11),
//                           ),
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
//                   height: 110,
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
//                       Text('Component: ${c.imageName ?? 'Text'}'),
//                       const SizedBox(height: 16),
//                       if (c.text != null) ...[
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
//                                               color: Colors.blue,
//                                               width: 2,
//                                             )
//                                             : null,
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
//             onWillAccept: (data) => true, // Allow drop acceptance
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
//             ..color = Colors.blue
//             ..strokeWidth = 2
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
//       padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
//       child: Row(
//         children: [
//           IconButton(
//             icon: const Icon(Icons.arrow_left),
//             onPressed: _scrollLeft,
//             color: Colors.grey,
//           ),
//           Expanded(
//             child: SingleChildScrollView(
//               controller: _scrollController,
//               scrollDirection: Axis.horizontal,
//               child: Row(
//                 children:
//                     imageNames
//                         .map(
//                           (imageName) => Padding(
//                             padding: const EdgeInsets.symmetric(horizontal: 8),
//                             child: Draggable<String>(
//                               data: imageName,
//                               feedback: Material(
//                                 elevation: 8,
//                                 borderRadius: BorderRadius.circular(8),
//                                 child: Container(
//                                   padding: const EdgeInsets.all(12),
//                                   decoration: BoxDecoration(
//                                     color: Colors.blue.withOpacity(0.8),
//                                     borderRadius: BorderRadius.circular(8),
//                                   ),
//                                   child: Text(
//                                     imageName
//                                         .replaceAll('.png', '')
//                                         .replaceAll('_', ' '),
//                                     style: const TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 12,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               child: Container(
//                                 width: 100,
//                                 height: 80,
//                                 decoration: BoxDecoration(
//                                   border: Border.all(color: Colors.grey[300]!),
//                                   borderRadius: BorderRadius.circular(8),
//                                   color: Colors.white,
//                                   boxShadow: const [
//                                     BoxShadow(
//                                       color: Colors.black12,
//                                       blurRadius: 4,
//                                       offset: Offset(0, 2),
//                                     ),
//                                   ],
//                                 ),
//                                 child: Column(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     SizedBox(
//                                       width: 80,
//                                       height: 60,
//                                       child: Image.asset(
//                                         'assets/images/$imageName',
//                                         fit: BoxFit.contain,
//                                         errorBuilder:
//                                             (context, error, stackTrace) =>
//                                                 Container(
//                                                   color: Colors.grey,
//                                                   child: const Center(
//                                                     child: Text('Image Error'),
//                                                   ),
//                                                 ),
//                                       ),
//                                     ),
//                                     const SizedBox(height: 8),
//                                     Text(
//                                       imageName
//                                           .replaceAll('.png', '')
//                                           .replaceAll('_', ' '),
//                                       style: const TextStyle(
//                                         fontSize: 11,
//                                         fontWeight: FontWeight.w500,
//                                       ),
//                                       textAlign: TextAlign.center,
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
//           IconButton(
//             icon: const Icon(Icons.arrow_right),
//             onPressed: _scrollRight,
//             color: Colors.grey,
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
//     width: (j['width'] as num).toDouble(),
//     height: (j['height'] as num).toDouble(),
//     rotation: (j['rotation'] as num).toDouble(),
//     imageName: j['imageName'] as String?,
//     text: j['text'] as String?,
//     fontSize: (j['fontSize'] as num?)?.toDouble(),
//     color: j['color'] != null ? Color(j['color'] as int) : null,
//   );
// }
