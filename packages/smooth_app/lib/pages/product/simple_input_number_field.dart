import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/helpers/text_input_formatters_helper.dart';
import 'package:smooth_app/query/product_query.dart';

/// Simple input text field, for numbers.
class SimpleInputNumberField extends StatelessWidget {
  const SimpleInputNumberField({
    required this.focusNode,
    required this.constraints,
    required this.hintText,
    required this.controller,
    required this.decimal,
    required this.numberFormat,
    required this.numberRegExp,
    this.withClearButton = false,
  });

  final FocusNode focusNode;
  final BoxConstraints constraints;
  final String hintText;
  final TextEditingController controller;
  final bool decimal;
  final NumberFormat numberFormat;
  final RegExp numberRegExp;
  final bool withClearButton;

  // we admit both decimal points (anyway, the keyboard will only show one)
  static RegExp getNumberRegExp({required final bool decimal}) =>
      decimal ? RegExp(r'[\d,.]') : RegExp(r'\d');

  static NumberFormat getNumberFormat({required final bool decimal}) =>
      NumberFormat(
        decimal ? '####0.#####' : '######0',
        ProductQuery.getLocaleString(),
      );

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.only(start: LARGE_SPACE),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        SizedBox(
          width:
              constraints.maxWidth -
              LARGE_SPACE -
              (withClearButton ? MINIMUM_TOUCH_SIZE : 0),
          child: TextField(
            keyboardType: TextInputType.numberWithOptions(
              signed: false,
              decimal: decimal,
            ),
            controller: controller,
            decoration: InputDecoration(
              filled: true,
              border: const OutlineInputBorder(
                borderRadius: ANGULAR_BORDER_RADIUS,
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: SMALL_SPACE,
                vertical: SMALL_SPACE,
              ),
              hintText: hintText,
            ),
            // a lot of confusion if set to `true`
            autofocus: false,
            focusNode: focusNode,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(numberRegExp),
              if (decimal) DecimalSeparatorRewriter(numberFormat),
            ],
          ),
        ),
        if (withClearButton)
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () => controller.text = '',
          ),
      ],
    ),
  );
}
