import 'package:flutter/material.dart';
import '../utils/Colors.dart';
import '../utils/Common.dart';
import '../utils/Constants.dart';
import '../utils/Extensions/app_common.dart';

class DrawerWidget extends StatefulWidget {
  final String title;
  final String iconData;
  final IconData? icon;
  final Function() onTap;

  DrawerWidget({required this.title, required this.iconData, this.icon, required this.onTap});

  @override
  DrawerWidgetState createState() => DrawerWidgetState();
}

class DrawerWidgetState extends State<DrawerWidget> {
  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return inkWellWidget(
      onTap: widget.onTap,
      child: Padding(
        padding:  EdgeInsets.symmetric(vertical:  8.0),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(border: Border.all(color: dividerColor), borderRadius: radius(defaultRadius)),
                  child: Image.asset(widget.iconData, height: 30, width: 30),
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Text(widget.title, style: primaryTextStyle()),
                ),
                Icon(Icons.arrow_forward_ios, size: 16, color: dividerColor)
              ],
            ),
          ],
        ),
      ),
    );
  }
}
