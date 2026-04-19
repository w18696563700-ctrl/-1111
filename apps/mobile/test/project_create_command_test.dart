import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/exhibition/data/exhibition_consumer_layer.dart';

void main() {
  test('project create command omits optional scope summary when empty', () {
    final command = ProjectCreateCommand(
      title: '春季医疗器械展 - 迈德瑞',
      exhibitionName: '春季医疗器械展',
      brandName: '迈德瑞',
      buildingType: 'exhibition',
      budgetAmount: 180000,
      provinceCode: '110000',
      provinceName: '北京',
      cityCode: '110100',
      cityName: '北京',
      detailAddress: '国家会议中心 1 号馆',
      scopeSummary: null,
    );

    expect(command.toJson().containsKey('scopeSummary'), isFalse);
  });

  test('project save command omits optional scope summary when empty', () {
    final command = ProjectSaveCommand(
      projectId: 'project-1',
      title: '春季医疗器械展 - 迈德瑞',
      exhibitionName: '春季医疗器械展',
      brandName: '迈德瑞',
      buildingType: 'exhibition',
      budgetAmount: 180000,
      provinceCode: '110000',
      provinceName: '北京',
      cityCode: '110100',
      cityName: '北京',
      detailAddress: '国家会议中心 1 号馆',
      scopeSummary: null,
    );

    expect(command.toJson().containsKey('scopeSummary'), isFalse);
  });
}
