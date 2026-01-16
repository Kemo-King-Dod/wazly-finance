/// Enum for time period filters in analytics
enum TimeFilter {
  /// Current month
  thisMonth,

  /// Previous month
  lastMonth,

  /// All time (no filter)
  allTime,
}

/// Extension for TimeFilter display names
extension TimeFilterExtension on TimeFilter {
  String get displayName {
    switch (this) {
      case TimeFilter.thisMonth:
        return 'This Month';
      case TimeFilter.lastMonth:
        return 'Last Month';
      case TimeFilter.allTime:
        return 'All Time';
    }
  }
}
