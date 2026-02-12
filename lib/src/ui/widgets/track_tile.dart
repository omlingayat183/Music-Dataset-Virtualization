import 'package:flutter/material.dart';

import '../../models/track.dart';

class TrackTile extends StatelessWidget {
  const TrackTile({super.key, required this.track, required this.onTap});

  final Track track;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      title: Text(track.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text('${track.artist} • ID: ${track.id}'),
      onTap: onTap,
    );
  }
}
