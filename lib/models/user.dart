class User {
	int? userId;
	String username;
	String password;
	int age;
	String gender;
	String topicPreference;

	User({
		this.userId,
		required this.username,
		required this.password,
		required this.age,
		required this.gender,
		required this.topicPreference,
	});

	factory User.fromMap(Map<String, dynamic> map) {
		return User(
			userId: map['userId'] as int?,
			username: map['username'] as String,
			password: map['password'] as String,
			age: map['age'] as int,
			gender: map['gender'] as String,
			topicPreference: map['topicPreference'] as String,
		);
	}

	Map<String, dynamic> toMap() {
		return {
			'userId': userId,
			'username': username,
			'password': password,
			'age': age,
			'gender': gender,
			'topicPreference': topicPreference,
		};
	}
}
