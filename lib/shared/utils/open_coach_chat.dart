import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kynos/app/router.dart';
import 'package:kynos/domain/entities/coach/coach_chat_seed.dart';
import 'package:kynos/domain/entities/coach/coach_seed_topic.dart';
import 'package:kynos/shared/providers/coach_chat_seed_provider.dart';

/// Opens coach chat with an optional structured seed.
void openCoachChat(
  BuildContext context,
  WidgetRef ref, {
  String? seed,
  CoachSeedTopic topic = CoachSeedTopic.general,
  String? runId,
  String? questId,
  String? threadId,
}) {
  if (seed != null && seed.trim().isNotEmpty ||
      runId != null ||
      questId != null) {
    ref
        .read(coachChatSeedProvider.notifier)
        .setSeed(
          CoachChatSeedData(
            message: seed?.trim(),
            topic: topic,
            runId: runId,
            questId: questId,
          ),
        );
  }
  final path = threadId == null
      ? Routes.dashboard
      : '${Routes.dashboard}?threadId=$threadId';
  context.go(path);
}
