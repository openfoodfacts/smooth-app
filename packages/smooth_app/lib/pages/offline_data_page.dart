import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';

class OfflineDataPage extends StatefulWidget {
  const OfflineDataPage({Key? key}) : super(key: key);

  @override
  State<OfflineDataPage> createState() => _OfflineDataPageState();
}

Future<int> getNoOfProducts(DaoProduct daoProduct) async {
  final int noOfProducts = await daoProduct.getTotalNoOfProducts();
  return noOfProducts;
}

class _OfflineDataPageState extends State<OfflineDataPage> {
  int totalNoOfProducts = 0;
  List<Widget> children = <Widget>[];
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const String headerAsset = 'assets/preferences/main.svg';
    const Color headerColor =  Color(0xFFEBF1FF);
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final double backgroundHeight = MediaQuery.of(context).size.height * .20;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Data'),
      ),
      body: ListView(
        children: <Widget>[
          Container(
            color: dark ? null : headerColor,
            padding: const EdgeInsets.symmetric(vertical: SMALL_SPACE),
            child: SvgPicture.asset(headerAsset, height: backgroundHeight),
          ),
          const OfflineStatsWidget(),
          OfflineDataPageListTile(
              title: 'Offline Product Data',
              subtitle: '100 products available for immediate scaning',
              trailing: const Text('2.5 MB'),
              onTap: () {}),
          const ListTile(
            title: Text('Update Offline Product Data'),
            subtitle: Text(
                'Update the local product database with the latest data from server'),
            trailing: Icon(Icons.refresh),
          ),
          const ListTile(
            title: Text('Clear Offline Product Data'),
            subtitle: Text(
                'Clear all local product data from your app to free up space'),
            trailing: Icon(Icons.delete),
          ),
          const ListTile(
            title: Text('Know More'),
            subtitle: Text('Click to know more about offline data'),
            trailing: Icon(Icons.info),
          ),
        ],
      ),
    );
  }
}

class OfflineStatsWidget extends StatefulWidget {
  const OfflineStatsWidget({Key? key}) : super(key: key);

  @override
  State<OfflineStatsWidget> createState() => _OfflineStatsWidgetState();
}

class _OfflineStatsWidgetState extends State<OfflineStatsWidget> {
  @override
  Widget build(BuildContext context) {
    final LocalDatabase localDatabase = context.read<LocalDatabase>();
    final DaoProduct daoProduct = DaoProduct(localDatabase);
    return ListTile(
      title: const Text('Offline Product Data'),
      subtitle: FutureBuilder<int>(
        future: daoProduct.getTotalNoOfProducts(),
        builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
          if (snapshot.hasData) {
            return Text(
                '${snapshot.data} products available for immediate scaning');
          } else {
            return const Text('0 products available for immediate scaning');
          }
        },
      ),
      trailing: FutureBuilder<double>(
        future: daoProduct.getTotalSizeInMB(),
        builder: (BuildContext context, AsyncSnapshot<double> snapshot) {
          if (snapshot.hasData) {
            return Text('${snapshot.data} MB');
          } else {
            return const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator.adaptive(),
            );
          }
        },
      ),
    );
  }
}

class OfflineDataPageListTile extends StatelessWidget {
  const OfflineDataPageListTile({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.onTap,
    this.localDatabase,
  }) : super(key: key);

  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback onTap;
  final LocalDatabase? localDatabase;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SMALL_SPACE),
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}
