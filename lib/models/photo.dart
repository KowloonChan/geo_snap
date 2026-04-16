import 'dart:typed_data';

class Photo {
	int? photoId;
	int postId;
	Uint8List photoBlob;
	String? photoCaption;

	Photo({
		this.photoId,
		required this.postId,
		required this.photoBlob,
		this.photoCaption,
	});

	factory Photo.fromMap(Map<String, dynamic> map) {
		return Photo(
			photoId: map['photoId'] as int?,
			postId: map['postId'] as int,
			photoBlob: map['photoBlob'] as Uint8List,
			photoCaption: map['photoCaption'] as String?,
		);
	}

	Map<String, dynamic> toMap() {
		return {
			'photoId': photoId,
			'postId': postId,
			'photoBlob': photoBlob,
			'photoCaption': photoCaption,
		};
	}
}
