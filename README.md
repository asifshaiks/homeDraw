# Floor Plan Designer

A Flutter-based interactive application for creating and editing 2D floor plans. Design professional floor plans with drag-and-drop components, customizable dimensions, and export capabilities.

## 🎯 Features

- **Interactive Design**: Drag and drop components like doors, windows, and electrical fixtures onto a scalable canvas
- **Room Customization**: Adjust room dimensions with real-time updates
- **Component Management**: Resize, rotate, duplicate, or delete components with ease
- **Text Annotations**: Add customizable text labels with adjustable font size and color
- **Precision Tools**: Toggle grid visibility and dimension labels for accurate measurements
- **Export Options**: Save designs as JSON files or export as high-quality PNG images
- **Modern UI**: Clean, responsive interface with organized toolbar and properties panel
- **State Management**: Efficient state handling using the Provider package

## 📋 Prerequisites

Before setting up the Floor Plan Designer, ensure you have:

- **Flutter SDK**: Version 3.0.0 or higher
- **Dart**: Latest stable version (included with Flutter)
- **Development Environment**: 
  - IDE with Flutter/Dart plugins (VS Code, Android Studio, or IntelliJ)
  - Command-line tools for Flutter development
- **Git**: For repository management (optional)
- **Web Browser**: Chrome, Firefox, or Edge for web deployment
- **Required Assets**: Component images and Inter font (see Assets section)

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/asifshaiks/homeDraw.git
cd floor_plan_designer
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Verify Setup

```bash
flutter doctor
```

Resolve any issues reported before proceeding.

### 4. Run the Application

**For Web (Recommended):**
```bash
flutter run -d chrome
```

**For Mobile/Desktop:**
```bash
flutter run
```

## 📁 Project Structure

```
floor_plan_designer/
├── lib/
│   ├── main.dart                           # Application entry point
│   ├── models/
│   │   └── placed_component.dart           # Component data models
│   ├── providers/
│   │   └── floor_plan_provider.dart        # State management
│   ├── screens/
│   │   └── floor_plan_designer.dart        # Main application screen
│   └── widgets/
│       ├── canvas_area.dart                # Interactive drawing canvas
│       ├── component_properties_panel.dart # Component editing panel
│       ├── component_toolbar.dart          # Component selection toolbar
│       └── floor_plan_painter.dart         # Custom canvas painters
├── assets/
│   ├── images/                            # Component image assets
│   └── fonts/                             # Typography assets
└── pubspec.yaml                           # Project configuration
```

## 🎨 Required Assets

### Component Images
Place the following PNG files in `assets/images/`:

- `breaker_box.png` - Electrical breaker box
- `dd_9lite.png` - Double door with 9 lite glass
- `door_lh.png` / `door_rh.png` - Left/right hinged doors
- `flower_box.png` - Decorative flower box
- `lh_9lite.png` / `rh_9lite.png` - Left/right 9 lite windows
- `light.png` - Light fixture
- `loft.png` - Loft access
- `receptacle.png` - Electrical outlet
- `rud.png` - Rough utility door
- `switch.png` - Light switch
- `w_shutters.png` - Window with shutters
- `window_with_shutter.png` - Alternative shutter window
- `window.png` - Standard window
- `work_bench.png` - Work bench

### Typography
- `Inter-Regular.ttf` - Place in `assets/fonts/`

Ensure all assets are declared in `pubspec.yaml` under the appropriate sections.

## 🖥️ Usage Guide

### Getting Started
1. **Launch the Application**: Open in your preferred environment
2. **Interface Overview**:
   - **Left Panel**: Component properties and editing controls
   - **Main Canvas**: Interactive design area
   - **Top Toolbar**: Room dimensions, zoom, and text tools
   - **Bottom Toolbar**: Draggable component library

### Creating Your Floor Plan

#### Basic Setup
- Set room dimensions using the Width/Length inputs in the top toolbar
- Use zoom controls (+/-) to adjust your view or reset to 100%

#### Adding Components
- Drag any component from the bottom toolbar onto the canvas
- Components automatically snap to grid points for precision
- Select components to access editing options in the left panel

#### Text Annotations
- Enter text in the top toolbar input field
- Click "Add Text" to place labels on your floor plan
- Customize text properties through the properties panel

#### Component Editing
- **Position**: Drag components to move them
- **Resize**: Use handles or input precise dimensions
- **Rotate**: Adjust orientation in 90-degree increments
- **Duplicate**: Create copies of existing components
- **Delete**: Remove unwanted elements

#### Precision Tools
- Toggle grid visibility for alignment assistance
- Enable dimension labels for measurement display
- Use snap-to-grid for precise component placement

### Saving and Sharing

#### Save Project
- Click "Save as JSON" to export your floor plan
- JSON files preserve all component data and can be reloaded

#### Load Project
- Use "Load JSON" to import previously saved designs
- Supports full restoration of component positions and properties

#### Export Image
- Click "Export as PNG" to generate high-quality images
- Perfect for presentations, documentation, or printing

## 📦 Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| flutter | SDK | Core Flutter framework |
| provider | ^6.0.0 | State management |
| uuid | ^3.0.0 | Unique component identification |
| screenshot | ^1.2.0 | PNG export functionality |

Update dependencies with:
```bash
flutter pub upgrade
```

## 🔧 Build and Deployment

### Development Build
```bash
flutter run
```

### Production Web Build
```bash
flutter build web
```
Output: `build/web/` directory

### Mobile/Desktop Builds
Refer to [Flutter's deployment documentation](https://docs.flutter.dev/deployment) for platform-specific instructions.

## 🐛 Troubleshooting

### Common Issues

**Missing Component Images**
- Verify all PNG files are in `assets/images/`
- Check `pubspec.yaml` asset declarations
- Run `flutter pub get` after adding assets

**Font Display Issues**
- Ensure `Inter-Regular.ttf` is in `assets/fonts/`
- Verify font declaration in `pubspec.yaml`
- Clear cache with `flutter clean`

**File Operations Not Working**
- File save/load features require web environment
- Use `dart:html` compatible browsers
- For mobile deployment, consider alternative file handling

**Performance Issues**
- Reduce component count for complex designs
- Optimize image asset sizes
- Consider implementing component virtualization

**Build Errors**
```bash
flutter clean
flutter pub get
flutter run
```

**JSON Import Errors**
- Verify JSON format matches expected schema
- Check for corrupted or incomplete files
- Ensure proper component ID formatting

## 🤝 Contributing

We welcome contributions! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

For questions or support, reach out via Slack chat.

## 📄 License

This project is licensed under the MIT License. See the LICENSE file for details.

## 🔗 Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Provider Package](https://pub.dev/packages/provider)
- [Flutter Web Deployment](https://docs.flutter.dev/deployment/web)

---

**Made with ❤️ using Flutter**