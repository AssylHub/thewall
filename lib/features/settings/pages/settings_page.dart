/* 

SETTINGS PAGE

- Dark Mode
- Blocked Users
- Account Settings

*/

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/responsive/constrainded_scaffol.dart';
import 'package:social_media_app/themes/theme_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // theme cubit
    final themeCubit = context.watch<ThemeCubit>();

    // is dark mode
    bool isDarkMode = themeCubit.isDarkMode;

    // SCAFFOLD
    return ConstraindedScaffold(
      appBar: AppBar(title: Text("Settings")),
      body: Column(
        children: [
          // dark mode tile
          ListTile(
            title: Text("Dark Mode"),
            trailing: CupertinoSwitch(
              value: isDarkMode,
              onChanged: (value) {
                themeCubit.toggleTheme();
              },
            ),
          ),
        ],
      ),
    );
  }
}
