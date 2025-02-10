import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/data_models/news_feed/newsfeed_model.dart';
import 'package:smooth_app/data_models/news_feed/newsfeed_provider.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';
import 'package:smooth_app/helpers/provider_helper.dart';

/// Listen to [AppNewsProvider] feed and provide a list of [AppNewsItem]
/// randomly sorted by unread, then displayed and clicked news.
class ScanNewsFeedProvider extends ValueNotifier<ScanTagLineState> {
  ScanNewsFeedProvider(BuildContext context)
      : _newsFeedProvider = context.read<AppNewsProvider>(),
        _userPreferences = context.read<UserPreferences>(),
        super(const ScanTagLineStateLoading()) {
    _newsFeedProvider.addListener(_onNewsFeedStateChanged);
    // Refresh with the current state
    _onNewsFeedStateChanged();
  }

  final AppNewsProvider _newsFeedProvider;
  final UserPreferences _userPreferences;

  void _onNewsFeedStateChanged() {
    switch (_newsFeedProvider.state) {
      case AppNewsStateLoading():
        emit(const ScanTagLineStateLoading());
      case AppNewsStateError():
        emit(const ScanTagLineStateNoContent());
      case AppNewsStateLoaded():
        _onTagLineContentAvailable(
            (_newsFeedProvider.state as AppNewsStateLoaded).content);
    }
  }

  Future<void> _onTagLineContentAvailable(AppNews tagLine) async {
    if (!tagLine.feed.isNotEmpty) {
      emit(const ScanTagLineStateNoContent());
      return;
    }

    final List<AppNewsItem> unreadNews = <AppNewsItem>[];
    final List<AppNewsItem> displayedNews = <AppNewsItem>[];
    final List<AppNewsItem> clickedNews = <AppNewsItem>[];

    final List<String> taglineFeedAlreadyClickedNews =
        _userPreferences.taglineFeedClickedNews;
    final List<String> taglineFeedAlreadyDisplayedNews =
        _userPreferences.taglineFeedDisplayedNews;

    for (final AppNewsFeedItem feedItem in tagLine.feed.news) {
      if (taglineFeedAlreadyClickedNews.contains(feedItem.id)) {
        clickedNews.add(feedItem.news);
      } else if (taglineFeedAlreadyDisplayedNews.contains(feedItem.id)) {
        displayedNews.add(feedItem.news);
      } else {
        unreadNews.add(feedItem.news);
      }
    }

    emit(
      ScanTagLineStateLoaded(
        <AppNewsItem>[
          ...unreadNews..shuffle(),
          ...displayedNews..shuffle(),
          ...clickedNews..shuffle(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _newsFeedProvider.removeListener(_onNewsFeedStateChanged);
    super.dispose();
  }
}

sealed class ScanTagLineState {
  const ScanTagLineState();
}

class ScanTagLineStateLoading extends ScanTagLineState {
  const ScanTagLineStateLoading();
}

class ScanTagLineStateNoContent extends ScanTagLineState {
  const ScanTagLineStateNoContent();
}

class ScanTagLineStateLoaded extends ScanTagLineState {
  const ScanTagLineStateLoaded(this.tagLine);

  final Iterable<AppNewsItem> tagLine;
}
