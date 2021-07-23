class ExtractedResult {
  final String? text;

  ExtractedResult({
    this.text,
  });

  factory ExtractedResult.fromJson(Map<String, dynamic> json) {
    return ExtractedResult(
      text: json['text'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
    };
  }
}
