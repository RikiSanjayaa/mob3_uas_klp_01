import 'package:flutter/material.dart';

class CustomElevatedBtn extends StatelessWidget {
  const CustomElevatedBtn(
      {super.key,
      required this.onPressed,
      required this.child,
      this.color = Colors.deepPurple});

  final Function() onPressed;
  final Widget child;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          backgroundColor: color,
        ),
        child: child,
      ),
    );
  }
}
