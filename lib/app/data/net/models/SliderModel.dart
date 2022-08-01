class SingleSlide {
  SingleSlide({
    required this.text,
    required this.image,
  });
  late final String text;
  late final String image;

  SingleSlide.fromJson(Map<String, dynamic> json) {
    text = json['text'];
    image = json['image'];
  }
}
