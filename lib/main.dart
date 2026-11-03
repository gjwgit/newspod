/// Main program for NewsPod, a privacy-first news feed reader.
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

import 'package:solidui/solidui.dart';
import 'package:window_manager/window_manager.dart';

import 'package:newspod/app.dart';
import 'package:newspod/constants/app.dart';
import 'package:newspod/services/feed_list.dart';
import 'package:newspod/services/news.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SolidSecurityKeyCentralManager.instance;

  // 20261102 gjw Read the saved feeds, and the stories dismissed, kept for
  // later and viewed, before the first frame, then start reading the news while
  // the window opens.

  await feedList.load();
  await news.load();
  news.refresh();

  // 20260913 gjw Open at the size the window was last left at, and keep that
  // size up to date as it is resized. The user sets the size, and turns off
  // remembering it, under Settings in the profile menu. Until a size has been
  // remembered the window opens at the default in `linux/my_application.cc`.

  if (isDesktop) {
    await windowManager.ensureInitialized();
    await SolidWindowSize.show(const WindowOptions(title: appTitle));
  }

  runApp(const App());
}
