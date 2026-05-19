import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/custom_text.dart';

class UserHeader extends StatelessWidget {
  const UserHeader({
    super.key,
    required this.userName,
    required this.userImage,
  });
  final String userName, userImage;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CustomText(
                  text: 'Hello, ',
                  size: 30,
                  weight: FontWeight.w300,
                  color: Colors.grey.shade400,
                ),
                CustomText(
                  text: userName,
                  size: 30,
                  weight: FontWeight.w200,
                  color: Colors.white,
                ),
              ],
            ),
            CustomText(
              text: 'HUNGRY RIGHT NOW 🙄?',
              size: 14,
              weight: FontWeight.w500,
              color: Colors.grey.shade100,
            ),
          ],
        ),
        Spacer(),
        CircleAvatar(
          radius: 30,
          backgroundColor: AppColors.primary,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(200),
            child: Image.network(
              userImage,
              fit: BoxFit.cover,
              errorBuilder:
                  (context, err, builder) =>
                      Icon(Icons.person, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
