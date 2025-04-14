// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StackedNavigatorGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:flutter/foundation.dart' as _i22;
import 'package:flutter/material.dart' as _i21;
import 'package:flutter/material.dart';
import 'package:hung/ui/views/article/article_view.dart' as _i4;
import 'package:hung/ui/views/chat/chat_view.dart' as _i5;
import 'package:hung/ui/views/chatsity/chatsity_view.dart' as _i13;
import 'package:hung/ui/views/clientchat/clientchat_view.dart' as _i18;
import 'package:hung/ui/views/home/home_view.dart' as _i2;
import 'package:hung/ui/views/pantrylogin/pantrylogin_view.dart' as _i19;
import 'package:hung/ui/views/pinterest/pinterest_view.dart' as _i17;
import 'package:hung/ui/views/profile/profile_view.dart' as _i6;
import 'package:hung/ui/views/promotetowords/promotetowords_view.dart' as _i12;
import 'package:hung/ui/views/prompt_to_favo_page/prompt_to_favo_page_view.dart'
    as _i15;
import 'package:hung/ui/views/prompt_to_query_favorite/prompt_to_query_favorite_view.dart'
    as _i14;
import 'package:hung/ui/views/prompt_to_real/prompt_to_real_view.dart' as _i10;
import 'package:hung/ui/views/prompt_to_select/prompt_to_select_view.dart'
    as _i16;
import 'package:hung/ui/views/prompt_to_translate/prompt_to_translate_view.dart'
    as _i11;
import 'package:hung/ui/views/sesame/sesame_view.dart' as _i20;
import 'package:hung/ui/views/startup/startup_view.dart' as _i3;
import 'package:hung/ui/views/storyly_instagram/storyly_instagram_view.dart'
    as _i7;
import 'package:hung/ui/views/travelcard/travelcard_view.dart' as _i8;
import 'package:hung/ui/views/travelstory/travelstory_view.dart' as _i9;
import 'package:stacked/stacked.dart' as _i1;
import 'package:stacked_services/stacked_services.dart' as _i23;

class Routes {
  static const homeView = '/home-view';

  static const startupView = '/startup-view';

  static const articleView = '/article-view';

  static const chatView = '/chat-view';

  static const profileView = '/profile-view';

  static const storylyInstagramView = '/storyly-instagram-view';

  static const travelcardView = '/travelcard-view';

  static const travelstoryView = '/travelstory-view';

  static const promptToRealView = '/prompt-to-real-view';

  static const promptToTranslateView = '/prompt-to-translate-view';

  static const promotetowordsView = '/promotetowords-view';

  static const chatsityView = '/chatsity-view';

  static const promptToQueryFavoriteView = '/prompt-to-query-favorite-view';

  static const promptToFavoPageView = '/prompt-to-favo-page-view';

  static const promptToSelectView = '/prompt-to-select-view';

  static const pinterestView = '/pinterest-view';

  static const clientchatView = '/clientchat-view';

  static const pantryloginView = '/pantrylogin-view';

  static const sesameView = '/sesame-view';

  static const all = <String>{
    homeView,
    startupView,
    articleView,
    chatView,
    profileView,
    storylyInstagramView,
    travelcardView,
    travelstoryView,
    promptToRealView,
    promptToTranslateView,
    promotetowordsView,
    chatsityView,
    promptToQueryFavoriteView,
    promptToFavoPageView,
    promptToSelectView,
    pinterestView,
    clientchatView,
    pantryloginView,
    sesameView,
  };
}

class StackedRouter extends _i1.RouterBase {
  final _routes = <_i1.RouteDef>[
    _i1.RouteDef(
      Routes.homeView,
      page: _i2.HomeView,
    ),
    _i1.RouteDef(
      Routes.startupView,
      page: _i3.StartupView,
    ),
    _i1.RouteDef(
      Routes.articleView,
      page: _i4.ArticleView,
    ),
    _i1.RouteDef(
      Routes.chatView,
      page: _i5.ChatView,
    ),
    _i1.RouteDef(
      Routes.profileView,
      page: _i6.ProfileView,
    ),
    _i1.RouteDef(
      Routes.storylyInstagramView,
      page: _i7.StorylyInstagramView,
    ),
    _i1.RouteDef(
      Routes.travelcardView,
      page: _i8.TravelcardView,
    ),
    _i1.RouteDef(
      Routes.travelstoryView,
      page: _i9.TravelstoryView,
    ),
    _i1.RouteDef(
      Routes.promptToRealView,
      page: _i10.PromptToRealView,
    ),
    _i1.RouteDef(
      Routes.promptToTranslateView,
      page: _i11.PromptToTranslateView,
    ),
    _i1.RouteDef(
      Routes.promotetowordsView,
      page: _i12.PromotetowordsView,
    ),
    _i1.RouteDef(
      Routes.chatsityView,
      page: _i13.ChatsityView,
    ),
    _i1.RouteDef(
      Routes.promptToQueryFavoriteView,
      page: _i14.PromptToQueryFavoriteView,
    ),
    _i1.RouteDef(
      Routes.promptToFavoPageView,
      page: _i15.PromptToFavoPageView,
    ),
    _i1.RouteDef(
      Routes.promptToSelectView,
      page: _i16.PromptToSelectView,
    ),
    _i1.RouteDef(
      Routes.pinterestView,
      page: _i17.PinterestView,
    ),
    _i1.RouteDef(
      Routes.clientchatView,
      page: _i18.ClientchatView,
    ),
    _i1.RouteDef(
      Routes.pantryloginView,
      page: _i19.PantryloginView,
    ),
    _i1.RouteDef(
      Routes.sesameView,
      page: _i20.SesameView,
    ),
  ];

