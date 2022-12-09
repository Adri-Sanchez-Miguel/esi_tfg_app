import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class DetailScreen extends StatelessWidget {
  final String path;
  final String tag;
  const DetailScreen({super.key, required this.path, required this.tag});

  @override
  Widget build(BuildContext context) {
    try{
      return Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Center(
            child: Hero(
              tag: tag,
              child: CachedNetworkImage(
                key: ValueKey<String>(path),
                imageUrl: path,
                placeholder: (context, url) => Platform.isAndroid ? 
                  const CircularProgressIndicator() 
                  : const CupertinoActivityIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
          ),
        ),
      );
    }catch(e){
      Fluttertoast.showToast(
        msg: e.toString(),
        fontSize: 20,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red[400]
      );
      return Container(height: 0.0,);
    }
  }
}