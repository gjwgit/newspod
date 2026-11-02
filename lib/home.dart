/// The app's home, the solidui scaffold with its menu of pages.
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

import 'package:flutter/material.dart';

import 'package:solidpod/solidpod.dart' show getWebId;
import 'package:solidui/solidui.dart';

import 'package:newspod/constants/app.dart';
import 'package:newspod/screens/dismissed_screen.dart';
import 'package:newspod/screens/feeds_screen.dart';
import 'package:newspod/screens/news_screen.dart';
import 'package:newspod/services/news.dart';

/// The scaffold: the News, Dismissed and Feeds pages, a Refresh button in
/// the app bar, and the login status for the optional Pod.

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String? _webId;

  @override
  void initState() {
    super.initState();
    _loadWebId();
  }

  // 20261102 gjw Once logged in the feeds and the stories dismissed on other
  // devices are fetched, and changes made here while logged out reach the
  // Pod.

  Future<void> _loadWebId() async {
    final webId = await getWebId();
    if (webId != null) news.sync();
    if (mounted) setState(() => _webId = webId);
  }

  @override
  Widget build(BuildContext context) {
    return SolidScaffold(
      appBar: SolidAppBarConfig(
        title: appName,
        actions: [
          SolidAppBarAction(
            icon: Icons.refresh,
            tooltip:
                '**Refresh**\n\nRead every feed again for the latest '
                'stories. On a phone, pulling the news down does the same.',
            onPressed: news.refresh,
          ),
        ],

        // 20261002 gjw Always supply the versionConfig. SolidScaffold loads the
        // version only if it is present when the scaffold is first built.
        versionConfig: const SolidVersionConfig(changelogUrl: changelogUrl),
      ),
      themeToggle: const SolidThemeToggleConfig(enabled: true),
      statusBar: SolidStatusBarConfig(
        serverInfo: _webId != null ? SolidServerInfo.fromWebId(_webId!) : null,
        loginStatus: SolidLoginStatus(webId: _webId),
      ),
      aboutConfig: SolidAboutConfig(
        applicationName: appTitle.replaceAll(' - ', '\n'),
        applicationIcon: Image.asset(
          'assets/images/app_icon.png',
          width: 64,
          height: 64,
        ),
        applicationLegalese: '© 2026 Togaware Pty Ltd',
        text: """
NewsPod gathers the stories from the RSS and Atom feeds you choose into one
list, newest first. Tap a story to read it in full on its own site. Add and
remove feeds under Feeds.

There is no account, no tracking and no algorithm choosing what you see. Your
feeds, and the stories you swipe away, are kept on this device. Logging in to
a Solid Pod is optional. When you do, they are kept on your Pod too, encrypted,
so every device shows the same feeds and the same stories stay away.

**GitHub** [https://github.com/gjwgit/newspod](https://github.com/gjwgit/newspod)

**Author** [Graham Williams](https://togaware.com/graham.williams.html)
""",
      ),
      menu: const [
        SolidMenuItem(
          title: 'News',
          icon: Icons.newspaper,
          tooltip:
              '**News**\n\nThe stories from all your feeds, newest first. '
              'Tap one to read it on its own site, or swipe it left to '
              'remove it.',
          child: NewsScreen(),
        ),
        SolidMenuItem(
          title: 'Dismissed',
          icon: Icons.visibility_off_outlined,
          tooltip:
              '**Dismissed**\n\nThe stories swiped out of the news, while '
              'their feeds still have them. Swipe one right to bring it back '
              'to the news.',
          child: DismissedScreen(),
        ),
        SolidMenuItem(
          title: 'Feeds',
          icon: Icons.rss_feed,
          tooltip:
              '**Feeds**\n\nThe feeds the news comes from. Add a feed by its '
              'address, or remove one.',
          child: FeedsScreen(),
        ),
      ],
    );
  }
}
