import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/shared/file/attachment_tile.dart';
import 'package:mobile/shared/file/file_open_coordinator.dart';
import 'package:mobile/shared/format/money_formatter.dart';
import 'package:mobile/shared/state/submit_guard.dart';
import 'package:mobile/shared/ui/app_visual_components.dart';
import 'package:mobile/shared/ui/status_badge_policy.dart';
import 'package:mobile/shared/widgets/app_page_state_view.dart';
import 'package:open_filex/open_filex.dart';

void main() {
  group('FileOpenCoordinator', () {
    test('opens local path through injected open_filex adapter', () async {
      final coordinator = FileOpenCoordinator(
        openFile: (String path, {String? mimeType}) async {
          expect(path, '/tmp/demo.pdf');
          expect(mimeType, 'application/pdf');
          return OpenResult(type: ResultType.done);
        },
      );

      final result = await coordinator.openPath(
        path: '/tmp/demo.pdf',
        mimeType: 'application/pdf',
      );

      expect(result.opened, isTrue);
    });

    test('falls back to desktop process when open_filex cannot open', () async {
      var processCalled = false;
      final coordinator = FileOpenCoordinator(
        openFile: (String path, {String? mimeType}) async {
          return OpenResult(type: ResultType.error);
        },
        platformResolver: () => const FileOpenPlatformSnapshot(
          isMacOS: true,
          isLinux: false,
          isWindows: false,
        ),
        runProcess: (String executable, List<String> arguments) async {
          processCalled = true;
          expect(executable, 'open');
          expect(arguments, <String>['/tmp/demo.pdf']);
          return ProcessResult(123, 0, '', '');
        },
      );

      final result = await coordinator.openPath(path: '/tmp/demo.pdf');

      expect(result.opened, isTrue);
      expect(processCalled, isTrue);
    });
  });

  group('MoneyFormatter', () {
    test('formats CNY yuan and cents for display only', () {
      expect(MoneyFormatter.yuan(2599, currency: 'CNY'), '¥2599');
      expect(MoneyFormatter.yuan(12.5, currency: 'CNY'), '¥12.5');
      expect(MoneyFormatter.cents(12345, currency: 'CNY'), '¥123.45');
    });

    test('handles empty, unavailable, and hidden amount labels', () {
      expect(MoneyFormatter.yuan(null), '待确认');
      expect(MoneyFormatter.yuan(10, unavailable: true), '不可用');
      expect(MoneyFormatter.yuan(10, hidden: true), '金额已隐藏');
      expect(MoneyFormatter.yuan(10, currency: 'USD'), 'USD 10');
    });
  });

  test('SubmitGuard blocks duplicate submissions and restores state', () async {
    final guard = SubmitGuard();
    final completer = Completer<int>();
    var calls = 0;
    var blocked = 0;

    final first = guard.run<int>(() {
      calls += 1;
      return completer.future;
    });
    final second = guard.run<int>(() async {
      calls += 1;
      return 2;
    }, onBlocked: () => blocked += 1);

    expect(guard.submitting, isTrue);
    expect(await second, isNull);
    expect(blocked, 1);
    expect(calls, 1);

    completer.complete(1);
    expect(await first, 1);
    expect(guard.submitting, isFalse);
    guard.dispose();
  });

  testWidgets('AttachmentTile renders file metadata and actions', (
    WidgetTester tester,
  ) async {
    var opened = false;
    var deleted = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AttachmentTile(
            fileName: 'quote-basis.pdf',
            fileTypeLabel: 'PDF',
            fileSizeLabel: '42 KB',
            statusLabel: '已确认',
            statusTone: AppStatusTone.success,
            onOpen: () => opened = true,
            onDelete: () => deleted = true,
          ),
        ),
      ),
    );

    expect(find.text('quote-basis.pdf'), findsOneWidget);
    expect(find.text('PDF · 42 KB'), findsOneWidget);
    expect(find.text('已确认'), findsOneWidget);

    await tester.tap(find.byTooltip('打开'));
    await tester.pump();
    await tester.tap(find.byTooltip('删除'));
    await tester.pump();

    expect(opened, isTrue);
    expect(deleted, isTrue);
  });

  testWidgets('AppPageStateView renders retryable error and retry action', (
    WidgetTester tester,
  ) async {
    var retried = false;

    await tester.pumpWidget(
      MaterialApp(
        home: AppPageStateView(
          state: AppPageState.errorRetryable,
          content: const Text('content'),
          onRetry: () => retried = true,
        ),
      ),
    );

    expect(find.text('当前内容暂不可用'), findsOneWidget);
    expect(find.text('请稍后重试。'), findsOneWidget);
    await tester.tap(find.text('重试'));
    await tester.pump();
    expect(retried, isTrue);
  });

  test('StatusBadgePolicy keeps unknown fallback display-only', () {
    expect(StatusBadgePolicy.displayLabel(null), '未知状态');
    expect(
      StatusBadgePolicy.appTone(StatusBadgePolicyTone.pending),
      AppStatusTone.pending,
    );
  });
}