  final _pagesMap = <Type, _i1.StackedRouteFactory>{
    _i2.HomeView: (data) {
      return _i21.MaterialPageRoute<dynamic>(
        builder: (context) => const _i2.HomeView(),
        settings: data,
      );
    },
    _i3.StartupView: (data) {
      return _i21.MaterialPageRoute<dynamic>(
        builder: (context) => const _i3.StartupView(),
        settings: data,
      );
    },
    _i4.ArticleView: (data) {
      return _i21.MaterialPageRoute<dynamic>(
        builder: (context) => const _i4.ArticleView(),
        settings: data,
      );
    },
    _i5.ChatView: (data) {
      return _i21.MaterialPageRoute<dynamic>(
        builder: (context) => const _i5.ChatView(),
        settings: data,
      );
    },
    _i6.ProfileView: (data) {
      return _i21.MaterialPageRoute<dynamic>(
        builder: (context) => const _i6.ProfileView(),
        settings: data,
      );
    },
    _i7.StorylyInstagramView: (data) {
      return _i21.MaterialPageRoute<dynamic>(
        builder: (context) => const _i7.StorylyInstagramView(),
        settings: data,
      );
    },
    _i8.TravelcardView: (data) {
      final args = data.getArgs<TravelcardViewArguments>(nullOk: false);
      return _i21.MaterialPageRoute<dynamic>(
        builder: (context) => _i8.TravelcardView(
            scrollController: args.scrollController, key: args.key),
        settings: data,
      );
    },
    _i9.TravelstoryView: (data) {
      return _i21.MaterialPageRoute<dynamic>(
        builder: (context) => const _i9.TravelstoryView(),
        settings: data,
      );
    },
    _i10.PromptToRealView: (data) {
      return _i21.MaterialPageRoute<dynamic>(
        builder: (context) => const _i10.PromptToRealView(),
        settings: data,
      );
    },
    _i11.PromptToTranslateView: (data) {
      final args = data.getArgs<PromptToTranslateViewArguments>(nullOk: false);
      return _i21.MaterialPageRoute<dynamic>(
        builder: (context) => _i11.PromptToTranslateView(
            scrollController: args.scrollController, key: args.key),
        settings: data,
      );
    },
    _i12.PromotetowordsView: (data) {
      final args = data.getArgs<PromotetowordsViewArguments>(nullOk: false);
      return _i21.MaterialPageRoute<dynamic>(
        builder: (context) => _i12.PromotetowordsView(
            scrollController: args.scrollController, key: args.key),
        settings: data,
      );
    },
    _i13.ChatsityView: (data) {
      return _i21.MaterialPageRoute<dynamic>(
        builder: (context) => const _i13.ChatsityView(),
        settings: data,
      );
    },
    _i14.PromptToQueryFavoriteView: (data) {
      final args =
          data.getArgs<PromptToQueryFavoriteViewArguments>(nullOk: false);
      return _i21.MaterialPageRoute<dynamic>(
        builder: (context) => _i14.PromptToQueryFavoriteView(
            scrollController: args.scrollController, key: args.key),
        settings: data,
      );
    },
    _i15.PromptToFavoPageView: (data) {
      return _i21.MaterialPageRoute<dynamic>(
        builder: (context) => const _i15.PromptToFavoPageView(),
        settings: data,
      );
    },
    _i16.PromptToSelectView: (data) {
      return _i21.MaterialPageRoute<dynamic>(
        builder: (context) => const _i16.PromptToSelectView(),
        settings: data,
      );
    },
    _i17.PinterestView: (data) {
      return _i21.MaterialPageRoute<dynamic>(
        builder: (context) => const _i17.PinterestView(),
        settings: data,
      );
    },
    _i18.ClientchatView: (data) {
      return _i21.MaterialPageRoute<dynamic>(
        builder: (context) => const _i18.ClientchatView(),
        settings: data,
      );
    },
    _i19.PantryloginView: (data) {
      return _i21.MaterialPageRoute<dynamic>(
        builder: (context) => const _i19.PantryloginView(),
        settings: data,
      );
    },
    _i20.SesameView: (data) {
      return _i21.MaterialPageRoute<dynamic>(
        builder: (context) => const _i20.SesameView(),
        settings: data,
      );
    },
  };

  @override
  List<_i1.RouteDef> get routes => _routes;

  @override
  Map<Type, _i1.StackedRouteFactory> get pagesMap => _pagesMap;
}

class TravelcardViewArguments {
  const TravelcardViewArguments({
    required this.scrollController,
    this.key,
  });

