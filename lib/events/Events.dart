import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';

import 'package:OpenJMU/constants/Constants.dart';

/// Event for testing.
class TestEvent {
  var content;
  TestEvent({this.content});
}

class ConnectivityChangeEvent {
  ConnectivityResult type;
  ConnectivityChangeEvent(this.type);
}

class ActionsEvent {
  String type;
  ActionsEvent(this.type);
}

class LogoutEvent {}

class TicketGotEvent {
  bool isWizard; // 账号是否已通过新人引导
  TicketGotEvent(this.isWizard);
}

class TicketFailedEvent {}

class PostForwardedEvent {
  int postId;
  int forwards;
  PostForwardedEvent(this.postId, this.forwards);
}

class PostForwardDeletedEvent {
  int postId;
  int forwards;
  PostForwardDeletedEvent(this.postId, this.forwards);
}

class PostCommentedEvent {
  int postId;
  PostCommentedEvent(this.postId);
}

class PostCommentDeletedEvent {
  int postId;
  PostCommentDeletedEvent(this.postId);
}

class PostPraisedEvent {
  int postId;
  PostPraisedEvent(this.postId);
}

class PostUnPraisedEvent {
  int postId;
  PostUnPraisedEvent(this.postId);
}

class PostDeletedEvent {
  int postId;
  String page;
  int index;
  PostDeletedEvent(this.postId, this.page, this.index);
}

class TeamCommentDeletedEvent {
  int postId;
  TeamCommentDeletedEvent(this.postId);
}

class ForwardInPostUpdatedEvent {
  int postId, count;
  ForwardInPostUpdatedEvent(this.postId, this.count);
}

class CommentInPostUpdatedEvent {
  int postId, count;
  CommentInPostUpdatedEvent(this.postId, this.count);
}

class PraiseInPostUpdatedEvent {
  int postId, count;
  String type;
  bool isLike;
  PraiseInPostUpdatedEvent({this.postId, this.type, this.count, this.isLike});
}

class AvatarUpdatedEvent {}

class SignatureUpdatedEvent {
  String signature;
  SignatureUpdatedEvent(this.signature);
}

class AddEmoticonEvent {
  String emoticon;
  String route;
  AddEmoticonEvent(this.emoticon, this.route);
}

class HasUpdateEvent {
  bool forceUpdate;
  String currentVersion;
  int currentBuild;
  Map<String, dynamic> response;
  HasUpdateEvent({
    this.forceUpdate,
    this.currentVersion,
    this.currentBuild,
    this.response,
  });
}

class OTAEvent {
  dynamic otaEvent;
  OTAEvent(this.otaEvent);
}

class UserInfoGotEvent {
  UserInfo userInfo;
  UserInfoGotEvent(this.userInfo);
}

class BlacklistUpdateEvent {}

class NotificationsChangeEvent {
  Notifications notifications;
  NotificationsChangeEvent(this.notifications);
}

class ChangeThemeEvent {
  Color color;
  ChangeThemeEvent(this.color);
}

class ChangeBrightnessEvent {
  bool isDarkState;
  Brightness brightness;
  Color primaryColor;

  ChangeBrightnessEvent(bool isDark) {
    if (isDark) {
      this.isDarkState = true;
      this.brightness = Brightness.dark;
      this.primaryColor = Colors.grey[850];
    } else {
      this.isDarkState = false;
      this.brightness = Brightness.light;
      this.primaryColor = Colors.white;
    }
  }
}

class ChangeAMOLEDDarkEvent {
  bool isAMOLEDDark;
  ChangeAMOLEDDarkEvent(this.isAMOLEDDark);
}

class ScrollToTopEvent {
  int tabIndex;
  String type;
  ScrollToTopEvent({this.tabIndex, this.type});
}

class PostChangeEvent {
  Post post;
  bool remove;
  PostChangeEvent(this.post, [this.remove = false]);
}

class CurrentWeekUpdatedEvent {}

class AppCenterRefreshEvent {
  int currentIndex;
  AppCenterRefreshEvent(this.currentIndex);
}

class AppCenterSettingsUpdateEvent {}

class ScoreRefreshEvent {}

class CourseScheduleRefreshEvent {}

class CoursePageShowWeekEvent {
  bool show;
  CoursePageShowWeekEvent(this.show);
}

/// Events for message
class MessageReceivedEvent {
  int type;
  int senderUid;
  String senderMultiPortId;
  DateTime sendTime;
  String ackId;
  Map<String, dynamic> content;

  MessageReceivedEvent({
    this.type,
    this.senderUid,
    this.senderMultiPortId,
    this.sendTime,
    this.ackId,
    this.content,
  });
}
