import 'dart:convert';
import 'dart:io';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openfoodfacts/utils/CountryHelper.dart';
import 'package:smooth_app/database/dao_product.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/query/product_query.dart';
import 'package:task_manager/task_manager.dart';

///Broadly classify the tasks into 2 categories
/// All the tasks related to image upload
const String IMAGE_UPLOAD_TASK = 'IMAGE_UPLOAD';

/// All the tasks related to product edit
const String PRODUCT_EDIT_TASK = 'PRODUCT_EDIT';

const int SUCESS_CODE = 1;

///Further classify the Product edit tasks more categoreis
/// Constant for ingredient edit task
const String INGREDIENT_EDIT = 'INGREDIENTS_EDIT';

/// Constant for nutrition edit task
const String NUTRITION_EDIT = 'NUTRITION_EDIT';

/// Constant for basic details edit task
const String BASIC_DETAILS = 'BASIC_DETAILS';

/// Runs whenever a task is started in the background.
/// Whatever invoked with TaskManager.addTask() will be run in this method.
/// Gets automatically invoked when there is a task added to the queue and the network conditions are favorable.
Future<TaskResult> callbackDispatcher(
  LocalDatabase localDatabase,
) async {
  await TaskManager().init(
    runTasksInIsolates: false,
    executor: (Task inputData) async {
      final String processName = inputData.data!['processName'] as String;
      switch (processName) {
        case IMAGE_UPLOAD_TASK:
          return uploadImage(inputData.data!, localDatabase);

        case PRODUCT_EDIT_TASK:
          return otherDetails(inputData.data!, localDatabase);

        default:
          return TaskResult.success;
      }
    },
  );
  return TaskResult.success;
}

///  This takes the product json and uploads the data to openfoodfacts server
///  and queries the updated [Product] then it updates the product in the local database
Future<TaskResult> otherDetails(
  Map<String, dynamic> inputData,
  LocalDatabase localDatabase,
) async {
  final BackgroundOtherDetailsInput inputTask =
      BackgroundOtherDetailsInput.fromJson(inputData);
  final Map<String, dynamic> productMap =
      json.decode(inputTask.inputMap) as Map<String, dynamic>;
  final User user =
      User.fromJson(jsonDecode(inputTask.user) as Map<String, dynamic>);
  await OpenFoodAPIClient.saveProduct(
    user,
    Product.fromJson(productMap),
    language: LanguageHelper.fromJson(inputTask.languageCode),
    country: CountryHelper.fromJson(inputTask.country),
  );
  final DaoProduct daoProduct = DaoProduct(localDatabase);
  final ProductQueryConfiguration configuration = ProductQueryConfiguration(
    inputTask.barcode,
    fields: ProductQuery.fields,
    language: LanguageHelper.fromJson(inputTask.languageCode),
    country: CountryHelper.fromJson(inputTask.country),
  );

  final ProductResult queryResult =
      await OpenFoodAPIClient.getProduct(configuration);
  // if queryResult.status = SUCESS_CODE (ie.1) , it means query was sucessful
  if (queryResult.status == SUCESS_CODE) {
    final Product? product = queryResult.product;
    if (product != null) {
      await daoProduct.put(product);
      localDatabase.notifyListeners();
    }
  }
  // Returns true to let platform know that the task is completed
  return TaskResult.success;
}

