import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:poortak/common/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VoiceCacheEntry {
  final String localPath;
  final String? checksum;
  final String? contentType;

  const VoiceCacheEntry({
    required this.localPath,
    this.checksum,
    this.contentType,
  });

  factory VoiceCacheEntry.fromJson(Map<String, dynamic> json) {
    return VoiceCacheEntry(
      localPath: json['localPath'] as String,
      checksum: json['checksum'] as String?,
      contentType: json['contentType'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'localPath': localPath,
        'checksum': checksum,
        'contentType': contentType,
      };
}

class VoicePrefetchItem {
  final String fileId;
  final String? checksum;

  const VoicePrefetchItem({
    required this.fileId,
    this.checksum,
  });
}

/// Downloads and caches IKnow public voice files keyed by [voiceFileId].
class IKnowVoiceCacheService {
  static const _prefsKey = 'iknow_voice_cache_v1';

  final Dio _dio;
  final StorageService _storageService;
  final SharedPreferences _prefs;

  final Map<String, VoiceCacheEntry> _cache = {};
  final Map<String, Future<String?>> _inFlight = {};
  Directory? _voiceDir;

  IKnowVoiceCacheService({
    required Dio dio,
    required StorageService storageService,
    required SharedPreferences prefs,
  })  : _dio = dio,
        _storageService = storageService,
        _prefs = prefs {
    _loadCacheMetadata();
  }

  Future<String?> getLocalVoice(String fileId) async {
    final cached = _cache[fileId];
    if (cached == null) return null;
    final file = File(cached.localPath);
    if (await file.exists()) return cached.localPath;
    _cache.remove(fileId);
    await _persistCacheMetadata();
    return null;
  }

  /// Ensures a voice file is on disk and returns its local path.
  /// Returns null when download fails or the server file is unavailable.
  Future<String?> ensureVoice({
    required String fileId,
    String? checksum,
  }) {
    if (fileId.trim().isEmpty) return Future.value(null);

    final existing = _inFlight[fileId];
    if (existing != null) return existing;

    final future = _ensureVoiceInternal(fileId: fileId, checksum: checksum);
    _inFlight[fileId] = future;
    return future.whenComplete(() {
      _inFlight.remove(fileId);
    });
  }

  Future<void> prefetchVoices(List<VoicePrefetchItem> items) async {
    final seen = <String>{};
    for (final item in items) {
      final id = item.fileId.trim();
      if (id.isEmpty || !seen.add(id)) continue;
      unawaited(ensureVoice(fileId: id, checksum: item.checksum));
    }
  }

  Future<String?> _ensureVoiceInternal({
    required String fileId,
    String? checksum,
  }) async {
    try {
      final cached = _cache[fileId];
      if (cached != null) {
        final file = File(cached.localPath);
        final exists = await file.exists();
        if (exists &&
            (checksum == null ||
                checksum.isEmpty ||
                cached.checksum == checksum)) {
          return cached.localPath;
        }
        if (exists && cached.checksum != checksum) {
          // Stale checksum — redownload
          try {
            await file.delete();
          } catch (_) {}
          _cache.remove(fileId);
        } else if (!exists) {
          _cache.remove(fileId);
        }
      }

      return await _downloadVoice(fileId: fileId, checksum: checksum);
    } catch (e, st) {
      log('ensureVoice failed for $fileId: $e\n$st');
      return null;
    }
  }

  Future<String?> _downloadVoice({
    required String fileId,
    String? checksum,
  }) async {
    final dir = await _ensureVoiceDir();
    final url = _storageService.getDownloadPublicUrl(fileId);
    final tempPath = '${dir.path}/$fileId.tmp';
    final tempFile = File(tempPath);

    try {
      if (await tempFile.exists()) {
        await tempFile.delete();
      }

      final response = await _dio.get<List<int>>(
        url,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: true,
          validateStatus: (status) =>
              status != null && status >= 200 && status < 400,
        ),
      );

      final status = response.statusCode ?? 0;
      if (status == 404 || status == 403 || status == 410) {
        await _removeCacheEntry(fileId);
        return null;
      }

      final bytes = response.data;
      if (bytes == null || bytes.isEmpty) {
        return null;
      }

      final contentType = response.headers.value('content-type');
      final extension = _extensionForContentType(contentType);
      final finalPath = '${dir.path}/$fileId$extension';
      final finalFile = File(finalPath);

      await tempFile.writeAsBytes(bytes, flush: true);
      if (await finalFile.exists()) {
        await finalFile.delete();
      }
      await tempFile.rename(finalPath);

      _cache[fileId] = VoiceCacheEntry(
        localPath: finalPath,
        checksum: checksum,
        contentType: contentType,
      );
      await _persistCacheMetadata();
      return finalPath;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 404 || status == 403 || status == 410) {
        await _removeCacheEntry(fileId);
      }
      log('voice download DioException for $fileId: $e');
      return null;
    } catch (e) {
      log('voice download failed for $fileId: $e');
      try {
        if (await tempFile.exists()) await tempFile.delete();
      } catch (_) {}
      return null;
    }
  }

  Future<Directory> _ensureVoiceDir() async {
    if (_voiceDir != null) return _voiceDir!;
    final support = await getApplicationSupportDirectory();
    final dir = Directory('${support.path}/iknow_voices');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    _voiceDir = dir;
    return dir;
  }

  String _extensionForContentType(String? contentType) {
    if (contentType == null) return '';
    final ct = contentType.toLowerCase().split(';').first.trim();
    switch (ct) {
      case 'audio/mpeg':
      case 'audio/mp3':
        return '.mp3';
      case 'audio/mp4':
      case 'audio/aac':
      case 'audio/x-m4a':
        return '.m4a';
      case 'audio/wav':
      case 'audio/x-wav':
        return '.wav';
      case 'audio/ogg':
        return '.ogg';
      default:
        return '';
    }
  }

  void _loadCacheMetadata() {
    final raw = _prefs.getString(_prefsKey);
    if (raw == null || raw.isEmpty) return;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return;
      decoded.forEach((key, value) {
        if (key is! String || value is! Map) return;
        _cache[key] = VoiceCacheEntry.fromJson(
          Map<String, dynamic>.from(value),
        );
      });
    } catch (e) {
      log('Failed to load voice cache metadata: $e');
    }
  }

  Future<void> _persistCacheMetadata() async {
    final map = <String, dynamic>{};
    _cache.forEach((key, value) {
      map[key] = value.toJson();
    });
    await _prefs.setString(_prefsKey, jsonEncode(map));
  }

  Future<void> _removeCacheEntry(String fileId) async {
    final cached = _cache.remove(fileId);
    if (cached != null) {
      try {
        final file = File(cached.localPath);
        if (await file.exists()) await file.delete();
      } catch (_) {}
    }
    await _persistCacheMetadata();
  }
}
