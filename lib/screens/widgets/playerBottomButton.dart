import 'package:flutter/material.dart';
import 'package:music_player/common/color.dart';

class PlayerBottomButton extends StatelessWidget {
  final String title;
  final String icon;
  final VoidCallback onPressed;

  const PlayerBottomButton({super.key, required this.title, required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: IconButton(
              onPressed: onPressed,
              icon: Image.asset(icon, width: 30, height: 30, color: AppColor.primaryText80),
            ),
          ),
          Text(title, style: TextStyle(color: AppColor.secondaryText, fontSize: 8)),
        ],
      ),
    );
  }
}
