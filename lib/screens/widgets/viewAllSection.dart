import 'package:flutter/material.dart';
import 'package:music_player/common/color.dart';


class ViewAllSection extends StatelessWidget {
  final String title;
  final String buttonTitle;
  final VoidCallback onPressed;

  const ViewAllSection({super.key, required this.title, this.buttonTitle = "View All", required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                  color: AppColor.primaryText80,
                  fontSize: 15,
                  fontWeight: FontWeight.w600),
            ),
          ),

          TextButton(onPressed: onPressed , child: Text(
            buttonTitle,
            style: TextStyle(
                color: AppColor.org,
                fontSize: 11),
          ))
        ],
      ),
    );
  }
}
