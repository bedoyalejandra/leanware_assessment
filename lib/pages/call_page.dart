import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:leanware_assessment/utils/functions/relative_time_util.dart';
import 'package:native_device_orientation/native_device_orientation.dart';

import '../controllers/call_controller.dart';
import '../widgets/call_controlls.dart';

class CallPage extends StatefulWidget {
  const CallPage({this.roomId, Key? key}) : super(key: key);
  final String? roomId;

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  CallController controller = CallController();

  Offset _smallVideoPosition = const Offset(20, 20);

  late Size _screenSize;
  int controllersSize = 120;
  double smallVideoHeight = 150;
  double smallVideoWidth = 120;
  double controllersHeight = 110;

  double bottomPadding = 0;
  double screenWidth = 300;
  double screenHeight = 300;

  NativeDeviceOrientation orientation = NativeDeviceOrientation.portraitUp;

  @override
  void initState() {
    super.initState();
    controller.init(refresh, roomId: widget.roomId);
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: kIsWeb
            ? AppBar(
                title: Text(controller.roomId),
                automaticallyImplyLeading: false,
              )
            : null,
        body: kIsWeb ? _webLayout() : _mobileLayout(),
      );

  Widget _webLayout() {
    return Stack(
      children: [
        Row(
          children: [
            Expanded(child: _localVideo()),
            Expanded(child: _remoteVideo()),
          ],
        ),
        _floatingControls(),
      ],
    );
  }

  Widget _mobileLayout() {
    return NativeDeviceOrientationReader(
      builder: (context) {
        NativeDeviceOrientation newOrientation =
            NativeDeviceOrientationReader.orientation(context);
        _screenSize = MediaQuery.of(context).size;
        screenWidth = MediaQuery.of(context).size.width;
        screenHeight = MediaQuery.of(context).size.height;

        if (newOrientation == NativeDeviceOrientation.landscapeLeft ||
            newOrientation == NativeDeviceOrientation.landscapeRight) {
          SystemChrome.setEnabledSystemUIMode(
            SystemUiMode.manual,
            overlays: [SystemUiOverlay.bottom],
          );
        } else {
          SystemChrome.setEnabledSystemUIMode(
            SystemUiMode.manual,
            overlays: SystemUiOverlay.values,
          );
        }

        double buttonSize = orientation == NativeDeviceOrientation.portraitUp
            ? screenWidth * 0.13
            : (screenHeight - MediaQuery.of(context).padding.top) * 0.11;

        if (newOrientation != orientation) {
          _updateVideoPositionForNewOrientation(newOrientation);
          orientation = newOrientation;
        }

        return Stack(
          children: [
            if (controller.isSmallVideoLocal) _remoteVideo() else _localVideo(),
            Positioned(
              left: _smallVideoPosition.dx,
              top: _smallVideoPosition.dy,
              child: GestureDetector(
                onTap: controller.switchVideos,
                onPanUpdate: _updatePosition,
                onPanEnd: _snapToNearestEdge,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    height: smallVideoHeight,
                    width: smallVideoWidth,
                    child: controller.isSmallVideoLocal
                        ? _localVideo()
                        : _remoteVideo(),
                  ),
                ),
              ),
            ),
            Positioned(
              top: orientation == NativeDeviceOrientation.portraitUp
                  ? MediaQuery.of(context).padding.top
                  : 10,
              left: MediaQuery.of(context).padding.left,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.roomId,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                      StreamBuilder<Duration>(
                        stream: controller.elapsedTimeStream,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Text(
                              formatDuration(snapshot.data!),
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            );
                          } else {
                            return const SizedBox.shrink();
                          }
                        },
                      ),
                      if (controller.showWarning)
                        Container(
                          margin: const EdgeInsets.only(top: 10),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey[100]?.withOpacity(0.3),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.warning,
                                color: Colors.yellow,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                controller.warning,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: orientation == NativeDeviceOrientation.portraitUp
                  ? 150 + bottomPadding
                  : 10,
              right: orientation == NativeDeviceOrientation.portraitUp
                  ? 10
                  : orientation == NativeDeviceOrientation.landscapeRight
                      ? controllersHeight + MediaQuery.of(context).padding.left
                      : controllersHeight,
              child: Row(
                children: [
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: controller.switchOnBlur,
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(255, 159, 159, 159)!
                                .withOpacity(0.5),
                            blurRadius: 2,
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          controller.blurBackground
                              ? Icons.blur_off
                              : Icons.blur_on,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (orientation == NativeDeviceOrientation.portraitUp)
              _bottomControls(buttonSize)
            else
              _rigthControls(buttonSize),
          ],
        );
      },
    );
  }

  Widget _localVideo() {
    if (controller.localUserJoined) {
      return AgoraVideoView(
        controller: VideoViewController(
          rtcEngine: controller.engine,
          canvas: const VideoCanvas(uid: 0),
        ),
      );
    } else {
      return SizedBox(
        width: kIsWeb ? 50 : 100,
        height: kIsWeb ? 50 : 100,
        child: const Center(child: CircularProgressIndicator(strokeWidth: 3)),
      );
    }
  }

