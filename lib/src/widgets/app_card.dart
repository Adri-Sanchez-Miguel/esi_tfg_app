import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {    
  final Function()? onTap;
  final Widget? title;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? photo;
  final Widget? trailing;
  final Color? color;
  final Color? iconColor;
  final Color? textColor;
  final bool active;
  final Color borderColor;
  final double radius;
  const AppCard({Key? key, this.onTap, this.title, this.subtitle, this.leading, this.color, this.textColor, this.iconColor, required this.radius, required this.borderColor, this.trailing, this.photo, required this.active}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 3),
      color: active ? Colors.white : color,
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
                selected: active,
                enabled: true,
                trailing: trailing,
                contentPadding: const EdgeInsets.all(4.0),
                selectedColor: Colors.redAccent,
                selectedTileColor: Colors.white,
                iconColor: iconColor,
                textColor: textColor,
                leading: SizedBox(height: 100, width: 60, child:leading),
                title: title,
                subtitle: subtitle,
                onTap: onTap,
              ),
            ),
          ],
        ),
        subtitle: photo,
      ),
    );
  }
}