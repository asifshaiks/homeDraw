import 'package:draw/floor_plan_designer/providers/floor_plan_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'dart:convert';
import 'dart:html' as html;

class ComponentPropertiesPanel extends StatelessWidget {
  final ScreenshotController screenshotController;
  final TextEditingController widthCtrl;
  final TextEditingController heightCtrl;

  const ComponentPropertiesPanel({
    super.key,
    required this.screenshotController,
    required this.widthCtrl,
    required this.heightCtrl,
  });

  Widget _modernButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    Color backgroundColor = const Color(0xFF2C2C2C),
    Color iconColor = Colors.white,
  }) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    child: Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(icon, size: 18, color: iconColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: iconColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _iconToggle(
    IconData icon,
    String tooltip,
    VoidCallback onPressed,
    bool active,
  ) => Container(
    margin: const EdgeInsets.only(right: 8),
    child: Material(
      color: active ? const Color(0xFF2C2C2C) : const Color(0xFFF8F8F8),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 18,
            color: active ? Colors.white : const Color(0xFF666666),
          ),
        ),
      ),
    ),
  );

  Widget _modernSlider(
    String label,
    double val,
    Function(double) onChange,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
          color: Color(0xFF2C2C2C),
        ),
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                activeTrackColor: const Color(0xFF2C2C2C),
                inactiveTrackColor: const Color(0xFFE0E0E0),
                thumbColor: const Color(0xFF2C2C2C),
                overlayColor: const Color(0xFF2C2C2C).withOpacity(0.1),
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              ),
              child: Slider(
                value: val,
                min: 0.5,
                max: 10,
                divisions: 19,
                onChanged: onChange,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F8F8),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${val.toStringAsFixed(1)} ft',
              style: const TextStyle(fontSize: 11, color: Color(0xFF666666)),
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
    ],
  );

  Widget _fontSizeSlider(
    String label,
    double val,
    Function(double) onChange,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
          color: Color(0xFF2C2C2C),
        ),
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                activeTrackColor: const Color(0xFF2C2C2C),
                inactiveTrackColor: const Color(0xFFE0E0E0),
                thumbColor: const Color(0xFF2C2C2C),
                overlayColor: const Color(0xFF2C2C2C).withOpacity(0.1),
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              ),
              child: Slider(
                value: val,
                min: 8,
                max: 48,
                divisions: 40,
                onChanged: onChange,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F8F8),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${val.toStringAsFixed(0)} pt',
              style: const TextStyle(fontSize: 11, color: Color(0xFF666666)),
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final p = context.read<FloorPlanProvider>();

    void saveToJson() {
      final json = jsonEncode(p.toJson());
      final blob = html.Blob([utf8.encode(json)]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final fileName =
          'floor_plan_${DateTime.now().millisecondsSinceEpoch}.json';
      html.AnchorElement()
        ..href = url
        ..download = fileName
        ..click();
      html.Url.revokeObjectUrl(url);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Floor plan saved as JSON!'),
          backgroundColor: const Color(0xFF2C2C2C),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: const Duration(seconds: 2),
        ),
      );
    }

    void loadFromJson() {
      final input = html.FileUploadInputElement()..accept = '.json';
      input.click();
      input.onChange.listen((e) {
        final files = input.files;
        if (files!.isEmpty) return;
        final file = files[0];
        final reader = html.FileReader();
        reader.onLoadEnd.listen((e) {
          try {
            final content = reader.result as String;
            final jsonData = jsonDecode(content) as Map<String, dynamic>;
            p.loadFromJson(jsonData);
            widthCtrl.text = p.roomWidth.toString();
            heightCtrl.text = p.roomHeight.toString();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Floor plan loaded from file!'),
                backgroundColor: const Color(0xFF2C2C2C),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                duration: const Duration(seconds: 2),
              ),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error loading JSON: $e'),
                backgroundColor: const Color(0xFF666666),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                duration: const Duration(seconds: 3),
              ),
            );
          }
        });
        reader.readAsText(file);
      });
    }

    void exportImage() async {
      final image = await screenshotController.capture();
      if (image != null) {
        final blob = html.Blob([image]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final fileName =
            'floor_plan_${DateTime.now().millisecondsSinceEpoch}.png';
        html.AnchorElement()
          ..href = url
          ..download = fileName
          ..click();
        html.Url.revokeObjectUrl(url);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Floor plan image exported!'),
            backgroundColor: const Color(0xFF2C2C2C),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }

    return Container(
      width: 280,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Color(0xFFE0E0E0), width: 1)),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Properties',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2C2C2C),
                ),
              ),
              const SizedBox(height: 24),
              Consumer<FloorPlanProvider>(
                builder: (_, p, __) {
                  final c = p.selectedComponent;
                  if (c == null) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F8F8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Select a component to edit properties',
                        style: TextStyle(
                          color: Color(0xFF9E9E9E),
                          fontSize: 13,
                        ),
                      ),
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F8F8),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.layers,
                              size: 16,
                              color: Color(0xFF666666),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              c.imageName ?? 'Text Element',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2C2C2C),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (c.text != null) ...[
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFE0E0E0)),
                          ),
                          child: TextField(
                            decoration: const InputDecoration(
                              labelText: 'Text Content',
                              labelStyle: TextStyle(
                                color: Color(0xFF9E9E9E),
                                fontSize: 12,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(12),
                            ),
                            controller: TextEditingController(text: c.text),
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF2C2C2C),
                            ),
                            onChanged:
                                (value) =>
                                    p.updateTextProperties(c.id, text: value),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _fontSizeSlider(
                          'Font Size',
                          c.fontSize ?? 16.0,
                          (v) => p.updateTextProperties(c.id, fontSize: v),
                        ),
                        const Text(
                          'Text Color',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: Color(0xFF2C2C2C),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _colorButton(
                              Colors.black,
                              c.color,
                              (color) =>
                                  p.updateTextProperties(c.id, color: color),
                            ),
                            const SizedBox(width: 8),
                            _colorButton(
                              const Color(0xFF666666),
                              c.color,
                              (color) =>
                                  p.updateTextProperties(c.id, color: color),
                            ),
                            const SizedBox(width: 8),
                            _colorButton(
                              const Color(0xFF9E9E9E),
                              c.color,
                              (color) =>
                                  p.updateTextProperties(c.id, color: color),
                            ),
                            const SizedBox(width: 8),
                            _colorButton(
                              const Color(0xFFBDBDBD),
                              c.color,
                              (color) =>
                                  p.updateTextProperties(c.id, color: color),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ] else ...[
                        _modernSlider(
                          'Width',
                          c.width,
                          (v) => p.updateComponentSize(c.id, v, c.height),
                        ),
                        _modernSlider(
                          'Height',
                          c.height,
                          (v) => p.updateComponentSize(c.id, c.width, v),
                        ),
                      ],
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F8F8),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Position',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                color: Color(0xFF2C2C2C),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      const Text(
                                        'X: ',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF666666),
                                        ),
                                      ),
                                      Text(
                                        '${(c.position.dx / (p.scale * p.zoomLevel)).toStringAsFixed(1)} ft',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF2C2C2C),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Row(
                                    children: [
                                      const Text(
                                        'Y: ',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF666666),
                                        ),
                                      ),
                                      Text(
                                        '${(c.position.dy / (p.scale * p.zoomLevel)).toStringAsFixed(1)} ft',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF2C2C2C),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.rotate_right,
                                  size: 14,
                                  color: Color(0xFF666666),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Rotation: ${c.rotation}°',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF666666),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.only(bottom: 16),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Actions',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2C2C2C),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _modernButton(
                      icon: Icons.rotate_right,
                      label: 'Rotate',
                      onPressed: p.rotateSelected,
                    ),
                    _modernButton(
                      icon: Icons.copy,
                      label: 'Duplicate',
                      onPressed: p.duplicateSelected,
                    ),
                    _modernButton(
                      icon: Icons.delete_outline,
                      label: 'Delete',
                      onPressed: p.deleteSelected,
                      backgroundColor: const Color(0xFF666666),
                    ),
                    _modernButton(
                      icon: Icons.clear_all,
                      label: 'Clear All',
                      onPressed: p.clearAll,
                      backgroundColor: const Color(0xFF9E9E9E),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'View Options',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2C2C2C),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Consumer<FloorPlanProvider>(
                        builder:
                            (_, prov, __) => _iconToggle(
                              Icons.grid_on,
                              'Toggle Grid',
                              prov.toggleGrid,
                              prov.showGrid,
                            ),
                      ),
                      Consumer<FloorPlanProvider>(
                        builder:
                            (_, prov, __) => _iconToggle(
                              Icons.straighten,
                              'Toggle Dimensions',
                              prov.toggleDimensions,
                              prov.showDimensions,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.only(top: 20),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Color(0xFFE0E0E0), width: 1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'File Operations',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2C2C2C),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _modernButton(
                      icon: Icons.save_alt,
                      label: 'Save as JSON',
                      onPressed: saveToJson,
                    ),
                    _modernButton(
                      icon: Icons.folder_open,
                      label: 'Load JSON',
                      onPressed: loadFromJson,
                    ),
                    _modernButton(
                      icon: Icons.image,
                      label: 'Export as PNG',
                      onPressed: exportImage,
                      backgroundColor: const Color(0xFF4A4A4A),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _colorButton(
    Color color,
    Color? selectedColor,
    Function(Color) onSelect,
  ) => GestureDetector(
    onTap: () => onSelect(color),
    child: Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(
          color:
              selectedColor == color
                  ? const Color(0xFF2C2C2C)
                  : const Color(0xFFE0E0E0),
          width: selectedColor == color ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
    ),
  );
}
