import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/child.dart';
import '../../../core/models/class_model.dart';
import '../../../core/services/api_service.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../core/widgets/error_widget.dart';
import '../../../generated/l10n/app_localizations.dart';
import 'child_detail_screen.dart';

class ClubKidsScreen extends StatefulWidget {
  final ClassModel classItem;

  const ClubKidsScreen({super.key, required this.classItem});

  @override
  State<ClubKidsScreen> createState() => _ClubKidsScreenState();
}

class _ClubKidsScreenState extends State<ClubKidsScreen> {
  List<Child>? _children;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadChildren();
  }

  Future<void> _loadChildren() async {
    final classId = widget.classItem.id;
    if (classId == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final apiService = context.read<ApiService>();
      final list = await apiService.getChildrenInClass(classId);
      if (mounted) {
        setState(() {
          _children = list;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  void _openChildDetail(Child child) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChildDetailScreen(
          child: child,
          classItem: widget.classItem,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.classItem.displayName),
      ),
      body: _loading
          ? const Center(child: SizedBox(height: 200, child: LoadingWidget()))
          : _error != null
              ? ErrorDisplayWidget(
                  message: _error!,
                  onRetry: _loadChildren,
                )
              : _children == null || _children!.isEmpty
                  ? Center(child: Text(l10n.noKidsInClub))
                  : RefreshIndicator(
                      onRefresh: _loadChildren,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                        itemCount: _children!.length,
                        itemBuilder: (context, index) {
                          final child = _children![index];
                          final hasImage = child.hasImage == true;
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: CircleAvatar(
                                backgroundColor: hasImage
                                    ? Theme.of(context).colorScheme.primaryContainer
                                    : Theme.of(context).colorScheme.errorContainer,
                                child: Icon(
                                  hasImage ? Icons.person : Icons.person_off,
                                  color: hasImage
                                      ? Theme.of(context).colorScheme.onPrimaryContainer
                                      : Theme.of(context).colorScheme.onErrorContainer,
                                ),
                              ),
                              title: Text(
                                child.fullName,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (child.age != null)
                                    Text(
                                      '${l10n.age}: ${child.age}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                    ),
                                  if (!hasImage)
                                    Text(
                                      l10n.noPhotosRegistered,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .error,
                                          ),
                                    ),
                                ],
                              ),
                              onTap: () => _openChildDetail(child),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
