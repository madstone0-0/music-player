import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:music_player/models/artists.dart';

class Artists extends StatefulWidget {
  const Artists({super.key});

  @override
  State<Artists> createState() => _ArtistsState();
}

class _ArtistsState extends State<Artists> {
  final vm = Get.put(ArtistsViewModel());

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text("Artists")));
  }
}
