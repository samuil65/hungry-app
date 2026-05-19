import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:huungry/core/constants/app_colors.dart';
import '../../../shared/custom_text.dart';

class CardItem extends StatelessWidget {
  const CardItem({
    super.key,
    required this.image,
    required this.text,
    required this.desc,
    required this.rate,
  });
  final String image, text, desc, rate;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 500),
        child: Card(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// Image
                Center(
                  child: Image.network(image, width: 200, height: 140),
                ),
                // Stack(
                //   clipBehavior: Clip.none,
                //   children: [
                //     Positioned(
                //       bottom: 0,
                //       right: 0,
                //       left: 0,
                //       child: Image.asset(
                //         'assets/icon/shadow.png',
                //         color: Colors.black26,
                //       ),
                //     ),
                //
                //   ],
                // ),

                /// Details
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: text,
                        weight: FontWeight.w300,
                        size: 18,
                        color: Colors.green.shade900,
                      ),
                      Gap(5),
                      CustomText(text: desc, size: 12, color: AppColors.primary,weight: FontWeight.w300,),
                      Gap(10),
                      Row(
                        children: [
                          Icon(
                            CupertinoIcons.star_fill,
                            size: 16,
                            color: Colors.yellow.shade500,
                          ),
                          Icon(
                            CupertinoIcons.star_fill,
                            size: 16,
                            color: Colors.yellow.shade500,
                          ),
                          Icon(
                            CupertinoIcons.star_fill,
                            size: 16,
                            color: Colors.grey.shade500,
                          ),
                          Icon(
                            CupertinoIcons.star_fill,
                            size: 16,
                            color: Colors.grey.shade500,
                          ),
                          Gap(6),
                          CustomText(
                            text: rate,
                            size: 15,
                            weight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                          Spacer(),
                          Icon(
                            CupertinoIcons.heart,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
