import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../identifying/identifying_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isReady = false;
  bool _isTakingPicture = false;
  FlashMode _flashMode = FlashMode.auto;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pulseCtrl.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) _controller?.dispose();
    if (state == AppLifecycleState.resumed) _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) return;

      _controller = CameraController(
        _cameras!.firstWhere((c) => c.lensDirection == CameraLensDirection.back,
            orElse: () => _cameras!.first),
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.unknown,
      );

      await _controller!.initialize();
      try {
        await _controller!.setFlashMode(_flashMode);
      } catch (_) {
        debugPrint('Flash not supported on this device');
      }

      if (mounted) setState(() => _isReady = true);
    } catch (e) {
      debugPrint('Camera init error: $e');
    }
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized || _isTakingPicture) return;

    setState(() => _isTakingPicture = true);

    try {
      final xFile = await _controller!.takePicture();
      final bytes = await xFile.readAsBytes();

      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => IdentifyingScreen(
              imageBytes: bytes,
              imagePath: xFile.path,
            ),
            transitionDuration: const Duration(milliseconds: 300),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }
    } catch (e) {
      debugPrint('Take picture error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to take picture')),
        );
      }
    }

    if (mounted) setState(() => _isTakingPicture = false);
  }

  void _cycleFlash() {
    setState(() {
      switch (_flashMode) {
        case FlashMode.auto:
          _flashMode = FlashMode.always;
          break;
        case FlashMode.always:
          _flashMode = FlashMode.off;
          break;
        case FlashMode.off:
          _flashMode = FlashMode.auto;
          break;
        default:
          _flashMode = FlashMode.auto;
      }
      _controller?.setFlashMode(_flashMode);
    });
  }

  String get _flashLabel {
    switch (_flashMode) {
      case FlashMode.always:
        return 'On';
      case FlashMode.off:
        return 'Off';
      default:
        return 'Auto';
    }
  }

  IconData get _flashIcon {
    switch (_flashMode) {
      case FlashMode.always:
        return Icons.flash_on;
      case FlashMode.off:
        return Icons.flash_off;
      default:
        return Icons.flash_auto;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady || _controller == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: UrPlantTheme.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.camera_alt, color: Colors.white, size: 28),
              ),
              const SizedBox(height: 16),
              const Text('Starting camera...',
                  style: TextStyle(color: Colors.white70, fontSize: 14)),
            ],
          ),
        ),
      );
    }

    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera preview
          CameraPreview(_controller!),

          // Scanning overlay
          Center(
            child: AnimatedBuilder(
              animation: _pulseAnim,
              builder: (context, child) {
                return Container(
                  width: size.width * 0.85 * _pulseAnim.value,
                  height: size.width * 0.85 * _pulseAnim.value,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: UrPlantTheme.primaryLight.withValues(alpha: 0.4 * _pulseAnim.value),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.eco,
                        size: 48,
                        color: UrPlantTheme.primaryLight.withValues(alpha: 0.25 * _pulseAnim.value),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Frame the plant',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5 * _pulseAnim.value),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Make sure there\'s good lighting',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.3 * _pulseAnim.value),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Top bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Close button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 24),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  // Flash button
                  GestureDetector(
                    onTap: _cycleFlash,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_flashIcon, color: Colors.white, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            _flashLabel,
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Capture button — gradient ring
          Positioned(
            bottom: 56,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _takePicture,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: UrPlantTheme.primaryGradient,
                    boxShadow: [
                      BoxShadow(
                        color: UrPlantTheme.primaryLight.withValues(alpha: 0.5),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                    child: _isTakingPicture
                        ? const Center(
                            child: SizedBox(
                              width: 28,
                              height: 28,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : null,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}