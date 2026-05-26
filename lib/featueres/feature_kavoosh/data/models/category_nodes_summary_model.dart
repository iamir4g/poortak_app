class CategoryNodesSummaryResponse {
  final bool ok;
  final Map<String, dynamic> meta;
  final List<CategoryNodeSummary> data;
 
  CategoryNodesSummaryResponse({
    required this.ok,
    required this.meta,
    required this.data,
  });
 
  factory CategoryNodesSummaryResponse.fromJson(Map<String, dynamic> json) {
    return CategoryNodesSummaryResponse(
      ok: json['ok'] == true,
      meta: (json['meta'] as Map?)?.cast<String, dynamic>() ?? {},
      data: (json['data'] as List? ?? [])
          .map((e) => CategoryNodeSummary.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
    );
  }
}
 
class CategoryNodeSummary {
  final String id;
  final String title;
  final String description;
  final String type;
  final String treeId;
  final String? parentId;
  final int order;
  final DateTime createdAt;
  final DateTime updatedAt;
  final CategoryNodeCount count;
  final List<CategoryNodeSummary> children;
 
  CategoryNodeSummary({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.treeId,
    required this.parentId,
    required this.order,
    required this.createdAt,
    required this.updatedAt,
    required this.count,
    required this.children,
  });
 
  factory CategoryNodeSummary.fromJson(Map<String, dynamic> json) {
    return CategoryNodeSummary(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      treeId: json['treeId']?.toString() ?? '',
      parentId: json['parentId']?.toString(),
      order: (json['order'] is int) ? json['order'] as int : int.tryParse('${json['order']}') ?? 0,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0),
      count: CategoryNodeCount.fromJson((json['_count'] as Map?)?.cast<String, dynamic>() ?? {}),
      children: (json['children'] as List? ?? [])
          .map((e) => CategoryNodeSummary.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
    );
  }
}
 
class CategoryNodeCount {
  final int courses;
  final int children;
 
  CategoryNodeCount({
    required this.courses,
    required this.children,
  });
 
  factory CategoryNodeCount.fromJson(Map<String, dynamic> json) {
    return CategoryNodeCount(
      courses: (json['courses'] is int) ? json['courses'] as int : int.tryParse('${json['courses']}') ?? 0,
      children: (json['children'] is int) ? json['children'] as int : int.tryParse('${json['children']}') ?? 0,
    );
  }
}
