class ImageResponse {
  final String id;
  final String filename;
  final String data;

  ImageResponse({required this.id, required this.filename, required this.data});

  Map<String, dynamic> toJson() => {
        'id': id,
        'filename': filename,
        'data': data,
      };

  factory ImageResponse.fromJson(Map<String, dynamic> json) => ImageResponse(
        id: json['id'],
        filename: json['filename'],
        data: json['data'],
      );
}