  Widget _remoteVideo() {
    if (controller.remoteUid != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: controller.engine,
          canvas: VideoCanvas(uid: controller.remoteUid),
          connection: RtcConnection(channelId: controller.roomId),
        ),
      );
    } else {
      return const Center(
        child: Text(
          'Waiting for another user',
          textAlign: TextAlign.center,
        ),
      );
    }
  }

  Widget _rigthControls(double buttonSize) => Positioned(
        bottom: 0,
        top: 0,
        right: 0,
        child: Container(
          padding: const EdgeInsets.only(
            top: 10,
            bottom: 10,
          ),
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 100, 100, 100),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
          ),
          child: SafeArea(
            bottom: false,
            top: false,
            right: orientation == NativeDeviceOrientation.landscapeRight,
            left: false,
            child: Padding(
              padding: const EdgeInsets.only(
                left: 10,
                right: 10,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  speakerButton(controller, buttonSize),
                  cameraButton(controller, buttonSize),
                  muteButton(controller, buttonSize),
                  flipButton(controller, buttonSize),
                  hangUpButton(controller, buttonSize),
                ],
              ),
            ),
          ),
        ),
      );

  Widget _bottomControls(double buttonSize) => Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Container(
          padding: const EdgeInsets.only(top: 25, bottom: 10),
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 100, 100, 100),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                speakerButton(controller, buttonSize),
                cameraButton(controller, buttonSize),
                muteButton(controller, buttonSize),
                flipButton(controller, buttonSize),
                hangUpButton(controller, buttonSize),
              ],
            ),
          ),
        ),
      );

  Widget _floatingControls() {
    double buttonSize = screenWidth * 0.13;
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: EdgeInsets.only(bottom: 20),
        height: 100,
        width: MediaQuery.of(context).size.width * 0.5,
        padding: const EdgeInsets.only(top: 25, bottom: 10),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 100, 100, 100),
          borderRadius: BorderRadius.circular(16),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              speakerButton(controller, buttonSize),
              cameraButton(controller, buttonSize),
              muteButton(controller, buttonSize),
              flipButton(controller, buttonSize),
              // blurButton(controller, buttonSize),
              hangUpButton(controller, buttonSize),
            ],
          ),
        ),
      ),
    );
  }

  // Adjust the small video position when the orientation changes
  void _updateVideoPositionForNewOrientation(
    NativeDeviceOrientation newOrientation,
  ) {
    if (newOrientation == NativeDeviceOrientation.landscapeLeft ||
        newOrientation == NativeDeviceOrientation.landscapeRight) {
      double screenWidth = _screenSize.height > _screenSize.width
          ? _screenSize.height
          : _screenSize.width;
      double maxX = screenWidth - smallVideoWidth - controllersHeight;

      _smallVideoPosition = Offset(maxX, 0);
    } else {
      double screenWidth = _screenSize.height > _screenSize.width
          ? _screenSize.width
          : _screenSize.height;
      double maxX = screenWidth - smallVideoWidth;

      _smallVideoPosition = Offset(maxX, MediaQuery.of(context).padding.right);
    }
  }

  void _updatePosition(DragUpdateDetails details) {
    double maxX = _screenSize.width;
    double maxY = _screenSize.height;
    if (orientation == NativeDeviceOrientation.portraitUp) {
      maxX = _screenSize.width - smallVideoWidth;
      maxY = _screenSize.height -
          smallVideoHeight -
          controllersHeight -
          MediaQuery.of(context).padding.bottom;
    } else {
      maxX = _screenSize.width -
          smallVideoWidth -
          controllersHeight -
          10; // 10 corresponding of the padding
      maxY = _screenSize.height - smallVideoHeight;
    }
    setState(() {
      Offset newPosition = _smallVideoPosition + details.delta;
      double newX =
          newPosition.dx.clamp(MediaQuery.of(context).padding.right, maxX);
      double newY =
          newPosition.dy.clamp(MediaQuery.of(context).padding.top, maxY);
      _smallVideoPosition = Offset(newX, newY);
    });
  }

  void _snapToNearestEdge(DragEndDetails details) {
    double leftDistance = _smallVideoPosition.dx;
    double rightDistance =
        _screenSize.width - _smallVideoPosition.dx - smallVideoWidth;
    double topDistance = _smallVideoPosition.dy;
    double bottomDistance =
        _screenSize.height - _smallVideoPosition.dy - smallVideoHeight;
    double minXDistance =
        leftDistance < rightDistance ? leftDistance : rightDistance;
    double minYDistance =
        topDistance < bottomDistance ? topDistance : bottomDistance;

    double bottomLimit = _screenSize.height - smallVideoHeight;

    if (orientation == NativeDeviceOrientation.portraitUp) {
      bottomDistance -= controllersHeight;
      bottomLimit -= controllersHeight;
    }
    setState(() {
      if (minXDistance < minYDistance) {
        if (leftDistance < rightDistance) {
          _smallVideoPosition = Offset(
            MediaQuery.of(context).padding.right,
            _smallVideoPosition.dy,
          );
        } else {
          _smallVideoPosition = Offset(
            _screenSize.width - smallVideoWidth,
            _smallVideoPosition.dy,
          );
        }
      } else {
        if (topDistance < bottomDistance) {
          _smallVideoPosition = Offset(
            _smallVideoPosition.dx,
            MediaQuery.of(context).padding.top,
          ); // Prevent hiding under top bar
        } else {
          _smallVideoPosition = Offset(
            _smallVideoPosition.dx,
            bottomLimit,
          ); // Prevent hiding under bottom container
        }
      }
    });
  }

  void refresh() {
    if (mounted) {
      setState(() {});
    }
  }
}
