import 'dart:io';

import 'package:url_launcher/url_launcher_string.dart';

Future<bool> launchExternalMapWithFallback({
  required double? latitude,
  required double? longitude,
  required String? address,
  required String? mapLinkUrl,
}) async {
  final candidates = externalMapCandidateUrls(
    latitude: latitude,
    longitude: longitude,
    address: address,
    mapLinkUrl: mapLinkUrl,
  );
  for (final candidate in candidates) {
    try {
      final opened = await launchUrlString(
        candidate,
        mode: LaunchMode.externalApplication,
      );
      if (opened) {
        return true;
      }
    } catch (_) {
      // Try the next candidate and keep the existing web fallback available.
    }
  }
  return false;
}

List<String> externalMapCandidateUrls({
  required double? latitude,
  required double? longitude,
  required String? address,
  required String? mapLinkUrl,
}) {
  final label = externalMapLabel(address);
  final encodedLabel = Uri.encodeComponent(label);
  final hasCoordinates = latitude != null && longitude != null;
  final candidates = <String>[];

  if (hasCoordinates) {
    final lat = latitude.toString();
    final lng = longitude.toString();
    if (Platform.isIOS) {
      candidates.add('maps://?q=$encodedLabel&ll=$lat,$lng');
      candidates.add(
        'iosamap://viewMap?sourceApplication=exhibition_app&poiname=$encodedLabel&lat=$lat&lon=$lng&dev=0',
      );
    } else {
      candidates.add('geo:$lat,$lng?q=$lat,$lng($encodedLabel)');
      candidates.add(
        'androidamap://viewMap?sourceApplication=exhibition_app&poiname=$encodedLabel&lat=$lat&lon=$lng&dev=0',
      );
    }
    candidates.add(
      'baidumap://map/marker?location=$lat,$lng&title=$encodedLabel&content=$encodedLabel',
    );
    candidates.add(
      'qqmap://map/marker?marker=coord:$lat,$lng;title:$encodedLabel',
    );
    candidates.add('comgooglemaps://?q=$lat,$lng');
    candidates.add('http://maps.apple.com/?ll=$lat,$lng&q=$encodedLabel');
  } else if (label.isNotEmpty) {
    candidates.add('http://maps.apple.com/?q=$encodedLabel');
    candidates.add('geo:0,0?q=$encodedLabel');
  }

  final normalizedFallback = mapLinkUrl?.trim();
  if (normalizedFallback != null && normalizedFallback.isNotEmpty) {
    candidates.add(normalizedFallback);
  }

  final seen = <String>{};
  return candidates
      .where((String candidate) => seen.add(candidate))
      .toList(growable: false);
}

String externalMapLabel(String? address) {
  final normalized = address?.trim();
  return normalized == null || normalized.isEmpty ? '目的地' : normalized;
}
