class ExtractedData {
  String? text;

  ExtractedData({
    this.text,
  });

  factory ExtractedData.fromJson(Map<String, dynamic> json) {
    return ExtractedData(
      text: json['text'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
    }..removeWhere((key, value) => value == null);
  }
}
