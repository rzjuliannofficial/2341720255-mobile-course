/// Filter options based on note synchronization state.
enum NoteSyncFilter { all, dirtyOnly, syncedOnly }

/// Sort order options for displaying notes.
enum NoteSortOrder { newestFirst, titleAsc }

/// Immutable search, filter, and sort parameters in the domain layer.
class NotesQuery {
  const NotesQuery({
    this.query = '',
    this.syncFilter = NoteSyncFilter.all,
    this.sortOrder = NoteSortOrder.newestFirst,
  });

  final String query;
  final NoteSyncFilter syncFilter;
  final NoteSortOrder sortOrder;

  /// Whether all query, filter, and sort controls are at default values.
  bool get isDefault =>
      query.trim().isEmpty &&
      syncFilter == NoteSyncFilter.all &&
      sortOrder == NoteSortOrder.newestFirst;

  NotesQuery copyWith({
    String? query,
    NoteSyncFilter? syncFilter,
    NoteSortOrder? sortOrder,
  }) {
    return NotesQuery(
      query: query ?? this.query,
      syncFilter: syncFilter ?? this.syncFilter,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotesQuery &&
          runtimeType == other.runtimeType &&
          query == other.query &&
          syncFilter == other.syncFilter &&
          sortOrder == other.sortOrder;

  @override
  int get hashCode => Object.hash(query, syncFilter, sortOrder);
}
