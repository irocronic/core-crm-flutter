// lib/shared/models/pagination_model.dart
class PaginationModel<T> {
  final int count;
  final String? next;
  final String? previous;
  final List<T> results;

  PaginationModel({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory PaginationModel.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    return PaginationModel<T>(
      count: json['count'] as int,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: (json['results'] as List)
          .map((item) => fromJsonT(item))
          .toList(),
    );
  }

  bool get hasNext => next != null;
  bool get hasPrevious => previous != null;
}