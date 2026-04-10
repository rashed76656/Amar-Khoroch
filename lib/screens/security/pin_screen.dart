import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amar_khoroch/core/theme/app_theme.dart';
import 'package:amar_khoroch/providers/security_provider.dart';

enum PinScreenMode { unlock, setup, remove }

class PinScreen extends ConsumerStatefulWidget {
  final PinScreenMode mode;
  final VoidCallback? onSuccess;

  const PinScreen({
    super.key,
    required this.mode,
    this.onSuccess,
  });

  @override
  ConsumerState<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends ConsumerState<PinScreen>
    with SingleTickerProviderStateMixin {
  String _pin = '';
  String _setupFirstPin = '';
  bool _isConfirming = false;
  String _errorMessage = '';

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _onKeypadTap(String value) {
    if (_pin.length < 4) {
      setState(() {
        _pin += value;
        _errorMessage = '';
      });

      if (_pin.length == 4) {
        _processPin();
      }
    }
  }

  void _onBackspace() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
        _errorMessage = '';
      });
    }
  }

  Future<void> _processPin() async {
    final notifier = ref.read(securityProvider.notifier);
    
    // Slight delay for UX
    await Future.delayed(const Duration(milliseconds: 200));

    if (!mounted) return;

    if (widget.mode == PinScreenMode.unlock) {
      final success = await notifier.verifyAndUnlock(_pin);
      if (success) {
        widget.onSuccess?.call();
      } else {
        _showError('Incorrect PIN');
      }
    } else if (widget.mode == PinScreenMode.setup) {
      if (!_isConfirming) {
        setState(() {
          _setupFirstPin = _pin;
          _pin = '';
          _isConfirming = true;
        });
      } else {
        if (_pin == _setupFirstPin) {
          await notifier.setupPin(_pin);
          widget.onSuccess?.call();
          if (mounted) Navigator.pop(context);
        } else {
          _showError('PINs do not match');
          setState(() {
            _setupFirstPin = '';
            _isConfirming = false;
          });
        }
      }
    } else if (widget.mode == PinScreenMode.remove) {
      final success = await notifier.removePin(_pin);
      if (success) {
        widget.onSuccess?.call();
        if (mounted) Navigator.pop(context);
      } else {
        _showError('Incorrect PIN');
      }
    }
  }

  void _showError(String message) {
    _shakeController.forward().then((_) => _shakeController.reverse());
    setState(() {
      _pin = '';
      _errorMessage = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    String title = 'Enter PIN';
    if (widget.mode == PinScreenMode.setup) {
      title = _isConfirming ? 'Confirm PIN' : 'Create PIN';
    } else if (widget.mode == PinScreenMode.remove) {
      title = 'Enter current PIN';
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: widget.mode != PinScreenMode.unlock
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(CupertinoIcons.back),
                onPressed: () => Navigator.pop(context),
              ),
            )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 1),
            Icon(
              widget.mode == PinScreenMode.unlock
                  ? CupertinoIcons.lock_fill
                  : CupertinoIcons.lock_shield_fill,
              size: 48,
              color: AppTheme.primaryAccent,
            ),
            const SizedBox(height: 24),
            Text(title, style: AppTheme.headlineMedium),
            const SizedBox(height: 12),
            SizedBox(
              height: 24,
              child: Text(
                _errorMessage,
                style: AppTheme.bodySmall
                    .copyWith(color: AppTheme.expenseColor),
              ),
            ),
            const SizedBox(height: 32),
            AnimatedBuilder(
              animation: _shakeAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(
                    _shakeAnimation.value * (_shakeController.status == AnimationStatus.forward ? 1 : -1),
                    0,
                  ),
                  child: child,
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  final isFilled = index < _pin.length;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: isFilled ? AppTheme.primaryAccent : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isFilled
                            ? AppTheme.primaryAccent
                            : AppTheme.textTertiary,
                        width: 1.5,
                      ),
                    ),
                  );
                }),
              ),
            ),
            const Spacer(flex: 2),
            _buildKeypad(),
            const Spacer(flex: 1),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          _buildKeypadRow(['1', '2', '3']),
          const SizedBox(height: 24),
          _buildKeypadRow(['4', '5', '6']),
          const SizedBox(height: 24),
          _buildKeypadRow(['7', '8', '9']),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 72), // Empty space
              _buildKeypadButton('0'),
              _buildBackspaceButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKeypadRow(List<String> numbers) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: numbers.map((n) => _buildKeypadButton(n)).toList(),
    );
  }

  Widget _buildKeypadButton(String number) {
    return GestureDetector(
      onTap: () => _onKeypadTap(number),
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          shape: BoxShape.circle,
          boxShadow: AppTheme.cardShadow,
        ),
        child: Center(
          child: Text(
            number,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w400,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceButton() {
    return GestureDetector(
      onTap: _onBackspace,
      child: Container(
        width: 72,
        height: 72,
        color: Colors.transparent,
        child: Center(
          child: Icon(
            CupertinoIcons.delete_left,
            size: 28,
            color: AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}
