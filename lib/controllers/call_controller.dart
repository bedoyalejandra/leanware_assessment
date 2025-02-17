import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:leanware_assessment/services/navigation_service.dart';
import 'package:permission_handler/permission_handler.dart';

const appId = "a879f008f7cb4f20bc42bab4e87ca6c4";
const token = "";
const channel = "test-channel";

class CallController {
  late Function refresh;
  User? user;
  late String userId;

  late RtcEngine engine;
  late String roomId;

  bool isSpeakerOn = true;
  bool isAudioOn = true;
  bool isVideoOn = true;
  bool isFrontCameraSelected = true;

  int? remoteUid;
  bool localUserJoined = false;
  bool isSmallVideoLocal = true;

  bool showWarning = false;
  String warning = '';

  Timer? _timer;
  Duration elapsedTime = Duration.zero;
  StreamController<Duration>? _elapsedTimeController;
  Stream<Duration>? get elapsedTimeStream => _elapsedTimeController?.stream;

  void init(
    Function refresh, {
    String? roomId,
  }) {
    this.refresh = refresh;
    this.roomId = roomId ?? generateRoomId().toString();
    _elapsedTimeController = StreamController<Duration>.broadcast();

    FirebaseAuth auth = FirebaseAuth.instance;
    user = auth.currentUser;
    if (user != null) {
      userId = user!.uid;
    }

    initAgora();
  }

  Future<void> dispose() async {
    await engine.leaveChannel();
    await engine.release();
  }

  int generateRoomId() {
    Random random = Random();
    return random.nextInt(9000) + 1000;
  }

  Future<void> initAgora() async {
    await [Permission.microphone, Permission.camera].request();

    engine = createAgoraRtcEngine();
    await engine.initialize(
      const RtcEngineContext(
        appId: appId,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      ),
    );

    agoraEventHandlers();

    await engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await engine.enableVideo();
    await engine.startPreview();

    await engine.joinChannel(
      token: token,
      channelId: roomId,
      uid: 0,
      options: const ChannelMediaOptions(),
    );
  }

  void agoraEventHandlers() {
    engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint('local user ${connection.localUid} joined');
          localUserJoined = true;
          _startTimer();
          refresh();
        },
        onUserJoined: (RtcConnection connection, int? remoteUid, int elapsed) {
          debugPrint('remote user $remoteUid joined');
          this.remoteUid = remoteUid;
          isSmallVideoLocal = false;
          refresh();
        },
        onUserOffline: (RtcConnection connection, int? remoteUid,
            UserOfflineReasonType reason) {
          debugPrint('remote user $remoteUid left channel');

          remoteUid = null;
          refresh();
        },
        onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
          debugPrint(
              '[onTokenPrivilegeWillExpire] connection: ${connection.toJson()}, token: $token');
        },
      ),
    );
  }

  void _startTimer() {
    final startTime = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      var now = DateTime.now();
      var difference = now.difference(startTime);
      elapsedTime = difference;
      _elapsedTimeController?.add(elapsedTime);
      refresh();

      if (difference.inHours >= 1) {
        _timer?.cancel();

        _timer = Timer.periodic(const Duration(minutes: 1), (Timer timer) {
          var now = DateTime.now();
          elapsedTime = now.difference(startTime!);
          _elapsedTimeController?.add(elapsedTime);
          refresh();
        });
      }
    });
  }

  void _showTemporaryWarning(String message) {
    warning = message;
    showWarning = true;

    Future.delayed(const Duration(seconds: 10), () {
      if (warning == message) {
        showWarning = false;
        warning = '';
      }
    });
  }

  Future<void> toggleMic() async {
    isAudioOn = !isAudioOn;
    if (isAudioOn) {
      await engine.muteLocalAudioStream(false);
    } else {
      await engine.muteLocalAudioStream(true);
    }
    refresh();
  }

  Future<void> toggleCamera() async {
    isVideoOn = !isVideoOn;
    if (isVideoOn) {
      await engine.enableVideo();
    } else {
      await engine.disableVideo();
    }
    refresh();
  }

  Future<void> toggleSpeaker() async {
    isSpeakerOn = !isSpeakerOn;
    if (isSpeakerOn) {
      await engine.setEnableSpeakerphone(false);
    } else {
      await engine.setEnableSpeakerphone(true);
    }
    refresh();
  }

  Future<void> switchCamera() async {
    await engine.switchCamera();
    refresh();
  }

  void switchVideos() {
    isSmallVideoLocal = !isSmallVideoLocal;
    refresh();
  }

  Future<void> endCall() async {
    isSmallVideoLocal = false;
    showWarning = false;
    warning = '';
    elapsedTime = Duration.zero;
    _elapsedTimeController?.close();

    await engine.leaveChannel();

    NavigationService.instance.goBack();
  }
}
