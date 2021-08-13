class ExtractedData {
  String? text;
  String? imagePath;
  String? base64Image;

  ExtractedData({
    this.text,
    this.imagePath,
    this.base64Image,
  });

  factory ExtractedData.fromJson(Map<String, dynamic> json) {
    return ExtractedData(
      text: json['text'],
      imagePath: json['imagePath'],
      base64Image: json['base64Image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'imagePath': imagePath,
      'base64Image': base64Image,
    }..removeWhere((key, value) => value == null);
  }
}
