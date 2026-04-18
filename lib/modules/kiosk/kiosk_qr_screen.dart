import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pulsera/modules/login/login_screen.dart';
import 'package:pulsera/shared/components/components.dart';
import 'package:pulsera/shared/network/local/cache_helper.dart';
import 'package:pulsera/shared/services/totp_service.dart';
import 'package:pulsera/shared/styles/colors.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// Full-screen kiosk mode QR display.
///
/// - No AppBar, no back button
/// - PopScope blocks system back
/// - WakelockPlus keeps screen on
/// - Secure logout requires password re-authentication
class KioskQrScreen extends StatefulWidget {
  final String companyId;

  const KioskQrScreen({super.key, required this.companyId});

  @override
  State<KioskQrScreen> createState() => _KioskQrScreenState();
}

class _KioskQrScreenState extends State<KioskQrScreen> {
  Timer? _timer;
  String _currentHash = '';
  String? _sharedSecret;
  int _secondsUntilRefresh = 5;
  bool _isLoading = true;
  String? _companyName;
  String _currentTime = '';

  @override
  void initState() {
    super.initState();
    // Keep screen awake
    WakelockPlus.enable();
    // Hide system UI for full kiosk experience
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _fetchCompanyData();
    _updateClock();
  }

  @override
  void dispose() {
    _timer?.cancel();
    WakelockPlus.disable();
    // Restore system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  /// Fetches the company's shared secret and name from Firestore.
  Future<void> _fetchCompanyData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('companies')
          .doc(widget.companyId)
          .get();

      if (doc.exists && doc.data() != null) {
        setState(() {
          _sharedSecret = doc.data()!['sharedSecret'];
          _companyName = doc.data()!['organizationName'];
          _isLoading = false;
        });

        if (_sharedSecret != null && _sharedSecret!.isNotEmpty) {
          _generateCurrentHash();
          _startTimer();
        }
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _generateCurrentHash() {
    if (_sharedSecret == null) return;
    final nowSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    setState(() {
      _currentHash = TotpService.generateHash(_sharedSecret!, nowSeconds);
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
        _updateClock();
      });
    });
  }

  void _updateClock() {
    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';
    setState(() {
      _currentTime = '$hour:$minute $period';
    });
  }

  /// Shows the secure logout dialog requiring password re-authentication.
  void _showSecureLogoutDialog() {
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.orange500.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_outline,
                  color: AppColors.orange500,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Exit Kiosk Mode',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Enter your password to exit kiosk mode.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock, color: AppColors.blue500),
                    filled: true,
                    fillColor: AppColors.grey100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(dialogContext),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;

                      setDialogState(() => isLoading = true);

                      try {
                        final user = FirebaseAuth.instance.currentUser!;
                        final credential = EmailAuthProvider.credential(
                          email: user.email!,
                          password: passwordController.text,
                        );
                        await user.reauthenticateWithCredential(credential);

                        // Re-auth success → perform logout
                        await FirebaseAuth.instance.signOut();
                        await Future.wait([
                          CacheHelper.removeData(key: 'uId'),
                          CacheHelper.removeData(key: 'isKiosk'),
                          CacheHelper.removeData(key: 'companyId'),
                        ]);

                        // Disable wakelock before leaving
                        WakelockPlus.disable();
                        SystemChrome.setEnabledSystemUIMode(
                            SystemUiMode.edgeToEdge);

                        if (dialogContext.mounted) {
                          Navigator.pop(dialogContext); // Close dialog
                        }
                        if (mounted) {
                          navigateAndFinish(context, LoginScreen());
                        }
                      } catch (e) {
                        setDialogState(() => isLoading = false);

                        Fluttertoast.showToast(
                          msg: 'Incorrect password. Please try again.',
                          backgroundColor: AppColors.error,
                          textColor: Colors.white,
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Exit',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                  children: [
                    // Main QR content
                    Center(
                      child: _sharedSecret == null || _sharedSecret!.isEmpty
                          ? _buildNoSecretView()
                          : _buildQrView(),
                    ),

                    // Exit button (top-right)
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: _showSecureLogoutDialog,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.grey100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.borderColor,
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.lock_outline,
                                  size: 18,
                                  color: AppColors.textSecondary,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Exit',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildNoSecretView() {
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
          const Text(
            'QR Verification Not Configured',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            'Please ask an admin to generate a shared secret '
            'from the QR Code Generator in Settings.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQrView() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Company name
            if (_companyName != null) ...[
              Text(
                _companyName!,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
            ],

            // Current time
            Text(
              _currentTime,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 32),

            // QR Code card
            Container(
              padding: const EdgeInsets.all(28),
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
                  // Active status
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.green400.withAlpha(25),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.green400.withAlpha(80),
                      ),
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
                        const Text(
                          'Active',
                          style: TextStyle(
                            color: AppColors.green400,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // QR Code
                  QrImageView(
                    data: _currentHash,
                    version: QrVersions.auto,
                    size: 250,
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
                  const SizedBox(height: 24),

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
              child: const Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: AppColors.primary, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Kiosk Mode Active',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Display this screen at your office entrance. '
                    'Employees must scan this QR code before checking in, '
                    'taking breaks, or checking out. The code refreshes '
                    'every 5 seconds for security.',
                    style: TextStyle(
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
              'Refreshes in ${_secondsUntilRefresh}s',
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
