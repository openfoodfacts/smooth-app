import 'package:flutter/foundation.dart';
import 'package:smooth_app/data_models/preferences/user_preferences.dart';

/// A provider with 4 states:
/// * [PreferencesSelectorInitialState]: initial state, no value
/// * [PreferencesSelectorLoadingState]: loading values
/// * [PreferencesSelectorLoadedState]: values loaded and/or saved
/// * [PreferencesSelectorEditingState]: the user has selected a value
/// (temporary selection)
abstract class PreferencesSelectorProvider<T>
    extends ValueNotifier<PreferencesSelectorState<T>> {
  PreferencesSelectorProvider({
    required this.preferences,
    required this.autoValidate,
  }) : super(PreferencesSelectorInitialState<T>()) {
    preferences.addListener(onPreferencesChanged);
    onPreferencesChanged();
  }

  final UserPreferences preferences;
  final bool autoValidate;

  Future<void> onSaveItem(T item);
  Future<void> onPreferencesChanged();
  Future<List<T>> onLoadValues();
  T getSelectedValue(List<T> values);

  @immutable
  void changeSelectedItem(T item) {
    final PreferencesSelectorLoadedState<T> state =
        value as PreferencesSelectorLoadedState<T>;

    value = PreferencesSelectorEditingState<T>.fromLoadedState(
      loadedState: state,
      selectedItemOverride: item,
    );

    if (autoValidate) {
      saveSelectedItem();
    }
  }

  @immutable
  Future<void> saveSelectedItem() async {
    if (value is! PreferencesSelectorEditingState) {
      return;
    }

    /// No need to refresh the state here, the [UserPreferences] will notify
    return onSaveItem(
      (value as PreferencesSelectorEditingState<T>).selectedItemOverride as T,
    );
  }

  @immutable
  void dismissSelectedItem() {
    if (value is PreferencesSelectorEditingState) {
      value = (value as PreferencesSelectorEditingState<T>).toLoadedState();
    }
  }

  @protected
  Future<void> loadValues() async {
    value = PreferencesSelectorLoadingState<T>();

    final List<T> values = await onLoadValues();
    value = PreferencesSelectorLoadedState<T>(
      selectedItem: getSelectedValue(values),
      items: values,
    );
  }

  @override
  void dispose() {
    preferences.removeListener(onPreferencesChanged);
    super.dispose();
  }
}

@immutable
sealed class PreferencesSelectorState<T> {
  const PreferencesSelectorState();
}

class PreferencesSelectorInitialState<T>
    extends PreferencesSelectorLoadingState<T> {
  const PreferencesSelectorInitialState();
}

class PreferencesSelectorLoadingState<T> extends PreferencesSelectorState<T> {
  const PreferencesSelectorLoadingState();
}

class PreferencesSelectorLoadedState<T> extends PreferencesSelectorState<T> {
  const PreferencesSelectorLoadedState({
    required this.selectedItem,
    required this.items,
  });

  final T? selectedItem;
  final List<T> items;

  PreferencesSelectorLoadedState<T> copyWith({
    T? selectedItem,
    List<T>? items,
  }) =>
      PreferencesSelectorLoadedState<T>(
        selectedItem: selectedItem ?? this.selectedItem,
        items: items ?? this.items,
      );

  @override
  String toString() {
    return 'PreferencesSelectorLoadedState{selectedItem: $selectedItem, items: $items}';
  }
}

class PreferencesSelectorEditingState<T>
    extends PreferencesSelectorLoadedState<T> {
  PreferencesSelectorEditingState.fromLoadedState({
    required this.selectedItemOverride,
    required PreferencesSelectorLoadedState<T> loadedState,
  }) : super(
          selectedItem: loadedState.selectedItem,
          items: loadedState.items,
        );

  final T? selectedItemOverride;

  PreferencesSelectorLoadedState<T> toLoadedState() =>
      PreferencesSelectorLoadedState<T>(
        selectedItem: selectedItem,
        items: items,
      );

  @override
  String toString() {
    return 'PreferencesSelectorEditingState{selectedItem: $selectedItem}';
  }
}
