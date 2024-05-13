class MyImage {
  final String id;
  String filename;
  final String data; // base64 encoded image data

  MyImage({required this.id, required this.filename, required this.data});

  factory MyImage.fromJson(Map<String, dynamic> json) {
    return MyImage(
      id: json['id'],
      filename: json['filename'],
      data: json['data'],
    );
  }

  get image => this;
}
