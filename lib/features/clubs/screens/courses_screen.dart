import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/organization.dart';
import '../../../core/services/api_service.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../core/widgets/error_widget.dart';
import '../../../generated/l10n/app_localizations.dart';
import '../bloc/course_bloc.dart';
import 'classes_screen.dart';

class CoursesScreen extends StatelessWidget {
  final Organization organization;

  const CoursesScreen({super.key, required this.organization});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocProvider(
      create: (context) => CourseBloc(apiService: context.read<ApiService>())
        ..add(LoadCourses(organizationId: organization.id)),
      child: Scaffold(
        appBar: AppBar(
          title: Text(organization.name),
        ),
        body: BlocBuilder<CourseBloc, CourseState>(
          builder: (context, state) {
            if (state is CourseLoading) {
              return const Center(child: SizedBox(height: 200, child: LoadingWidget()));
            }
            if (state is CourseError) {
              return ErrorDisplayWidget(
                message: state.message,
                onRetry: () => context.read<CourseBloc>().add(
                      LoadCourses(organizationId: organization.id),
                    ),
              );
            }
            if (state is CourseLoaded) {
              if (state.courses.isEmpty) {
                return Center(child: Text(l10n.noCourses));
              }
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                itemCount: state.courses.length,
                itemBuilder: (context, index) {
                  final course = state.courses[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        child: Icon(
                          Icons.school,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                      title: Text(
                        course.displayName,
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
                            builder: (_) => ClassesScreen(course: course),
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
