import 'package:flutter/material.dart';

class PickupTile extends StatelessWidget {
  final String left;
  final String right;
  const PickupTile({super.key, required this.left, required this.right});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(left),
            const SizedBox(
              width: 20,
            ),
            Flexible(child: Text(right))
          ],
        ),
      ),
    );
  }
}
