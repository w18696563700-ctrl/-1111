import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/exhibition/data/enterprise_hub_consumer_layer.dart';
import 'package:mobile/features/exhibition/presentation/enterprise_hub_board_surface.dart';

void main() {
  test(
    'company card summary prefers frozen summary fields over weak credit placeholder',
    () {
      const item = EnterpriseHubListItem(
        enterpriseId: 'enterprise-company-1',
        boardType: EnterpriseBoardType.company,
        name: '上海汉诺特展览服务有限公司',
        provinceName: '上海',
        cityName: '上海市',
        primaryBoardLabel: '优秀公司',
        secondaryCapabilityLabels: <String>['优秀公司'],
        shortIntro: '展会服务',
        certificationLabel: '已认证',
        caseCount: 8,
        avgScore: 4.8,
        keywordTags: <String>[],
        boardHighlights: <String, Object?>{
          'company': <String, Object?>{
            'exhibitionTypes': <String>['特装展台', '会议活动'],
            'serviceItems': <String>['策划设计', '主场承建'],
            'serviceCities': <String>['上海市', '深圳市'],
            'maxProjectScale': '500 万以内',
          },
        },
      );

      expect(
        enterpriseBoardCardSummaryText(item),
        '展会类型：特装展台 / 会议活动  |  服务项目：策划设计 / 主场承建',
      );
      expect(enterpriseBoardCardSummaryChips(item), <String>[
        '特装展台',
        '策划设计',
        '已认证',
        '规模 500 万以内',
      ]);
    },
  );

  test('factory card summary keeps score behavior unchanged', () {
    const item = EnterpriseHubListItem(
      enterpriseId: 'enterprise-factory-1',
      boardType: EnterpriseBoardType.factory,
      name: '重庆坤特展示工厂',
      provinceName: '重庆',
      cityName: '重庆市',
      primaryBoardLabel: '优秀工厂',
      secondaryCapabilityLabels: <String>['优秀工厂'],
      shortIntro: '工厂履约',
      certificationLabel: '已认证',
      caseCount: 3,
      avgScore: 4.6,
      keywordTags: <String>[],
      boardHighlights: <String, Object?>{
        'factory': <String, Object?>{
          'processTypes': <String>['木作'],
          'deliveryRadiusDesc': '西南地区',
        },
      },
    );

    expect(enterpriseBoardCardSummaryChips(item), <String>[
      '木作',
      '配送 西南地区',
      '已认证',
      '4.6 分',
    ]);
  });

  test('supplier card summary ignores retired supplyMode highlight', () {
    const item = EnterpriseHubListItem(
      enterpriseId: 'enterprise-supplier-1',
      boardType: EnterpriseBoardType.supplier,
      name: '重庆坤特展览展示有限公司',
      provinceName: '重庆',
      cityName: '重庆市',
      primaryBoardLabel: '优秀供应商',
      secondaryCapabilityLabels: <String>['桁架舞台搭建厂'],
      shortIntro: '供应商履约',
      certificationLabel: '已认证',
      caseCount: 1,
      keywordTags: <String>[],
      boardHighlights: <String, Object?>{
        'supplier': <String, Object?>{
          'supplyCategories': <String>['桁架舞台搭建厂'],
          'supplyMode': <String>['现货供应'],
          'responseSlaDesc': '2小时内响应',
        },
      },
    );

    expect(enterpriseBoardCardSummaryText(item), '品类：桁架舞台搭建厂');
    expect(enterpriseBoardCardSummaryChips(item), <String>[
      '桁架舞台搭建厂',
      '响应 2小时内响应',
      '已认证',
      '1 个案例',
    ]);
  });
}
