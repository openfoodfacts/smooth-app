import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

class TextWidget extends StatelessWidget {
  const TextWidget();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;

    return ListView.builder(
      itemCount: 999,
      itemBuilder: (BuildContext context, int index) {
        return Text(appLocalizations.plural_ago_days(index));
      },
    );
  }
}

void main() {
  Widget makeTestableWidget({required Locale locale}) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
      home: const TextWidget(),
    );
  }

  testWidgets('Widget', (WidgetTester tester) async {
    await tester.pumpWidget(makeTestableWidget(
      locale: const Locale('en'),
    ));
    await tester.pump();

    expect(find.textContaining('1'), findsOneWidget);
    expect(find.textContaining('1'), findsOneWidget);
  });
}
