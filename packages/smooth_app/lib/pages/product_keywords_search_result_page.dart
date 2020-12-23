import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/bottom_sheet_views/group_query_filter_view.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_card_found.dart';
import 'package:smooth_app/data_models/product_keywords_search_result_model.dart';
import 'package:smooth_app/pages/personalized_ranking_page.dart';
import 'package:smooth_ui_library/animations/smooth_reveal_animation.dart';

class ProductKeywordsSearchResultPage extends StatelessWidget {
  const ProductKeywordsSearchResultPage(
      {@required this.keywords,
      @required this.heroTag,
      @required this.mainColor});

  final String keywords;
  final String heroTag;
  final Color mainColor;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ProductKeywordsSearchResultModel>(
      create: (BuildContext context) =>
          ProductKeywordsSearchResultModel(keywords, context),
      child: Consumer<ProductKeywordsSearchResultModel>(
        builder: (BuildContext context,
            ProductKeywordsSearchResultModel productKeywordsSearchResultModel,
            Widget child) {
          return Scaffold(
              floatingActionButton:
                  productKeywordsSearchResultModel.products != null &&
                          productKeywordsSearchResultModel.products.isNotEmpty
                      ? SmoothRevealAnimation(
                          animationCurve: Curves.easeInOutBack,
                          startOffset: const Offset(0.0, 1.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.09,
                              ),
                              FloatingActionButton.extended(
                                elevation: 12.0,
                                icon: SvgPicture.asset(
                                  'assets/actions/smoothie.svg',
                                  width: 24.0,
                                  height: 24.0,
                                  color: mainColor,
                                ),
                                label: Text(
                                  'My personalized ranking',
                                  style: TextStyle(color: mainColor),
                                ),
                                backgroundColor: Colors.white,
                                onPressed: () {
                                  Navigator.push<dynamic>(
                                    context,
                                    MaterialPageRoute<dynamic>(
                                        builder: (BuildContext context) =>
                                            PersonalizedRankingPage(
                                              input:
                                                  productKeywordsSearchResultModel
                                                      .displayProducts,
                                            )),
                                  );
                                },
                              ),
                            ],
                          ),
                        )
                      : null,
              body: Stack(
                children: <Widget>[
                  Hero(
                    tag: heroTag,
                    child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        decoration: BoxDecoration(
                          color: mainColor.withAlpha(32),
                          borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(20.0),
                              bottomRight: Radius.circular(20.0)),
                        ),
                        padding: const EdgeInsets.only(
                            left: 10.0, right: 10.0, top: 96.0),
                        child: Column(
                          children: <Widget>[
                            Container(
                              height: 80.0,
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Flexible(
                                    child: AnimatedOpacity(
                                        opacity:
                                            productKeywordsSearchResultModel
                                                    .showTitle
                                                ? 1.0
                                                : 0.0,
                                        duration:
                                            const Duration(milliseconds: 250),
                                        child: Text(keywords,
                                            textAlign: TextAlign.center,
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline1
                                                .copyWith(color: mainColor))),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )),
                  ),
                  if (productKeywordsSearchResultModel.products != null)
                    if (productKeywordsSearchResultModel.products.isNotEmpty)
                      ListView.builder(
                        itemCount: productKeywordsSearchResultModel
                            .displayProducts.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12.0, vertical: 8.0),
                            child: SmoothProductCardFound(
                                    heroTag: productKeywordsSearchResultModel
                                        .displayProducts[index].barcode,
                                    product: productKeywordsSearchResultModel
                                        .displayProducts[index],
                                    elevation: 4.0)
                                .build(context),
                          );
                        },
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.25,
                            bottom: 80.0),
                        controller:
                            productKeywordsSearchResultModel.scrollController,
                      )
                    else
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Flexible(
                              child: Text('No product found in this category',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle1
                                      .copyWith(
                                          color: mainColor, fontSize: 18.0)),
                            ),
                          ],
                        ),
                      )
                  else
                    Center(
                      child: Container(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(mainColor),
                        ),
                      ),
                    ),
                  AnimatedOpacity(
                    opacity:
                        productKeywordsSearchResultModel.showTitle ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 250),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(top: 28.0),
                          child: IconButton(
                            icon: Icon(
                              Icons.arrow_back,
                              color: mainColor,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        if (productKeywordsSearchResultModel.products != null)
                          if (productKeywordsSearchResultModel
                              .products.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 24.0),
                              child: FlatButton.icon(
                                icon: Icon(
                                  Icons.filter_list,
                                  color: mainColor,
                                ),
                                label: const Text('Filter'),
                                textColor: mainColor,
                                onPressed: () {
                                  showCupertinoModalBottomSheet<Widget>(
                                    expand: false,
                                    context: context,
                                    backgroundColor: Colors.transparent,
                                    bounce: true,
                                    barrierColor: Colors.black45,
                                    builder: (BuildContext context,
                                            ScrollController
                                                scrollController) =>
                                        GroupQueryFilterView(
                                      categories:
                                          productKeywordsSearchResultModel
                                              .categories,
                                      categoriesList:
                                          productKeywordsSearchResultModel
                                              .sortedCategories,
                                      callback: productKeywordsSearchResultModel
                                          .selectCategory,
                                    ),
                                  );
                                },
                              ),
                            ),
                        /*Container(
                              margin:
                                  const EdgeInsets.only(top: 28.0, right: 8.0),
                              padding: const EdgeInsets.only(left: 10.0),
                              width: MediaQuery.of(context).size.width * 0.75,
                              decoration: const BoxDecoration(
                                color: Colors.white30,
                                borderRadius: BorderRadius.all(Radius.circular(12.0))
                              ),
                              child: DropdownButton<String>(
                                items: productGroupQueryModel.sortedCategories
                                    .map((String key) {
                                  return DropdownMenuItem<String>(
                                    value: key,
                                    child: Container(
                                      width: MediaQuery.of(context).size.width * 0.65,
                                      child: Text(productGroupQueryModel.categories[key] ?? 'error', style: Theme.of(context)
                                          .textTheme
                                          .bodyText1
                                          .copyWith(
                                          color: mainColor, fontSize: 12.0)),
                                    ),
                                  );
                                }).toList(),
                                value: productGroupQueryModel.selectedCategory,
                                onChanged: (String value) => productGroupQueryModel.selectCategory(value),
                                icon: Icon(Icons.arrow_drop_down, color: mainColor,),
                                underline: Container(),
                              ),
                            ),*/
                      ],
                    ),
                  ),
                ],
              ));
          /**/
        },
      ),
    );
  }
}
