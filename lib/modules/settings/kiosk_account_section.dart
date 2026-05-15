import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pulsera/shared/cubit/kiosk_cubit.dart';
import 'package:pulsera/shared/cubit/states.dart';
import 'package:pulsera/shared/styles/colors.dart';
import 'package:pulsera/shared/styles/icon_broken.dart';

/// Settings section for Company Owners to create and manage a kiosk account.
///
/// Shows either:
/// - A creation form (email + password) if no kiosk exists
/// - The existing kiosk email + change password option
class KioskAccountSection extends StatefulWidget {
  final String companyId;
  final String? companyName;

  const KioskAccountSection({
    super.key,
    required this.companyId,
    this.companyName,
  });

  @override
  State<KioskAccountSection> createState() => _KioskAccountSectionState();
}

class _KioskAccountSectionState extends State<KioskAccountSection> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    // Auto-generate email suggestion
    final sanitizedName = (widget.companyName ?? 'company')
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]'), '');
    _emailController.text = 'kiosk@$sanitizedName.com';

    // Check if kiosk already exists
    KioskCubit.get(context).checkKioskExists(widget.companyId);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<KioskCubit, KioskStates>(
      listener: (context, state) {
        if (state is KioskCreateSuccessState) {
          Fluttertoast.showToast(
            msg: 'Kiosk account created successfully!',
            backgroundColor: AppColors.green400,
            textColor: Colors.white,
          );
          _passwordController.clear();
        }
        if (state is KioskCreateErrorState) {
          Fluttertoast.showToast(
            msg: 'Error: ${state.error}',
            backgroundColor: AppColors.error,
            textColor: Colors.white,
          );
        }
        if (state is KioskChangePasswordSuccessState) {
          Fluttertoast.showToast(
            msg: 'Password updated successfully!',
            backgroundColor: AppColors.green400,
            textColor: Colors.white,
          );
        }
        if (state is KioskChangePasswordErrorState) {
          Fluttertoast.showToast(
            msg: state.error,
            backgroundColor: AppColors.error,
            textColor: Colors.white,
          );
        }
      },
      builder: (context, state) {
        final cubit = KioskCubit.get(context);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 8, bottom: 8),
              child: Text(
                'Kiosk Account',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderColor),
              ),
              child: state is KioskFetchLoadingState
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : cubit.kioskExists
                  ? _buildKioskExistsView(cubit, state)
                  : _buildCreateKioskView(cubit, state),
            ),
          ],
        );
      },
    );
  }

  /// View when a kiosk account already exists.
  Widget _buildKioskExistsView(KioskCubit cubit, KioskStates state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Kiosk info
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.green400.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.desktop_mac_outlined,
                color: AppColors.green400,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kiosk Account Active',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    cubit.kioskEmail ?? '',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Change password button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _showChangePasswordDialog(context, cubit),
            icon: const Icon(
              IconBroken.Lock,
              size: 18,
              color: AppColors.primary,
            ),
            label: const Text(
              'Change Password',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: const BorderSide(color: AppColors.borderColor),
            ),
          ),
        ),
      ],
    );
  }

  /// Shows a bottom-sheet dialog for changing the kiosk password.
  void _showChangePasswordDialog(BuildContext context, KioskCubit cubit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider<KioskCubit>.value(
        value: cubit,
        child: _ChangePasswordSheet(kioskEmail: cubit.kioskEmail ?? ''),
      ),
    );
  }

  /// View when no kiosk account exists — creation form.
  Widget _buildCreateKioskView(KioskCubit cubit, KioskStates state) {
    final isCreating = state is KioskLoadingState;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.desktop_mac_outlined,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Create a dedicated account for kiosk devices.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Email field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Kiosk Email',
              prefixIcon: const Icon(
                IconBroken.Message,
                color: AppColors.blue500,
              ),
              filled: true,
              fillColor: AppColors.grey100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an email';
              }
              if (!value.contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),

          const SizedBox(height: 14),

          // Password field
          TextFormField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(IconBroken.Lock, color: AppColors.blue500),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.blue500,
                ),
                onPressed: () {
                  setState(() => _isPasswordVisible = !_isPasswordVisible);
                },
              ),
              filled: true,
              fillColor: AppColors.grey100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),

          const SizedBox(height: 20),

          // Create button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: isCreating
                  ? null
                  : () {
                      if (_formKey.currentState!.validate()) {
                        cubit.createKioskAccount(
                          email: _emailController.text.trim(),
                          password: _passwordController.text,
                          companyId: widget.companyId,
                        );
                      }
                    },
              icon: isCreating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.desktop_mac_outlined, color: Colors.white),
              label: Text(
                isCreating ? 'Creating...' : 'Create Kiosk Account',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
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
}

// =============================================================================
// Change Password Bottom Sheet
// =============================================================================

class _ChangePasswordSheet extends StatefulWidget {
  final String kioskEmail;

  const _ChangePasswordSheet({required this.kioskEmail});

  @override
  State<_ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<_ChangePasswordSheet> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      KioskCubit.get(context).changeKioskPassword(
        email: widget.kioskEmail,
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<KioskCubit, KioskStates>(
      listener: (context, state) {
        if (state is KioskChangePasswordSuccessState) {
          Navigator.pop(context); // Close the sheet on success
        }
      },
      builder: (context, state) {
        final isLoading = state is KioskChangePasswordLoadingState;

        return Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              left: 24,
              right: 24,
              top: 16,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Drag handle ──
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: AppColors.grey300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // ── Header icon ──
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.blue500.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      IconBroken.Lock,
                      color: AppColors.blue500,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Title ──
                  Text(
                    'Change Kiosk Password',
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // ── Kiosk email (read-only info) ──
                  Row(
                    children: [
                      const Icon(
                        Icons.desktop_mac_outlined,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.kioskEmail,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── Current Password ──
                  _buildPasswordField(
                    controller: _currentPasswordController,
                    label: 'Current Password',
                    isVisible: _showCurrentPassword,
                    onToggle: () => setState(
                      () => _showCurrentPassword = !_showCurrentPassword,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the current password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // ── New Password ──
                  _buildPasswordField(
                    controller: _newPasswordController,
                    label: 'New Password',
                    isVisible: _showNewPassword,
                    onToggle: () =>
                        setState(() => _showNewPassword = !_showNewPassword),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a new password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // ── Confirm New Password ──
                  _buildPasswordField(
                    controller: _confirmPasswordController,
                    label: 'Confirm New Password',
                    isVisible: _showConfirmPassword,
                    onToggle: () => setState(
                      () => _showConfirmPassword = !_showConfirmPassword,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm the new password';
                      }
                      if (value != _newPasswordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // ── Submit button ──
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor: AppColors.primary.withValues(
                          alpha: 0.4,
                        ),
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: AppColors.white,
                              ),
                            )
                          : Text(
                              'Update Password',
                              style: Theme.of(context).textTheme.titleMedium!
                                  .copyWith(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Builds a styled password field with visibility toggle.
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool isVisible,
    required VoidCallback onToggle,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !isVisible,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(IconBroken.Lock, color: AppColors.blue500),
        suffixIcon: IconButton(
          icon: Icon(
            isVisible
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: AppColors.blue500,
          ),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: AppColors.grey100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
