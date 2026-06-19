import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/child.dart';
import '../../../core/models/recognition_log.dart';
import '../../../core/models/class_model.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/auth_storage_service.dart';
import '../../../core/services/face_recognition_service.dart';
import '../../../core/widgets/report_card_widget.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../../settings/screens/user_image_recognition_screen.dart';
import '../bloc/child_detail_bloc.dart';
import 'in_app_camera_screen.dart';

class ChildDetailScreen extends StatelessWidget {
  final Child child;
  final ClassModel classItem;

  const ChildDetailScreen({
    super.key,
    required this.child,
    required this.classItem,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChildDetailBloc(
        apiService: context.read<ApiService>(),
        faceService: FaceRecognitionService(),
        authStorage: context.read<AuthStorageService>(),
      )..add(LoadChildDetail(
          childId: child.id!,
          classId: classItem.id!,
          childKbUuid: child.kbUuid,
          fetchKidPhoto: child.hasImage == true,
        )),
      child: _ChildDetailView(child: child, classItem: classItem),
    );
  }
}

class _ChildDetailView extends StatefulWidget {
  final Child child;
  final ClassModel classItem;

  const _ChildDetailView({required this.child, required this.classItem});

  @override
  State<_ChildDetailView> createState() => _ChildDetailViewState();
}

class _ChildDetailViewState extends State<_ChildDetailView> {
  Future<void> _recognizeFlow() async {
    if (widget.child.kbUuid == null || widget.classItem.id == null) return;
    context.read<ChildDetailBloc>().add(const ResetRecognition());
    final path = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const InAppCameraScreen()),
    );
    if (path == null || !mounted) return;
    context.read<ChildDetailBloc>().add(
      RecognizeChild(
        photo: File(path),
        childKbUuid: widget.child.kbUuid!,
        sectionId: widget.classItem.id!,
      ),
    );
  }

  Widget _buildKidPhoto(
    BuildContext context,
    ChildDetailState state,
    AppLocalizations l10n,
  ) {
    if (state.kidPhotoLoading) {
      return const Center(
        child: SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    final url = state.kidPhotoUrl;
    if (url == null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_off,
            size: 48,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.noPhotosRegistered,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(11),
      child: Image.network(
        url,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const Center(
            child: SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.broken_image,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openPhotoUpdate() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => UserImageRecognitionScreen(
          child: widget.child,
          classItem: widget.classItem,
          isPhotoUpdate: true,
        ),
      ),
    );
    if (result == true && mounted && widget.child.id != null && widget.classItem.id != null) {
      context.read<ChildDetailBloc>().add(
        RefreshVisitHistories(
          childId: widget.child.id!,
          classId: widget.classItem.id!,
          childKbUuid: widget.child.kbUuid,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final name = widget.child.fullName;

    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: BlocConsumer<ChildDetailBloc, ChildDetailState>(
        listener: (context, state) {
          if (state.recognitionError != null) {
            var message = state.recognitionError!;
            if (message.startsWith('Exception: ')) {
              message = message.substring(11);
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
          if (state.recognizedMatch == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.studentPresent, style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),),
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              ),
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                if (widget.child.id != null && widget.classItem.id != null) {
                  context.read<ChildDetailBloc>().add(
                    RefreshVisitHistories(
                      childId: widget.child.id!,
                      classId: widget.classItem.id!,
                      childKbUuid: widget.child.kbUuid,
                    ),
                  );
                }
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    //kid photo
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _buildKidPhoto(context, state, l10n),
                    ),
            
                    //recognition result
                    if (state.recognizedMatch != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            state.recognizedMatch!
                                ? Icons.check_circle
                                : Icons.cancel,
                            size: 32,
                            color: state.recognizedMatch!
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.error,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            state.recognizedMatch!
                                ? l10n.studentPresent
                                : l10n.notRecognized,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: state.recognizedMatch!
                                      ? Theme.of(context).colorScheme.onSurface
                                      : Theme.of(context).colorScheme.error,
                                ),
                          ),
                        ],
                      ),
                    ],
            
                    const SizedBox(height: 16),
            
                    //action buttons
                    FilledButton.icon(
                      onPressed: state.recognizing ? null : _recognizeFlow,
                      icon: state.recognizing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.face),
                      label: Text(l10n.recognizeFace),
                    ),
                    const SizedBox(height: 8),
                    FilledButton.tonalIcon(
                      onPressed: _openPhotoUpdate,
                      icon: const Icon(Icons.photo_library),
                      label: Text(l10n.updatePhotos),
                    ),
            
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
            
                    //attendance history
                    Text(
                      l10n.attendanceHistory,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 8),
                    if (state.historyLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (state.historyError != null)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          state.historyError!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      )
                    else if (state.visitHistories.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Text(
                            l10n.noAttendanceHistory,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ),
                      )
                    else
                      ...state.visitHistories.map(
                        (vh) => ReportCardWidget(visitHistory: vh),
                      ),
            
                    //recognition logs
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                    Text(
                      l10n.recognitionHistory,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 8),
                    if (!state.historyLoading && state.recognitionLogs.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Text(
                            l10n.noRecognitionHistory,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ),
                      )
                    else if (!state.historyLoading)
                      ...state.recognitionLogs.map(
                        (log) => _RecognitionLogCard(log: log),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RecognitionLogCard extends StatelessWidget {
  final RecognitionLog log;

  const _RecognitionLogCard({required this.log});

  String _formatTimestamp(String timestamp) {
    try {
      final dt = DateTime.parse(timestamp);
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inDays == 0) {
        if (diff.inHours == 0) return '${diff.inMinutes} min ago';
        return '${diff.inHours}h ago';
      } else if (diff.inDays == 1) {
        return 'Yesterday';
      } else if (diff.inDays < 7) {
        return '${diff.inDays}d ago';
      }
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return timestamp;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isRecognized = log.recognized == true;
    final confidencePercent = log.confidence != null
        ? '${(log.confidence! * 100).toStringAsFixed(1)}%'
        : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              isRecognized ? Icons.check_circle : Icons.cancel,
              color: isRecognized
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.error,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isRecognized ? l10n.recognized : l10n.notRecognized,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  if (confidencePercent != null)
                    Text(
                      '${l10n.confidence}: $confidencePercent',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                ],
              ),
            ),
            Text(
              _formatTimestamp(log.timestamp),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
