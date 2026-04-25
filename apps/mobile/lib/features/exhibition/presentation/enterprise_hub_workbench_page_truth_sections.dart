part of 'enterprise_hub_workbench_pages.dart';

extension _EnterpriseWorkbenchPageTruthSections
    on _EnterpriseApplicationPageState {
  Widget _buildAddressAssistSection() {
    return _SectionNotice(
      key: const ValueKey<String>('enterprise-workbench-address-assist-note'),
      tone: _SectionNoticeTone.neutral,
      title: '企业位置解析',
      lines: const <String>[
        '当前位置和位置补充说明都会进入云端位置解析，解析成功后保存为同一套企业位置真值。',
        '无坐标时只按文字地址保存，不会伪装成地图已接通。',
      ],
      action: Wrap(
        spacing: 10,
        runSpacing: 8,
        children: <Widget>[
          TextButton.icon(
            key: const ValueKey<String>(
              'enterprise-workbench-address-fill-from-location',
            ),
            onPressed: _resolvingLocation
                ? null
                : _fillAddressFromCurrentLocation,
            icon: const Icon(Icons.my_location_rounded),
            label: Text(_resolvingLocation ? '解析中' : '用当前位置填入'),
          ),
          OutlinedButton.icon(
            key: const ValueKey<String>(
              'enterprise-workbench-address-resolve-manual',
            ),
            onPressed: _resolvingLocation ? null : _resolveManualAddress,
            icon: const Icon(Icons.travel_explore_rounded),
            label: const Text('解析文字地址'),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationTruthPreview(EnterpriseHubLocationData location) {
    final hasMap = location.isResolved;
    final colorScheme = Theme.of(context).colorScheme;
    final statusText = switch (location.geoStatus) {
      'resolved' => '已解析坐标',
      'text_only' => '仅保存文字地址',
      'failed' => '解析失败，待校正',
      _ => '位置待提供',
    };
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: hasMap
            ? colorScheme.primaryContainer.withValues(alpha: 0.28)
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: hasMap
              ? colorScheme.primary.withValues(alpha: 0.28)
              : colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                hasMap ? Icons.map_rounded : Icons.location_off_outlined,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '位置状态：$statusText',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(location.displayAddress ?? '当前还没有可展示地址。'),
          if (location.coordinatesLabel != null) ...<Widget>[
            const SizedBox(height: 6),
            Text('坐标：${location.coordinatesLabel}'),
          ],
          if (!hasMap) ...<Widget>[
            const SizedBox(height: 6),
            const Text('当前不会展示地图卡片；请先解析出真实坐标。'),
          ],
        ],
      ),
    );
  }

  Widget _buildUpstreamTruthSection() {
    return EnterpriseSectionCard(
      key: const ValueKey<String>('enterprise-workbench-truth-section'),
      title: '上游真值',
      subtitle: '这些字段来自我的公司或企业认证，当前页只读；仅在缺值或需要按来源修复时显示。',
      child: Column(
        children: <Widget>[
          _ReadonlyTruthField(
            key: const ValueKey<String>(
              'enterprise-workbench-enterprise-name-readonly',
            ),
            label: '企业名称',
            sourceLabel: '企业认证真值',
            value: _enterpriseNameTruthValue(),
            placeholder: '当前还没有同步到企业认证主体名称',
            helperText: _enterpriseNameTruthValue() == null
                ? '当前字段来源于企业认证/营业执照识别结果；当前页不能修改，如需继续请先完成企业认证信息补齐。'
                : '当前字段来源于企业认证/营业执照识别结果，当前页不单独修改。',
          ),
          const SizedBox(height: 12),
          _ReadonlyTruthField(
            key: const ValueKey<String>(
              'enterprise-workbench-registered-city-readonly',
            ),
            label: enterpriseWorkbenchOrganizationCityTruthLabel,
            sourceLabel: '我的公司真值',
            value: _registeredCityController.text,
            placeholder:
                '当前还没有同步到我的公司里的$enterpriseWorkbenchOrganizationCityTruthLabel真值',
            helperText: enterpriseWorkbenchOrganizationCityTruthHelperText(
              isMissing:
                  _normalizedText(_registeredCityController.text) == null,
            ),
          ),
          const SizedBox(height: 12),
          _ReadonlyTruthField(
            key: const ValueKey<String>(
              'enterprise-workbench-founded-at-readonly',
            ),
            label: '成立日期',
            sourceLabel: '企业认证真值',
            value: _displayDateLabel(_foundedAtController.text),
            placeholder: '当前还没有同步到企业认证里的成立日期真值',
            helperText: _foundedAtController.text.trim().isEmpty
                ? '当前字段来源于企业认证/营业执照识别结果；当前页不能修改。如需补齐，请先完成企业认证信息补齐。'
                : '当前字段来源于企业认证真值，当前页不单独修改。',
          ),
        ],
      ),
    );
  }

  Widget _buildCertificationSummarySection(
    EnterpriseHubWorkbenchCertification? certification,
  ) {
    final statusLabel = _workbenchCertificationStatusLabel(
      certification?.certificationStatus,
    );
    final rejectReason = _normalizedText(certification?.rejectReason);
    final lines = <String>[
      '认证状态：$statusLabel',
      '企业名称：${certification?.legalName ?? '当前未同步'}',
      '统一社会信用代码：${certification?.uscc ?? '当前未同步'}',
    ];
    if (rejectReason != null) {
      lines.add('驳回原因：$rejectReason');
    }

    return _SectionNotice(
      key: const ValueKey<String>(
        'enterprise-workbench-certification-summary-section',
      ),
      tone:
          _isApprovedWorkbenchCertificationStatus(
            certification?.certificationStatus,
          )
          ? _SectionNoticeTone.neutral
          : _SectionNoticeTone.warning,
      title: '认证摘要',
      lines: lines,
    );
  }

  String _workbenchHeaderStatus() {
    if (_isCaseEditorWorkbench) {
      return _isPublishedChangeMode
          ? '当前页只维护单条案例；保存修改只写入待发布变更稿，不会直接更新线上展示。'
          : '当前页只维护单条案例；保存后只回写当前展示档，不影响其他企业资料。';
    }
    if (_isPublishedChangeMode) {
      final readiness = _publishedWorkbenchData?.changeReadiness;
      final currentStatus =
          _publishedChangeStatus?.changeStatus ??
          _publishedWorkbenchData?.currentChangeRequest?.changeStatus;
      if (currentStatus == 'revision_required') {
        return '当前变更已被退回补充；继续修改的是同一条 change request。新增案例和保存案例只写入 current change carrier，确认后再提交。';
      }
      if (currentStatus == 'approved') {
        return '当前变更已审核通过，待 apply；approved 不等于已上线。当前新增案例和保存案例不会直接改 live 展示。';
      }
      if (currentStatus == 'applied') {
        return '当前变更已 apply 到 live listing；若继续新增案例或修改内容，会再次进入新的 current change carrier。';
      }
      if (readiness?.submitReady == true) {
        return '当前变更内容已齐；新增案例和保存修改只写入 current change carrier，确认后再提交变更。';
      }
      if (readiness?.blockers.isNotEmpty == true) {
        return '先完成 ${readiness!.blockers.first}，其余阻断会在提交区继续显示。';
      }
      return '当前展示已发布；本页只维护 published-change corridor，不直接修改线上展示。';
    }
    final data = _workbenchResult?.data;
    final readiness =
        data?.readiness ??
        const EnterpriseHubWorkbenchReadiness(
          hasApplication: false,
          draftEditable: false,
          basicCompleted: false,
          profileCompleted: false,
          hasCase: false,
          hasContact: false,
          certificationApproved: false,
          submitReady: false,
          blockers: <String>[],
        );
    if (readiness.submitReady) {
      return '先检查板块画像和基础资料，当前资料已齐，可以直接提交入驻申请。';
    }
    if (readiness.blockers.isNotEmpty) {
      return '先完成 ${readiness.blockers.first}，其余阻断会在提交区继续显示。';
    }
    if (data?.enterpriseId == null) {
      return '先补板块画像和基础资料，保存时会先准备展示档。';
    }
    return '先补板块画像、基础资料和联系人，再决定是否提交当前申请。';
  }

  String? _enterpriseNameTruthValue() {
    return _normalizedText(_currentCertification?.legalName) ??
        _normalizedText(_certificationLegalNameTruth) ??
        _normalizedText(_currentBasic?.name) ??
        _normalizedText(_nameController.text);
  }

  bool _shouldShowUpstreamTruthSection() {
    return enterpriseWorkbenchShouldShowUpstreamTruthSection(
      enterpriseNameTruth: _enterpriseNameTruthValue(),
      organizationCityTruth: _registeredCityController.text,
      foundedAtTruth: _foundedAtController.text,
    );
  }

  bool _shouldShowCertificationSummarySection(
    EnterpriseHubWorkbenchCertification? certification,
  ) {
    return enterpriseWorkbenchShouldShowCertificationSummary(
      certificationStatus: certification?.certificationStatus,
      rejectReason: certification?.rejectReason,
    );
  }

  List<String> _contactMissingFields() {
    final missing = <String>[];
    if ((_normalizedText(_applicantNameController.text)) == null) {
      missing.add('联系人姓名');
    }
    if ((_normalizedText(_applicantMobileController.text)) == null) {
      missing.add('联系人手机号');
    }
    return missing;
  }

  List<String> _basicMissingFields() {
    final missing = <String>[];
    if ((_normalizedText(_fullIntroController.text)) == null) {
      missing.add('公司介绍');
    }
    return missing;
  }

  List<String> _profileMissingFields() {
    final missing = <String>[];
    if (_boardType == EnterpriseBoardType.factory &&
        (_normalizedText(_factoryNameController.text)) == null) {
      missing.add('工厂名');
    }
    if (_selectedProfileOneOptions.isEmpty) {
      missing.add(_profileLabelOne(_boardType));
    } else if (_boardType == EnterpriseBoardType.supplier &&
        _selectedProfileOneOptions.length != 1) {
      missing.add(_profileLabelOne(_boardType));
    }
    if (_boardType == EnterpriseBoardType.factory) {
      if ((_normalizedText(_profileTwoController.text)) == null) {
        missing.add(_profileLabelTwo(_boardType));
      }
    } else if (_boardType == EnterpriseBoardType.company &&
        _selectedProfileTwoOptions.isEmpty) {
      missing.add(_profileLabelTwo(_boardType));
    }
    if (_boardType == EnterpriseBoardType.supplier &&
        (_normalizedText(_profileThreeController.text)) == null) {
      missing.add(_profileLabelThree(_boardType));
    }
    return missing;
  }

  Widget? _buildGuard(AppShellContextSnapshot snapshot) {
    final blockingState = snapshot.blockingState;
    if (blockingState == GlobalShellState.unauthenticated) {
      return const EnterpriseSectionCard(
        title: '当前尚未登录',
        subtitle: '企业展示工作台属于组织侧动作，需先登录。',
        child: _GuardAction(
          actionLabel: '进入登录入口',
          routeName: ProfileIdentityRoutes.login,
        ),
      );
    }
    if (blockingState == GlobalShellState.noOrganization ||
        snapshot.shellContext.organizationId == null) {
      return const EnterpriseSectionCard(
        title: '当前缺少组织上下文',
        subtitle: '企业展示工作台必须绑定当前组织后才能继续。',
        child: _GuardAction(
          actionLabel: '前往组织承接',
          routeName: ProfileIdentityRoutes.organizationHandoff,
        ),
      );
    }
    return null;
  }
}
