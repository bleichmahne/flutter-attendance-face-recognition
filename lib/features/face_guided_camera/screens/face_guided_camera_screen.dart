import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/face_detection_service.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../bloc/face_guided_camera_bloc.dart';
import '../widgets/face_overlay_painter.dart';
import '../widgets/pose_progress_indicator.dart';

//full-screen face-guided camera for capturing 3 posed photos
class FaceGuidedCameraScreen extends StatelessWidget {
  const FaceGuidedCameraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FaceGuidedCameraBloc(
        faceDetectionService: FaceDetectionService(),
      )..add(const InitGuidedCamera()),
      child: const _FaceGuidedCameraBody(),
    );
  }
}

class _FaceGuidedCameraBody extends StatelessWidget {
  const _FaceGuidedCameraBody();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<FaceGuidedCameraBloc, FaceGuidedCameraState>(
      listenWhen: (prev, curr) => prev.step != curr.step,
      listener: (context, state) {
        if (state.step == GuidedCameraStep.completed) {
          //return captured photos and pop
          final photos =
              state.capturedPhotos.map((p) => File(p)).toList();
          Navigator.of(context).pop(photos);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            title: Text(l10n.guidedPhotoCapture),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: _buildBody(context, state, l10n),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    FaceGuidedCameraState state,
    AppLocalizations l10n,
  ) {
    switch (state.step) {
      case GuidedCameraStep.initializing:
        return const Center(
          child: CircularProgressIndicator(color: Colors.white),
        );

      case GuidedCameraStep.guiding:
      case GuidedCameraStep.capturing:
        return _buildCameraView(context, state, l10n);

      case GuidedCameraStep.reviewing:
        return _buildReviewView(context, state, l10n);

      case GuidedCameraStep.completed:
        return const Center(
          child: CircularProgressIndicator(color: Colors.white),
        );

      case GuidedCameraStep.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  state.error ?? 'unknown error',
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => context
                      .read<FaceGuidedCameraBloc>()
                      .add(const InitGuidedCamera()),
                  child: Text(l10n.retry),
                ),
              ],
            ),
          ),
        );
    }
  }

  Widget _buildCameraView(
    BuildContext context,
    FaceGuidedCameraState state,
    AppLocalizations l10n,
  ) {
    if (state.controller == null || !state.controller!.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    final poseMatches = state.detectedPose == state.requiredPose;

    return Stack(
      fit: StackFit.expand,
      children: [
        //layer 1: camera preview
        CameraPreview(state.controller!),

        //layer 2: face overlay
        CustomPaint(
          painter: FaceOverlayPainter(
            faceBoundingBox: state.faceBoundingBox,
            imageSize: state.imageSize,
            poseMatches: poseMatches,
            isFrontCamera: true,
          ),
        ),

        //layer 3: top pose instruction banner
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: _buildInstructionBanner(context, state, l10n),
        ),

        //layer 4: bottom progress indicator
        Positioned(
          bottom: 120,
          left: 0,
          right: 0,
          child: Center(
            child: PoseProgressIndicator(progress: state.holdProgress),
          ),
        ),

        //layer 5: bottom photo thumbnails
        Positioned(
          bottom: 24,
          left: 16,
          right: 16,
          child: _buildThumbnailStrip(context, state, l10n),
        ),
      ],
    );
  }

  Widget _buildInstructionBanner(
    BuildContext context,
    FaceGuidedCameraState state,
    AppLocalizations l10n,
  ) {
    final String instruction;
    final IconData icon;
    final Color iconColor;

    if (state.detectedPose == null) {
      instruction = l10n.faceNotDetected;
      icon = Icons.face_retouching_off;
      iconColor = Colors.red;
    } else if (state.detectedPose == state.requiredPose) {
      instruction = l10n.holdSteady;
      icon = Icons.check_circle;
      iconColor = Colors.green;
    } else {
      instruction = _poseInstruction(state.requiredPose, l10n);
      icon = Icons.info_outline;
      iconColor = Colors.orange;
    }

    return Container(
      color: Colors.black54,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: 12),
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    instruction,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.nOfThreePhotos(state.capturedPhotos.length + 1),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnailStrip(
    BuildContext context,
    FaceGuidedCameraState state,
    AppLocalizations l10n,
  ) {
    final labels = [l10n.photoFront, l10n.photoLeft, l10n.photoRight];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final isCaptured = index < state.capturedPhotos.length;
        final isCurrent = index == state.currentPoseIndex;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 6),
          width: 64,
          height: 80,
          decoration: BoxDecoration(
            border: Border.all(
              color: isCurrent
                  ? Theme.of(context).colorScheme.primary
                  : Colors.white.withValues(alpha: 0.3),
              width: isCurrent ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: isCaptured
                ? Image.file(
                    File(state.capturedPhotos[index]),
                    fit: BoxFit.cover,
                  )
                : Center(
                    child: Text(
                      labels[index],
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
          ),
        );
      }),
    );
  }

  Widget _buildReviewView(
    BuildContext context,
    FaceGuidedCameraState state,
    AppLocalizations l10n,
  ) {
    final lastPhoto = state.capturedPhotos.isNotEmpty
        ? state.capturedPhotos.last
        : null;

    return Column(
      children: [
        Expanded(
          child: lastPhoto != null
              ? Image.file(
                  File(lastPhoto),
                  fit: BoxFit.contain,
                )
              : const SizedBox.shrink(),
        ),
        Container(
          color: Colors.black,
          padding: const EdgeInsets.all(16),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      l10n.photoCaptured,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.nOfThreePhotos(state.capturedPhotos.length),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 16),
                //thumbnail strip
                _buildThumbnailStrip(context, state, l10n),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white54),
                        ),
                        onPressed: () => context
                            .read<FaceGuidedCameraBloc>()
                            .add(const RetakePhoto()),
                        child: Text(l10n.retake),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => context
                            .read<FaceGuidedCameraBloc>()
                            .add(const AcceptPhoto()),
                        child: Text(
                          state.capturedPhotos.length >= 3
                              ? l10n.done
                              : l10n.takeNext,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _poseInstruction(FacePose pose, AppLocalizations l10n) {
    switch (pose) {
      case FacePose.front:
        return l10n.photoFrontHint;
      case FacePose.left:
        return l10n.photoLeftHint;
      case FacePose.right:
        return l10n.photoRightHint;
      case FacePose.unknown:
        return '';
    }
  }
}
