import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../state/model.dart';
import '../theme/tokens.dart';
import '../widgets/akaya_icon.dart';
import '../widgets/chrome.dart';
import '../widgets/pearl.dart';

class VoiceScreen extends StatefulWidget {
  const VoiceScreen({super.key});

  @override
  State<VoiceScreen> createState() => _VoiceScreenState();
}

class _VoiceScreenState extends State<VoiceScreen> {
  String _phase = 'idle';
  String _transcript = '';
  String _reply = '';
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _demo() {
    const line = 'Remind me to call Rahul at 5 PM';
    final words = line.split(' ');
    setState(() {
      _phase = 'listening';
      _transcript = '';
      _reply = '';
    });
    var i = 0;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 280), (t) {
      i++;
      if (!mounted) return;
      if (i <= words.length) {
        setState(() => _transcript = words.take(i).join(' '));
      } else {
        t.cancel();
        _finish(line);
      }
    });
  }

  void _finish(String heard) {
    final model = AkayaScope.of(context);
    setState(() => _phase = 'thinking');
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() {
        _reply = model.mockReply(heard);
        _phase = 'speaking';
      });
      Future.delayed(const Duration(milliseconds: 1600), () {
        if (mounted && _phase == 'speaking') setState(() => _phase = 'idle');
      });
    });
  }

  void _mic() {
    if (_phase == 'listening') {
      _timer?.cancel();
      _finish(_transcript.isEmpty ? 'Hello' : _transcript);
      return;
    }
    if (_phase == 'denied') {
      setState(() => _phase = 'denied');
      return;
    }
    setState(() => _phase = 'denied');
  }

  @override
  Widget build(BuildContext context) {
    final p = paletteOf(context);
    final model = AkayaScope.of(context);
    final mood = switch (_phase) {
      'listening' => PearlMood.listening,
      'thinking' => PearlMood.thinking,
      'speaking' => PearlMood.happy,
      _ => PearlMood.idle,
    };
    final status = switch (_phase) {
      'listening' => 'Listening… (demo)',
      'thinking' => 'Thinking…',
      'speaking' => 'Akaya says',
      'denied' => 'Microphone is blocked',
      _ => 'Tap the mic and just speak',
    };
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
          child: Row(
            children: [
              AkayaIconButton(icon: 'back', label: 'Back to Home', onTap: () => context.go('/home')),
              const SizedBox(width: 10),
              Text('Voice', style: comfortaa(20, p.text)),
              const Spacer(),
              GestureDetector(
                onTap: () => context.go('/vnotes'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: glass(p, radius: 99),
                  child: Row(
                    children: [
                      AkayaIcon('wave', size: 15, color: p.text),
                      const SizedBox(width: 5),
                      Text('Voice Notes', style: manrope(12, p.text, weight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(color: p.tint(model.mode == 'on-device' ? 'green' : 'blue'), borderRadius: BorderRadius.circular(99)),
                child: Row(
                  children: [
                    AkayaIcon(model.mode == 'on-device' ? 'chip' : 'globe', size: 12, color: model.mode == 'on-device' ? p.greenText : AkayaPalette.blue),
                    const SizedBox(width: 4),
                    Text(model.mode == 'on-device' ? 'On-device' : 'Online', style: manrope(11, model.mode == 'on-device' ? p.greenText : AkayaPalette.blue, weight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Center(child: Pearl(width: 300, height: 240, radius: 84, scene: _phase != 'listening', mood: mood, interactive: true, label: 'Akaya')),
        ),
        Text(status, style: manrope(14, p.text, weight: FontWeight.w700)),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: _phase == 'denied'
              ? Container(
                  padding: const EdgeInsets.all(14),
                  decoration: glass(p, radius: 16),
                  child: Column(
                    children: [
                      Text('Allow microphone access in your browser settings to talk to Akaya. You can also try a demo.', textAlign: TextAlign.center, style: manrope(13.5, p.text, weight: FontWeight.w600, height: 1.4)),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () => setState(() => _phase = 'denied'),
                            child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: p.lineStrong)), child: Text('Try again', style: manrope(13, p.text, weight: FontWeight.w800))),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: _demo,
                            child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), decoration: BoxDecoration(gradient: p.brand, borderRadius: BorderRadius.circular(12)), child: Text('Demo mode', style: manrope(13, Colors.white, weight: FontWeight.w800))),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              : Text(
                  _reply.isNotEmpty && _phase != 'listening'
                      ? _reply
                      : (_transcript.isNotEmpty ? '“$_transcript”' : (_phase == 'listening' ? 'Go ahead, I’m listening' : 'Try: “Remind me to call Rahul at 5”')),
                  textAlign: TextAlign.center,
                  style: manrope(14.5, _transcript.isEmpty && _reply.isEmpty ? p.text3 : p.text, weight: FontWeight.w600, height: 1.45),
                ),
        ),
        const SizedBox(height: 14),
        WaveBars(color: p.violetText, height: 38),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.only(bottom: 22),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AkayaIconButton(icon: 'keyboard', label: 'Type instead', onTap: () => context.go('/chat')),
              const SizedBox(width: 22),
              GestureDetector(
                onTap: _mic,
                child: Container(
                  width: 78,
                  height: 78,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: _phase == 'listening' ? p.gOrange : p.brand,
                    boxShadow: const [BoxShadow(color: Color(0x805028DC), blurRadius: 24, offset: Offset(0, 10), spreadRadius: -8)],
                  ),
                  child: AkayaIcon(_phase == 'listening' ? 'stop' : 'mic', size: 30, color: Colors.white, strokeWidth: 2.2),
                ),
              ),
              const SizedBox(width: 22),
              AkayaIconButton(icon: 'spark', label: 'Demo', onTap: _demo),
            ],
          ),
        ),
      ],
    );
  }
}
