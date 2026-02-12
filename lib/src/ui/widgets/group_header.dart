import 'package:flutter/material.dart';

class GroupHeaderDelegate extends SliverPersistentHeaderDelegate {
  GroupHeaderDelegate(this.label);

  final String label;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(label, style: Theme.of(context).textTheme.titleMedium),
    );
  }

  @override
  double get maxExtent => 40;

  @override
  double get minExtent => 40;

  @override
  bool shouldRebuild(covariant GroupHeaderDelegate oldDelegate) {
    return oldDelegate.label != label;
  }
}
