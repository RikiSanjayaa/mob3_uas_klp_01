import 'package:flutter/material.dart';

class CustomOutlineBtn extends StatelessWidget {
  const CustomOutlineBtn(
      {super.key,
      required this.onPressed,
      this.leadingImageAssetsPath = '',
      required this.text});

  final void Function() onPressed;
  final String leadingImageAssetsPath;
  final Text text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.grey),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (leadingImageAssetsPath != '')
              Image.asset(
                'assets/images/google.png',
                height: 25,
              ),
            if (leadingImageAssetsPath != '') const SizedBox(width: 10),
            text
          ],
        ),
      ),
    );
  }
}
