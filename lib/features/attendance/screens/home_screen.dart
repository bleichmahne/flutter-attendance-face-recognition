import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../clubs/bloc/organization_bloc.dart';
import '../../clubs/screens/courses_screen.dart';
import '../../report_cards/bloc/report_card_bloc.dart';
import '../../../core/widgets/report_card_widget.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../core/widgets/error_widget.dart';
import '../../../generated/l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.home),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.organizations),
            Tab(text: l10n.reportCards),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _OrganizationsTab(),
          _ReportCardsTab(),
        ],
      ),
    );
  }
}

class _OrganizationsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<OrganizationBloc, OrganizationState>(
      builder: (context, state) {
        if (state is OrganizationLoading) {
          return const Center(
            child: SizedBox(height: 200, child: LoadingWidget()),
          );
        }
        if (state is OrganizationError) {
          return ErrorDisplayWidget(
            message: state.message,
            onRetry: () => context.read<OrganizationBloc>().add(const LoadOrganizations()),
          );
        }
        if (state is OrganizationLoaded) {
          if (state.organizations.isEmpty) {
            return Center(child: Text(l10n.noOrganizations));
          }
          return RefreshIndicator(
            onRefresh: () async {
              context.read<OrganizationBloc>().add(const RefreshOrganizations());
            },
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              itemCount: state.organizations.length,
              itemBuilder: (context, index) {
                final org = state.organizations[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      child: Icon(
                        Icons.business,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                    title: Text(
                      org.name,
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
                          builder: (_) => CoursesScreen(organization: org),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _ReportCardsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportCardBloc, ReportCardState>(
      builder: (context, reportCardState) {
        if (reportCardState is ReportCardLoading) {
          return const Center(
            child: SizedBox(height: 200, child: LoadingWidget()),
          );
        }
        if (reportCardState is ReportCardError) {
          return ErrorDisplayWidget(
            message: reportCardState.message,
            onRetry: () =>
                context.read<ReportCardBloc>().add(LoadReportCards()),
          );
        }
        if (reportCardState is ReportCardLoaded) {
          if (reportCardState.visitHistories.isEmpty) {
            return Center(
              child: Text(AppLocalizations.of(context)!.noReportCards),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 24),
            itemCount: reportCardState.visitHistories.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    AppLocalizations.of(context)!.reportCards,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }
              return ReportCardWidget(
                visitHistory: reportCardState.visitHistories[index - 1],
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
