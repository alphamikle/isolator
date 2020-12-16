class Item {
  const Item(
    this.id,
    this.createdAt,
    this.profile,
    this.imageUrl,
  );

  factory Item.fromJson(dynamic json) {
    return Item(json['MemberId'], DateTime.parse(json['createdAt']), json['profile'], json['image'] ?? '');
  }

  static List<Item> fromJsonList(List<dynamic> jsonList) => jsonList.map((dynamic json) => Item.fromJson(json)).toList();

  final int id;
  final DateTime createdAt;
  final String profile;
  final String imageUrl;
}
