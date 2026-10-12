/// Result of an image crop operation for image upload background tasks.
class BackgroundCropResult {
  BackgroundCropResult.success({
    required String this.filePath,
    required int this.fileSize,
    required int this.width,
    required int this.height,
    required this.message,
  }) : isError = false;

  BackgroundCropResult.error(this.message)
    : filePath = null,
      fileSize = null,
      width = null,
      height = null,
      isError = true;

  final String? filePath;
  final int? fileSize;
  final int? width;
  final int? height;
  final String message;
  final bool isError;

  @override
  String toString() {
    return 'BackgroundCropResult(error: $isError'
        ', message: $message'
        ', fileSize: $fileSize'
        ', imageSize: ${width}x$height'
        ')';
  }
}
