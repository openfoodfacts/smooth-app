import 'dart:html' as html;

class CameraWebHelper {
  late html.VideoElement _videoElement;

  Future<void> initialize() async {
    _videoElement = html.VideoElement();
    final html.MediaStream stream = await html.window.navigator.getUserMedia(
      video: true,
    );
    _videoElement.srcObject = stream;
    await _videoElement.play();
  }

  html.VideoElement get videoElement => _videoElement;
}
