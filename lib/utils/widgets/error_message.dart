import 'package:flutter/material.dart';

Widget errorMessageWidget(
  BuildContext context,
  String text, [
  double? fontSize,
]) =>
    Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.info_outline,
            color: Colors.red,
          ),
          const SizedBox(
            width: 10,
          ),
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * .7,
            ),
            child: Text(
              text,
              style: TextStyle(
                height: 1.2,
                color: Colors.red,
                fontWeight: FontWeight.w500,
                fontSize: fontSize ?? 15,
              ),
            ),
          ),
        ],
      ),
    );
