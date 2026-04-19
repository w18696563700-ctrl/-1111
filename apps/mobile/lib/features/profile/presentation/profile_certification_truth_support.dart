import 'package:mobile/features/profile/data/profile_identity_consumer_layer.dart';

class ProfileCertificationTruthField {
  const ProfileCertificationTruthField({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;
}

String? profileCertificationFormalSubjectName(
  ProfileCertificationCurrentView? certification,
) {
  final value = certification?.legalName?.trim();
  return value == null || value.isEmpty ? null : value;
}

List<ProfileCertificationTruthField> buildProfileCertificationTruthFields(
  ProfileCertificationCurrentView? certification,
) {
  if (certification == null) {
    return const <ProfileCertificationTruthField>[];
  }

  final items = <ProfileCertificationTruthField>[
    if (certification.legalName?.trim().isNotEmpty ?? false)
      ProfileCertificationTruthField(
        label: '认证主体',
        value: certification.legalName!.trim(),
      ),
    if (certification.uscc?.trim().isNotEmpty ?? false)
      ProfileCertificationTruthField(
        label: '统一社会信用代码',
        value: certification.uscc!.trim(),
      ),
    if (certification.legalPerson?.trim().isNotEmpty ?? false)
      ProfileCertificationTruthField(
        label: '法定代表人',
        value: certification.legalPerson!.trim(),
      ),
    if (_normalizedCertificationBusinessType(certification.businessType)
        case final String businessType)
      ProfileCertificationTruthField(label: '企业类型', value: businessType),
    if (certification.address?.trim().isNotEmpty ?? false)
      ProfileCertificationTruthField(
        label: '住所',
        value: certification.address!.trim(),
      ),
    if (certification.registeredCapital?.trim().isNotEmpty ?? false)
      ProfileCertificationTruthField(
        label: '注册资本',
        value: certification.registeredCapital!.trim(),
      ),
    if (certification.establishedAt?.trim().isNotEmpty ?? false)
      ProfileCertificationTruthField(
        label: '成立日期',
        value: certification.establishedAt!.trim(),
      ),
    if (certification.businessTerm?.trim().isNotEmpty ?? false)
      ProfileCertificationTruthField(
        label: '营业期限',
        value: certification.businessTerm!.trim(),
      ),
    if (certification.businessScope?.trim().isNotEmpty ?? false)
      ProfileCertificationTruthField(
        label: '经营范围',
        value: certification.businessScope!.trim(),
      ),
  ];
  return List<ProfileCertificationTruthField>.unmodifiable(items);
}

String? _normalizedCertificationBusinessType(String? raw) {
  final value = raw?.trim();
  if (value == null || value.isEmpty) {
    return null;
  }

  final normalized = value.toLowerCase().replaceAll(RegExp(r'\s+'), '');
  if (normalized == 'qrcode' ||
      normalized == 'qr码' ||
      value == 'QRCode' ||
      value == '二维码') {
    return null;
  }

  return value;
}
