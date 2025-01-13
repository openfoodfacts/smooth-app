import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/haptic_feedback_helper.dart';
import 'package:smooth_app/pages/folksonomy/folksonomy_provider.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/smooth_theme_colors.dart';
import 'package:smooth_app/widgets/v2/smooth_buttons_bar.dart';

class FolksonomyEditTagContent extends StatefulWidget {
  const FolksonomyEditTagContent({
    required this.action,
    this.existingKeys,
    this.oldKey,
    this.oldValue,
  });

  final List<String>? existingKeys;
  final String? oldKey;
  final String? oldValue;
  final FolksonomyAction action;

  @override
  FolksonomyEditTagContentState createState() =>
      FolksonomyEditTagContentState();
}

class FolksonomyEditTagContentState extends State<FolksonomyEditTagContent> {
  static const String regexString = r'^[a-z0-9_-]+(:[a-z0-9_-]+)*$';
  late TextEditingController keyController;
  late TextEditingController valueController;
  bool isKeyValid = true;
  bool isValueValid = true;

  @override
  void initState() {
    super.initState();
    keyController = TextEditingController(text: widget.oldKey);
    valueController = TextEditingController(text: widget.oldValue);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _FolksonomyEditTagContentBody(
          keyController: keyController,
          valueController: valueController,
          isKeyEditable: widget.action == FolksonomyAction.add,
          isKeyValid: isKeyValid,
          isValueValid: isValueValid,
          onSave: _onSubmit,
        ),
        _FolksonomyEditTagContentFooter(
          onSave: _onSubmit,
        ),
      ],
    );
  }

  Future<void> _onSubmit() async {
    isKeyValid = RegExp(regexString).hasMatch(keyController.text);

    if (widget.action == FolksonomyAction.add) {
      isKeyValid =
          isKeyValid && !widget.existingKeys!.contains(keyController.text);
    } else if (widget.action == FolksonomyAction.edit) {
      isKeyValid = isKeyValid &&
          (keyController.text == widget.oldKey ||
              !widget.existingKeys!.contains(keyController.text));
    }

    isValueValid = valueController.text.trim().isNotEmpty;

    if (!isKeyValid || !isValueValid) {
      setState(() {});
      return SmoothHapticFeedback.error();
    }

    return Navigator.of(context).pop(
      FolksonomyTag(
        key: keyController.text,
        value: valueController.text,
      ),
    );
  }

  @override
  void dispose() {
    keyController.dispose();
    valueController.dispose();
    super.dispose();
  }
}

class _FolksonomyEditTagContentBody extends StatelessWidget {
  const _FolksonomyEditTagContentBody({
    required this.keyController,
    required this.valueController,
    required this.onSave,
    required this.isKeyEditable,
    required this.isKeyValid,
    required this.isValueValid,
  });

  final TextEditingController keyController;
  final TextEditingController valueController;
  final bool isKeyEditable;
  final bool isKeyValid;
  final bool isValueValid;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: MEDIUM_SPACE,
        vertical: MEDIUM_SPACE,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _FolksonomyEditTagContentTitle(
            isKeyEditable
                ? appLocalizations.tag_key
                : appLocalizations.tag_key_uneditable,
            explanation: appLocalizations.tag_key_explanations,
            hasErrors: !isKeyValid,
          ),
          TextField(
            controller: keyController,
            autofocus: isKeyEditable,
            autocorrect: false,
            readOnly: !isKeyEditable,
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.none,
            keyboardType: TextInputType.text,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(
                RegExp(r'[a-zA-Z0-9_\-\:]'),
              ),
              LowerCaseTextFormatter(),
            ],
            decoration: InputDecoration(
              hintText: appLocalizations.tag_key_input_hint,
              hintStyle: const TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
          const SizedBox(height: LARGE_SPACE),
          _FolksonomyEditTagContentTitle(
            appLocalizations.tag_value,
            hasErrors: isValueValid,
          ),
          TextField(
            controller: valueController,
            autofocus: !isKeyEditable,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.send,
            decoration: InputDecoration(
              hintText: appLocalizations.tag_value_input_hint,
              hintStyle: const TextStyle(fontStyle: FontStyle.italic),
            ),
            onSubmitted: (_) => onSave(),
          ),
        ],
      ),
    );
  }
}

class _FolksonomyEditTagContentTitle extends StatefulWidget {
  const _FolksonomyEditTagContentTitle(
    this.title, {
    this.explanation,
    this.hasErrors = false,
  });

  final String title;
  final bool hasErrors;
  final String? explanation;

  @override
  State<_FolksonomyEditTagContentTitle> createState() =>
      _FolksonomyEditTagContentTitleState();
}

class _FolksonomyEditTagContentTitleState
    extends State<_FolksonomyEditTagContentTitle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Animation<Color?>? _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )
      ..addListener(() => setState(() {}))
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          _controller.reverse();
        }
      });
  }

  @override
  void didUpdateWidget(_FolksonomyEditTagContentTitle oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.hasErrors != widget.hasErrors) {
      _controller.repeat(count: 2);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_animation == null) {
      final SmoothColorsThemeExtension extension =
          context.extension<SmoothColorsThemeExtension>();

      _animation = ColorTween(
        begin: DefaultTextStyle.of(context).style.color,
        end: extension.error,
      ).animate(_controller);
    }

    final Widget text = Text(
      widget.title,
      style: TextStyle(
        color: _animation!.value,
        fontSize: 17.0,
        fontWeight: FontWeight.bold,
      ),
    );

    if (widget.explanation != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          text,
          Text(
            widget.explanation!,
            style: TextStyle(
              color: _animation!.value,
              fontSize: 14.5,
            ),
          ),
        ],
      );
    }

    return text;
  }
}

class _FolksonomyEditTagContentFooter extends StatelessWidget {
  const _FolksonomyEditTagContentFooter({
    required this.onSave,
  });

  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    double bottomPadding = MediaQuery.viewInsetsOf(context).bottom;
    if (bottomPadding == 0) {
      bottomPadding = MediaQuery.viewPaddingOf(context).bottom;
    }

    return Column(
      children: <Widget>[
        SmoothButtonsBar2(
          addViewPadding: false,
          positiveButton: SmoothActionButton2(
            text: appLocalizations.save,
            onPressed: onSave,
          ),
          negativeButton: SmoothActionButton2(
            text: appLocalizations.cancel,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        SizedBox(height: bottomPadding),
      ],
    );
  }
}

class LowerCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toLowerCase(),
      selection: newValue.selection,
    );
  }
}

class FolksonomyTag {
  FolksonomyTag({
    required this.key,
    required this.value,
  });

  final String key;
  final String value;
}
