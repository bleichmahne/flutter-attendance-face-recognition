import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/models/child.dart';
import '../../../core/models/class_model.dart';
import '../../../core/services/auth_storage_service.dart';
import '../../../core/services/face_recognition_service.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../../clubs/bloc/club_bloc.dart';
import '../../face_guided_camera/screens/face_guided_camera_screen.dart';
import '../../face_recognition/bloc/face_recognition_bloc.dart';

class UserImageRecognitionScreen extends StatefulWidget {
  final Child? child;
  final ClassModel? classItem;
  final bool isPhotoUpdate;

  const UserImageRecognitionScreen({
    super.key,
    this.child,
    this.classItem,
    this.isPhotoUpdate = false,
  });

  @override
  State<UserImageRecognitionScreen> createState() =>
      _UserImageRecognitionScreenState();
}

class _UserImageRecognitionScreenState
    extends State<UserImageRecognitionScreen> {
  final List<File?> _photos = [null, null, null];
  final ImagePicker _picker = ImagePicker();
  ClassModel? _selectedClass;
  final TextEditingController _voucherController = TextEditingController();
  final FaceRecognitionService _faceService = FaceRecognitionService();
  bool _submitting = false;
  bool _takingSequence = false;
  int? _sequenceStep;
  File? _singlePhoto;
  bool _recognizing = false;
  bool? _recognizedMatch;

  bool get _isSingleStudentMode =>
      widget.child != null && widget.classItem != null && !widget.isPhotoUpdate;

  bool get _isPhotoUpdateMode => widget.isPhotoUpdate && widget.child != null;

  @override
  void initState() {
    super.initState();
    if (!_isSingleStudentMode && !_isPhotoUpdateMode) {
      context.read<ClubBloc>().add(LoadClubs());
    } else {
      _selectedClass = widget.classItem;
    }
  }

  @override
  void dispose() {
    _voucherController.dispose();
    super.dispose();
  }

  Future<void> _takePhoto(int index) async {
    final xFile = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.rear,
    );
    if (xFile != null && mounted) {
      setState(() {
        _photos[index] = File(xFile.path);
      });
    }
  }

  Future<void> _takePhotosInSequence() async {
    if (_takingSequence) return;
    setState(() => _takingSequence = true);
    for (int i = 0; i < 3 && mounted; i++) {
      setState(() => _sequenceStep = i + 1);
      await _takePhoto(i);
    }
    if (mounted) {
      setState(() {
        _takingSequence = false;
        _sequenceStep = null;
      });
    }
  }

  Future<void> _takeGuidedPhotos() async {
    final result = await Navigator.of(context).push<List<File>>(
      MaterialPageRoute(builder: (_) => const FaceGuidedCameraScreen()),
    );
    if (result != null && result.length == 3 && mounted) {
      setState(() {
        _photos[0] = result[0];
        _photos[1] = result[1];
        _photos[2] = result[2];
      });
    }
  }

  void _clearImages() {
    setState(() {
      _photos[0] = null;
      _photos[1] = null;
      _photos[2] = null;
    });
  }

  bool get _canSubmit {
    final hasThreePhotos =
        _photos.every((p) => p != null) && _photos.length == 3;
    if (_isPhotoUpdateMode) {
      return hasThreePhotos && !_submitting;
    }
    final hasClub = _selectedClass != null;
    final hasVoucher = _voucherController.text.trim().isNotEmpty;
    return hasThreePhotos && hasClub && hasVoucher && !_submitting;
  }

  bool get _hasAnyPhoto => _photos.any((p) => p != null);

  String _sequenceHint(AppLocalizations l10n) {
    switch (_sequenceStep) {
      case 1:
        return '${l10n.photoNOf3(1)} — ${l10n.photoFrontHint}';
      case 2:
        return '${l10n.photoNOf3(2)} — ${l10n.photoLeftHint}';
      case 3:
        return '${l10n.photoNOf3(3)} — ${l10n.photoRightHint}';
      default:
        return l10n.take3PhotosInSequence;
    }
  }

  Widget _buildPhotoSlot(int index, String label, String hint) {
    return Expanded(
      child: Padding(
        
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: _PhotoSlot(
          file: _photos[index],
          label: label,
          hint: hint,
          onTap: () {}, //() => _takePhoto(index),
        ),
      ),
    );
  }

  Future<void> _takeSinglePhoto() async {
    final xFile = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.rear,
    );
    if (xFile != null && mounted) {
      setState(() {
        _singlePhoto = File(xFile.path);
        _recognizedMatch = null;
      });
    }
  }

  Future<void> _checkSingleStudent() async {
    if (_singlePhoto == null || widget.child == null) return;
    final child = widget.child!;
    setState(() {
      _recognizing = true;
      _recognizedMatch = null;
    });
    try {
      //same auth shape as /verify: username = user.username, password = user.kbUuid
      final user = await AuthStorageService().getUser();
      final sectionId = widget.classItem?.id;
      if (user == null || sectionId == null) {
        if (!mounted) return;
        setState(() {
          _recognizing = false;
          _recognizedMatch = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('missing credentials or class'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return;
      }
      final result = await _faceService.recognize(
        _singlePhoto!,
        username: user.username,
        password: user.kbUuid,
        sectionId: sectionId,
        threshold: 0.8,
      );
      if (!mounted) return;
      final match = result.recognized && result.uuid == child.kbUuid;
      setState(() {
        _recognizing = false;
        _recognizedMatch = match;
      });
      if (match) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.studentPresent),
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _recognizing = false;
          _recognizedMatch = false;
        });
        String message = e.toString();
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
    }
  }

  void _submitPhotoUpdate() {
    final photos = _photos.whereType<File>().toList();
    if (photos.length != 3 || widget.child?.kbUuid == null) return;
    final uuid = widget.child!.kbUuid!;
    if (widget.child!.hasImage == true) {
      context.read<FaceRecognitionBloc>().add(
        UpdateUserPhotos(uuid: uuid, photos: photos),
      );
    } else {
      context.read<FaceRecognitionBloc>().add(
        CreateFaceUser(uuid: uuid, photos: photos),
      );
    }
  }

  Future<void> _submit() async {
    if (!_canSubmit) return;
    final voucher = _voucherController.text.trim();
    final photos = _photos.whereType<File>().toList();
    if (photos.length != 3) return;

    setState(() => _submitting = true);
    try {
      await _faceService.createUser(voucher, photos);
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.userRegisteredFor(voucher, _selectedClass!.displayName),
          ),
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        ),
      );
      setState(() {
        _photos[0] = null;
        _photos[1] = null;
        _photos[2] = null;
        _selectedClass = null;
        _voucherController.clear();
      });
    } catch (e) {
      if (!mounted) return;
      String message = e.toString();
      if (message.startsWith('Exception: ')) {
        message = message.substring(11);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  Future<void> _onRefresh() async {
    _clearImages();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_isPhotoUpdateMode) {
      return _buildPhotoUpdateBody(l10n);
    }
    if (_isSingleStudentMode) {
      return _buildSingleStudentBody(l10n);
    }
    return Scaffold(
      appBar: AppBar(title: Text(l10n.userImageRecognition)),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.take3PicturesOfUser,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Card(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 20,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                l10n.photoTips,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: _takeGuidedPhotos,
                      icon: const Icon(Icons.face),
                      label: Text(l10n.guidedPhotoCapture),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.guidedPhotoSubtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    // FilledButton.tonalIcon(
                    //   onPressed: _takingSequence ? null : _takePhotosInSequence,
                    //   icon: _takingSequence
                    //       ? const SizedBox(
                    //           width: 20,
                    //           height: 20,
                    //           child: CircularProgressIndicator(strokeWidth: 2),
                    //         )
                    //       : const Icon(Icons.camera_alt),
                    //   label: Text(
                    //     _takingSequence && _sequenceStep != null
                    //         ? _sequenceHint(l10n)
                    //         : l10n.take3PhotosInSequence,
                    //   ),
                    // ),
                    // const SizedBox(height: 12),
                    Text(
                      l10n.orTapBoxToTakeOrReplace,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildPhotoSlot(
                          0,
                          l10n.photoFront,
                          l10n.photoFrontHint,
                        ),
                        _buildPhotoSlot(1, l10n.photoLeft, l10n.photoLeftHint),
                        _buildPhotoSlot(
                          2,
                          l10n.photoRight,
                          l10n.photoRightHint,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.selectClub,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    BlocBuilder<ClubBloc, ClubState>(
                      builder: (context, clubState) {
                        if (clubState is ClubLoading) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        if (clubState is ClubError) {
                          return Text(
                            clubState.message,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          );
                        }
                        if (clubState is ClubLoaded) {
                          final classes = clubState.classes;
                          if (classes.isEmpty) {
                            return Text(l10n.noClubsAvailable);
                          }
                          return DropdownButtonFormField<ClassModel>(
                            value: _selectedClass,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            hint: Text(l10n.chooseClub),
                            items: classes
                                .map(
                                  (c) => DropdownMenuItem(
                                    value: c,
                                    child: Text(c.displayName),
                                  ),
                                )
                                .toList(),
                            onChanged: (classItem) {
                              setState(() => _selectedClass = classItem);
                            },
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.voucherNumber,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _voucherController,
                      decoration: InputDecoration(
                        hintText: l10n.enterVoucherNumber,
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.text,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  OutlinedButton.icon(
                    onPressed: _hasAnyPhoto ? _clearImages : null,
                    icon: const Icon(Icons.delete_outline),
                    label: Text(l10n.clearImages),
                  ),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: _canSubmit ? _submit : null,
                    child: _submitting
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.submit),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoUpdateBody(AppLocalizations l10n) {
    final name = widget.child?.fullName ?? widget.child?.kbUuid ?? '';
    return BlocListener<FaceRecognitionBloc, FaceRecognitionState>(
      listener: (context, state) {
        if (state is FaceRecognitionLoading) {
          setState(() => _submitting = true);
          return;
        }
        setState(() => _submitting = false);
        if (state is FaceRecognitionUserCreated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.photosUpdated),
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            ),
          );
          Navigator.of(context).pop(true);
        } else if (state is FaceRecognitionPhotosUpdated) {
          if (state.result.isUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.photosUpdated),
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              ),
            );
            Navigator.of(context).pop(true);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.photosRejected),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        } else if (state is FaceRecognitionError) {
          var message = state.message;
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
      },
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.updatePhotosFor(name))),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.take3PicturesOfUser,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Card(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 20,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                l10n.photoTips,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: _submitting ? null : _takeGuidedPhotos,
                      icon: const Icon(Icons.face),
                      label: Text(l10n.guidedPhotoCapture),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.guidedPhotoSubtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    // const SizedBox(height: 12),
                    // FilledButton.tonalIcon(
                    //   onPressed: _takingSequence || _submitting
                    //       ? null
                    //       : _takePhotosInSequence,
                    //   icon: _takingSequence
                    //       ? const SizedBox(
                    //           width: 20,
                    //           height: 20,
                    //           child: CircularProgressIndicator(strokeWidth: 2),
                    //         )
                    //       : const Icon(Icons.camera_alt),
                    //   label: Text(
                    //     _takingSequence && _sequenceStep != null
                    //         ? _sequenceHint(l10n)
                    //         : l10n.take3PhotosInSequence,
                    //   ),
                    // ),
                    // const SizedBox(height: 12),
                    Text(
                      l10n.orTapBoxToTakeOrReplace,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildPhotoSlot(
                          0,
                          l10n.photoFront,
                          l10n.photoFrontHint,
                        ),
                        _buildPhotoSlot(1, l10n.photoLeft, l10n.photoLeftHint),
                        _buildPhotoSlot(
                          2,
                          l10n.photoRight,
                          l10n.photoRightHint,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _hasAnyPhoto && !_submitting
                          ? _clearImages
                          : null,
                      icon: const Icon(Icons.delete_outline),
                      label: Text(l10n.clearImages),
                    ),
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: _canSubmit ? _submitPhotoUpdate : null,
                      child: _submitting
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l10n.updatePhotos),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSingleStudentBody(AppLocalizations l10n) {
    final name = widget.child?.fullName ?? widget.child?.kbUuid ?? '';
    return Scaffold(
      appBar: AppBar(title: Text(l10n.checkAttendanceFor(name))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.takePhotoToRecognize,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _recognizing ? null : _takeSinglePhoto,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _singlePhoto == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo,
                            size: 48,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.takePhotoToRecognize,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          _singlePhoto!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
              ),
            ),
            if (_recognizedMatch != null) ...[
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _recognizedMatch! ? Icons.check_circle : Icons.cancel,
                    size: 48,
                    color: _recognizedMatch!
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _recognizedMatch!
                        ? l10n.studentPresent
                        : l10n.notRecognized,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: _recognizedMatch!
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _singlePhoto != null && !_recognizing
                  ? _checkSingleStudent
                  : null,
              child: _recognizing
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.recognizing),
            ),
            if (_singlePhoto != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: OutlinedButton(
                  onPressed: _recognizing
                      ? null
                      : () {
                          setState(() {
                            _singlePhoto = null;
                            _recognizedMatch = null;
                          });
                        },
                  child: Text(l10n.retake),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PhotoSlot extends StatelessWidget {
  final File? file;
  final String label;
  final String? hint;
  final VoidCallback onTap;

  const _PhotoSlot({
    required this.file,
    required this.label,
    this.hint,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 100,width: 100,
            decoration: BoxDecoration(
              border: Border.all(
                color: file != null
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: file == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_a_photo,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        label,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )
                : Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(7),
                        child: Image.file(
                          file!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(7),
                              bottomRight: Radius.circular(7),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            label,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
          if (hint != null) ...[
            const SizedBox(height: 4),
            Text(
              hint!,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
