import 'package:flutter/material.dart';

class CopyToListView extends StatelessWidget {
  const CopyToListView(
    this._scrollController, {
    this.callback,
    @required this.children,
  });

  final ScrollController _scrollController;
  final Function callback;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.9,
        child: Stack(
          children: <Widget>[
            Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Container(
                  height: MediaQuery.of(context).size.height * 0.9,
                  child: ListView(
                    controller: _scrollController,
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        margin: const EdgeInsets.only(top: 20.0, bottom: 24.0),
                        child: Text(
                          'Copy to:',
                          style: Theme.of(context).textTheme.headline1,
                        ),
                      ),
                      Wrap(
                        direction: Axis.horizontal,
                        children: children,
                        spacing: 8.0,
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.15,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
