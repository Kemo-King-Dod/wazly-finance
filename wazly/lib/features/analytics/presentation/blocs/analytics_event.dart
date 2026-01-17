import 'package:equatable/equatable.dart';
import '../../domain/entities/time_filter.dart';

abstract class AnalyticsEvent extends Equatable {
  const AnalyticsEvent();

  @override
  List<Object?> get props => [];
}

class FetchAnalyticsData extends AnalyticsEvent {
  final TimeFilter filter;

  const FetchAnalyticsData(this.filter);

  @override
  List<Object?> get props => [filter];
}
