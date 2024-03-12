import 'package:flutter/material.dart';

class ShortcutButton extends StatelessWidget {
  final String img;
  final String title;
  const ShortcutButton({super.key, required this.img, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        (img.contains('assets'))
        ? Image.asset(
          img,
          width: (title != 'Avatar' && title != 'Reels') ? 30 : 24,
          height: (title != 'Avatar' && title != 'Reels') ? 30 : 24,
        )
        : Image.network(img),
        const SizedBox(
          height: 5,
        ),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        )
      ],
    );
  }
}