  final _i21.ScrollController scrollController;

  final _i22.Key? key;

  @override
  String toString() {
    return '{"scrollController": "$scrollController", "key": "$key"}';
  }

  @override
  bool operator ==(covariant TravelcardViewArguments other) {
    if (identical(this, other)) return true;
    return other.scrollController == scrollController && other.key == key;
  }

  @override
  int get hashCode {
    return scrollController.hashCode ^ key.hashCode;
  }
}

class PromptToTranslateViewArguments {
  const PromptToTranslateViewArguments({
    required this.scrollController,
    this.key,
  });

  final _i21.ScrollController scrollController;

  final _i22.Key? key;

  @override
  String toString() {
    return '{"scrollController": "$scrollController", "key": "$key"}';
  }

  @override
  bool operator ==(covariant PromptToTranslateViewArguments other) {
    if (identical(this, other)) return true;
    return other.scrollController == scrollController && other.key == key;
  }

  @override
  int get hashCode {
    return scrollController.hashCode ^ key.hashCode;
  }
}

class PromotetowordsViewArguments {
  const PromotetowordsViewArguments({
    required this.scrollController,
    this.key,
  });

  final _i21.ScrollController scrollController;

  final _i22.Key? key;

  @override
  String toString() {
    return '{"scrollController": "$scrollController", "key": "$key"}';
  }

  @override
  bool operator ==(covariant PromotetowordsViewArguments other) {
    if (identical(this, other)) return true;
    return other.scrollController == scrollController && other.key == key;
  }

  @override
  int get hashCode {
    return scrollController.hashCode ^ key.hashCode;
  }
}

class PromptToQueryFavoriteViewArguments {
  const PromptToQueryFavoriteViewArguments({
    required this.scrollController,
    this.key,
  });

  final _i21.ScrollController scrollController;

  final _i22.Key? key;

  @override
  String toString() {
    return '{"scrollController": "$scrollController", "key": "$key"}';
  }

  @override
  bool operator ==(covariant PromptToQueryFavoriteViewArguments other) {
    if (identical(this, other)) return true;
    return other.scrollController == scrollController && other.key == key;
  }

  @override
  int get hashCode {
    return scrollController.hashCode ^ key.hashCode;
  }
}

extension NavigatorStateExtension on _i23.NavigationService {
  Future<dynamic> navigateToHomeView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.homeView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToStartupView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.startupView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToArticleView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.articleView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToChatView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.chatView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToProfileView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.profileView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToStorylyInstagramView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.storylyInstagramView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToTravelcardView({
    required _i21.ScrollController scrollController,
    _i22.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.travelcardView,
        arguments: TravelcardViewArguments(
            scrollController: scrollController, key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToTravelstoryView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.travelstoryView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToPromptToRealView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.promptToRealView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToPromptToTranslateView({
    required _i21.ScrollController scrollController,
    _i22.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.promptToTranslateView,
        arguments: PromptToTranslateViewArguments(
            scrollController: scrollController, key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToPromotetowordsView({
    required _i21.ScrollController scrollController,
    _i22.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.promotetowordsView,
        arguments: PromotetowordsViewArguments(
            scrollController: scrollController, key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToChatsityView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.chatsityView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToPromptToQueryFavoriteView({
    required _i21.ScrollController scrollController,
    _i22.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.promptToQueryFavoriteView,
        arguments: PromptToQueryFavoriteViewArguments(
            scrollController: scrollController, key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToPromptToFavoPageView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.promptToFavoPageView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToPromptToSelectView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.promptToSelectView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToPinterestView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.pinterestView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToClientchatView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.clientchatView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToPantryloginView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.pantryloginView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToSesameView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.sesameView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithHomeView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.homeView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithStartupView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.startupView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithArticleView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.articleView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithChatView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.chatView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithProfileView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.profileView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithStorylyInstagramView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.storylyInstagramView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithTravelcardView({
    required _i21.ScrollController scrollController,
    _i22.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.travelcardView,
        arguments: TravelcardViewArguments(
            scrollController: scrollController, key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithTravelstoryView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.travelstoryView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithPromptToRealView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.promptToRealView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithPromptToTranslateView({
    required _i21.ScrollController scrollController,
    _i22.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.promptToTranslateView,
        arguments: PromptToTranslateViewArguments(
            scrollController: scrollController, key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithPromotetowordsView({
    required _i21.ScrollController scrollController,
    _i22.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.promotetowordsView,
        arguments: PromotetowordsViewArguments(
            scrollController: scrollController, key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithChatsityView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.chatsityView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithPromptToQueryFavoriteView({
    required _i21.ScrollController scrollController,
    _i22.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.promptToQueryFavoriteView,
        arguments: PromptToQueryFavoriteViewArguments(
            scrollController: scrollController, key: key),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithPromptToFavoPageView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.promptToFavoPageView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithPromptToSelectView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.promptToSelectView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithPinterestView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.pinterestView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithClientchatView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.clientchatView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithPantryloginView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.pantryloginView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithSesameView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.sesameView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }
}
