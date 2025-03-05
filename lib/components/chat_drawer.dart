import 'package:chat_app/components/chat_text.dart';
import 'package:chat_app/services/auth/auth_service.dart';
import 'package:chat_app/pages/home_page.dart';
import 'package:chat_app/pages/settings_page.dart';
import 'package:flutter/material.dart';

class ChatDrawer extends StatelessWidget {
  const ChatDrawer({super.key});

  void logout(BuildContext context) async {
    final authService = AuthService();

    try {
      await authService.signOut();
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(e.toString()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
                Padding(
                padding: const EdgeInsets.only(left: 5.0, top: 50.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                  padding: const EdgeInsets.only(left: 20.0,top: 20.0,bottom: 20.0),
                  child: Text(
                    "Menu",
                    style: TextStyle(
                    color: Theme.of(context).colorScheme.tertiary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    ),
                  ),
                  ),
                ),
                ),
              Padding(
                padding: const EdgeInsets.only(left: 5.0),
                child: ListTile(
                  title: ChatText(
                    text: 'Chats',
                    size: 18,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                  leading: Icon(
                    Icons.forum,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomePage(),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 5.0),
                child: ListTile(
                  title: ChatText(
                    text: 'Settings',
                    size: 18,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                  leading: Icon(
                    Icons.settings,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsPage(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 25.0, bottom: 25.0),
            child: ListTile(
              title: ChatText(
                text: 'Logout',
                size: 20,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.tertiary,
              ),
              leading: Icon(
                Icons.logout,
                color: Theme.of(context).colorScheme.tertiary,
              ),
              onTap: () => logout(context),
            ),
          ),
        ],
      ),
    );
  }
}
