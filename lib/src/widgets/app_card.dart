import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {    
  final Function()? onTap;
  final Widget? title;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final Color? color;
  final Color? iconColor;
  final Color? textColor;
  final Color borderColor;
  final double radius;
  const AppCard({Key? key, this.onTap, this.title, this.subtitle, this.leading, this.color, this.textColor, this.iconColor, required this.radius, required this.borderColor, this.trailing}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 3),
      color: color,
      elevation: 5,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          width: radius,
          color: borderColor
        ),
        borderRadius: const BorderRadius.all(Radius.circular(12.0)),
      ),
      child: ListTile(
        minVerticalPadding: 8.0,
        title: Row(
          children: <Widget>[
            Expanded(
              child: ListTile(
                trailing: trailing,
                contentPadding: const EdgeInsets.all(4.0),
                selectedColor: Colors.black,
                iconColor: iconColor,
                textColor: textColor,
                leading: leading,
                title: title,
                subtitle: subtitle,
                onTap: onTap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}