part of '../exhibition_consumer_layer.dart';

class ProjectLifecycleActionCommand {
  const ProjectLifecycleActionCommand({required this.projectId});

  final String projectId;

  Map<String, Object?> toJson() => <String, Object?>{'projectId': projectId};
}
