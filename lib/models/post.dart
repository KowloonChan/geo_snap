class Post {
	int? postId;
	int userId;
	int categoryId;
	String title;
	String description;
	int likesCount;
	double latitude;
	double longitude;
	int createdAt;

	Post({
		this.postId,
		required this.userId,
		required this.categoryId,
		required this.title,
		required this.description,
		required this.likesCount,
		required this.latitude,
		required this.longitude,
		required this.createdAt,
	});

	factory Post.fromMap(Map<String, dynamic> map) {
		return Post(
			postId: map['postId'] as int?,
			userId: map['userId'] as int,
			categoryId: map['categoryId'] as int,
			title: map['title'] as String,
			description: map['description'] as String,
			likesCount: map['likesCount'] as int,
			latitude: (map['latitude'] as num).toDouble(),
			longitude: (map['longitude'] as num).toDouble(),
			createdAt: map['createdAt'] as int,
		);
	}

	Map<String, dynamic> toMap() {
		return {
			'postId': postId,
			'userId': userId,
			'categoryId': categoryId,
			'title': title,
			'description': description,
			'likesCount': likesCount,
			'latitude': latitude,
			'longitude': longitude,
			'createdAt': createdAt,
		};
	}
}
