import 'package:draw/floor_plan_designer/models/placed_component.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class FloorPlanProvider extends ChangeNotifier {
  double roomWidth = 20,
      roomHeight = 15,
      scale = 30,
      zoomLevel = 0.6; // Set initial zoom to 60%
  List<PlacedComponent> components = [];
  PlacedComponent? selectedComponent;
  bool showGrid = true, showDimensions = true;

  void updateRoomDimensions(double w, double h) {
    roomWidth = w;
    roomHeight = h;
    notifyListeners();
  }

  void updateZoom(double delta) => setZoom(zoomLevel + delta);

  void setZoom(double z) {
    zoomLevel = z.clamp(0.5, 2.0);
    notifyListeners();
  }

  void addComponent(String imageName, Offset pos) {
    components.add(
      selectedComponent = PlacedComponent(
        id: const Uuid().v4(),
        imageName: imageName,
        position: pos,
        width: 3.0, // Default width
        height: 3.0, // Default height
        rotation: 0,
      ),
    );
    updateComponentPosition(selectedComponent!.id, pos);
    notifyListeners();
  }

  void addText(String text, Offset pos) {
    components.add(
      selectedComponent = PlacedComponent(
        id: const Uuid().v4(),
        position: pos,
        width: 2.0,
        height: 1.0,
        rotation: 0,
        text: text,
        fontSize: 16.0,
        color: Colors.black,
      ),
    );
    updateComponentPosition(selectedComponent!.id, pos);
    notifyListeners();
  }

  void updateComponentPosition(String id, Offset pos) {
    final c = components.firstWhere((c) => c.id == id);
    c.position = pos; // Allow unrestricted positioning
    notifyListeners();
  }

  void updateComponentSize(String id, double w, double h) {
    final c = components.firstWhere((c) => c.id == id);
    c.width = w.clamp(0.5, roomWidth * 2);
    c.height = h.clamp(0.5, roomHeight * 2);
    updateComponentPosition(id, c.position);
    notifyListeners();
  }

  void updateTextProperties(
    String id, {
    String? text,
    double? fontSize,
    Color? color,
  }) {
    final c = components.firstWhere((c) => c.id == id);
    if (text != null) c.text = text;
    if (fontSize != null) c.fontSize = fontSize.clamp(8.0, 48.0);
    if (color != null) c.color = color;
    notifyListeners();
  }

  void selectComponent(PlacedComponent? c) {
    selectedComponent = c;
    notifyListeners();
  }

  void deleteSelected() {
    if (selectedComponent != null) {
      components.remove(selectedComponent);
      selectedComponent = null;
      notifyListeners();
    }
  }

  void duplicateSelected() {
    if (selectedComponent != null) {
      final s = selectedComponent!;
      components.add(
        selectedComponent = PlacedComponent(
          id: const Uuid().v4(),
          imageName: s.imageName,
          position: s.position + const Offset(20, 20),
          width: s.width,
          height: s.height,
          rotation: s.rotation,
          text: s.text,
          fontSize: s.fontSize,
          color: s.color,
        ),
      );
      updateComponentPosition(
        selectedComponent!.id,
        selectedComponent!.position,
      );
      notifyListeners();
    }
  }

  void rotateSelected() {
    if (selectedComponent != null) {
      final s = selectedComponent!;
      s.rotation = (s.rotation + 90) % 360;
      if (s.imageName != null && (s.rotation == 90 || s.rotation == 270)) {
        final temp = s.width;
        s.width = s.height;
        s.height = temp;
      }
      updateComponentPosition(s.id, s.position);
      notifyListeners();
    }
  }

  void clearAll() {
    components.clear();
    selectedComponent = null;
    notifyListeners();
  }

  void toggleGrid() {
    showGrid = !showGrid;
    notifyListeners();
  }

  void toggleDimensions() {
    showDimensions = !showDimensions;
    notifyListeners();
  }

  Map<String, dynamic> toJson() => {
    'roomWidth': roomWidth,
    'roomHeight': roomHeight,
    'scale': scale,
    'components': components.map((c) => c.toJson(scale)).toList(),
    'showGrid': showGrid,
    'showDimensions': showDimensions,
    'version': '2.0',
  };

  void loadFromJson(Map<String, dynamic> json) {
    try {
      roomWidth = (json['roomWidth'] as num?)?.toDouble() ?? 20.0;
      roomHeight = (json['roomHeight'] as num?)?.toDouble() ?? 15.0;
      scale = (json['scale'] as num?)?.toDouble() ?? 30.0;
      showGrid = json['showGrid'] as bool? ?? true;
      showDimensions = json['showDimensions'] as bool? ?? true;
      final version = json['version'] as String? ?? '1.0';
      final isLegacy = version == '1.0';
      components =
          (json['components'] as List? ?? [])
              .asMap()
              .entries
              .map((entry) {
                final index = entry.key;
                final c = entry.value as Map<String, dynamic>;
                final component = PlacedComponent.fromJson(c, scale, isLegacy);
                debugPrint(
                  'Loaded component: ${component.imageName ?? 'Text'}, Scaled Position: (${component.position.dx}, ${component.position.dy})',
                );
                return component;
              })
              .whereType<PlacedComponent>()
              .toList();
      selectedComponent = null;
      for (var c in components) {
        updateComponentPosition(c.id, c.position);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading JSON: $e');
      throw Exception('Invalid JSON format: $e');
    }
  }
}
