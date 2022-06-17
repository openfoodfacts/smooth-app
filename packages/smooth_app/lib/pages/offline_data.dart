// ignore_for_file: avoid_dynamic_calls

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/local_database.dart';

class OfflineDataScreen extends StatefulWidget {
  const OfflineDataScreen();
  @override
  State<OfflineDataScreen> createState() => _OfflineDataScreenState();
}

int length = 0;
double size = 0;

class _OfflineDataScreenState extends State<OfflineDataScreen> {
  Future<void> getDetails(DaoProduct daoProduct) async {
    length = await daoProduct.getLength() ?? 0;
    size = await daoProduct.getSize();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final DaoProduct daoProduct = DaoProduct(context.watch<LocalDatabase>());
    getDetails(daoProduct);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Data'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            ListTile(
              dense: true,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(Icons.refresh),
                  IconButton(
                    onPressed: () async {
                      final int noOdDeletedProducts =
                          await daoProduct.clearAll();
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              '$noOdDeletedProducts products deleted, freed $size Mb'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.delete),
                  ),
                ],
              ),
              title: Text(
                'Offline Product Data',
                style: Theme.of(context).textTheme.headline3,
              ),
              subtitle: Text(
                '$length products available for immediate scan \nApproximate disk space used: $size Mb',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
