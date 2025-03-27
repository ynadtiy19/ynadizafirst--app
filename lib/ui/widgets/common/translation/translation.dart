import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hyper_effects/hyper_effects.dart';

class Translation extends StatefulWidget {
  final List<dynamic>? translations; // 将translations改为可空类型
  const Translation({required this.translations, super.key});

  @override
  State<Translation> createState() => _TranslationState();
}

class _TranslationState extends State<Translation> {
  int lastTranslation = 0;
  int translation = 0;

  late Timer timer;

  @override
  void initState() {
    super.initState();

    // 如果translations为null或为空，则不启动定时器
    if (widget.translations != null && widget.translations!.isNotEmpty) {
      timer = Timer.periodic(
        Duration(milliseconds: (2000 * timeDilation).toInt()),
        (timer) {
          setState(() {
            lastTranslation = translation;
            translation = (translation + 1) % widget.translations!.length;
          });
        },
      );
    }
  }

  @override
  void dispose() {
    if (timer.isActive) {
      timer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 如果translations为null或为空，显示占位文本
    if (widget.translations == null || widget.translations!.isEmpty) {
      return const Center(
        child: Text(
          'No translations available',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ShaderMask(
            shaderCallback: (rect) => LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withOpacity(0),
                Colors.white,
                Colors.white,
                Colors.white,
                Colors.white,
                Colors.white.withOpacity(0),
              ],
            ).createShader(rect),
            child: ShaderMask(
              shaderCallback: (rect) => const LinearGradient(
                colors: [
                  Color(0xFFD4145A),
                  Color(0xFFFBB03B),
                ],
              ).createShader(rect),
              child: Text(
                widget.translations![lastTranslation], // 确保translations不为空后再访问
                style: GoogleFonts.sacramento().copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              )
                  .roll(
                    widget.translations![translation],
                    symbolDistanceMultiplier: 2,
                    tapeCurve: Curves.easeInOutBack,
                    widthCurve: Curves.easeInOutQuart,
                    padding: const EdgeInsets.only(right: 5, left: 5),
                  )
                  .animate(
                    trigger: translation,
                    duration: const Duration(milliseconds: 1000),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
