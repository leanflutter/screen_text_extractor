class ExtractedData {
  String? text;
  String? imagePath;
  double? imageWidth;
  double? imageHeight;
  String? base64Image;

  ExtractedData({
    this.text,
    this.imagePath,
    this.imageWidth,
    this.imageHeight,
    this.base64Image,
  });

  factory ExtractedData.fromJson(Map<String, dynamic> json) {
    return ExtractedData(
      text: json['text'],
      imagePath: json['imagePath'],
      imageWidth: json['imageWidth'],
      imageHeight: json['imageHeight'],
      base64Image: json['base64Image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'imagePath': imagePath,
      'imageWidth': imageWidth,
      'imageHeight': imageHeight,
      'base64Image': base64Image,
    }..removeWhere((key, value) => value == null);
  }
}
