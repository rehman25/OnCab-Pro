import 'package:flutter/material.dart';
import 'package:taxi_driver/utils/Images.dart';

import '../main.dart';
import '../utils/Common.dart';
import '../utils/Extensions/app_common.dart';

class ImageSourceDialog extends StatefulWidget {
 final Function()? onGallery;
 final Function()? onCamera;
 final Function()? onFile;
 final bool isFile;

 ImageSourceDialog({this.onGallery, this.onCamera,this.onFile,this.isFile = false});

  @override
  State<ImageSourceDialog> createState() => _ImageSourceDialogState();
}

class _ImageSourceDialogState extends State<ImageSourceDialog> {
  @override
  Widget build(BuildContext context) {
    return Padding(padding: EdgeInsets.all(20),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(language.selectSources, style: boldTextStyle(size: 18)),
            InkWell(onTap: (){
              Navigator.pop(context);
            },child: Icon(Icons.cancel_outlined)),
          ],
        ),
        SizedBox(height: 16),
        inkWellWidget(
          onTap: widget.onGallery ?? (){},
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(ic_gallery, height: 26, width: 26, fit: BoxFit.cover,color: Colors.black),
                SizedBox(width: 8),
                Text(language.gallery, style: primaryTextStyle()),
              ],
            ),
          ),
        ),
        Divider(height: 16),
        inkWellWidget(
          onTap: widget.onCamera ?? (){},
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(ic_camera, height: 26, width: 26, fit: BoxFit.cover,color: Colors.black),
                SizedBox(width: 8),
                Text(language.camera, style: primaryTextStyle()),
              ],
            ),
          ),
        ),
        Divider(height: 16),
        if(widget.isFile) inkWellWidget(
          onTap: widget.onFile ?? (){},
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(ic_pdf, height: 26, width: 26, fit: BoxFit.cover,color: Colors.black),
                SizedBox(width: 8),
                Text(language.file, style: primaryTextStyle()),
              ],
            ),
          ),
        ),
      ],
    ),);
  }
}
