import 'package:draw/floor_plan_designer/providers/floor_plan_provider.dart';
import 'package:draw/floor_plan_designer/widgets/canvas_area.dart';
import 'package:draw/floor_plan_designer/widgets/component_properties_panel.dart';
import 'package:draw/floor_plan_designer/widgets/component_toolbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';

class FloorPlanDesigner extends StatefulWidget {
  const FloorPlanDesigner({super.key});

  @override
  _FloorPlanDesignerState createState() => _FloorPlanDesignerState();
}

class _FloorPlanDesignerState extends State<FloorPlanDesigner> {
  final screenshotController = ScreenshotController();
  final widthCtrl = TextEditingController(text: '20');
  final heightCtrl = TextEditingController(text: '15');
  final textCtrl = TextEditingController();

  Widget _dimInput(
    String label,
    TextEditingController ctrl,
    Function(double) onChange,
  ) => Row(
    children: [
      Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
          color: Color(0xFF2C2C2C),
        ),
      ),
      const SizedBox(width: 8),
      Container(
        width: 70,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          style: const TextStyle(fontSize: 12, color: Color(0xFF2C2C2C)),
          decoration: const InputDecoration(
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            suffixText: 'ft',
            suffixStyle: TextStyle(color: Color(0xFF9E9E9E), fontSize: 11),
          ),
          onChanged: (v) => onChange(double.tryParse(v) ?? 20),
        ),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final p = context.read<FloorPlanProvider>();
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Row(
        children: [
          ComponentPropertiesPanel(
            screenshotController: screenshotController,
            widthCtrl: widthCtrl,
            heightCtrl: heightCtrl,
          ),
          Expanded(
            child: Column(
              children: [
                Container(
                  height: 60,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _dimInput(
                            'Width',
                            widthCtrl,
                            (w) => p.updateRoomDimensions(w, p.roomHeight),
                          ),
                          const SizedBox(width: 20),
                          _dimInput(
                            'Length',
                            heightCtrl,
                            (h) => p.updateRoomDimensions(p.roomWidth, h),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            width: 1,
                            height: 30,
                            color: const Color(0xFFE0E0E0),
                          ),
                          Row(
                            children: [
                              const Text(
                                'Zoom',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  color: Color(0xFF2C2C2C),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8F8F8),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(0xFFE0E0E0),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove, size: 16),
                                      onPressed: () => p.updateZoom(-0.1),
                                      padding: const EdgeInsets.all(6),
                                      constraints: const BoxConstraints(),
                                      color: const Color(0xFF666666),
                                    ),
                                    Consumer<FloorPlanProvider>(
                                      builder:
                                          (_, prov, __) => Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                            ),
                                            child: Text(
                                              '${(prov.zoomLevel * 100).toInt()}%',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF2C2C2C),
                                              ),
                                            ),
                                          ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add, size: 16),
                                      onPressed: () => p.updateZoom(0.1),
                                      padding: const EdgeInsets.all(6),
                                      constraints: const BoxConstraints(),
                                      color: const Color(0xFF666666),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              TextButton(
                                onPressed: () => p.setZoom(1.0),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  backgroundColor: const Color(0xFF2C2C2C),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                child: const Text(
                                  'Reset',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            width: 1,
                            height: 30,
                            color: const Color(0xFFE0E0E0),
                          ),
                          Container(
                            width: 180,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: const Color(0xFFE0E0E0),
                              ),
                            ),
                            child: TextField(
                              controller: textCtrl,
                              decoration: const InputDecoration(
                                hintText: 'Enter text label',
                                hintStyle: TextStyle(
                                  color: Color(0xFFBDBDBD),
                                  fontSize: 12,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF2C2C2C),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () {
                              final p = context.read<FloorPlanProvider>();
                              p.addText(
                                textCtrl.text.isEmpty ? 'Text' : textCtrl.text,
                                Offset(
                                  p.roomWidth * p.scale / 2,
                                  p.roomHeight * p.scale / 2,
                                ),
                              );
                              textCtrl.clear();
                            },
                            icon: const Icon(Icons.text_fields, size: 16),
                            label: const Text(
                              'Add Text',
                              style: TextStyle(fontSize: 11),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2C2C2C),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CanvasArea(
                        screenshotController: screenshotController,
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 120,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: Color(0xFFE0E0E0), width: 1),
                    ),
                  ),
                  child: const ComponentToolbar(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
