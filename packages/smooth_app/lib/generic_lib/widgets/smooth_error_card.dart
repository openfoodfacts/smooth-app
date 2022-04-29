import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_app/generic_lib/buttons/smooth_simple_button.dart';
import 'package:smooth_app/generic_lib/widgets/smooth_card.dart';
import 'package:smooth_app/helpers/extension_on_text_helper.dart';

class SmoothErrorCard extends StatefulWidget {
  const SmoothErrorCard({Key? key, required this.errorMessage, required this.tryAgainFunction})
      : super(key: key);
  final String errorMessage;
  final void Function() tryAgainFunction;

  @override
  State<SmoothErrorCard> createState() => _SmoothErrorCardState();
}

class _SmoothErrorCardState extends State<SmoothErrorCard> {
  late AppLocalizations _appLocalizations;
  final double _buttonsHeight = 40;
  final double _buttonsWidth = 200;
  final TextStyle _buttonsTextStyle = const TextStyle(color: Colors.white);
  bool _showErrorText = false;

  void _setShowErrorText() {
    setState(() {
      _showErrorText = !_showErrorText;
    });
  }

  Widget _getTryAgainButton() {
    return SmoothSimpleButton(
      height: _buttonsHeight,
      child: Text(
        _appLocalizations.try_again,
        style: _buttonsTextStyle,
      ),
      onPressed: widget.tryAgainFunction,
      minWidth: _buttonsWidth,
    );
  }

  Widget _getErrorMessage() {
    return Container(
      margin: const EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(
            Icons.error_outline,
            size: 40,
            color: Colors.red,
          ),
          Expanded(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    _appLocalizations.error_occurred,
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    widget.errorMessage,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ).selectable(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getErrorButton() {
    if (_showErrorText) {
      return _getErrorMessage();
    }

    return SmoothSimpleButton(
      height: _buttonsHeight,
      child: Text(
        _appLocalizations.learnMore,
        style: _buttonsTextStyle,
      ),
      onPressed: _setShowErrorText,
      minWidth: _buttonsWidth,
    );
  }

  Widget _getButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: <Widget>[
          _getTryAgainButton(),
          const SizedBox(height: 5),
          _getErrorButton(),
        ],
      ),
    );
  }

  Widget _getTitle() {
    return  Align(
      alignment: AlignmentDirectional.centerStart,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 7),
        child: Text(
          _appLocalizations.there_was_an_error,
          style: const TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _appLocalizations = AppLocalizations.of(context)!;

    return Center(
      child: SizedBox(
        width: 500,
        child: SmoothCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _getTitle(),
              _getButtons(),
            ],
          ),
        ),
      ),
    );
  }
}
