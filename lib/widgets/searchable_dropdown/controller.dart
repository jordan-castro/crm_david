import 'dart:async';

import 'package:flutter/material.dart';
import 'package:searchable_paginated_dropdown/searchable_paginated_dropdown.dart';

// Enum must be before that class.
// ignore: prefer-match-file-name
enum SearchableDropdownStatus { initial, busy, error, loaded }

extension ContextExtension on BuildContext {
  double get deviceHeight => MediaQuery.of(this).size.height;
}

extension CustomGlobalKeyExtension on GlobalKey {
  Rect? get globalPaintBounds {
    final renderObject = currentContext?.findRenderObject();
    final translation = renderObject?.getTransformTo(null).getTranslation();
    if (translation != null && renderObject?.paintBounds != null) {
      final offset = Offset(translation.x, translation.y);
      return renderObject!.paintBounds.shift(offset);
    } else {
      return null;
    }
  }
}

extension CustomStringExtension on String {
  bool containsWithTurkishChars(String key) {
    return replaceTurkishChars.contains(key.replaceTurkishChars);
  }

  String get replaceTurkishChars {
    var replaced = toLowerCase();
    replaced = replaced.replaceAll('ş', 's');
    replaced = replaced.replaceAll('ı', 'i');
    replaced = replaced.replaceAll('ğ', 'g');
    replaced = replaced.replaceAll('ç', 'c');
    replaced = replaced.replaceAll('ö', 'o');
    replaced = replaced.replaceAll('ü', 'u');
    return replaced;
  }
}

class SearchableDropdownController<T> {
  SearchableDropdownController({
    SearchableDropdownMenuItem<T>? initialItem,
    TextInputType? textInputType,
  }) {
    if (initialItem != null) selectedItem.value = initialItem;

    if (textInputType != null) {
      this.textInputType = textInputType;
    }
  }

  TextInputType textInputType = TextInputType.text;

  final GlobalKey key = GlobalKey();
  final ValueNotifier<List<SearchableDropdownMenuItem<T>>?> paginatedItemList =
      ValueNotifier<List<SearchableDropdownMenuItem<T>>?>(null);
  final ValueNotifier<SearchableDropdownMenuItem<T>?> selectedItem =
      ValueNotifier<SearchableDropdownMenuItem<T>?>(null);
  final ValueNotifier<SearchableDropdownStatus> status =
      ValueNotifier<SearchableDropdownStatus>(SearchableDropdownStatus.initial);

  late Future<List<SearchableDropdownMenuItem<T>>?> Function(
    int page,
    String? key,
  )? paginatedRequest;
  late Future<List<SearchableDropdownMenuItem<T>>?> Function()? futureRequest;

  late int requestItemCount;

  late List<SearchableDropdownMenuItem<T>>? items;

  String searchText = '';
  final ValueNotifier<List<SearchableDropdownMenuItem<T>>?> searchedItems =
      ValueNotifier<List<SearchableDropdownMenuItem<T>>?>(null);

  bool _hasMoreData = true;
  int _page = 1;
  int get page => _page;

  Future<void> getItemsWithPaginatedRequest({
    required int page,
    String? key,
    bool isNewSearch = false,
  }) async {
    if (paginatedRequest == null) return;
    if (isNewSearch) {
      _page = 1;
      paginatedItemList.value = null;
      _hasMoreData = true;
    }
    if (!_hasMoreData) return;
    status.value = SearchableDropdownStatus.busy;
    final response = await paginatedRequest!(page, key);
    if (response is! List<SearchableDropdownMenuItem<T>>) return;

    paginatedItemList.value ??= [];
    paginatedItemList.value = paginatedItemList.value! + response;
    if (response.length < requestItemCount) {
      _hasMoreData = false;
    } else {
      _page = _page + 1;
    }
    status.value = SearchableDropdownStatus.loaded;
  }

  Future<void> getItemsWithFutureRequest() async {
    if (futureRequest == null) return;

    status.value = SearchableDropdownStatus.busy;
    final response = await futureRequest!();
    if (response is! List<SearchableDropdownMenuItem<T>>) return;
    items = response;
    searchedItems.value = response;
    status.value = SearchableDropdownStatus.loaded;
  }

  void fillSearchedList(String? value) {
    if (value == null || value.isEmpty) searchedItems.value = items;

    final tempList = <SearchableDropdownMenuItem<T>>[];
    for (final element in items ?? <SearchableDropdownMenuItem<T>>[]) {
      if (element.label.containsWithTurkishChars(value!)) tempList.add(element);
    }
    searchedItems.value = tempList;
  }

  void clear() {
    selectedItem.value = null;
  }

  void dispose() {
    paginatedItemList.dispose();
    selectedItem.dispose();
    status.dispose();
    searchedItems.dispose();
  }
}
