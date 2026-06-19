import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/course.dart';
import '../../../core/services/api_service.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../core/widgets/error_widget.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../bloc/class_bloc.dart';
import 'club_kids_screen.dart';

class ClassesScreen extends StatelessWidget {
  final Course course;

  const ClassesScreen({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final courseId = course.id;
    if (courseId == null) {
      return Scaffold(
        appBar: AppBar(title: Text(course.displayName)),
        body: Center(child: Text(l10n.noClasses)),
      );
    }
    return BlocProvider(
      create: (context) => ClassBloc(apiService: context.read<ApiService>())
        ..add(LoadClassesByCourse(courseId: courseId)),
      child: Scaffold(
        appBar: AppBar(
          title: Text(course.displayName),
        ),
        body: BlocBuilder<ClassBloc, ClassState>(
          builder: (context, state) {
            if (state is ClassLoading) {
              return const Center(child: SizedBox(height: 200, child: LoadingWidget()));
            }
            if (state is ClassError) {
              return ErrorDisplayWidget(
                message: state.message,
                onRetry: () => context.read<ClassBloc>().add(
                      LoadClassesByCourse(courseId: courseId),
                    ),
              );
            }
            if (state is ClassLoaded) {
              if (state.classes.isEmpty) {
                return Center(child: Text(l10n.noClasses));
              }
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                itemCount: state.classes.length,
                itemBuilder: (context, index) {
                  final classItem = state.classes[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        child: Icon(
                          Icons.group,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                      title: Text(
                        classItem.displayName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      trailing: Icon(
                        Icons.chevron_right,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => ClubKidsScreen(classItem: classItem),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
