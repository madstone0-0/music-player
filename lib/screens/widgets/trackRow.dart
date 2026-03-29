import 'package:flutter/material.dart';
import 'package:music_player/common/color.dart';
import 'package:music_player/db/db.dart';

class TrackRow extends StatelessWidget {
  final TrackData track;
  final VoidCallback onPressedPlay;
  final VoidCallback onPressed;
  const TrackRow({
    super.key,
    required this.track,
    required this.onPressed,
    required this.onPressedPlay,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: onPressedPlay,
              icon: Image.asset(
                "assets/img/play_btn.png",
                width: 25,
                height: 25,
              ),
            ),
            Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      track.title,
                      maxLines: 1,
                      style: TextStyle(
                          color: AppColor.primaryText60,
                          fontSize: 13,
                          fontWeight: FontWeight.w700),
                    ),
                    Text(
                      track.artist ?? "Unknown Artist",
                      maxLines: 1,
                      style: TextStyle(color: AppColor.secondaryText, fontSize: 10),
                    )
                  ],
                )),
          ],
        ),
        Divider(
          color: Colors.white.withOpacity(0.07),
          indent: 50,
        ),
      ],
    );
  }
}
