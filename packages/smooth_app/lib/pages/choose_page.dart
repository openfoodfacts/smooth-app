import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:openfoodfacts/utils/PnnsGroups.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/cards/category_cards/category_card.dart';
import 'package:smooth_app/cards/category_cards/category_chip.dart';
import 'package:smooth_app/cards/category_cards/subcategory_card.dart';
import 'package:smooth_app/data_models/choose_page_model.dart';
import 'package:smooth_app/pages/product_group_query_page.dart';
import 'package:smooth_ui_library/widgets/smooth_search_bar.dart';
import 'package:smooth_app/generated/l10n.dart';

class ChoosePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ChoosePageModel>(
      create: (BuildContext context) => ChoosePageModel(),
      child: Consumer<ChoosePageModel>(builder: (BuildContext context,
          ChoosePageModel choosePageModel, Widget child) {
        return WillPopScope(
            onWillPop: choosePageModel.onWillPop,
            child: Scaffold(
              body: NestedScrollView(
                  controller: choosePageModel.scrollController,
                  headerSliverBuilder:
                      (BuildContext context, bool innerBoxIsScrolled) {
                    return <Widget>[
                      SliverAppBar(
                        expandedHeight: 248.0,
                        backgroundColor: Theme.of(context).scaffoldBackgroundColor,//choosePageModel.appBarColor,
                        pinned: true,
                        elevation: 8.0,
                        /*title: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text('Smoothie', style: Theme.of(context).textTheme.headline2.copyWith(color: Colors.black.withOpacity(choosePageModel.opacity)),),
                        ),*/
                        centerTitle: true,
                        flexibleSpace: FlexibleSpaceBar(
                          collapseMode: CollapseMode.parallax,
                          background: Column(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 46.0,
                                    right: 16.0,
                                    left: 16.0,
                                    bottom: 4.0),
                                child: Row(
                                  children: <Widget>[
                                    Flexible(
                                      child: Text(
                                        S.of(context).searchTitle,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline1,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 12.0),
                                child: SmoothSearchBar(
                                  hintText: S.of(context).searchHintText,
                                ),
                              ),
                            ],
                          ),
                        ),
                        bottom: PreferredSize(
                          preferredSize:
                              Size(MediaQuery.of(context).size.width, 20.0),
                          child: Container(
                            padding: const EdgeInsets.only(
                              left: 12.0,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor, //choosePageModel.appBarColor,
                              /*boxShadow: <BoxShadow>[
                                BoxShadow(color: Colors.black.withOpacity(choosePageModel.opacity / 8.0), offset: const Offset(0.0, 6.0), blurRadius: 4.0),
                              ],*/
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Flexible(
                                  child: Text(
                                    S.of(context).categories,
                                    style:
                                        Theme.of(context).textTheme.headline3,
                                  ),
                                ),
                                MaterialButton(
                                  child: Text(
                                    S.of(context).showAll,
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle1
                                        .copyWith(color: Colors.black),
                                  ),
                                  onPressed: () {
                                    choosePageModel.unSelectCategory();
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ];
                  },
                  body: Column(
                    children: <Widget>[
                      Consumer<ChoosePageModel>(builder: (BuildContext context,
                          ChoosePageModel choosePageModel, Widget child) {
                        if (choosePageModel.selectedCategory != null) {
                          return Container(
                            padding: const EdgeInsets.only(bottom: 0.0),
                            width: MediaQuery.of(context).size.width,
                            height: 100.0,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: List<Widget>.generate(
                                  PnnsGroup1.values.length, (int index) {
                                final PnnsGroup1 group =
                                    PnnsGroup1.values[index];
                                final Color color = choosePageModel.colors[
                                    index % choosePageModel.colors.length];
                                return AnimationConfiguration.staggeredList(
                                  position: index,
                                  duration: const Duration(milliseconds: 250),
                                  child: SlideAnimation(
                                    verticalOffset: 50.0,
                                    child: FadeInAnimation(
                                        child: CategoryChip(
                                      title: group.name,
                                      color: color,
                                      onTap: () {
                                        choosePageModel.selectCategory(
                                            group, color);
                                      },
                                    )),
                                  ),
                                );
                              }),
                            ),
                          );
                        }
                        return Container();
                      }),
                      Expanded(
                        child: Consumer<ChoosePageModel>(builder:
                            (BuildContext context,
                                ChoosePageModel choosePageModel, Widget child) {
                          if (choosePageModel.selectedCategory == null) {
                            return GridView.count(
                              crossAxisCount: 2,
                              childAspectRatio: 3 / 2,
                              padding: const EdgeInsets.only(
                                  top: 10.0,
                                  bottom: 80.0,
                                  right: 10.0,
                                  left: 10.0),
                              mainAxisSpacing: 20.0,
                              crossAxisSpacing: 10.0,
                              children: List<Widget>.generate(
                                PnnsGroup1.values.length,
                                (int index) {
                                  final PnnsGroup1 group =
                                      PnnsGroup1.values[index];
                                  final Color color = choosePageModel.colors[
                                      index % choosePageModel.colors.length];
                                  return AnimationConfiguration.staggeredGrid(
                                    position: index,
                                    duration: const Duration(milliseconds: 400),
                                    columnCount: 2,
                                    child: ScaleAnimation(
                                      child: FadeInAnimation(
                                        child: CategoryCard(
                                          title: group.name,
                                          color: color,
                                          iconName: choosePageModel
                                              .getCategoryIcon(group),
                                          onTap: () {
                                            choosePageModel.selectCategory(
                                                group, color);
                                          },
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          }
                          return ListView(
                            padding:
                                const EdgeInsets.only(top: 8.0, bottom: 80.0),
                            children: List<Widget>.generate(
                                choosePageModel.selectedCategory.subGroups
                                    .length, (int index) {
                              return AnimationConfiguration.staggeredList(
                                position: index,
                                duration: const Duration(milliseconds: 250),
                                child: SlideAnimation(
                                  horizontalOffset: 50.0,
                                  child: FadeInAnimation(
                                      child: SubcategoryCard(
                                    heroTag: choosePageModel
                                        .selectedCategory.subGroups[index].name,
                                    title: choosePageModel
                                        .selectedCategory.subGroups[index].name,
                                    color: choosePageModel.selectedColor,
                                    onTap: () {
                                      Navigator.push<dynamic>(
                                          context,
                                          MaterialPageRoute<dynamic>(
                                              builder: (BuildContext context) =>
                                                  ProductGroupQueryPage(
                                                      heroTag: choosePageModel
                                                          .selectedCategory
                                                          .subGroups[index]
                                                          .name,
                                                      mainColor: choosePageModel
                                                          .selectedColor,
                                                      group: choosePageModel
                                                          .selectedCategory
                                                          .subGroups[index])));
                                    },
                                  )),
                                ),
                              );
                            }),
                          );
                        }),
                      )
                    ],
                  )),
            ));
      }),
    );
  }
}
