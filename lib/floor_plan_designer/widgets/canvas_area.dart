import 'package:draw/floor_plan_designer/providers/floor_plan_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'dart:math' as math;

import 'package:draw/floor_plan_designer/widgets/floor_plan_painter.dart';

class CanvasArea extends StatelessWidget {
  final ScreenshotController screenshotController;
  const CanvasArea({super.key, required this.screenshotController});

  @override
  Widget build(BuildContext context) {
    return Consumer<FloorPlanProvider>(
      builder: (_, p, __) {
        final w = p.roomWidth * p.scale * p.zoomLevel;
        final h = p.roomHeight * p.scale * p.zoomLevel;
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTapUp: (details) {
            final box = context.findRenderObject() as RenderBox?;
            if (box == null) return;
            final local = box.globalToLocal(details.globalPosition);
            final adjustedLocal =
                local - const Offset(16, 16); // Account for margin
            for (var c in p.components.reversed) {
              final rect = Rect.fromLTWH(
                c.position.dx,
                c.position.dy,
                c.width * p.scale * p.zoomLevel,
                c.height * p.scale * p.zoomLevel,
              );
              if (rect.contains(adjustedLocal)) {
                p.selectComponent(c);
                break;
              }
            }
          },
          onPanStart: (_) {},
          onPanUpdate: (_) {},
          child: DragTarget<String>(
            builder:
                (_, candidateData, rejectedData) => Screenshot(
                  controller: screenshotController,
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: const Color(0xFFFAFAFA),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Center(
                          child: SizedBox(
                            width: w,
                            height: h,
                            child: CustomPaint(
                              size: Size(w, h),
                              painter: FloorPlanPainter(
                                roomWidth: p.roomWidth,
                                roomHeight: p.roomHeight,
                                scale: p.scale * p.zoomLevel,
                                showGrid: p.showGrid,
                                showDimensions: p.showDimensions,
                              ),
                            ),
                          ),
                        ),
                        ...p.components.map(
                          (c) => Positioned(
                            left: c.position.dx,
                            top: c.position.dy,
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () => p.selectComponent(c),
                              onPanStart: (_) => p.selectComponent(c),
                              onPanUpdate:
                                  (d) => p.updateComponentPosition(
                                    c.id,
                                    c.position + d.delta,
                                  ),
                              child: Transform.rotate(
                                angle: c.rotation * math.pi / 180,
                                child: Container(
                                  width: c.width * p.scale * p.zoomLevel,
                                  height: c.height * p.scale * p.zoomLevel,
                                  decoration: BoxDecoration(
                                    border:
                                        p.selectedComponent?.id == c.id
                                            ? Border.all(
                                              color: const Color(0xFFD3D3D3),
                                              width: 1,
                                            )
                                            : null,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                  child: CustomPaint(
                                    painter: ComponentPainter(
                                      imageName: c.imageName,
                                      isSelected:
                                          p.selectedComponent?.id == c.id,
                                      text: c.text,
                                      fontSize: c.fontSize,
                                      color: c.color,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            onWillAccept: (data) => true,
            onAcceptWithDetails: (details) {
              final box = context.findRenderObject() as RenderBox?;
              if (box == null) return;
              final local = box.globalToLocal(details.offset);
              final adjustedLocal =
                  local - const Offset(16, 16); // Account for margin
              p.addComponent(details.data, adjustedLocal);
            },
          ),
        );
      },
    );
  }
}
