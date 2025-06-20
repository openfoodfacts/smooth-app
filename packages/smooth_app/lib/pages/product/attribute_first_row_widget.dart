import 'package:flutter/material.dart';
import 'package:smooth_app/l10n/app_localizations.dart';
import 'package:smooth_app/pages/product/attribute_first_row_helper.dart';

class AttributeFirstRowWidget extends StatefulWidget {
  const AttributeFirstRowWidget({
    required this.helper,
  });

  final AttributeFirstRowHelper helper;

  @override
  State<AttributeFirstRowWidget> createState() =>
      _AttributeFirstRowWidgetState();
}

class _AttributeFirstRowWidgetState extends State<AttributeFirstRowWidget> {
  bool _showAllTerms = false;
  late final List<StringPair> allTerms;

  @override
  void initState() {
    super.initState();
    allTerms = widget.helper.getAllTerms();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    const int numberThreshold = 4;
    final bool hasManyTerms = allTerms.length > numberThreshold;
    final List<StringPair> firstTerms = allTerms
        .take(
          numberThreshold,
        )
        .toList();

    if (firstTerms.isEmpty) {
      firstTerms.add(
        StringPair(first: appLocalizations.no_data_available),
      );
    }
    return Column(
      children: <Widget>[
        ListTile(
          leading: widget.helper.getLeadingIcon(),
          title: Text(
            widget.helper.getTitle(context),
          ),
          trailing: const Icon(
            Icons.edit,
          ),
          titleTextStyle: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 20.0,
            color: theme.primaryColor,
          ),
          iconColor: theme.primaryColor,
          tileColor: theme.colorScheme.secondary,
          onTap: () async => widget.helper.onTap(context: context),
        ),
        _termsList(
          _showAllTerms ? allTerms : firstTerms,
          borderFlag: !hasManyTerms,
        ),
        if (hasManyTerms) ...<Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 100.0),
            child: ExpansionTile(
              onExpansionChanged: (bool value) => setState(() {
                _showAllTerms = value;
              }),
              title: const Text(
                'Expand',
                style: TextStyle(
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          )
        ]
      ],
    );
  }

  Widget _termsList(
    List<StringPair> terms, {
    bool borderFlag = false,
  }) {
    return ListView.builder(
      padding: const EdgeInsets.only(left: 100.0),
      itemCount: terms.length,
      shrinkWrap: true,
      itemBuilder: (_, int index) {
        return ListTile(
          title: Text(
            terms[index].first,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          shape: (index == terms.length - 1 && borderFlag)
              ? null
              : const Border(
                  bottom: BorderSide(),
                ),
          trailing:
              terms[index].second != null ? Text(terms[index].second!) : null,
        );
      },
    );
  }
}
