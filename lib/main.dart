import 'package:draw/floor_plan_designer/providers/floor_plan_provider.dart';
import 'package:draw/floor_plan_designer/screens/floor_plan_designer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() => runApp(
  ChangeNotifierProvider(
    create: (_) => FloorPlanProvider(),
    child: MaterialApp(
      title: 'Floor Plan Designer',
      theme: ThemeData(
        primarySwatch: Colors.grey,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        fontFamily: 'Inter',
      ),
      debugShowCheckedModeBanner: false,
      home: const FloorPlanDesigner(),
    ),
  ),
);

const List<String> imageNames = [
  "breaker_box.png",
  "dd_9lite.png",
  "door_lh.png",
  "door_rh.png",
  "flower_box.png",
  "lh_9lite.png",
  "light.png",
  "loft.png",
  "receptacle.png",
  "rh_9lite.png",
  "rud.png",
  "switch.png",
  "w_shutters.png",
  "window_with_shutter.png",
  "window.png",
  "work_bench.png",
];
