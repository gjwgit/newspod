/// The root of the widget tree: the theme and the optional Solid login.
//
// Time-stamp: <>
//
/// Copyright (C) 2026, Togaware Pty Ltd
///
/// Licensed under the GNU General Public License, Version 3 (the "License").
///
/// License: https://opensource.org/license/gpl-3-0.
//
// This program is free software: you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation, either version 3 of the License, or (at your option) any later
// version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
// details.
//
// You should have received a copy of the GNU General Public License along with
// this program.  If not, see <https://opensource.org/license/gpl-3-0>.
///
/// Authors: Graham Williams

library;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'package:solidui/solidui.dart';

import 'package:newspod/constants/app.dart';
import 'package:newspod/home.dart';

/// The app. It starts straight on the news, as though CONTINUE had been
/// tapped, since reading feeds needs no login. Logging in to a Pod is there
/// from the app bar for anyone who wants it.

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return SolidThemeApp(
      debugShowCheckedModeBanner: false,
      title: appTitle,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: seedColour),
        useMaterial3: true,
        snackBarTheme: solidSnackBarTheme,
      ),
      home: SolidLogin(
        title: appTitle.replaceAll(' - ', '\n'),
        appDirectory: appDirectory,
        skipLogin: true,
        image: const AssetImage('assets/images/app_image.jpg'),
        logo: const AssetImage('assets/images/app_icon.png'),
        continueButtonStyle: const ContinueButtonStyle(
          visible: true,
          text: 'News',
        ),
        link: 'https://github.com/gjwgit/newspod/blob/dev/README.md',
        clientId: 'https://gjwgit.github.io/newspod/client-profile.jsonld',

        // On web the redirect must be same-origin as where the app is served,
        // otherwise redirect.html's BroadcastChannel cannot hand the auth
        // response back and login hangs on the spinner.
        redirectUris: kIsWeb
            ? ['${Uri.base.origin}/redirect.html']
            : const [
                'com.togaware.newspod://redirect',
                'http://localhost:4400/redirect.html',
              ],
        child: const Home(),
      ),
    );
  }
}
