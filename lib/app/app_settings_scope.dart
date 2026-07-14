import 'package:flutter/widgets.dart';
import 'package:nutrilens/models/models.dart';
import 'package:nutrilens/services/user_repository.dart';

class AppSettingsController extends ChangeNotifier {
  AppSettingsController({
    required UserRepository repository,
    required String uid,
  }) : _repository = repository,
       _uid = uid;

  UserRepository _repository;
  String _uid;
  UserProfile? _profile;
  SegmentControlStyle _segmentControlStyle = SegmentControlStyle.minimalTabs;
  bool _sleepModeEnabled = false;
  bool _accessibilityModeEnabled = false;
  AppTextScale _textScale = AppTextScale.medium;
  AppThemePalette _themePalette = AppThemePalette.classic;
  bool _loading = true;
  bool _saving = false;

  SegmentControlStyle get segmentControlStyle => _segmentControlStyle;
  bool get sleepModeEnabled => _sleepModeEnabled;
  bool get accessibilityModeEnabled => _accessibilityModeEnabled;
  AppTextScale get textScale => _textScale;
  AppThemePalette get themePalette => _themePalette;
  bool get loading => _loading;
  bool get saving => _saving;

  Future<void> reload({
    required UserRepository repository,
    required String uid,
  }) async {
    _repository = repository;
    _uid = uid;
    _profile = null;
    _segmentControlStyle = SegmentControlStyle.minimalTabs;
    _sleepModeEnabled = false;
    _accessibilityModeEnabled = false;
    _textScale = AppTextScale.medium;
    _themePalette = AppThemePalette.classic;
    _loading = true;
    notifyListeners();
    await load();
  }

  Future<void> load() async {
    try {
      final profile = await _repository.getProfile(_uid);
      _profile = profile;
      _segmentControlStyle =
          profile?.segmentControlStyle ?? SegmentControlStyle.minimalTabs;
      _sleepModeEnabled = profile?.sleepModeEnabled ?? false;
      _accessibilityModeEnabled = profile?.accessibilityModeEnabled ?? false;
      _textScale = profile?.textScale ?? AppTextScale.medium;
      _themePalette = profile?.themePalette ?? AppThemePalette.classic;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> updateSegmentControlStyle(SegmentControlStyle style) async {
    if (style == _segmentControlStyle || _saving) {
      return;
    }

    final previousStyle = _segmentControlStyle;
    final previousProfile = _profile;
    _segmentControlStyle = style;
    _saving = true;
    notifyListeners();

    try {
      final profile = _profile ?? await _repository.getProfile(_uid);
      if (profile == null) {
        throw StateError('User profile is unavailable.');
      }

      final updated = profile.copyWith(segmentControlStyle: style);
      await _repository.saveProfile(updated);
      _profile = updated;
    } catch (_) {
      _profile = previousProfile;
      _segmentControlStyle = previousStyle;
      rethrow;
    } finally {
      _saving = false;
      notifyListeners();
    }
  }

  Future<void> updateSleepModeEnabled(bool enabled) async {
    if (enabled == _sleepModeEnabled || _saving) {
      return;
    }

    final previousEnabled = _sleepModeEnabled;
    final previousProfile = _profile;
    _sleepModeEnabled = enabled;
    _saving = true;
    notifyListeners();

    try {
      final profile = _profile ?? await _repository.getProfile(_uid);
      if (profile == null) {
        throw StateError('User profile is unavailable.');
      }

      final updated = profile.copyWith(sleepModeEnabled: enabled);
      await _repository.saveProfile(updated);
      _profile = updated;
    } catch (_) {
      _profile = previousProfile;
      _sleepModeEnabled = previousEnabled;
      rethrow;
    } finally {
      _saving = false;
      notifyListeners();
    }
  }

  Future<void> updateAccessibilityModeEnabled(bool enabled) async {
    await _updateProfileField(
      apply: () => _accessibilityModeEnabled = enabled,
      rollback: (previous) => _accessibilityModeEnabled = previous,
      read: () => _accessibilityModeEnabled,
      write: (profile, value) =>
          profile.copyWith(accessibilityModeEnabled: value),
      value: enabled,
    );
  }

  Future<void> updateTextScale(AppTextScale scale) async {
    await _updateProfileField(
      apply: () => _textScale = scale,
      rollback: (previous) => _textScale = previous,
      read: () => _textScale,
      write: (profile, value) => profile.copyWith(textScale: value),
      value: scale,
    );
  }

  Future<void> updateThemePalette(AppThemePalette palette) async {
    await _updateProfileField(
      apply: () => _themePalette = palette,
      rollback: (previous) => _themePalette = previous,
      read: () => _themePalette,
      write: (profile, value) => profile.copyWith(themePalette: value),
      value: palette,
    );
  }

  Future<void> _updateProfileField<T>({
    required VoidCallback apply,
    required void Function(T previous) rollback,
    required T Function() read,
    required UserProfile Function(UserProfile profile, T value) write,
    required T value,
  }) async {
    if (value == read() || _saving) {
      return;
    }

    final previous = read();
    final previousProfile = _profile;
    apply();
    _saving = true;
    notifyListeners();

    try {
      final profile = _profile ?? await _repository.getProfile(_uid);
      if (profile == null) {
        throw StateError('User profile is unavailable.');
      }

      final updated = write(profile, value);
      await _repository.saveProfile(updated);
      _profile = updated;
    } catch (_) {
      _profile = previousProfile;
      rollback(previous);
      rethrow;
    } finally {
      _saving = false;
      notifyListeners();
    }
  }
}

class AppSettingsScope extends StatefulWidget {
  const AppSettingsScope({
    super.key,
    required this.repository,
    required this.uid,
    required this.child,
  });

  final UserRepository repository;
  final String uid;
  final Widget child;

  static AppSettingsController of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<_AppSettingsInherited>();
    if (scope == null) {
      throw FlutterError(
        'AppSettingsScope.of() called with no AppSettingsScope in context.',
      );
    }
    return scope.notifier!;
  }

  static AppSettingsController? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_AppSettingsInherited>()
        ?.notifier;
  }

  @override
  State<AppSettingsScope> createState() => _AppSettingsScopeState();
}

class _AppSettingsScopeState extends State<AppSettingsScope> {
  late final AppSettingsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AppSettingsController(
      repository: widget.repository,
      uid: widget.uid,
    );
    _controller.load();
  }

  @override
  void didUpdateWidget(covariant AppSettingsScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.repository != widget.repository ||
        oldWidget.uid != widget.uid) {
      _controller.reload(repository: widget.repository, uid: widget.uid);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _AppSettingsInherited(controller: _controller, child: widget.child);
  }
}

class _AppSettingsInherited extends InheritedNotifier<AppSettingsController> {
  const _AppSettingsInherited({
    required AppSettingsController controller,
    required super.child,
  }) : super(notifier: controller);
}
