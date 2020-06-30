import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/cards/category_cards/category_card.dart';
import 'package:smooth_app/cards/category_cards/category_chip.dart';
import 'package:smooth_app/cards/category_cards/subcategory_card.dart';
import 'package:smooth_app/data_models/choose_page_model.dart';
import 'package:smooth_ui_library/widgets/smooth_search_bar.dart';

class ChoosePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ChangeNotifierProvider<ChoosePageModel>(
            create: (BuildContext context) => ChoosePageModel(),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                      top: 46.0, right: 16.0, left: 16.0, bottom: 4.0),
                  child: Row(
                    children: <Widget>[
                      Flexible(
                        child: Text(
                          'Search.\nFind the perfect product',
                          style: Theme.of(context).textTheme.headline1,
                        ),
                      )
                    ],
                  ),
                ),
                const Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: SmoothSearchBar(
                    hintText: 'Enter a barcode, category or product name',
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 12.0,
                    right: 12.0,
                    top: 8.0,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Flexible(
                        child: Text(
                          'Categories',
                          style: Theme.of(context).textTheme.headline3,
                        ),
                      ),
                      Consumer<ChoosePageModel>(builder: (BuildContext context,
                          ChoosePageModel choosePageModel, Widget child) {
                        return MaterialButton(
                          child: Text(
                            'Show all',
                            style: Theme.of(context)
                                .textTheme
                                .subtitle1
                                .copyWith(color: Colors.black),
                          ),
                          onPressed: () {
                            choosePageModel.unSelectCategory();
                          },
                        );
                      }),
                    ],
                  ),
                ),
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
                            choosePageModel.categories.length, (int index) {
                          final String key =
                              choosePageModel.categories.keys.toList()[index];
                          return AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: 250),
                            child: SlideAnimation(
                              verticalOffset: 50.0,
                              child: FadeInAnimation(
                                  child: CategoryChip(
                                title: key,
                                color: choosePageModel.categories[key],
                                onTap: () {
                                  choosePageModel.selectCategory(key);
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
                      (BuildContext context, ChoosePageModel choosePageModel,
                          Widget child) {
                    if (choosePageModel.selectedCategory == null) {
                      return GridView.count(
                        crossAxisCount: 2,
                        childAspectRatio: 3 / 2,
                        padding: const EdgeInsets.only(
                            top: 10.0, bottom: 120.0, right: 10.0, left: 10.0),
                        mainAxisSpacing: 20.0,
                        crossAxisSpacing: 10.0,
                        children: List<Widget>.generate(
                          choosePageModel.categories.length,
                          (int index) {
                            final String key =
                                choosePageModel.categories.keys.toList()[index];
                            return AnimationConfiguration.staggeredGrid(
                              position: index,
                              duration: const Duration(milliseconds: 400),
                              columnCount: 2,
                              child: ScaleAnimation(
                                child: FadeInAnimation(
                                  child: CategoryCard(
                                    title: key,
                                    color: choosePageModel.categories[key],
                                    onTap: () {
                                      choosePageModel.selectCategory(key);
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
                      padding: const EdgeInsets.only(top: 8.0, bottom: 100.0),
                      children: List<Widget>.generate(
                          choosePageModel
                              .subCategories[choosePageModel.selectedCategory]
                              .length, (int index) {
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 250),
                          child: SlideAnimation(
                            horizontalOffset: 50.0,
                            child: FadeInAnimation(
                                child: SubcategoryCard(
                              title: choosePageModel.subCategories[
                                  choosePageModel.selectedCategory][index],
                              color: choosePageModel
                                  .categories[choosePageModel.selectedCategory],
                            )),
                          ),
                        );
                      }),
                    );
                  }),
                )
              ],
            )));
  }
}
