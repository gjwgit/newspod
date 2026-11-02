/// A list kept on the device and in step with a copy on the Pod.
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

import 'dart:async';
import 'dart:convert';
import 'dart:math' show min;

import 'package:flutter/foundation.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:solidpod/solidpod.dart' show isUserLoggedIn;

import 'package:newspod/services/pod_json.dart';

/// A list kept on this device and, when logged in, on the Pod, so each
/// device shows the same.
///
/// 20261102 gjw A change is made to the device's list at once and queued.
/// [sync] reads the Pod's list, applies the queue to it in order, writes it
/// back and takes the result, so the Pod's list wins, with this device's
/// changes on top. Until the app is logged in, or while the Pod cannot be
/// reached, the queue waits, saved on the device, for the next [sync]. A
/// Pod with no file yet is given this device's list. A removal is queued
/// too, not merely forgotten, so that removing an item on one device
/// removes it from the others.

class SyncedList<T> extends ChangeNotifier {
  SyncedList({
    required String key,
    required String file,
    required String Function(T) keyOf,
    required Object? Function(T) toJson,
    required T Function(Object?) fromJson,
    List<T> initial = const [],
    int? keep,
    Future<bool> Function() connected = isUserLoggedIn,
    Future<Object?> Function(String) read = readPodJson,
    Future<void> Function(String, Object) write = writePodJson,
  }) : _key = key,
       _file = file,
       _keyOf = keyOf,
       _toJson = toJson,
       _fromJson = fromJson,
       _items = [...initial],
       _keep = keep,
       _connected = connected,
       _read = read,
       _write = write {
    _rekey();
  }

  final String _key;
  final String _file;
  final String Function(T) _keyOf;
  final Object? Function(T) _toJson;
  final T Function(Object?) _fromJson;
  final int? _keep;
  final Future<bool> Function() _connected;
  final Future<Object?> Function(String) _read;
  final Future<void> Function(String, Object) _write;

  List<T> _items;
  Set<String> _keys = {};

  // The changes not yet on the Pod: {'add': item, 'at': index} or
  // {'remove': key}.

  List<Map<String, Object?>> _queue = [];

  Future<void>? _syncing;
  bool _again = false;

  /// The items, in order.

  List<T> get items => List.unmodifiable(_items);

  /// Whether an item with [key] is in the list.

  bool containsKey(String key) => _keys.contains(key);

  /// Read the list and the queue saved on this device, keeping the initial
  /// list when nothing is saved yet.

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    if (prefs.getString(_key) case final saved?) {
      _items = [for (final json in jsonDecode(saved) as List) _fromJson(json)];
    }
    if (prefs.getString('${_key}_queue') case final saved?) {
      _queue = [
        for (final op in jsonDecode(saved) as List) op as Map<String, Object?>,
      ];
    }

    _rekey();
    notifyListeners();
  }

  /// Add [item], at the end or back [at] where it was.

  Future<void> add(T item, {int? at}) =>
      _change({'add': _toJson(item), 'at': at});

  /// Remove the item with [key], returning where it was so it can be put
  /// back.

  Future<int> removeKey(String key) async {
    final at = _items.indexWhere((item) => _keyOf(item) == key);
    await _change({'remove': key});

    return at;
  }

  // The list changes and listeners hear at once, since a Dismissible needs
  // its item gone in the same frame, then it is saved and synced.

  Future<void> _change(Map<String, Object?> op) async {
    _apply(_items, op);
    _queue.add(op);
    _rekey();
    notifyListeners();

    await _save();
    unawaited(sync());
  }

  void _apply(List<T> list, Map<String, Object?> op) {
    if (op['remove'] case final String key) {
      list.removeWhere((item) => _keyOf(item) == key);
    } else {
      final item = _fromJson(op['add']);
      list.removeWhere((other) => _keyOf(other) == _keyOf(item));
      list.insert(min(op['at'] as int? ?? list.length, list.length), item);
    }

    while (_keep != null && list.length > _keep) {
      list.removeAt(0);
    }
  }

  /// Bring the list into step with the Pod when logged in. A sync asked for
  /// while one runs runs again after it.

  Future<void> sync() {
    if (_syncing case final syncing?) {
      _again = true;
      return syncing;
    }

    return _syncing = _sync().whenComplete(() => _syncing = null);
  }

  // 20261102 gjw Each pass runs to its end, even one that finds it is not
  // logged in or fails, so a sync asked for meanwhile is never dropped.

  Future<void> _sync() async {
    do {
      _again = false;
      await _syncOnce();
    } while (_again);
  }

  Future<void> _syncOnce() async {
    try {
      if (!await _connected()) return;

      final ops = [..._queue];
      final json = await _read(_file);
      final pod = json == null
          ? [..._items]
          : [for (final item in json as List) _fromJson(item)];

      final merged = [...pod];
      for (final op in ops) {
        _apply(merged, op);
      }

      final mergedJson = _encode(merged);
      if (json == null || jsonEncode(json) != mergedJson) {
        await _write(_file, jsonDecode(mergedJson) as Object);
      }

      // Changes made while the Pod was being read stay queued, on top.

      _queue.removeRange(0, ops.length);
      final local = [...merged];
      for (final op in _queue) {
        _apply(local, op);
      }

      final changed = _encode(local) != _encode(_items);
      _items = local;
      _rekey();
      await _save();

      if (changed) notifyListeners();
    } catch (e) {
      // 20261102 gjw Not shown: the queue stays saved on the device and the
      // next sync tries again, on a refresh or the next change.

      debugPrint('[SyncedList] $_file not synced, kept for next time: $e');
    }
  }

  String _encode(List<T> list) =>
      jsonEncode([for (final i in list) _toJson(i)]);

  void _rekey() => _keys = {for (final item in _items) _keyOf(item)};

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, _encode(_items));
    await prefs.setString('${_key}_queue', jsonEncode(_queue));
  }
}
