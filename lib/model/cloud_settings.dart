///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2020/5/10 14:14
///
part of 'models.dart';

class CloudSettingsModel extends JsonModel {
  CloudSettingsModel() {
    lastModified = DateTime.now();
  }

  factory CloudSettingsModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> settings =
        (json['settings'] as Map<dynamic, dynamic>).cast<String, dynamic>();
    final CloudSettingsModel model = CloudSettingsModel()
      .._fontScale = '${settings[_fFontScale] ?? 1.0}'.toDouble()
      .._hideShieldPost = settings[_fHideShieldPost] ?? true
      .._homeSplashIndex = settings[_fHomeSplashIndex] ?? 0
      .._launchFromSystemBrowser = settings[_fLaunchFromSystemBrowser] ?? false
      .._newAppCenterIcon = settings[_fNewAppCenterIcon] ?? false
      .._isDark = settings[_fIsDark] ?? false
      .._amoledDark = settings[_fAMOLEDDark] ?? false
      .._platformBrightness = settings[_fPlatformBrightness] ?? true
      ..lastModified = DateTime.fromMillisecondsSinceEpoch(
        '${json['last_modified']}000'.toInt(),
      );
    return model;
  }

  factory CloudSettingsModel.fromProvider(
    SettingsProvider settingsProvider,
    ThemesProvider themesProvider,
  ) {
    return CloudSettingsModel()
      .._fontScale = settingsProvider.fontScale
      .._hideShieldPost = settingsProvider.hideShieldPost
      .._homeSplashIndex = settingsProvider.homeSplashIndex
      .._launchFromSystemBrowser = settingsProvider.launchFromSystemBrowser
      .._newAppCenterIcon = settingsProvider.newAppCenterIcon
      .._isDark = themesProvider.dark
      .._amoledDark = themesProvider.amoledDark
      .._platformBrightness = themesProvider.platformBrightness;
  }

  static const String _fFontScale = 'font_scale';
  static const String _fHideShieldPost = 'hide_shield_post';
  static const String _fHomeSplashIndex = 'home_splash_index';
  static const String _fLaunchFromSystemBrowser = 'launch_from_system_browser';
  static const String _fNewAppCenterIcon = 'new_app_center_icon';
  static const String _fIsDark = 'theme_is_dark';
  static const String _fAMOLEDDark = 'theme_amoled_dark';
  static const String _fPlatformBrightness = 'theme_platform_brightness';

  double _fontScale = 1.0;
  double get fontScale => _fontScale;

  bool _hideShieldPost = true;
  bool get hideShieldPost => _hideShieldPost;

  int _homeSplashIndex = 0;
  int get homeSplashIndex => _homeSplashIndex;

  bool _launchFromSystemBrowser = false;
  bool get launchFromSystemBrowser => _launchFromSystemBrowser;

  bool _newAppCenterIcon = false;
  bool get newAppCenterIcon => _newAppCenterIcon;

  bool _isDark = false;
  bool get isDark => _isDark;

  bool _amoledDark = false;
  bool get amoledDark => _amoledDark;

  bool _platformBrightness = true;
  bool get platformBrightness => _platformBrightness;

  DateTime lastModified;

  /// Font scale need to be converted as [String], because as it stored in
  /// the server, the type of the value (1.0) will be lost. ([double] -> [int])
  /// 字号需要处理成[String]，因为在存储的过程中1.0会丢失类型
  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'settings': <String, dynamic>{
        _fFontScale: '${_fontScale}',
        _fHideShieldPost: _hideShieldPost,
        _fHomeSplashIndex: _homeSplashIndex,
        _fLaunchFromSystemBrowser: _launchFromSystemBrowser,
        _fNewAppCenterIcon: _newAppCenterIcon,
        _fIsDark: _isDark,
        _fAMOLEDDark: _amoledDark,
        _fPlatformBrightness: _platformBrightness,
      },
      'last_modified':
          '${lastModified.millisecondsSinceEpoch}'.substring(0, 10),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CloudSettingsModel &&
          runtimeType == other.runtimeType &&
          _fontScale == other._fontScale &&
          _hideShieldPost == other._hideShieldPost &&
          _homeSplashIndex == other._homeSplashIndex &&
          _launchFromSystemBrowser == other._launchFromSystemBrowser &&
          _newAppCenterIcon == other._newAppCenterIcon &&
          _isDark == other._isDark &&
          _amoledDark == other._amoledDark &&
          _platformBrightness == other._platformBrightness;

  @override
  int get hashCode =>
      _fontScale.hashCode ^
      _hideShieldPost.hashCode ^
      _homeSplashIndex.hashCode ^
      _launchFromSystemBrowser.hashCode ^
      _newAppCenterIcon.hashCode ^
      _isDark.hashCode ^
      _amoledDark.hashCode ^
      _platformBrightness.hashCode;
}
