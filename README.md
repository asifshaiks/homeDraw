Floor Plan Designer
Floor Plan Designer is a Flutter-based application that allows users to create and edit 2D floor plans interactively. Users can add components (e.g., doors, windows, electrical fixtures), text labels, and customize room dimensions, with features like drag-and-drop, zooming, rotation, and exporting designs as JSON or PNG files.
Table of Contents

Features
Prerequisites
Setup Instructions
Running the Application
Project Structure
Usage
Dependencies
Assets
Troubleshooting
License

Features

Interactive Floor Plan Creation: Drag and drop components like doors, windows, and fixtures onto a scalable canvas.
Room Customization: Adjust room dimensions and zoom levels.
Component Manipulation: Resize, rotate, duplicate, or delete components.
Text Labels: Add and customize text labels with adjustable font size and color.
Grid and Dimensions: Toggle grid visibility and dimension labels for precise design.
Export Options: Save floor plans as JSON files or export as PNG images.
State Management: Uses the Provider package for efficient state handling.
Responsive UI: Modern, clean interface with a properties panel and toolbar.

Prerequisites
To set up and run the Floor Plan Designer, ensure you have the following installed:

Flutter SDK: Version 2.18.0 or higher (tested with Flutter 3.x).
Dart: Included with Flutter (version compatible with SDK).
Development Environment: 
IDE (e.g., Visual Studio Code, Android Studio) with Flutter and Dart plugins.
Command-line interface for running Flutter commands.


Git: For cloning the repository (optional).
Web Browser: For running the web version (e.g., Chrome, Firefox).
Assets: Image files and font file (Inter) as specified in the project.

Setup Instructions

Clone or Download the Project

If using Git, clone the repository:git clone <https://github.com/asifshaiks/homeDraw.git>
cd floor_plan_designer


Alternatively, download and extract the project zip file provided.


Install Dependencies

Navigate to the project root (floor_plan_designer/) and run:flutter pub get


This installs all dependencies listed in pubspec.yaml.


Add Assets

Ensure the assets/images/ folder contains the following image files:
breaker_box.png
dd_9lite.png
door_lh.png
door_rh.png
flower_box.png
lh_9lite.png
light.png
loft.png
receptacle.png
rh_9lite.png
rud.png
switch.png
w_shutters.png
window_with_shutter.png
window.png
work_bench.png


Place the Inter-Regular.ttf font file in assets/fonts/.
Verify that pubspec.yaml includes these assets under the flutter.assets and flutter.fonts sections.


Verify Flutter Setup

Run the following to ensure Flutter is configured correctly:flutter doctor


Resolve any issues reported by flutter doctor (e.g., missing tools or SDKs).



Running the Application

Run on Web

To run the app in a web browser (recommended for this project due to dart:html usage):flutter run -d chrome


The app will open in Google Chrome (or another specified browser).


Run on Emulator/Simulator

For Android/iOS:
Ensure an emulator or physical device is connected.
Run:flutter run


Note: Some features (e.g., JSON file operations) rely on dart:html, which is web-specific. Test thoroughly on non-web platforms.




Build for Production

For a web build:flutter build web


The output is in the build/web/ directory, which can be hosted on a web server.


For Android/iOS builds, refer to Flutter's official documentation for platform-specific instructions.



Project Structure
The project follows a modular structure for maintainability:
floor_plan_designer/
├── lib/
│   ├── main.dart                   # App entry point and image names
│   ├── models/
│   │   └── placed_component.dart   # Data model for components
│   ├── providers/
│   │   └── floor_plan_provider.dart # State management
│   ├── screens/
│   │   └── floor_plan_designer.dart # Main screen
│   ├── widgets/
│   │   ├── canvas_area.dart         # Canvas for drawing floor plan
│   │   ├── component_properties_panel.dart # Properties editing panel
│   │   ├── component_toolbar.dart   # Toolbar for component selection
│   │   └── floor_plan_painter.dart  # Custom painters for canvas and components
├── assets/
│   ├── images/                     # Component image assets
│   ├── fonts/                      # Inter font file
├── pubspec.yaml                    # Dependencies and asset declarations

Usage

Launch the App

Open the app in a browser or emulator.
The interface consists of:
Left Panel: Component properties and actions.
Main Canvas: Interactive area for placing and editing components.
Top Toolbar: Room dimensions, zoom controls, and text input.
Bottom Toolbar: Draggable component icons.




Designing a Floor Plan

Set Room Dimensions: Use the "Width" and "Length" inputs in the top toolbar.
Add Components: Drag components from the bottom toolbar onto the canvas.
Add Text: Enter text in the top toolbar's text field and click "Add Text".
Edit Components: Select a component to modify its size, position, rotation, or text properties in the left panel.
Zoom and View Options: Adjust zoom with +/- buttons or reset to 100%. Toggle grid and dimensions in the left panel.
Save/Load: Use "Save as JSON" to export the floor plan or "Load JSON" to import a saved plan.
Export: Click "Export as PNG" to download the floor plan as an image.


Key Features

Drag components to position them freely.
Rotate or duplicate components via the properties panel.
Save designs as JSON for later editing.
Export high-quality PNG images for sharing or printing.



Dependencies
The project uses the following packages (defined in pubspec.yaml):

flutter: Core Flutter SDK.
provider: ^6.0.0 - For state management.
uuid: ^3.0.0 - For generating unique component IDs.
screenshot: ^1.2.0 - For capturing canvas as PNG.

To update dependencies, run:
flutter pub upgrade

Assets

Images: 16 PNG files in assets/images/ for components (e.g., breaker_box.png, door_lh.png).
Font: Inter-Regular.ttf in assets/fonts/ for consistent typography.
Ensure all assets are correctly placed and referenced in pubspec.yaml.

Troubleshooting

Missing Assets: If components fail to load, verify that all images are in assets/images/ and listed in pubspec.yaml.
Font Issues: Ensure Inter-Regular.ttf is in assets/fonts/ and declared in pubspec.yaml.
Web-Specific Features: File operations (save/load JSON, export PNG) use dart:html. For mobile/desktop, additional plugins may be needed.
Build Errors: Run flutter clean and flutter pub get to resolve dependency issues.
Performance: For large floor plans, reduce the number of components or optimize image sizes.
Errors Loading JSON: Ensure JSON files match the expected format (see FloorPlanProvider.toJson).

For further assistance, consult the Flutter documentation or contact the development team.
or message me in the chats in slack .
