import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:openfoodfacts/utils/PnnsGroups.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/cards/category_cards/category_card.dart';
import 'package:smooth_app/cards/category_cards/category_chip.dart';
import 'package:smooth_app/cards/category_cards/subcategory_card.dart';
import 'package:smooth_app/data_models/choose_page_model.dart';
import 'package:smooth_app/database/full_products_database.dart';
import 'package:smooth_app/database/keywords_product_query.dart';
import 'package:smooth_app/database/group_product_query.dart';
import 'package:smooth_app/pages/product_query_page.dart';
import 'package:smooth_app/pages/product_page.dart';
import 'package:smooth_ui_library/widgets/smooth_search_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ChoosePage extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ChoosePageModel>(
      create: (BuildContext context) => ChoosePageModel(),
      child: Consumer<ChoosePageModel>(builder: (BuildContext context,
          ChoosePageModel choosePageModel, Widget child) {
        return WillPopScope(
            onWillPop: choosePageModel.onWillPop,
            child: Scaffold(
              key: _scaffoldKey,
              body: NestedScrollView(
                  controller: choosePageModel.scrollController,
                  headerSliverBuilder:
                      (BuildContext context, bool innerBoxIsScrolled) {
                    return <Widget>[
                      SliverAppBar(
                        expandedHeight: 248.0,
                        backgroundColor: Theme.of(context)
                            .scaffoldBackgroundColor, //choosePageModel.appBarColor,
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
                                        AppLocalizations.of(context)
                                            .searchTitle,
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
                                  color:
                                      Theme.of(context).dialogBackgroundColor,
                                  hintText: AppLocalizations.of(context)
                                      .searchHintText,
                                  onSubmitted: (String value) {
                                    if (int.parse(value,
                                            onError: (String e) => null) !=
                                        null) {
                                      showDialog<Widget>(
                                          context: context,
                                          builder: (BuildContext context) {
                                            barcodeSearch(value, context);
                                            return Dialog(
                                                backgroundColor:
                                                    Colors.transparent,
                                                child: ClipRRect(
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(
                                                                20.0)),
                                                    child: BackdropFilter(
                                                      filter: ImageFilter.blur(
                                                        sigmaX: 4.0,
                                                        sigmaY: 4.0,
                                                      ),
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(12.0),
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.8,
                                                        height: 120.0,
                                                        decoration:
                                                            const BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          20.0)),
                                                          color: Colors.white70,
                                                        ),
                                                        child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .max,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: <Widget>[
                                                              Text(
                                                                  'Looking for : $value'),
                                                              const SizedBox(
                                                                height: 24.0,
                                                              ),
                                                              const CircularProgressIndicator(),
                                                            ]),
                                                      ),
                                                    )));
                                          });
                                    } else {
                                      Navigator.push<dynamic>(
                                          context,
                                          MaterialPageRoute<dynamic>(
                                              builder: (BuildContext context) =>
                                                  ProductQueryPage(
                                                    productQuery:
                                                        KeywordsProductQuery(
                                                            value),
                                                    heroTag: 'search_bar',
                                                    mainColor:
                                                        Colors.deepPurple,
                                                    name: value,
                                                  )));
                                    }
                                  },
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
                              color: Theme.of(context)
                                  .scaffoldBackgroundColor, //choosePageModel.appBarColor,
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
                                    AppLocalizations.of(context).categories,
                                    style:
                                        Theme.of(context).textTheme.headline3,
                                  ),
                                ),
                                MaterialButton(
                                  child: Text(
                                    AppLocalizations.of(context).showAll,
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
                                    onTap: () => Navigator.push<dynamic>(
                                        context, MaterialPageRoute<dynamic>(
                                            builder: (BuildContext context) {
                                      final PnnsGroup2 group = choosePageModel
                                          .selectedCategory.subGroups[index];
                                      return ProductQueryPage(
                                        productQuery: GroupProductQuery(group),
                                        heroTag: group.id,
                                        mainColor:
                                            choosePageModel.selectedColor,
                                        name: group.name,
                                      );
                                    })),
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

  Future<void> barcodeSearch(String code, BuildContext context) async {
    final FullProductsDatabase productsDatabase = FullProductsDatabase();

    final bool result = await productsDatabase.checkAndFetchProduct(code);

    if (result) {
      final Product product = await productsDatabase.getProduct(code);
      Navigator.pop(context);
      Navigator.push<dynamic>(
          context,
          MaterialPageRoute<dynamic>(
              builder: (BuildContext context) => ProductPage(
                    product: product,
                  )));
    } else {
      Navigator.pop(context);
      showDialog<Widget>(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
                backgroundColor: Colors.transparent,
                child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: 4.0,
                        sigmaY: 4.0,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(12.0),
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: 120.0,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(20.0)),
                          color: Colors.white70,
                        ),
                        child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Flexible(
                                    child: Text(
                                      'No product found with matching barcode : $code',
                                      textAlign: TextAlign.center,
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 24.0,
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.3,
                                      height: 40.0,
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(50.0)),
                                        color: Colors.redAccent.withAlpha(50),
                                      ),
                                      child: Center(
                                        child: Text(
                                          'Close',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline4
                                              .copyWith(
                                                  color: Colors.redAccent),
                                        ),
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.3,
                                      height: 40.0,
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(50.0)),
                                        color: Colors.lightBlue.withAlpha(50),
                                      ),
                                      child: Center(
                                        child: Text(
                                          'Contribute',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline4
                                              .copyWith(
                                                  color: Colors.lightBlue),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ]),
                      ),
                    )));
          });
    }
  }
}
