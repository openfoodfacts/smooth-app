import 'dart:io';
import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/themes/theme_provider.dart';

class ImageCropPage extends StatelessWidget {
  ImageCropPage({Key? key}) : super(key: key);

  final CropController _controller = CropController();
  final ImagePicker picker = ImagePicker();

  Future<Uint8List?> pickImage() async {
    final XFile? pickedXFile = await picker.pickImage(
      source: ImageSource.camera,
    );
    if (pickedXFile == null) {
      // User didn't pick any image.
      return null;
    }

    return pickedXFile.readAsBytes();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    context.watch<ThemeProvider>();

    return Scaffold(
        body: FutureBuilder<Uint8List?>(
          future: pickImage(),
          builder: (
            BuildContext context,
            AsyncSnapshot<Uint8List?> snap,
          ) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snap.data == null) {
              Navigator.pop(context);
            }

            return Crop(
              image: snap.data!,
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
            );
          },
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
        ));
  }
}
