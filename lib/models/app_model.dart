import 'dart:convert';

class AppModel {
  final String id;
  final String name;
  final String url;
  final String? iconDataUrl; // data URL base64

  AppModel({
    required this.id,
    required this.name,
    required this.url,
    this.iconDataUrl,
  });

  // MODEL → JSON (per salvataggio locale)
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'url': url,
        'icon': iconDataUrl,
      };

  // JSON → MODEL (compatibile con backend attuale)
  factory AppModel.fromJson(Map<String, dynamic> json) {
    String? iconDataUrl;

    final icon = json['icon'];

    // Caso reale del backend:
    // icon.data = { type: "Buffer", data: [...] }
    if (icon is Map &&
        icon['data'] is Map &&
        icon['data']['data'] is List &&
        icon['mime'] is String) {

      final bytes = List<int>.from(icon['data']['data']);
      final mime = icon['mime'];
      final base64 = base64Encode(bytes);

      iconDataUrl = "data:$mime;base64,$base64";
    }

    return AppModel(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      iconDataUrl: iconDataUrl,
    );
  }
}

