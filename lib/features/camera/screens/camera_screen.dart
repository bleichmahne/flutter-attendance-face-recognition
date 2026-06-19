import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/camera_bloc/camera_bloc.dart';
import '../bloc/flow_bloc/camera_flow_bloc.dart';
import '../../../features/clubs/bloc/club_bloc.dart';
import '../../../features/report_cards/bloc/report_card_bloc.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../core/widgets/error_widget.dart';
import '../../../core/widgets/camera_grid.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../../face_guided_camera/widgets/face_detection_camera_view.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => CameraScreenState();
}

class CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  bool _autoSelectDone = false;
  final _faceDetectionKey = GlobalKey<FaceDetectionCameraViewState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    context.read<CameraBloc>().add(InitializeCamera());
    context.read<ClubBloc>().add(LoadClubs());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      //re-init camera when app returns to foreground
      final flowStep = context.read<CameraFlowBloc>().state.step;
      if (flowStep == CameraFlowStep.camera) {
        context.read<CameraBloc>().add(InitializeCamera());
      }
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      //release camera when app goes to background
      final cameraState = context.read<CameraBloc>().state;
      if (cameraState is CameraReady) {
        context.read<CameraBloc>().add(ResetCamera());
      }
    }
  }

  //called by MainScreen when camera tab becomes visible again
  void reinitIfNeeded() {
    final cameraState = context.read<CameraBloc>().state;
    final flowStep = context.read<CameraFlowBloc>().state.step;
    if (flowStep == CameraFlowStep.camera &&
        cameraState is! CameraReady &&
        cameraState is! CameraLoading) {
      context.read<CameraBloc>().add(InitializeCamera());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocListener<CameraFlowBloc, CameraFlowState>(
      listenWhen: (prev, curr) => prev.step != curr.step && curr.step == CameraFlowStep.summary,
      listener: (context, state) {
        context.read<ReportCardBloc>().add(LoadReportCards());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.attendanceRecorded)),
        );
      },
      child: BlocConsumer<CameraFlowBloc, CameraFlowState>(
        listenWhen: (prev, curr) =>
            prev.error != curr.error && curr.error != null,
        listener: (context, state) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        },
        builder: (context, flowState) {
          final showReset = flowState.step == CameraFlowStep.camera ||
              flowState.step == CameraFlowStep.captured ||
              flowState.step == CameraFlowStep.recognizing ||
              flowState.step == CameraFlowStep.summary;
          return Scaffold(
            appBar: AppBar(
              title: Text(
                flowState.step == CameraFlowStep.summary
                    ? l10n.summary
                    : l10n.camera,
              ),
              actions: [
                if (showReset)
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: l10n.reset,
                    onPressed: () {
                      context
                          .read<CameraFlowBloc>()
                          .add(const CameraFlowReset());
                      context.read<CameraBloc>().add(ResetCamera());
                    },
                  ),
              ],
            ),
            body: _buildBody(context, flowState, l10n),
          );
        },
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    CameraFlowState flowState,
    AppLocalizations l10n,
  ) {
    switch (flowState.step) {
      case CameraFlowStep.summary:
        return _buildSummary(context, flowState, l10n);
      case CameraFlowStep.clubSelection:
      case CameraFlowStep.loadingKids:
      case CameraFlowStep.clubSelected:
        return _buildClubSelection(context, flowState, l10n);
      case CameraFlowStep.captured:
      case CameraFlowStep.recognizing:
        return flowState.lastCapturedPath != null
            ? _buildCapturedPreview(context, flowState, l10n)
            : _buildCamera(context, l10n);
      case CameraFlowStep.camera:
        return _buildCamera(context, l10n);
    }
  }

  Widget _buildClubSelection(
    BuildContext context,
    CameraFlowState flowState,
    AppLocalizations l10n,
  ) {
    if (flowState.step == CameraFlowStep.loadingKids) {
      return const Center(child: LoadingWidget());
    }
    return BlocBuilder<ClubBloc, ClubState>(
      builder: (context, clubState) {
        if (clubState is ClubLoading) {
          return const Center(child: LoadingWidget());
        }
        if (clubState is ClubError) {
          return ErrorDisplayWidget(
            message: clubState.message,
            onRetry: () => context.read<ClubBloc>().add(LoadClubs()),
          );
        }
        if (clubState is ClubLoaded) {
          final classes = clubState.classes;
          if (classes.isEmpty) {
            return Center(child: Text(l10n.noClubsAvailable));
          }
          if (classes.length == 1 &&
              flowState.selectedClass == null &&
              flowState.step == CameraFlowStep.clubSelection &&
              !_autoSelectDone) {
            _autoSelectDone = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                context.read<CameraFlowBloc>().add(
                      CameraFlowSelectClub(classes.first),
                    );
              }
            });
          }
          if (flowState.step == CameraFlowStep.clubSelected &&
              flowState.selectedClass != null &&
              flowState.children.isNotEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${l10n.selectClub}: ${flowState.selectedClass!.displayName}',
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () {
                        context
                            .read<CameraFlowBloc>()
                            .add(const CameraFlowStartCamera());
                        context.read<CameraBloc>().add(InitializeCamera());
                      },
                      icon: const Icon(Icons.camera_alt),
                      label: Text(l10n.startCamera),
                    ),
                    if (classes.length > 1) ...[
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          context
                              .read<CameraFlowBloc>()
                              .add(const CameraFlowChangeClub());
                        },
                        child: Text(l10n.chooseClub),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }
          if (classes.length > 1 && flowState.step == CameraFlowStep.clubSelection) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: classes.length,
              itemBuilder: (context, index) {
                final classItem = classes[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(classItem.displayName),
                    subtitle: classItem.course != null
                        ? Text(classItem.course!.displayName)
                        : null,
                    onTap: () {
                      context
                          .read<CameraFlowBloc>()
                          .add(CameraFlowSelectClub(classItem));
                    },
                  ),
                );
              },
            );
          }
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildCamera(BuildContext context, AppLocalizations l10n) {
    return BlocConsumer<CameraBloc, CameraState>(
      listener: (context, cameraState) {
        if (cameraState is CameraCaptured) {
          context
              .read<CameraFlowBloc>()
              .add(CameraFlowPhotoCaptured(cameraState.imagePath));
        }
      },
      builder: (context, cameraState) {
        if (cameraState is CameraLoading) {
          return const Center(child: LoadingWidget());
        }
        if (cameraState is CameraError) {
          return ErrorDisplayWidget(
            message: cameraState.message,
            onRetry: () => context.read<CameraBloc>().add(InitializeCamera()),
          );
        }
        if (cameraState is CameraReady) {
          return Stack(
            children: [
              Positioned.fill(
                child: FaceDetectionCameraView(
                  key: _faceDetectionKey,
                  controller: cameraState.controller,
                  overlay: CameraGrid(
                    color: Colors.white,
                    strokeWidth: 1.0,
                  ),
                ),
              ),
              Positioned(
                bottom: 32,
                left: 0,
                right: 0,
                child: Center(
                  child: FloatingActionButton(
                    onPressed: () {
                      //stop face detection stream before capture
                      _faceDetectionKey.currentState?.stopDetection();
                      context.read<CameraBloc>().add(CapturePhoto());
                    },
                    child: const Icon(Icons.camera_alt),
                  ),
                ),
              ),
            ],
          );
        }
        if (cameraState is CameraCapturing) {
          return const Center(child: CircularProgressIndicator());
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildCapturedPreview(
    BuildContext context,
    CameraFlowState flowState,
    AppLocalizations l10n,
  ) {
    final path = flowState.lastCapturedPath!;
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(path),
                width: 300,
                height: 400,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 300,
                    height: 400,
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.image_not_supported,
                      size: 64,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            if (flowState.step == CameraFlowStep.recognizing)
              const Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              )
            else ...[
              FilledButton(
                onPressed: () {
                  context
                      .read<CameraFlowBloc>()
                      .add(CameraFlowUsePhotoAndRecognize(path));
                },
                child: Text(l10n.useThisPhoto),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  context.read<CameraFlowBloc>().add(const CameraFlowTakeNext());
                  context.read<CameraBloc>().add(InitializeCamera());
                },
                child: Text(l10n.retake),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FilledButton.tonal(
                    onPressed: () {
                      context
                          .read<CameraFlowBloc>()
                          .add(const CameraFlowTakeNext());
                      context.read<CameraBloc>().add(InitializeCamera());
                    },
                    child: Text(l10n.takeNext),
                  ),
                  const SizedBox(width: 16),
                  FilledButton(
                    onPressed: () {
                      context
                          .read<CameraFlowBloc>()
                          .add(const CameraFlowFinishSession());
                    },
                    child: Text(l10n.done),
                  ),
                ],
              ),
            ],
            if (flowState.recognizeError != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  flowState.recognizeError!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                ),
              ),
            if (flowState.recognizedUuids.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  '${l10n.present}: ${flowState.recognizedUuids.length}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(
    BuildContext context,
    CameraFlowState flowState,
    AppLocalizations l10n,
  ) {
    final presentChildren = flowState.children
        .where((c) => c.kbUuid != null && flowState.recognizedUuids.contains(c.kbUuid))
        .toList();
    final missingChildren = flowState.children
        .where((c) => c.kbUuid == null || !flowState.recognizedUuids.contains(c.kbUuid))
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.present,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          const SizedBox(height: 8),
          if (presentChildren.isEmpty)
            Text(
              l10n.noDataAvailable,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            )
          else
            ...presentChildren.map(
              (c) => ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: Text(c.fullName),
              ),
            ),
          const SizedBox(height: 24),
          Text(
            l10n.missing,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.error,
                ),
          ),
          const SizedBox(height: 8),
          if (missingChildren.isEmpty)
            Text(
              l10n.noDataAvailable,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            )
          else
            ...missingChildren.map(
              (c) => ListTile(
                leading: Icon(
                  Icons.cancel,
                  color: Theme.of(context).colorScheme.error,
                ),
                title: Text(c.fullName),
              ),
            ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: () {
              context
                  .read<CameraFlowBloc>()
                  .add(const CameraFlowNewSession());
              context.read<CameraBloc>().add(ResetCamera());
            },
            child: Text(l10n.startCamera),
          ),
        ],
      ),
    );
  }
}
