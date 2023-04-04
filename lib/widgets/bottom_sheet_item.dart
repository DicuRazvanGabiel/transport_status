import 'package:flutter/material.dart';

class BottomSheetItem extends StatelessWidget {
  final IconData leadingIcon;
  final IconData trailingIcon;
  final String title;
  final Function() onTap;

  const BottomSheetItem(
      {super.key,
      required this.leadingIcon,
      required this.trailingIcon,
      required this.title,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: ListTile(
        onTap: onTap,
        leading: Icon(leadingIcon),
        title: Text(title),
        trailing: Icon(trailingIcon),
      ),
    );
  }
}
