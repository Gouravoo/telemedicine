import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/services/agora_service.dart';
import '../../../../core/services/cloud_function_service.dart';

/// Full-screen video call screen with dark theme
/// Used by both Patient and Doctor roles
class VideoCallScreen extends ConsumerStatefulWidget {
  final String channelName;
  final String callerName;
  final String calleeName;
  final bool isDoctor;

  const VideoCallScreen({
    super.key,
    required this.channelName,
    required this.callerName,
    required this.calleeName,
    this.isDoctor = false,
  });

  @override
  ConsumerState<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends ConsumerState<VideoCallScreen> {
  bool _isMuted = false;
  bool _isCameraOff = false;
  bool _remoteUserJoined = false;
  int? _remoteUid;
  bool _isConnecting = true;
  int _callDuration = 0;
  Timer? _callTimer;
  late AgoraService _agoraService;

  @override
  void initState() {
    super.initState();
    _agoraService = ref.read(agoraServiceProvider);
    _initCall();
  }

  Future<void> _initCall() async {
    // Set up callbacks
    _agoraService.onUserJoined = (uid) {
      setState(() {
        _remoteUserJoined = true;
        _remoteUid = uid;
        _isConnecting = false;
      });
      _startTimer();
    };

    _agoraService.onUserOffline = (uid) {
      setState(() {
        _remoteUserJoined = false;
        _remoteUid = null;
      });
    };

    _agoraService.onJoinChannelSuccess = (connection, elapsed) {
      setState(() => _isConnecting = false);
    };

    _agoraService.onError = (message) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    };

    // Initialize Agora
    await _agoraService.initialize();

    // Get token from Cloud Function (mock for now)
    final token = await ref.read(cloudFunctionServiceProvider).generateAgoraToken(
      channelName: widget.channelName,
      uid: widget.isDoctor ? '1' : '2',
    );

    // Join channel
    await _agoraService.joinChannel(
      channelName: widget.channelName,
      token: token,
      uid: widget.isDoctor ? 1 : 2,
    );
  }

  void _startTimer() {
    _callTimer?.cancel();
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() => _callDuration++);
    });
  }

  String get _formattedDuration {
    final minutes = (_callDuration ~/ 60).toString().padLeft(2, '0');
    final seconds = (_callDuration % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _callTimer?.cancel();
    _agoraService.leaveChannel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.callBackground,
      body: Stack(
        children: [
          // ─── Remote Video (Full Screen) ───
          if (_remoteUserJoined && _remoteUid != null)
            AgoraVideoView(
              controller: VideoViewController.remote(
                rtcEngine: _agoraService.engine!,
                canvas: VideoCanvas(uid: _remoteUid),
                connection: RtcConnection(channelId: widget.channelName),
              ),
            )
          else
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Avatar placeholder
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.1),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 3,
                      ),
                    ),
                    child: Icon(
                      widget.isDoctor ? Icons.person : Icons.medical_services,
                      size: 56,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    widget.calleeName,
                    style: AppTextStyles.h1.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    _isConnecting ? 'Connecting...' : 'Waiting for ${widget.isDoctor ? 'patient' : 'doctor'}...',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                  if (_isConnecting) ...[
                    const SizedBox(height: AppSpacing.xl),
                    SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

          // ─── Local Video (Picture-in-Picture) ───
          if (!_isCameraOff)
            Positioned(
              top: MediaQuery.of(context).padding.top + AppSpacing.base,
              right: AppSpacing.base,
              child: Container(
                width: 120,
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 10,
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: _agoraService.engine != null
                    ? AgoraVideoView(
                        controller: VideoViewController(
                          rtcEngine: _agoraService.engine!,
                          canvas: const VideoCanvas(uid: 0),
                        ),
                      )
                    : Container(
                        color: AppColors.callSurface,
                        child: const Icon(
                          Icons.videocam_off,
                          color: Colors.white54,
                        ),
                      ),
              ),
            ),

          // ─── Top Bar (Name + Timer) ───
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + AppSpacing.sm,
                left: AppSpacing.base,
                right: AppSpacing.base,
                bottom: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.6),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => _endCall(),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          widget.calleeName,
                          style: AppTextStyles.subtitle.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        if (_remoteUserJoined)
                          Text(
                            _formattedDuration,
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontFeatures: [const FontFeature.tabularFigures()],
                            ),
                          )
                        else
                          Text(
                            _isConnecting ? 'Connecting...' : 'Ringing...',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.primaryLight,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 48), // Balance the back button
                ],
              ),
            ),
          ),

          // ─── Bottom Controls ───
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: AppSpacing.xl,
                bottom: MediaQuery.of(context).padding.bottom + AppSpacing.xxl,
                left: AppSpacing.xxl,
                right: AppSpacing.xxl,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Mute button
                  _controlButton(
                    icon: _isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                    label: _isMuted ? 'Unmute' : 'Mute',
                    isActive: _isMuted,
                    onTap: () async {
                      setState(() => _isMuted = !_isMuted);
                      await _agoraService.toggleMute(_isMuted);
                    },
                  ),
                  // Camera toggle
                  _controlButton(
                    icon: _isCameraOff
                        ? Icons.videocam_off_rounded
                        : Icons.videocam_rounded,
                    label: _isCameraOff ? 'Camera On' : 'Camera Off',
                    isActive: _isCameraOff,
                    onTap: () async {
                      setState(() => _isCameraOff = !_isCameraOff);
                      await _agoraService.toggleCamera(_isCameraOff);
                    },
                  ),
                  // End call
                  _controlButton(
                    icon: Icons.call_end_rounded,
                    label: 'End',
                    isEndCall: true,
                    onTap: _endCall,
                  ),
                  // Switch camera
                  _controlButton(
                    icon: Icons.cameraswitch_rounded,
                    label: 'Flip',
                    onTap: () => _agoraService.switchCamera(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _controlButton({
    required IconData icon,
    required String label,
    bool isActive = false,
    bool isEndCall = false,
    required VoidCallback onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isEndCall
                  ? AppColors.callEndButton
                  : isActive
                      ? Colors.white.withValues(alpha: 0.3)
                      : AppColors.callControlBg,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 26,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  void _endCall() {
    _agoraService.leaveChannel();
    if (mounted) {
      context.pop();
    }
  }
}
