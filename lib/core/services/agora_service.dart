import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ──────────────────────────────────────────────────────────────
/// AGORA SERVICE — Video calling operations
/// ──────────────────────────────────────────────────────────────
/// Manages Agora RTC engine lifecycle: initialize, join, leave,
/// toggle camera/mic, handle remote user events.
///
/// App Certificate is NEVER stored here — it lives in Cloud
/// Functions for secure token generation.
/// ──────────────────────────────────────────────────────────────

final agoraServiceProvider = Provider<AgoraService>((ref) => AgoraService());

class AgoraService {
  // ─── Agora Credentials ───
  // App ID is public (safe on client)
  static const String appId = '6ef4712b229a4c9691633f4f6cd8d42d';

  RtcEngine? _engine;
  RtcEngine? get engine => _engine;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // ─── Callbacks ───
  Function(int uid)? onUserJoined;
  Function(int uid)? onUserOffline;
  Function(RtcConnection connection, int elapsed)? onJoinChannelSuccess;
  Function(String message)? onError;

  /// Initialize the Agora RTC engine
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _engine = createAgoraRtcEngine();
      await _engine!.initialize(const RtcEngineContext(
        appId: appId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ));

      // Register event handlers
      _engine!.registerEventHandler(RtcEngineEventHandler(
        onJoinChannelSuccess: (connection, elapsed) {
          onJoinChannelSuccess?.call(connection, elapsed);
        },
        onUserJoined: (connection, remoteUid, elapsed) {
          onUserJoined?.call(remoteUid);
        },
        onUserOffline: (connection, remoteUid, reason) {
          onUserOffline?.call(remoteUid);
        },
        onError: (err, msg) {
          onError?.call('Agora Error $err: $msg');
        },
        onTokenPrivilegeWillExpire: (connection, token) {
          // TODO: Fetch new token from Cloud Function and call renewToken()
          // _engine?.renewToken(newToken);
        },
      ));

      // Enable video
      await _engine!.enableVideo();
      await _engine!.enableAudio();

      // Set video configuration
      await _engine!.setVideoEncoderConfiguration(
        const VideoEncoderConfiguration(
          dimensions: VideoDimensions(width: 640, height: 480),
          frameRate: 15,
          bitrate: 800,
        ),
      );

      _isInitialized = true;
    } catch (e) {
      onError?.call('Failed to initialize Agora: $e');
    }
  }

  /// Join a video call channel
  Future<void> joinChannel({
    required String channelName,
    required String token,
    required int uid,
  }) async {
    if (!_isInitialized) await initialize();

    try {
      // Start local preview
      await _engine!.startPreview();

      // Join channel
      await _engine!.joinChannel(
        token: token,
        channelId: channelName,
        uid: uid,
        options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          channelProfile: ChannelProfileType.channelProfileCommunication,
          autoSubscribeVideo: true,
          autoSubscribeAudio: true,
        ),
      );
    } catch (e) {
      onError?.call('Failed to join channel: $e');
    }
  }

  /// Leave the current channel
  Future<void> leaveChannel() async {
    try {
      await _engine?.stopPreview();
      await _engine?.leaveChannel();
    } catch (e) {
      onError?.call('Failed to leave channel: $e');
    }
  }

  /// Toggle local audio (mute/unmute)
  Future<void> toggleMute(bool muted) async {
    await _engine?.muteLocalAudioStream(muted);
  }

  /// Toggle local video (camera on/off)
  Future<void> toggleCamera(bool disabled) async {
    await _engine?.muteLocalVideoStream(disabled);
  }

  /// Switch between front and back camera
  Future<void> switchCamera() async {
    await _engine?.switchCamera();
  }

  /// Dispose the engine
  Future<void> dispose() async {
    await leaveChannel();
    await _engine?.release();
    _engine = null;
    _isInitialized = false;
  }
}
