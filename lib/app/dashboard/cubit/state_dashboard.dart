import 'package:equatable/equatable.dart';

enum DashboardPage {
  main,
  video,
  radio,
  login,
}

class StateDashboard extends Equatable {
  const StateDashboard({
    this.page = DashboardPage.login,
    this.pageData = const {},
  });

  StateDashboard copyWith({
    DashboardPage? page,
    Map<DashboardPage, dynamic>? pageData,
  }) {
    return StateDashboard(
      page: page ?? this.page,
      pageData: pageData ?? this.pageData,
    );
  }

  final DashboardPage page;
  final Map<DashboardPage, dynamic> pageData;

  @override
  List<Object?> get props => [
        page,
        pageData,
        pageData.length,
        pageData.hashCode,
      ];
}