/// This takes the Image and uploads it to openfoodfacts server
/// and queries the updated [Product] then it updates the product in the local database
Future<TaskResult> uploadImage(
  Map<String, dynamic> inputData,
  LocalDatabase localDatabase,
) async {
  final BackgroundImageInputData inputTask =
      BackgroundImageInputData.fromJson(inputData);
  final User user =
      User.fromJson(jsonDecode(inputTask.user) as Map<String, dynamic>);
  final SendImage image = SendImage(
    lang: LanguageHelper.fromJson(inputTask.languageCode),
    barcode: inputTask.barcode,
    imageField: ImageFieldExtension.getType(inputTask.imageField),
    imageUri: Uri.parse(inputTask.imagePath),
  );
  await OpenFoodAPIClient.addProductImage(user, image);
  // go to the file system and delete the file that was uploaded
  File(inputTask.imagePath).deleteSync();
  final DaoProduct daoProduct = DaoProduct(localDatabase);
  final ProductQueryConfiguration configuration = ProductQueryConfiguration(
    inputTask.barcode,
    fields: ProductQuery.fields,
    language: LanguageHelper.fromJson(inputTask.languageCode),
    country: CountryHelper.fromJson(inputTask.country),
  );

  final ProductResult queryResult =
      await OpenFoodAPIClient.getProduct(configuration);
  // if queryResult.status = SUCESS_CODE (ie.1) , it means query was sucessful
  if (queryResult.status == SUCESS_CODE) {
    final Product? product = queryResult.product;
    if (product != null) {
      await daoProduct.put(product);
      localDatabase.notifyListeners();
    }
  }
  return TaskResult.success;
}

/// Helper class for serialization and deserialization of data for the background task
class BackgroundImageInputData {
  BackgroundImageInputData({
    required this.processName,
    required this.uniqueId,
    required this.barcode,
    required this.imageField,
    required this.imagePath,
    required this.languageCode,
    required this.user,
    required this.country,
  });

  BackgroundImageInputData.fromJson(Map<String, dynamic> json)
      : processName = json['processName'] as String,
        uniqueId = json['uniqueId'] as String,
        barcode = json['barcode'] as String,
        imageField = json['imageField'] as String,
        imagePath = json['imagePath'] as String,
        languageCode = json['languageCode'] as String,
        user = json['user'] as String,
        country = json['country'] as String;

  final String processName;
  final String uniqueId;
  final String barcode;
  final String imageField;
  final String imagePath;
  final String languageCode;
  final String user;
  final String country;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'processName': processName,
        'uniqueId': uniqueId,
        'barcode': barcode,
        'imageField': imageField,
        'imagePath': imagePath,
        'languageCode': languageCode,
        'user': user,
        'country': country,
      };
}

class BackgroundOtherDetailsInput {
  BackgroundOtherDetailsInput({
    required this.processName,
    required this.uniqueId,
    required this.barcode,
    required this.languageCode,
    required this.inputMap,
    required this.user,
    required this.country,
  });
  BackgroundOtherDetailsInput.fromJson(Map<String, dynamic> json)
      : processName = json['processName'] as String,
        uniqueId = json['uniqueId'] as String,
        barcode = json['barcode'] as String,
        languageCode = json['languageCode'] as String,
        inputMap = json['inputMap'] as String,
        user = json['user'] as String,
        country = json['country'] as String;
  final String processName;
  final String uniqueId;
  final String barcode;
  final String languageCode;
  final String inputMap;
  final String user;
  final String country;
  Map<String, dynamic> toJson() => <String, dynamic>{
        'processName': processName,
        'uniqueId': uniqueId,
        'barcode': barcode,
        'languageCode': languageCode,
        'inputMap': inputMap,
        'user': user,
        'country': country,
      };
}

/// Generates a unique id for the background task
/// This ensures that the background task is unique and also
/// ensures that in case of conflict the background task is replaced
/// Example: 00000000_BASIC_DETAILS_en_us_"random_user_id"
class UniqueIdGenerator {
  const UniqueIdGenerator._();
  static String generateUniqueId(
    String barcode,
    String processIdentifier,
  ) {
    final StringBuffer stringBuffer = StringBuffer();
    stringBuffer
      ..write(barcode)
      ..write('_')
      ..write(processIdentifier)
      ..write('_')
      ..write(ProductQuery.getLanguage().code)
      ..write('_')
      ..write(ProductQuery.getCountry()!.iso2Code)
      ..write('_')
      ..write(ProductQuery.getUser().userId);
    return stringBuffer.toString();
  }
}
