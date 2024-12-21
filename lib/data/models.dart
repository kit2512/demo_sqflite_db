class PackageModel {
  final String id;
  final String title;
  final String description;
  final String image;

  const PackageModel({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
  });

  PackageModel copyWith({
    String? id,
    String? title,
    String? description,
    String? image,
  }) =>
      PackageModel(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        image: image ?? this.image,
      );

  factory PackageModel.fromJson(Map<String, dynamic> json) {
    return PackageModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'image': image,
      };
}

enum DisplayType {
  text,
  image,
}

class WordModel {
  final String id;
  final String packageId;
  final String front;
  final String back;
  final DisplayType frontType;
  final DisplayType backType;

  const WordModel({
    required this.id,
    required this.packageId,
    required this.front,
    required this.back,
    required this.frontType,
    required this.backType,
  });

  WordModel copyWith({
    String? id,
    String? packageId,
    String? front,
    String? back,
    DisplayType? frontType,
    DisplayType? backType,
  }) =>
      WordModel(
        id: id ?? this.id,
        packageId: packageId ?? this.packageId,
        front: front ?? this.front,
        back: back ?? this.back,
        frontType: frontType ?? this.frontType,
        backType: backType ?? this.backType,
      );

  factory WordModel.fromJson(Map<String, dynamic> json) => WordModel(
        id: json['id'],
        packageId: json['package_id'],
        front: json['front'],
        back: json['back'],
        frontType: DisplayType.values[json['frontType'] as int],
        backType: DisplayType.values[json['backType'] as int],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'package_id': packageId,
        'front': front,
        'back': back,
        'frontType': frontType.index,
        'backType': backType.index,
      };
}
