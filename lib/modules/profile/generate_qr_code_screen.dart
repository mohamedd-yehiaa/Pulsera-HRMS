import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pulsera/l10n/app_localizations.dart';
import 'package:pulsera/shared/components/components.dart';
import 'package:pulsera/shared/cubit/app_cubit.dart';
import 'package:pulsera/shared/services/totp_service.dart';
import 'package:pulsera/shared/styles/colors.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Admin-only screen that generates and displays a rotating QR code
/// using the company's shared secret and TOTP algorithm.
///
/// The QR refreshes every 5 seconds (matching [TotpService.timeStepSeconds]).
/// If no shared_secret exists, the admin can generate one.
class GenerateQrCodeScreen extends StatefulWidget {
  final String companyId;
  final String? sharedSecret;

  const GenerateQrCodeScreen({
    super.key,
    required this.companyId,
    required this.sharedSecret,
  });

  @override
  State<GenerateQrCodeScreen> createState() => _GenerateQrCodeScreenState();
}

class _GenerateQrCodeScreenState extends State<GenerateQrCodeScreen> {
  Timer? _timer;
  String _currentHash = '';
  String? _activeSecret;
  int _secondsUntilRefresh = 5;
  bool _isGeneratingSecret = false;

  @override
  void initState() {
    super.initState();
    _activeSecret = widget.sharedSecret;
    if (_activeSecret != null && _activeSecret!.isNotEmpty) {
      _generateCurrentHash();
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _generateCurrentHash() {
    if (_activeSecret == null) return;
    final nowSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    setState(() {
      _currentHash = TotpService.generateHash(_activeSecret!, nowSeconds);
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _secondsUntilRefresh--;
        if (_secondsUntilRefresh <= 0) {
          _secondsUntilRefresh = TotpService.timeStepSeconds;
          _generateCurrentHash();
        }
      });
    });
  }

  /// Generates a new shared_secret and saves it to Firestore.
  Future<void> _generateAndSaveSecret() async {
    setState(() => _isGeneratingSecret = true);

    try {
      // Generate a cryptographically-informed random secret
      final random = Random.secure();
      final bytes = List<int>.generate(32, (_) => random.nextInt(256));
      final secret = bytes
          .map((b) => b.toRadixString(16).padLeft(2, '0'))
          .join();

      // Save to Firestore
      await FirebaseFirestore.instance
          .collection('companies')
          .doc(widget.companyId)
          .update({'sharedSecret': secret});

      setState(() {
        _activeSecret = secret;
        _isGeneratingSecret = false;
        _secondsUntilRefresh = TotpService.timeStepSeconds;
      });

      // Refresh global company cache so all screens see the new sharedSecret
      if (mounted) {
        AppCubit.get(context).getCompanyData();
      }

      _generateCurrentHash();
      _startTimer();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).qrConfiguredSuccess),
            backgroundColor: AppColors.green400,
          ),
        );
      }
    } catch (e) {
      setState(() => _isGeneratingSecret = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).failedToConfigure(e.toString())),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: backButton(context),
        title: Text(
          S.of(context).qrCodeGenerator,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Center(
          child: _activeSecret == null || _activeSecret!.isEmpty
              ? _buildSetupView()
              : _buildQrView(),
        ),
      ),
    );
  }

  /// View shown when shared_secret is NOT configured yet.
  Widget _buildSetupView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.orange500.withAlpha(25),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.orange500.withAlpha(60)),
            ),
            child: const Icon(
              Icons.qr_code_2,
              size: 80,
              color: AppColors.orange500,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            S.of(context).qrVerificationNotConfigured,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            S.of(context).qrVerificationDescription,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _isGeneratingSecret ? null : _generateAndSaveSecret,
              icon: _isGeneratingSecret
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.security, color: Colors.white),
              label: Text(
                _isGeneratingSecret
                    ? S.of(context).configuring
                    : S.of(context).enableQrVerification,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// View shown when QR is actively generating.
  Widget _buildQrView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // QR Code card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withAlpha(20),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
              border: Border.all(color: AppColors.borderColor),
            ),
            child: Column(
              children: [
                // Status indicator
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.green400.withAlpha(25),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.green400.withAlpha(80)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.green400,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        S.of(context).active,
                        style: const TextStyle(
                          color: AppColors.green400,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // QR Code
                QrImageView(
                  data: _currentHash,
                  version: QrVersions.auto,
                  size: 220,
                  backgroundColor: Colors.white,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: AppColors.primary,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 20),

                // Countdown timer
                _buildCountdownBar(),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Instructions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(10),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withAlpha(30)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      S.of(context).instructionsLabel,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  S.of(context).qrDisplayInstructions,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountdownBar() {
    final progress = _secondsUntilRefresh / TotpService.timeStepSeconds;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.timer_outlined,
              size: 16,
              color: progress < 0.4
                  ? AppColors.orange500
                  : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              S.of(context).refreshesInSeconds(_secondsUntilRefresh),
              style: TextStyle(
                fontSize: 13,
                color: progress < 0.4
                    ? AppColors.orange500
                    : AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 4,
            backgroundColor: AppColors.grey100,
            valueColor: AlwaysStoppedAnimation<Color>(
              progress < 0.4 ? AppColors.orange500 : AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}
