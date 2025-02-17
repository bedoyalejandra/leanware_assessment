import 'dart:async';
import 'dart:math';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:leanware_assessment/services/navigation_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  bool blurBackground = false;

  bool showWarning = false;
  String warning = '';
  String? status;

  DateTime? startTime;
  Timer? _timer;
  Duration elapsedTime = Duration.zero;
  StreamController<Duration>? _elapsedTimeController;
  Stream<Duration>? get elapsedTimeStream => _elapsedTimeController?.stream;

  StreamSubscription<DocumentSnapshot>? _callStatusSubscription;
  FirebaseFirestore db = FirebaseFirestore.instance;

  void init(
    Function refresh, {
    String? roomId,
  }) {
    this.refresh = refresh;
    _elapsedTimeController = StreamController<Duration>.broadcast();

    FirebaseAuth auth = FirebaseAuth.instance;
    user = auth.currentUser;
    if (user != null) {
      userId = user!.uid;
    }

    startCall(roomId);
    initAgora();
  }

  Future<void> dispose() async {
    endCall();
  }

  int generateRoomId() {
    Random random = Random();
    return random.nextInt(9000) + 1000;
  }

  void startCall(String? roomId) {
    if (roomId != null) {
      this.roomId = roomId;
      joinRoom();
    } else {
      this.roomId = generateRoomId().toString();
      createRoom();
    }
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
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      var now = DateTime.now();
      var difference = now.difference(startTime!);
      elapsedTime = difference;
      _elapsedTimeController?.add(elapsedTime);

      // After one hour, update the timer every minute.
      if (difference.inHours >= 1) {
        _timer?.cancel();
        _timer = Timer.periodic(const Duration(minutes: 1), (Timer timer) {
          var now = DateTime.now();
          elapsedTime = now.difference(startTime!);
          _elapsedTimeController?.add(elapsedTime);
          refresh();
        });
      }

      refresh();
    });
  }

  Future<void> createRoom() async {
    DocumentReference roomRef = db.collection('Rooms').doc(roomId);
    await roomRef.set({'status': 'created'});
    getRoomDetails(roomId);
    startTimeOutTimer();
  }

  void startTimeOutTimer() {
    Future.delayed(const Duration(minutes: 1), () {
      if (status == 'created') {
        _showTemporaryWarning('2 minutes remaining');
      }
    });
    Future.delayed(const Duration(minutes: 8), () {
      if (status == 'created') {
        _showTemporaryWarning('2 minutes remaining');
      }
    });

    Future.delayed(const Duration(minutes: 9, seconds: 30), () {
      if (status == 'created') {
        _startCountdown(30);
      }
    });

    Future.delayed(const Duration(minutes: 10), () {
      if (status == 'created') {
        endCall();
      }
    });
  }

  void _startCountdown(int seconds) {
    if (seconds <= 0) return;
    warning = '${seconds} seconds remaining';
    showWarning = true;
    refresh();

    Future.delayed(const Duration(seconds: 1), () {
      if (status == 'created') {
        _startCountdown(seconds - 1);
      } else {
        showWarning = false;
        warning = '';
        refresh();
      }
    });
  }

  void _showTemporaryWarning(String message) {
    warning = message;
    showWarning = true;
    refresh();

    Future.delayed(const Duration(seconds: 10), () {
      if (warning == message) {
        showWarning = false;
        warning = '';
        refresh();
      }
    });
  }

  Future<void> joinRoom() async {
    DocumentReference roomRef = db.collection('Rooms').doc(roomId);
    var roomSnapshot = await roomRef.get();

    if (roomSnapshot.exists) {
      await roomRef.update({'status': 'accepted', 'startTime': DateTime.now()});
      getRoomDetails(roomId);
    } else {
      BuildContext? context = NavigationService.instance.getContext();
      if (context != null) {
        await showCupertinoModalPopup<void>(
          context: context,
          builder: (BuildContext context) => CupertinoAlertDialog(
            title: const Text('This room does not exists'),
            content: const Text('Must have ended'),
            actions: <CupertinoDialogAction>[
              CupertinoDialogAction(
                onPressed: () {
                  endCall();
                  NavigationService.instance.goBack();
                },
                isDefaultAction: true,
                child: const Text('Accept'),
              ),
            ],
          ),
        );
      }
    }
    refresh();
  }

  Stream<DocumentSnapshot> getRoomStream(String roomId) =>
      FirebaseFirestore.instance.collection('Rooms').doc(roomId).snapshots();

  void getRoomDetails(String roomId) {
    Stream<DocumentSnapshot> stream = getRoomStream(roomId);

    _callStatusSubscription = stream.listen((DocumentSnapshot document) {
      if (document.exists) {
        var data = document.data()! as Map<String, dynamic>;
        status = data['status'];

        if (startTime == null && data['startTime'] != null) {
          if (data['startTime'] is Timestamp) {
            startTime = (data['startTime'] as Timestamp).toDate();
          } else if (data['startTime'] is String) {
            startTime = DateTime.parse(data['startTime']);
          }
          _startTimer();
        }

        if (status == 'ended') {
          Future.delayed(const Duration(milliseconds: 500), endCall);
        }
      } else {
        endCall();
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

  void switchOnBlur() {
    blurBackground = !blurBackground;
    if (blurBackground) {
      setBlurBackground();
    } else {
      resetVirtualBackground();
    }
    refresh();
  }

  Future<void> setBlurBackground() async {
    final virtualBackgroundSource = const VirtualBackgroundSource(
      backgroundSourceType: BackgroundSourceType.backgroundBlur,
      blurDegree: BackgroundBlurDegree.blurDegreeHigh,
    );

    final segmentationProperty = const SegmentationProperty(
      modelType: SegModelType.segModelAi,
      greenCapacity: 0.5,
    );

    engine.enableVirtualBackground(
      enabled: true,
      backgroundSource: virtualBackgroundSource,
      segproperty: segmentationProperty,
    );
  }

  Future<void> resetVirtualBackground() async {
    engine.enableVirtualBackground(
      enabled: false,
      backgroundSource: VirtualBackgroundSource(),
      segproperty: SegmentationProperty(),
    );
  }

  Future<void> endCall() async {
    DocumentReference roomRef = db.collection('Rooms').doc(roomId);
    await roomRef.update({'status': 'ended', 'endTime': DateTime.now()});

    isSmallVideoLocal = false;
    showWarning = false;
    warning = '';
    elapsedTime = Duration.zero;
    _elapsedTimeController?.close();
    status = null;
    _callStatusSubscription?.cancel();
    _timer?.cancel();

    await engine.leaveChannel();
    await engine.release();

    NavigationService.instance.goBack();
  }
}
