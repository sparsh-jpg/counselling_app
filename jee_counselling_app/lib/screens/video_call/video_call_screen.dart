// SETUP REQUIRED:
// 1. Add to pubspec.yaml:
//      agora_rtc_engine: ^6.3.2
//      permission_handler: ^11.3.0
//
// 2. Add to android/app/src/main/AndroidManifest.xml inside <manifest>:
//      <uses-permission android:name="android.permission.CAMERA"/>
//      <uses-permission android:name="android.permission.RECORD_AUDIO"/>
//
// 3. Replace YOUR_AGORA_APP_ID with your App ID from console.agora.io

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const String _agoraAppId = 'b00cdf0604474f1795e7a018f826f8da';

class VideoCallScreen extends StatefulWidget {
  final String channelName;
  final String otherName;
  final String? callId; // Used to clean up the call signal on end

  const VideoCallScreen({
    super.key,
    required this.channelName,
    required this.otherName,
    this.callId,
  });

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  RtcEngine? _engine;
  bool _localUserJoined = false;
  int? _remoteUid;
  bool _isMuted = false;
  bool _isCameraOff = false;
  bool _isConnecting = true;

  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _initAgora();
  }

  Future<void> _initAgora() async {
    try {
      if (!kIsWeb) {
        await [Permission.microphone, Permission.camera].request();
      }

      _engine = createAgoraRtcEngine();
      await _engine!.initialize(const RtcEngineContext(
        appId: _agoraAppId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ));

      _engine!.registerEventHandler(
        RtcEngineEventHandler(
          onError: (err, msg) {
            setState(() => _errorMsg = 'Error $err: $msg');
          },
          onJoinChannelSuccess: (connection, elapsed) {
            setState(() {
              _localUserJoined = true;
              _isConnecting = false;
            });
          },
          onUserJoined: (connection, remoteUid, elapsed) {
            setState(() => _remoteUid = remoteUid);
          },
          onUserOffline: (connection, remoteUid, reason) {
            setState(() => _remoteUid = null);
            _showUserLeft();
          },
        ),
      );

      try {
        await _engine!.enableVideo();
        await _engine!.startPreview();
      } catch (videoError) {
        // Webcam is probably locked by another tab (Device in use)
        debugPrint("Camera locked by another process: $videoError");
      }

      int generatedUid = DateTime.now().millisecondsSinceEpoch.remainder(100000) + 1;
      
      await _engine!.joinChannel(
        token: '',
        channelId: widget.channelName,
        uid: generatedUid,
        options: const ChannelMediaOptions(),
      );
    } catch (e) {
      setState(() => _errorMsg = 'Init Error: $e');
    }
  }

  void _showUserLeft() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('${widget.otherName} left the call',
          style: GoogleFonts.poppins()),
      backgroundColor: Colors.red,
    ));
  }

  Future<void> _leaveCall() async {
    await _engine?.leaveChannel();
    await _engine?.release();
    
    // Mark the call signal as ended so receiver dialog dismisses
    if (widget.callId != null) {
      try {
        await FirebaseFirestore.instance
            .collection('call_signals')
            .doc(widget.callId)
            .update({'status': 'ended'});
      } catch (_) {}
    }
    
    if (!mounted) return;
    Navigator.pop(context);
  }

  void _toggleMute() async {
    _isMuted = !_isMuted;
    await _engine?.muteLocalAudioStream(_isMuted);
    setState(() {});
  }

  void _toggleCamera() async {
    _isCameraOff = !_isCameraOff;
    await _engine?.muteLocalVideoStream(_isCameraOff);
    setState(() {});
  }

  void _switchCamera() async {
    await _engine?.switchCamera();
  }

  @override
  void dispose() {
    _engine?.leaveChannel();
    _engine?.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Remote video full screen
          if (_remoteUid != null)
            AgoraVideoView(
              controller: VideoViewController.remote(
                rtcEngine: _engine!,
                canvas: VideoCanvas(uid: _remoteUid),
                connection:
                    RtcConnection(channelId: widget.channelName),
              ),
            )
          else
            _buildWaitingScreen(),

          // Local video PiP
          if (_localUserJoined && !_isCameraOff)
            Positioned(
              top: 60,
              right: 16,
              child: Container(
                width: 100,
                height: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: const Color(0xFF00E5CC), width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: AgoraVideoView(
                    controller: VideoViewController(
                      rtcEngine: _engine!,
                      canvas: const VideoCanvas(uid: 0),
                    ),
                  ),
                ),
              ),
            ),

          // Top bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent
                  ],
                ),
              ),
              child: Row(
                children: [
                  Text(widget.otherName,
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16)),
                  const SizedBox(width: 8),
                  if (_errorMsg != null)
                    Expanded(
                      child: Text(_errorMsg!,
                          style: GoogleFonts.poppins(
                              color: Colors.red, fontSize: 10)),
                    )
                  else if (_isConnecting)
                    Text('Connecting...',
                        style: GoogleFonts.poppins(
                            color: Colors.white54, fontSize: 12))
                  else if (_remoteUid != null)
                    Row(children: [
                      Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                              color: Color(0xFF22C55E),
                              shape: BoxShape.circle)),
                      const SizedBox(width: 4),
                      Text('Connected',
                          style: GoogleFonts.poppins(
                              color: const Color(0xFF22C55E),
                              fontSize: 12)),
                    ])
                  else
                    Text('Waiting...',
                        style: GoogleFonts.poppins(
                            color: Colors.orange, fontSize: 12)),
                ],
              ),
            ),
          ),

          // Bottom controls
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _controlBtn(
                  icon: _isMuted ? Icons.mic_off : Icons.mic,
                  color: _isMuted ? Colors.red : Colors.white,
                  onTap: _toggleMute,
                ),
                GestureDetector(
                  onTap: _leaveCall,
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.call_end,
                        color: Colors.white, size: 28),
                  ),
                ),
                _controlBtn(
                  icon: _isCameraOff
                      ? Icons.videocam_off
                      : Icons.videocam,
                  color: _isCameraOff ? Colors.red : Colors.white,
                  onTap: _toggleCamera,
                ),
                _controlBtn(
                  icon: Icons.flip_camera_ios,
                  color: Colors.white,
                  onTap: _switchCamera,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaitingScreen() {
    return Container(
      color: const Color(0xFF0A0A1A),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 48,
              backgroundColor: const Color(0xFF00E5CC).withOpacity(0.2),
              child: Text(
                widget.otherName[0].toUpperCase(),
                style: GoogleFonts.poppins(
                    color: const Color(0xFF00E5CC),
                    fontSize: 32,
                    fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 20),
            Text(widget.otherName,
                style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('Waiting for them to join...',
                style: GoogleFonts.poppins(
                    color: Colors.white38, fontSize: 13)),
            const SizedBox(height: 24),
            const CircularProgressIndicator(
                color: Color(0xFF00E5CC), strokeWidth: 2),
          ],
        ),
      ),
    );
  }

  Widget _controlBtn({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }
}