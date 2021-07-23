import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smooth_ui_library/navigation/models/smooth_bottom_navigation_bar_item.dart';

class SmoothBottomNavigationBar extends StatefulWidget {
  const SmoothBottomNavigationBar(
    this.items, {
    required this.fabAction,
    Key? key,
  }) : super(key: key);

  final List<SmoothBottomNavigationBarItem> items;
  final VoidCallback fabAction;

  @override
  State<StatefulWidget> createState() => SmoothBottomNavigationBarState();
}

class SmoothBottomNavigationBarState extends State<SmoothBottomNavigationBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _controller.forward(from: 0.0);
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 250));
    _offsetAnimation =
        Tween<Offset>(begin: const Offset(0.0, 2.0), end: Offset.zero)
            .animate(_controller);
    _controller.forward(from: 0.0);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: Center(
        child: widget.items[_selectedIndex].body,
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'action_button',
        child: SvgPicture.asset(
          'assets/actions/scanner_alt_2.svg',
          height: 25,
          color: Theme.of(context).colorScheme.primary,
        ),
        onPressed: () => widget.fabAction(),
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        color: Colors.transparent,
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 4.0,
              sigmaY: 4.0,
            ),
            child: Container(
              color: Colors.transparent,
              child: Row(
                //mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: getBottomAppBarIcons(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> getBottomAppBarIcons() {
    return List<Widget>.generate(
      widget.items.length,
      (int _index) {
        if (_index == _selectedIndex) {
          return buildSelectedItem(_index);
        } else {
          return buildUnselectedItem(_index);
        }
      },
    );
  }

  Widget buildUnselectedItem(int i) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTapped(i),
        child: SizedBox(
          height: 60,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              SvgPicture.asset(
                widget.items[i].iconPath,
                height: 30,
                color: Theme.of(context).colorScheme.secondary,
              ),
              Text(widget.items[i].name),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSelectedItem(int i) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTapped(i),
        child: SizedBox(
          height: 60,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              SvgPicture.asset(
                widget.items[i].iconPath,
                height: 30,
                color: Theme.of(context).colorScheme.secondary,
              ),
              SlideTransition(
                position: _offsetAnimation,
                child: Text(
                  widget.items[i].name,
                  style: Theme.of(context).textTheme.bodyText2!.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
