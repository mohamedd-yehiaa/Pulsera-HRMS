import 'package:flutter/material.dart';
import 'package:pulsera/l10n/app_localizations.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:pulsera/shared/styles/colors.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );

  /// Prevents multiple scans from triggering multiple results.
  bool _isProcessing = false;

  /// Overlay result state: null = scanning, true = success, false = failure.
  /// (Used for brief visual feedback before closing.)
  bool? _scanResult;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    // Guard: only process the first scan
    if (_isProcessing) return;

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final scannedValue = barcodes.first.rawValue;
    if (scannedValue == null || scannedValue.isEmpty) return;

    _isProcessing = true;

    // Stop the camera immediately
    _controller.stop();

    // Return the raw scanned hash to the caller (Cubit validates)
    // Show brief feedback overlay, then pop
    setState(() {
      _scanResult =
          true; // We show a "Scanned" indicator; cubit decides validity
    });

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        Navigator.pop(context, scannedValue);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera feed
          MobileScanner(controller: _controller, onDetect: _onDetect),

          // Dark overlay with cutout window
          _buildOverlay(),

          // Top bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Close button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context, null),
                    ),
                  ),
                  const Spacer(),
                  // Flash toggle
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.flash_on, color: Colors.white),
                      onPressed: () => _controller.toggleTorch(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Instruction text
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.2,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(150),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                _scanResult != null
                    ? S.of(context).qrScannedExclamation
                    : S.of(context).pointCameraAtQr,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  shadows: [Shadow(blurRadius: 8, color: Colors.black54)],
                ),
              ),
            ),
          ),

          // Result overlay (brief feedback)
          if (_scanResult != null) _buildResultOverlay(),
        ],
      ),
    );
  }

  Widget _buildOverlay() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scanAreaSize = constraints.maxWidth * 0.7;
        final top = (constraints.maxHeight - scanAreaSize) / 2;
        final left = (constraints.maxWidth - scanAreaSize) / 2;

        return Stack(
          children: [
            // Semi-transparent overlay
            ColorFiltered(
              colorFilter: const ColorFilter.mode(
                Colors.black54,
                BlendMode.srcOut,
              ),
              child: Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      backgroundBlendMode: BlendMode.dstOut,
                    ),
                  ),
                  Positioned(
                    top: top,
                    left: left,
                    child: Container(
                      width: scanAreaSize,
                      height: scanAreaSize,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Corner brackets
            Positioned(
              top: top,
              left: left,
              child: _buildCornerBrackets(scanAreaSize),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCornerBrackets(double size) {
    const bracketLength = 30.0;
    const bracketWidth = 4.0;
    final color = _scanResult != null ? AppColors.green400 : AppColors.primary;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // Top-left
          Positioned(
            top: 0,
            left: 0,
            child: _bracket(color, bracketLength, bracketWidth, topLeft: true),
          ),
          // Top-right
          Positioned(
            top: 0,
            right: 0,
            child: _bracket(color, bracketLength, bracketWidth, topRight: true),
          ),
          // Bottom-left
          Positioned(
            bottom: 0,
            left: 0,
            child: _bracket(
              color,
              bracketLength,
              bracketWidth,
              bottomLeft: true,
            ),
          ),
          // Bottom-right
          Positioned(
            bottom: 0,
            right: 0,
            child: _bracket(
              color,
              bracketLength,
              bracketWidth,
              bottomRight: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bracket(
    Color color,
    double length,
    double width, {
    bool topLeft = false,
    bool topRight = false,
    bool bottomLeft = false,
    bool bottomRight = false,
  }) {
    return Container(
      width: length,
      height: length,
      decoration: BoxDecoration(
        border: Border(
          top: (topLeft || topRight)
              ? BorderSide(color: color, width: width)
              : BorderSide.none,
          bottom: (bottomLeft || bottomRight)
              ? BorderSide(color: color, width: width)
              : BorderSide.none,
          left: (topLeft || bottomLeft)
              ? BorderSide(color: color, width: width)
              : BorderSide.none,
          right: (topRight || bottomRight)
              ? BorderSide(color: color, width: width)
              : BorderSide.none,
        ),
        borderRadius: BorderRadius.only(
          topLeft: topLeft ? const Radius.circular(12) : Radius.zero,
          topRight: topRight ? const Radius.circular(12) : Radius.zero,
          bottomLeft: bottomLeft ? const Radius.circular(12) : Radius.zero,
          bottomRight: bottomRight ? const Radius.circular(12) : Radius.zero,
        ),
      ),
    );
  }

  Widget _buildResultOverlay() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.qr_code_scanner,
              color: AppColors.green400,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              S.of(context).qrScanned,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
