import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:visionaid_ar/features/fully_blind/tts_helper.dart';

class ColorBlindScreen extends StatefulWidget {
  @override
  _ColorBlindScreenState createState() => _ColorBlindScreenState();
}

class _ColorBlindScreenState extends State<ColorBlindScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  String _currentFilter = "Normal";
  final TTSHelper _ttsHelper = TTSHelper();

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    _controller = CameraController(cameras[0], ResolutionPreset.medium);
    _initializeControllerFuture = _controller!.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  ColorFilter _getFilter(String type) {
    switch (type) {
      case "Protanopia":
        return ColorFilter.matrix([
          0.567,
          0.433,
          0.000,
          0,
          0,
          0.558,
          0.442,
          0.000,
          0,
          0,
          0.000,
          0.242,
          0.758,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
        ]);
      case "Deuteranopia":
        return ColorFilter.matrix([
          0.625,
          0.375,
          0.000,
          0,
          0,
          0.700,
          0.300,
          0.000,
          0,
          0,
          0.000,
          0.300,
          0.700,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
        ]);
      case "Tritanopia":
        return ColorFilter.matrix([
          0.950,
          0.050,
          0.000,
          0,
          0,
          0.000,
          0.433,
          0.567,
          0,
          0,
          0.000,
          0.475,
          0.525,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
        ]);
      case "Grayscale":
        return const ColorFilter.matrix([
          0.2126,
          0.7152,
          0.0722,
          0,
          0,
          0.2126,
          0.7152,
          0.0722,
          0,
          0,
          0.2126,
          0.7152,
          0.0722,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
        ]);
      default:
        return const ColorFilter.mode(Colors.transparent, BlendMode.multiply);
    }
  }

  Widget _buildFilterButton(String name, IconData icon) {
    bool isSelected = name == _currentFilter;
    return Semantics(
      label: '$name filter button',
      child: ElevatedButton.icon(
        /*style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.blue.shade100 : Colors.black,
          foregroundColor: isSelected ? Colors.black : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        ),*/
        onPressed: () async {
          setState(() => _currentFilter = name);
          await _ttsHelper.speak("$name mode activated");
        },
        icon: Icon(
          icon,
          color: isSelected ? Colors.black : Colors.white,
          size: 32, // Large icon
        ),
        label: Text(
          name,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20, // Large text
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.blue.shade100 : Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 30,
            vertical: 18,
          ), // Large padding
          elevation: isSelected ? 8 : 2,
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    final filters = [
      {'name': 'Normal', 'icon': Icons.visibility_outlined},
      {'name': 'Protanopia', 'icon': Icons.color_lens},
      {'name': 'Deuteranopia', 'icon': Icons.color_lens},
      {'name': 'Tritanopia', 'icon': Icons.color_lens},
      {'name': 'Grayscale', 'icon': Icons.color_lens},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center, // Center the buttons
        children:
            filters.map((f) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: _buildFilterButton(
                  f['name']! as String,
                  f['icon']! as IconData,
                ),
              );
            }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body:
          _controller == null
              ? Center(child: CircularProgressIndicator())
              : FutureBuilder(
                future: _initializeControllerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return Stack(
                      children: [
                        Positioned.fill(
                          child: ColorFiltered(
                            colorFilter: _getFilter(_currentFilter),
                            child: CameraPreview(_controller!),
                          ),
                        ),
                        SafeArea(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Colors.black54,
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.arrow_back,
                                          color: Colors.white,
                                        ),
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      "Color Blind Mode",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Spacer(),
                                    // ℹ️ Info Button with PopupMenu
                                    PopupMenuButton<String>(
                                      icon: Icon(
                                        Icons.info_outline,
                                        color: Colors.white,
                                      ),
                                      color: const Color.fromARGB(
                                        100,
                                        182,
                                        182,
                                        185,
                                      ),
                                      onSelected: (value) async {
                                        setState(() => _currentFilter = value);
                                        await _ttsHelper.speak(
                                          "$value mode activated",
                                        );
                                      },
                                      itemBuilder:
                                          (context) => [
                                            PopupMenuItem(
                                              value: "Protanopia",
                                              child: Text(
                                                "Protanopia: Red color blindness",
                                                style: TextStyle(
                                                  color: const Color.fromARGB(
                                                    255,
                                                    0,
                                                    0,
                                                    0,
                                                  ),
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            PopupMenuItem(
                                              value: "Deuteranopia",
                                              child: Text(
                                                "Deuteranopia: Green color blindness",
                                                style: TextStyle(
                                                  color: const Color.fromARGB(
                                                    255,
                                                    0,
                                                    0,
                                                    0,
                                                  ),
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            PopupMenuItem(
                                              value: "Tritanopia",
                                              child: Text(
                                                "Tritanopia: Blue color blindness",
                                                style: TextStyle(
                                                  color: const Color.fromARGB(
                                                    255,
                                                    0,
                                                    0,
                                                    0,
                                                  ),
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            PopupMenuItem(
                                              value: "Grayscale",
                                              child: Text(
                                                "Grayscale: No color distinction",
                                                style: TextStyle(
                                                  color: const Color.fromARGB(
                                                    255,
                                                    0,
                                                    0,
                                                    0,
                                                  ),
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            PopupMenuItem(
                                              value: "Normal",
                                              child: Text(
                                                "Normal: Original camera view",
                                                style: TextStyle(
                                                  color: const Color.fromARGB(
                                                    255,
                                                    0,
                                                    0,
                                                    0,
                                                  ),
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                      position: PopupMenuPosition.under,
                                    ),
                                  ],
                                ),
                              ),
                              Spacer(),
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(vertical: 20),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  child: _buildFilterBar(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                },
              ),
    );
  }
}
