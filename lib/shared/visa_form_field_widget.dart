import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:huungry/core/constants/app_colors.dart';
import 'package:huungry/shared/custom_text.dart';

class VisaFormFieldWidget extends StatefulWidget {
  const VisaFormFieldWidget({
    super.key,
    required this.cardNumberController,
    required this.cardHolderController,
    required this.expiryController,
    required this.cvvController,
    this.onCardAdded,
  });

  final TextEditingController cardNumberController;
  final TextEditingController cardHolderController;
  final TextEditingController expiryController;
  final TextEditingController cvvController;
  final VoidCallback? onCardAdded;

  @override
  State<VisaFormFieldWidget> createState() => _VisaFormFieldWidgetState();
}

class _VisaFormFieldWidgetState extends State<VisaFormFieldWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _flipAnimation;
  bool _showBack = false;
  bool _cardAdded = false;
  final FocusNode _cvvFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _flipAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _cvvFocus.addListener(() {
      if (_cvvFocus.hasFocus && !_showBack) {
        _controller.forward();
        setState(() => _showBack = true);
      } else if (!_cvvFocus.hasFocus && _showBack) {
        _controller.reverse();
        setState(() => _showBack = false);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _cvvFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder:
          (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.1),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
      child: _cardAdded ? _buildCardAddedView() : _buildFormView(),
    );
  }

  Widget _buildCardAddedView() {
    return Column(
      key: const ValueKey('card'),
      children: [
        AnimatedBuilder(
          animation: _flipAnimation,
          builder: (context, child) {
            final angle = _flipAnimation.value * 3.14159;
            final isFront = angle < 1.5708;
            return Transform(
              alignment: Alignment.center,
              transform:
                  Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(angle),
              child: isFront ? _buildCardFront() : _buildCardBack(),
            );
          },
        ),
        const Gap(12),
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () => setState(() => _cardAdded = false),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.edit, size: 16, color: Colors.grey.shade600),
                  const Gap(6),
                  Text(
                    'Edit Card',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormView() {
    return Column(
      key: const ValueKey('form'),
      children: [
        _buildFormFields(),
        const Gap(16),
        GestureDetector(
          onTap: _onAddCard,
          child: Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xff1a1a2e), Color(0xff0f3460)],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xff0f3460).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_card_rounded, color: Colors.white, size: 20),
                  Gap(8),
                  Text(
                    'Add Card',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _onAddCard() {
    final number = widget.cardNumberController.text.replaceAll(' ', '');
    final holder = widget.cardHolderController.text.trim();
    final expiry = widget.expiryController.text.trim();
    final cvv = widget.cvvController.text.trim();

    if (number.length < 16 ||
        holder.isEmpty ||
        expiry.length < 5 ||
        cvv.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill all card details'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _cardAdded = true);
    widget.onCardAdded?.call();
  }

  Widget _buildCardFront() {
    return Container(
      width: double.infinity,
      height: 200,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xff1a1a2e), Color(0xff16213e), Color(0xff0f3460)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff0f3460).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              /// Chip icon
              Container(
                width: 45,
                height: 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  gradient: const LinearGradient(
                    colors: [Color(0xffF7D96C), Color(0xffD4A843)],
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.memory, size: 20, color: Color(0xff8B7330)),
                ),
              ),
              const Icon(Icons.wifi, color: Colors.white54, size: 28),
            ],
          ),
          const Spacer(),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: widget.cardNumberController,
            builder: (_, value, __) {
              String display =
                  value.text.isEmpty
                      ? '**** **** **** ****'
                      : _formatDisplayNumber(value.text);
              return Text(
                display,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  letterSpacing: 3,
                  fontWeight: FontWeight.w500,
                ),
              );
            },
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CARD HOLDER',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 10,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const Gap(4),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: widget.cardHolderController,
                    builder:
                        (_, value, __) => SizedBox(
                          width: 180,
                          child: Text(
                            value.text.isEmpty
                                ? 'YOUR NAME'
                                : value.text.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'EXPIRES',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 10,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const Gap(4),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: widget.expiryController,
                    builder:
                        (_, value, __) => Text(
                          value.text.isEmpty ? 'MM/YY' : value.text,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardBack() {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..rotateY(3.14159),
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xff0f3460), Color(0xff16213e), Color(0xff1a1a2e)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xff0f3460).withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            const Gap(30),
            Container(
              width: double.infinity,
              height: 45,
              color: Colors.black87,
            ),
            const Gap(20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const Gap(12),
                  Container(
                    width: 60,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: ValueListenableBuilder<TextEditingValue>(
                        valueListenable: widget.cvvController,
                        builder:
                            (_, value, __) => Text(
                              value.text.isEmpty ? '***' : value.text,
                              style: const TextStyle(
                                color: Color(0xff1a1a2e),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                      ),
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

  Widget _buildFormFields() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: 'Card Details',
            size: 16,
            weight: FontWeight.w700,
            color: AppColors.primary,
          ),
          const Gap(16),

          /// Card Number
          _buildField(
            controller: widget.cardNumberController,
            label: 'Card Number',
            hint: '0000 0000 0000 0000',
            icon: Icons.credit_card_rounded,
            keyboardType: TextInputType.number,
            formatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(16),
              _CardNumberFormatter(),
            ],
          ),
          const Gap(14),

          /// Card Holder
          _buildField(
            controller: widget.cardHolderController,
            label: 'Card Holder Name',
            hint: 'John Doe',
            icon: Icons.person_outline_rounded,
            keyboardType: TextInputType.name,
            formatters: [LengthLimitingTextInputFormatter(30)],
          ),
          const Gap(14),

          /// Expiry + CVV
          Row(
            children: [
              Expanded(
                child: _buildField(
                  controller: widget.expiryController,
                  label: 'Expiry Date',
                  hint: 'MM/YY',
                  icon: Icons.calendar_month_rounded,
                  keyboardType: TextInputType.number,
                  formatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                    _ExpiryDateFormatter(),
                  ],
                ),
              ),
              const Gap(12),
              Expanded(
                child: _buildField(
                  controller: widget.cvvController,
                  label: 'CVV',
                  hint: '***',
                  icon: Icons.lock_outline_rounded,
                  keyboardType: TextInputType.number,
                  obscure: true,
                  focusNode: _cvvFocus,
                  formatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required TextInputType keyboardType,
    List<TextInputFormatter>? formatters,
    bool obscure = false,
    FocusNode? focusNode,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Gap(6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscure,
          focusNode: focusNode,
          inputFormatters: formatters,
          cursorColor: AppColors.primary,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            letterSpacing: 1,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 14,
              letterSpacing: 1,
            ),
            prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDisplayNumber(String text) {
    String digits = text.replaceAll(' ', '');
    String padded = digits.padRight(16, '*');
    return '${padded.substring(0, 4)} ${padded.substring(4, 8)} ${padded.substring(8, 12)} ${padded.substring(12, 16)}';
  }
}

/// Formats card number with spaces every 4 digits
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String digits = newValue.text.replaceAll(' ', '');
    StringBuffer buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    String formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Formats expiry date as MM/YY
class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String digits = newValue.text.replaceAll('/', '');
    StringBuffer buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i == 2) buffer.write('/');
      buffer.write(digits[i]);
    }
    String formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
