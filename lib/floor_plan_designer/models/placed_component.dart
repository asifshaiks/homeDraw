import 'package:flutter/material.dart';

class PlacedComponent {
  String id;
  Offset position;
  double width, height, rotation;
  String? imageName;
  String? text;
  double? fontSize;
  Color? color;

  PlacedComponent({
    required this.id,
    required this.position,
    required this.width,
    required this.height,
    required this.rotation,
    this.imageName,
    this.text,
    this.fontSize,
    this.color,
  });

  Map<String, dynamic> toJson(double scale) => {
    'id': id,
    'position': {'x': position.dx / scale, 'y': position.dy / scale},
    'width': width,
    'height': height,
    'rotation': rotation,
    if (imageName != null) 'imageName': imageName,
    if (text != null) 'text': text,
    if (fontSize != null) 'fontSize': fontSize,
    if (color != null) 'color': color?.value,
    'frame': {'width': width, 'height': height},
  };

  static PlacedComponent fromJson(
    Map<String, dynamic> j,
    double scale,
    bool isLegacy,
  ) => PlacedComponent(
    id: j['id'] as String,
    position:
        isLegacy
            ? Offset(
              (j['position']['x'] as num).toDouble(),
              (j['position']['y'] as num).toDouble(),
            )
            : Offset(
              (j['position']['x'] as num).toDouble() * scale,
              (j['position']['y'] as num).toDouble() * scale,
            ),
    width:
        (j['frame'] != null
            ? (j['frame']['width'] as num).toDouble()
            : (j['width'] as num).toDouble()) ??
        20.0,
    height:
        (j['frame'] != null
            ? (j['frame']['height'] as num).toDouble()
            : (j['height'] as num).toDouble()) ??
        15.0,
    rotation: (j['rotation'] as num).toDouble(),
    imageName: j['imageName'] as String?,
    text: j['text'] as String?,
    fontSize: (j['fontSize'] as num?)?.toDouble(),
    color: j['color'] != null ? Color(j['color'] as int) : null,
  );
}
