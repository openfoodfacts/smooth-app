import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:openfoodfacts/utils/PnnsGroups.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/cards/product_cards/smooth_product_card_found.dart';
import 'package:smooth_app/data_models/product_group_query_model.dart';
import 'package:smooth_app/pages/personalized_ranking_page.dart';
import 'package:smooth_ui_library/animations/smooth_reveal_animation.dart';

class ProductGroupQueryPage extends StatelessWidget {
  const ProductGroupQueryPage(
      {@required this.group, @required this.heroTag, @required this.mainColor});

  final PnnsGroup2 group;
  final String heroTag;
  final Color mainColor;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ProductGroupQueryModel>(
      create: (BuildContext context) => ProductGroupQueryModel(group),
      child: Consumer<ProductGroupQueryModel>(
        builder: (BuildContext context,
            ProductGroupQueryModel productGroupQueryModel, Widget child) {
          return Scaffold(
              floatingActionButton: productGroupQueryModel.products != null &&
                      productGroupQueryModel.products.isNotEmpty
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
                                              productGroupQueryModel.displayProducts,
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
                                            productGroupQueryModel.showTitle
                                                ? 1.0
                                                : 0.0,
                                        duration:
                                            const Duration(milliseconds: 250),
                                        child: Text(group.name,
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
                  if (productGroupQueryModel.products != null)
                    if (productGroupQueryModel.products.isNotEmpty)
                      ListView.builder(
                        itemCount: productGroupQueryModel.displayProducts.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12.0, vertical: 8.0),
                            child: SmoothProductCardFound(
                                    heroTag: productGroupQueryModel
                                        .displayProducts[index].barcode,
                                    product:
                                        productGroupQueryModel.displayProducts[index],
                                    elevation: 4.0)
                                .build(context),
                          );
                        },
                        padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.25),
                        controller: productGroupQueryModel.scrollController,
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
                    opacity: productGroupQueryModel.showTitle ? 1.0 : 0.0,
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
                        if (productGroupQueryModel.products != null)
                          if (productGroupQueryModel.products.isNotEmpty)
                            Container(
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
                            ),
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
