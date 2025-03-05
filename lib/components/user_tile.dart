import 'package:chat_app/components/chat_text.dart';
import 'package:flutter/material.dart';

class UserTile extends StatelessWidget {
  final String userName;
  final String userEmail;
  final void Function()? onTap;

  const UserTile({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          height: 55,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 15.0,
              vertical: 8.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 6),
                    ChatText(
                      text: userName,
                      size: 22,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                  ],
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 15.0,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
