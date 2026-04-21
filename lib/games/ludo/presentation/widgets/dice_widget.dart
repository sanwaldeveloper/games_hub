import 'dart:math';
import 'package:flutter/material.dart';

class DiceWidget extends StatefulWidget {
  final int? value;
  final VoidCallback onRoll;
  final bool enabled;

  const DiceWidget({
    super.key,
    required this.value,
    required this.onRoll,
    required this.enabled,
  });

  @override
  State<DiceWidget> createState() => _DiceWidgetState();
}

class _DiceWidgetState extends State<DiceWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnim;
  late Animation<double> _scaleAnim;
  int _displayValue = 1;
  bool _isRolling = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _rotationAnim = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _scaleAnim = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 50),
    ]).animate(_controller);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isRolling = false;
          if (widget.value != null) _displayValue = widget.value!;
        });
      }
    });
  }

  @override
  void didUpdateWidget(DiceWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If value changed, it means a roll just happened — animate
    if (widget.value != null && widget.value != oldWidget.value) {
      _startRolling();
    }
  }

  void _startRolling() {
    if (_isRolling) return;
    setState(() => _isRolling = true);
    _controller.reset();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildDiceFace(int val, double size) {
    final dots = _dotsForValue(val);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: widget.enabled ? Colors.green : Colors.grey,
          width: widget.enabled ? 3 : 1.5,
        ),
        boxShadow: widget.enabled
            ? [
                BoxShadow(
                  color: Colors.green.withOpacity(0.4),
                  blurRadius: 8,
                  spreadRadius: 2,
                )
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                )
              ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: List.generate(9, (i) {
            return Center(
              child: dots.contains(i)
                  ? Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.black87,
                        shape: BoxShape.circle,
                      ),
                    )
                  : const SizedBox(),
            );
          }),
        ),
      ),
    );
  }

  /// Returns grid indices (0-8, row-major 3x3) for each dice value dot pattern
  List<int> _dotsForValue(int val) {
    switch (val) {
      case 1:
        return [4]; // center
      case 2:
        return [2, 6];
      case 3:
        return [2, 4, 6];
      case 4:
        return [0, 2, 6, 8];
      case 5:
        return [0, 2, 4, 6, 8];
      case 6:
        return [0, 2, 3, 5, 6, 8];
      default:
        return [4];
    }
  }

  @override
  Widget build(BuildContext context) {
    // If not enabled and no value, show empty placeholder
    if (!widget.enabled && widget.value == null) {
      return Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey[400]!, width: 1.5),
        ),
      );
    }

    return GestureDetector(
      onTap: (widget.enabled && !_isRolling) ? widget.onRoll : null,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _isRolling ? _scaleAnim.value : 1.0,
            child: Transform.rotate(
              angle: _isRolling ? _rotationAnim.value : 0,
              child: _buildDiceFace(
                _isRolling
                    ? (Random().nextInt(6) + 1)
                    : (_displayValue),
                60,
              ),
            ),
          );
        },
      ),
    );
  }
}