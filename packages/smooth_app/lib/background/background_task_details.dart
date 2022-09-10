import 'dart:convert';

import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openfoodfacts/utils/CountryHelper.dart';
import 'package:smooth_app/background/abstract_background_task.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:task_manager/task_manager.dart';

/// Background task that changes product details (data, but no image upload).
class BackgroundTaskDetails extends AbstractBackgroundTask {
  const BackgroundTaskDetails._({
    required super.processName,
    required super.uniqueId,
    required super.barcode,
    required super.languageCode,
    required super.user,
    required super.country,
    required this.inputMap,
  });

  BackgroundTaskDetails._fromJson(Map<String, dynamic> json)
      : this._(
          processName: json['processName'] as String,
          uniqueId: json['uniqueId'] as String,
          barcode: json['barcode'] as String,
          languageCode: json['languageCode'] as String,
          user: json['user'] as String,
          country: json['country'] as String,
          inputMap: json['inputMap'] as String,
        );

  /// Task ID.
  static const String _PROCESS_NAME = 'PRODUCT_EDIT';

  /// Serialized product.
  final String inputMap;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'processName': processName,
        'uniqueId': uniqueId,
        'barcode': barcode,
        'languageCode': languageCode,
        'user': user,
        'country': country,
        'inputMap': inputMap,
      };

  /// Returns the deserialized background task if possible, or null.
  static AbstractBackgroundTask? fromTask(final Task task) {
    try {
      final AbstractBackgroundTask result =
          BackgroundTaskDetails._fromJson(task.data!);
      if (result.processName == _PROCESS_NAME) {
        return result;
      }
    } catch (e) {
      //
    }
    return null;
  }

  /// Adds the background task about changing a product.
  ///
  /// Either [productEditTask] or [productEditTasks] must be populated;
  /// we need that for classification purpose (and unique id computation).
  static Future<void> addTask(
    final Product minimalistProduct, {
    final List<ProductEditTask>? productEditTasks,
    final ProductEditTask? productEditTask,
  }) async {
    final String code;
    if (productEditTask != null) {
      if (productEditTasks != null) {
        throw Exception();
      }
      code = productEditTask.code;
    } else {
      if (productEditTasks == null || productEditTasks.isEmpty) {
        throw Exception();
      }
      final StringBuffer buffer = StringBuffer();
      for (final ProductEditTask task in productEditTasks) {
        buffer.write(task.code);
      }
      code = buffer.toString();
    }
    final String uniqueId = AbstractBackgroundTask.generateUniqueId(
      minimalistProduct.barcode!,
      code,
    );
    final BackgroundTaskDetails backgroundTask = BackgroundTaskDetails._(
      uniqueId: uniqueId,
      processName: _PROCESS_NAME,
      barcode: minimalistProduct.barcode!,
      languageCode: ProductQuery.getLanguage().code,
      inputMap: jsonEncode(minimalistProduct.toJson()),
      user: jsonEncode(ProductQuery.getUser().toJson()),
      country: ProductQuery.getCountry()!.iso2Code,
    );
    await TaskManager().addTask(
      Task(
        data: backgroundTask.toJson(),
        uniqueId: uniqueId,
      ),
    );
  }

  /// Uploads the product changes, downloads the whole product, updates locally.
  @override
  Future<TaskResult> execute(final LocalDatabase localDatabase) async {
    final Map<String, dynamic> productMap =
        json.decode(inputMap) as Map<String, dynamic>;
    final User user =
        User.fromJson(jsonDecode(this.user) as Map<String, dynamic>);

    await OpenFoodAPIClient.saveProduct(
      user,
      Product.fromJson(productMap),
      language: getLanguage(),
      country: getCountry(),
    );

    final DaoProduct daoProduct = DaoProduct(localDatabase);
    final ProductQueryConfiguration configuration = ProductQueryConfiguration(
      barcode,
      fields: ProductQuery.fields,
      language: getLanguage(),
      country: getCountry(),
    );

    final ProductResult queryResult =
        await OpenFoodAPIClient.getProduct(configuration);

    if (queryResult.status == AbstractBackgroundTask.SUCCESS_CODE) {
      final Product? product = queryResult.product;
      if (product != null) {
        await daoProduct.put(product);
        localDatabase.notifyListeners();
      }
    }

    // Returns true to let platform know that the task is completed
    return TaskResult.success;
  }
}

/// Product edit single tasks.
///
/// Used for classification (and unique id computation).
enum ProductEditTask {
  nutrition('N'),
  packaging('P'),
  ingredient('I'),
  basic('B'),
  store('S'),
  origin('O'),
  emb('E'),
  label('L'),
  category('K'),
  country('C');

  const ProductEditTask(this.code);

  /// Code used to distinguish the tasks.
  ///
  /// Of course there shouldn't be duplicates.
  final String code;
}
