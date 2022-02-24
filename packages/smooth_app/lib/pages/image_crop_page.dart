import 'dart:io';
import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/themes/theme_provider.dart';

Future<File?> startImageCropping(BuildContext context) async {
  final Uint8List? bytes = await pickImage();

  if (bytes == null) {
    return null;
  }

  return Navigator.push<File?>(
    context,
    MaterialPageRoute<File?>(
      builder: (BuildContext context) => ImageCropPage(imageBytes: bytes),
    ),
  );
}

Future<Uint8List?> pickImage() async {
  final ImagePicker picker = ImagePicker();

  final XFile? pickedXFile = await picker.pickImage(
    source: ImageSource.camera,
  );
  if (pickedXFile == null) {
    // User didn't pick any image.
    return null;
  }

  return pickedXFile.readAsBytes();
}

class ImageCropPage extends StatelessWidget {
  const ImageCropPage({Key? key, required this.imageBytes}) : super(key: key);

  final Uint8List imageBytes;

  @override
  Widget build(BuildContext context) {
    final CropController _controller = CropController();
    final ThemeData theme = Theme.of(context);
    context.watch<ThemeProvider>();

    return Scaffold(
      body: Crop(
        image: imageBytes,
        controller: _controller,
        onCropped: (Uint8List image) async {
          final Directory tempDir = await getTemporaryDirectory();
          final String tempPath = tempDir.path;
          final String filePath = '$tempPath/upload_img_file.tmp';
          final File file = await File(filePath).writeAsBytes(image);

          Navigator.pop(context, file);
        },
        initialSize: 0.5,
        baseColor: theme.colorScheme.primary,
        maskColor: Colors.white.withAlpha(100),
        cornerDotBuilder: (double size, EdgeAlignment edgeAlignment) =>
            DotControl(color: theme.colorScheme.primary),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.cancel_outlined),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            IconButton(
              icon: const Icon(Icons.done),
              onPressed: () {
                _controller.crop();
              },
            )
          ],
        ),
      ),
    );
  }
}
