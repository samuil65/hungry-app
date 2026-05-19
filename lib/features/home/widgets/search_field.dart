import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:huungry/core/constants/app_colors.dart';

class SearchField extends StatelessWidget {
  const SearchField({super.key, required this.controller, this.onChanged});
  final Function(String)? onChanged;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: TextField(
        onChanged: onChanged,
        cursorHeight: 15,
        controller: controller,
        decoration: InputDecoration(
          filled: true,
          contentPadding: EdgeInsets.zero,
          hintText: 'Search..',
          hintStyle: TextStyle(color: Colors.white),
          fillColor: Colors.transparent,
          prefixIcon: Icon(CupertinoIcons.search, size: 18,color: Colors.white),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(40),
            borderSide: BorderSide(
              color: Colors.white.withOpacity(0.2),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(40),
            borderSide: BorderSide(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
