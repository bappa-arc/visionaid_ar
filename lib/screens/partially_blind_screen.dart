import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:visionaid_ar/features/fully_blind/tts_helper.dart';

class PartiallyBlindScreen extends StatefulWidget {
  @override
  _PartiallyBlindScreenState createState() => _PartiallyBlindScreenState();
}

class _PartiallyBlindScreenState extends State<PartiallyBlindScreen>
    with SingleTickerProviderStateMixin {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  String _currentFilter = 'Normal';
  final TTSHelper _ttsHelper = TTSHelper();
  late AnimationController _animationController;
  late Animation<Color?> _colorAnimation;

  double _zoomLevel = 1.0; // Current zoom
  double _minZoom = 1.0; // Minimum supported by camera
  double _maxZoom = 1.0; // Maximum supported by camera

  @override
  void initState() {
    super.initState();
    _initializeCamera();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    _colorAnimation = ColorTween(
      begin: Colors.white,
      end: Colors.blue.shade100,
    ).animate(_animationController);
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      _controller = CameraController(cameras[0], ResolutionPreset.medium);
      _initializeControllerFuture = _controller!.initialize();
      await _initializeControllerFuture;

      // Get zoom range from camera
      _minZoom = await _controller!.getMinZoomLevel();
      _maxZoom = await _controller!.getMaxZoomLevel();

      print('Min Zoom: $_minZoom, Max Zoom: $_maxZoom');

      setState(() {
        _zoomLevel = _minZoom;
      });
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  void _changeFilter(String filterName) async {
    setState(() {
      _currentFilter = filterName;
      _animationController.forward(from: 0);
    });

    // Correct Haptic Feedback (using Vibrate)
    if (await Vibrate.canVibrate) {
      Vibrate.feedback(FeedbackType.success);
    }

    // Show small feedback message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Filter changed to $_currentFilter'),
        duration: Duration(milliseconds: 800),
      ),
    );

    await _ttsHelper.speak('Filter changed to $filterName mode');
  }

  @override
  void dispose() {
    _controller?.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildFilterButton(String name, IconData icon) {
    bool isSelected = _currentFilter == name;

    return Semantics(
      label: '$name filter button',
      child: AnimatedBuilder(
        animation: _colorAnimation,
        builder:
            (context, child) => ElevatedButton.icon(
              onPressed: () => _changeFilter(name),
              icon: Icon(
                icon,
                color: isSelected ? Colors.black : Colors.white,
                size: 32,
              ),
              label: Text(
                name,
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isSelected ? _colorAnimation.value : Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 18),
                elevation: isSelected ? 8 : 2,
              ),
            ),
      ),
    );
  }

  Widget _buildFilterButtons() {
    final filters = [
      {'name': 'Normal', 'icon': Icons.remove_red_eye},
      {'name': 'High Contrast', 'icon': Icons.tonality},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children:
            filters.map((filter) {
              final String name = filter['name'] as String;
              final IconData icon = filter['icon'] as IconData;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: _buildFilterButton(name, icon),
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
                        Positioned.fill(child: _buildFilteredPreview()),

                        SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                Text(
                                  "Partially Blind Mode",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      Shadow(
                                        blurRadius: 10,
                                        color: Colors.black,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 48), // Spacer
                              ],
                            ),
                          ),
                        ),

                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Filter buttons container
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
                                  child: _buildFilterButtons(),
                                ),
                              ),

                              // Zoom Slider
                              Padding(
                                padding: const EdgeInsets.only(
                                  bottom: 16.0,
                                  left: 16,
                                  right: 16,
                                  top: 8,
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      "Zoom: ${_zoomLevel.toStringAsFixed(1)}x",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Slider(
                                      value: _zoomLevel,
                                      min: _minZoom,
                                      max: _maxZoom,
                                      divisions: 10,
                                      onChanged: (value) async {
                                        setState(() {
                                          _zoomLevel = value;
                                        });
                                        await _controller?.setZoomLevel(value);
                                      },
                                      activeColor: Colors.white,
                                      inactiveColor: Colors.white24,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            Icons.remove,
                                            color: Colors.white,
                                          ),
                                          onPressed: () async {
                                            double newZoom = (_zoomLevel - 0.1)
                                                .clamp(_minZoom, _maxZoom);
                                            setState(
                                              () => _zoomLevel = newZoom,
                                            );
                                            await _controller?.setZoomLevel(
                                              _zoomLevel,
                                            );
                                          },
                                        ),
                                        SizedBox(width: 10),
                                        IconButton(
                                          icon: Icon(
                                            Icons.add,
                                            color: Colors.white,
                                          ),
                                          onPressed: () async {
                                            double newZoom = (_zoomLevel + 0.1)
                                                .clamp(_minZoom, _maxZoom);
                                            setState(
                                              () => _zoomLevel = newZoom,
                                            );
                                            await _controller?.setZoomLevel(
                                              _zoomLevel,
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
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

  Widget _buildFilteredPreview() {
    switch (_currentFilter) {
      case 'High Contrast':
        return ColorFiltered(
          colorFilter: ColorFilter.matrix([
            2,
            0,
            0,
            0,
            -255,
            0,
            2,
            0,
            0,
            -255,
            0,
            0,
            2,
            0,
            -255,
            0,
            0,
            0,
            1,
            0,
          ]),
          child: CameraPreview(_controller!),
        );
      default:
        return CameraPreview(_controller!);
    }
  }
}
