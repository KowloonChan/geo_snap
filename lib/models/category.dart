class BlogCategory {
  int? categoryId;
  String categoryName;
  static const List<String> categoryNames = [
    'General',
    'Travel',
    'Food',
    'Lifestyle',
    'Technology',
    'Sports',
    'Entertainment',
    'Health',
    'Education',
    'Business',
  ];

  BlogCategory({this.categoryId, required this.categoryName});

  factory BlogCategory.fromMap(Map<String, dynamic> map) {
    return BlogCategory(
      categoryId: map['categoryId'] as int?,
      categoryName: map['categoryName'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {'categoryId': categoryId, 'categoryName': categoryName};
  }
}
