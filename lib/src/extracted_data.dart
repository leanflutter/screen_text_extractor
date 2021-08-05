class ExtractedData {
  String? text;
  String? imagePath;

  ExtractedData({
    this.text,
    this.imagePath,
  });

  factory ExtractedData.fromJson(Map<String, dynamic> json) {
    return ExtractedData(
      text: json['text'],
      imagePath: json['imagePath'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'imagePath': imagePath,
    }..removeWhere((key, value) => value == null);
  }
}
