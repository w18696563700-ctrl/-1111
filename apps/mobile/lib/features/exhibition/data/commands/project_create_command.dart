part of '../exhibition_consumer_layer.dart';

class ProjectCreateCommand {
  ProjectCreateCommand({
    required this.title,
    required this.buildingType,
    required this.budgetAmount,
    required this.provinceCode,
    required this.provinceName,
    required this.cityCode,
    required this.cityName,
    required this.detailAddress,
    required this.scopeSummary,
    this.areaSqm,
    this.buildingTypeRemark,
    this.districtCode,
    this.districtName,
    this.plannedStartAt,
    this.plannedEndAt,
    this.scheduleDetail,
    this.description,
  }) : assert(
         _hasMeaningfulText(districtCode) == _hasMeaningfulText(districtName),
         'districtCode and districtName must be provided together or both omitted',
       );

  final String title;
  final String buildingType;
  final double budgetAmount;
  final String provinceCode;
  final String provinceName;
  final String cityCode;
  final String cityName;
  final String detailAddress;
  final String scopeSummary;
  final double? areaSqm;
  final String? buildingTypeRemark;
  final String? districtCode;
  final String? districtName;
  final String? plannedStartAt;
  final String? plannedEndAt;
  final String? scheduleDetail;
  final String? description;

  static bool _hasMeaningfulText(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'title': title,
    'buildingType': buildingType,
    'budgetAmount': budgetAmount,
    if (areaSqm != null) 'areaSqm': areaSqm,
    if (_hasMeaningfulText(buildingTypeRemark))
      'buildingTypeRemark': buildingTypeRemark,
    'provinceCode': provinceCode,
    'provinceName': provinceName,
    'cityCode': cityCode,
    'cityName': cityName,
    'detailAddress': detailAddress,
    'scopeSummary': scopeSummary,
    if (_hasMeaningfulText(districtCode)) 'districtCode': districtCode,
    if (_hasMeaningfulText(districtName)) 'districtName': districtName,
    if (_hasMeaningfulText(plannedStartAt)) 'plannedStartAt': plannedStartAt,
    if (_hasMeaningfulText(plannedEndAt)) 'plannedEndAt': plannedEndAt,
    if (_hasMeaningfulText(scheduleDetail)) 'scheduleDetail': scheduleDetail,
    if (_hasMeaningfulText(description)) 'description': description,
  };
}
