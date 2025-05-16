class Report {
  final String statusLokasi;
  final String catatanPatroli;
  final String? mediaPath;
  final String timestamp;
  final bool isVideo;

  Report({
    required this.statusLokasi,
    required this.catatanPatroli,
    this.mediaPath,
    required this.timestamp,
    required this.isVideo,
  });

  Map<String, dynamic> toJson() {
    return {
      'status_lokasi': statusLokasi,
      'catatan_patroli': catatanPatroli,
      'media_path': mediaPath,
      'timestamp': timestamp,
      'is_video': isVideo,
    };
  }
} 