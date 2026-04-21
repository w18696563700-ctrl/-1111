import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api/app_api_client.dart';
import 'package:mobile/features/exhibition/data/exhibition_consumer_layer.dart';
import 'package:mobile/shell/shell_app.dart';

import 'support/exhibition_home_test_doubles.dart';

void main() {
  testWidgets('app shell smoke test', (WidgetTester tester) async {
    final homeClient = FakeExhibitionHomeAggregationClient();
    final locationService = FakeDeviceLocationService();

    await tester.pumpWidget(
      ExhibitionMobileApp(
        exhibitionConsumerLayer: ExhibitionConsumerLayer(
          client: AppApiClient(
            config: AppApiConfig(baseUrl: 'http://127.0.0.1:8080/api/app'),
            transport: FakeAppApiTransport(
              handlers:
                  <
                    String,
                    Future<AppApiResponse> Function(AppApiRequest request)
                  >{
                    'GET /api/app/project/list': (AppApiRequest request) async {
                      return AppApiResponse(
                        statusCode: 200,
                        uri: request.uri,
                        body: const <String, Object?>{'items': <Object?>[]},
                      );
                    },
                  },
            ),
          ),
        ),
        exhibitionHomeAggregationClient: homeClient,
        deviceLocationService: locationService,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('天气与定位'), findsOneWidget);
    expect(find.text('秩序化首页'), findsNothing);
    expect(find.text('展览首页'), findsNothing);
    expect(find.text('当前定位：重庆'), findsNothing);
    expect(find.text('当前环境：联调环境'), findsNothing);
    expect(find.text('公开入口'), findsOneWidget);
    expect(find.text('推荐频道'), findsOneWidget);
    expect(find.widgetWithText(TextButton, '去发布项目'), findsOneWidget);
    expect(find.byTooltip('回到顶部'), findsOneWidget);
    expect(find.byTooltip('整页刷新'), findsOneWidget);
    expect(find.text('手动选择地区'), findsOneWidget);
    expect(find.text('项目'), findsOneWidget);
    expect(find.text('论坛'), findsOneWidget);
    expect(find.text('公司'), findsOneWidget);
    expect(find.text('工厂'), findsOneWidget);
    expect(find.text('供应商'), findsOneWidget);
    expect(find.text('团队'), findsOneWidget);
    expect(find.text('进入项目列表'), findsWidgets);
    expect(homeClient.loadCount, 1);
    expect(homeClient.refreshCount, 0);
    expect(locationService.requestCount, 1);
    expect(find.text('进入发布项目工作台'), findsNothing);
    expect(find.text('发布项目'), findsNothing);
    expect(find.text('当前进度'), findsNothing);
    expect(find.text('进入页面'), findsNothing);
  });
}
