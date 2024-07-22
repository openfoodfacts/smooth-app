import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/database/transient_file.dart';

class _ProductImageHelper {
  const _ProductImageHelper._();

  /// An image is considered outdated/expired after 1 year.
  /// Note: the value will be sent in the future by the backend.
  static bool isExpired(final DateTime? uploadedDate) {
    if (uploadedDate == null) {
      return false;
    }
    return DateTime.now().difference(uploadedDate).inDays > 365;
  }
}

extension ProductImageExtension on ProductImage {
  bool get expired => _ProductImageHelper.isExpired(uploaded);
}

extension TransientFileExtension on TransientFile {
  bool get expired => _ProductImageHelper.isExpired(uploadedDate);
}
