import 'dart:async';

import 'package:crypto/crypto.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:mobile/core/api/app_ui_contracts.dart';
import 'package:mobile/core/boot/app_bootstrap_controller.dart';
import 'package:mobile/core/boot/app_shell_context.dart';
import 'package:mobile/core/location/china_region_catalog.dart';
import 'package:mobile/core/location/china_region_picker.dart';
import 'package:mobile/core/location/device_location_service.dart';
import 'package:mobile/features/exhibition/data/exhibition_consumer_layer.dart';
import 'package:mobile/features/exhibition/data/enterprise_hub_consumer_layer.dart';
import 'package:mobile/features/exhibition/data/enterprise_hub_published_change_consumer_layer.dart';
import 'package:mobile/features/exhibition/data/enterprise_hub_preview_projection.dart';
import 'package:mobile/features/exhibition/data/enterprise_hub_workbench_consumer_layer.dart';
import 'package:mobile/features/exhibition/navigation/exhibition_routes.dart';
import 'package:mobile/features/exhibition/presentation/enterprise_hub_detail_relayout_surface.dart';
import 'package:mobile/features/exhibition/presentation/enterprise_hub_shared.dart';
import 'package:mobile/features/exhibition/presentation/enterprise_hub_workbench_widgets.dart';
import 'package:mobile/features/profile/data/profile_identity_consumer_layer.dart';
import 'package:mobile/features/profile/navigation/profile_identity_routes.dart';
import 'package:mobile/features/profile/presentation/profile_avatar_edit_confirmation_page.dart';
import 'package:mobile/features/profile/presentation/profile_avatar_picker.dart';
import 'package:mobile/shell/context/app_shell_scope.dart';

part 'enterprise_hub_workbench_page_form_state.dart';
part 'enterprise_hub_workbench_page_load.dart';
part 'enterprise_hub_workbench_page_hydration.dart';
part 'enterprise_hub_workbench_page_basic_profile_actions.dart';
part 'enterprise_hub_workbench_page_case_actions.dart';
part 'enterprise_hub_workbench_page_submit_actions.dart';
part 'enterprise_hub_workbench_page_media_actions.dart';
part 'enterprise_hub_workbench_page_location_actions.dart';
part 'enterprise_hub_workbench_page_interactions.dart';
part 'enterprise_hub_workbench_page_shell.dart';
part 'enterprise_hub_workbench_page_display_sections.dart';
part 'enterprise_hub_workbench_page_album_location_sections.dart';
part 'enterprise_hub_workbench_page_basic_sections.dart';
part 'enterprise_hub_workbench_page_case_sections.dart';
part 'enterprise_hub_workbench_page_snapshot_sections.dart';
part 'enterprise_hub_workbench_page_submit_sections.dart';
part 'enterprise_hub_workbench_page_truth_sections.dart';
part 'enterprise_hub_application_status_page.dart';
part 'enterprise_hub_workbench_request_support.dart';
part 'enterprise_hub_workbench_application_status_support.dart';
part 'enterprise_hub_workbench_published_change_disposition_support.dart';
part 'enterprise_hub_workbench_truth_copy_support.dart';
part 'enterprise_hub_workbench_error_copy_support.dart';
part 'enterprise_hub_workbench_ui_support.dart';
part 'enterprise_hub_workbench_format_support.dart';
part 'enterprise_hub_workbench_equipment_support.dart';
part 'enterprise_hub_workbench_guard_support.dart';
part 'enterprise_hub_workbench_media_support.dart';

typedef EnterpriseWorkbenchPlacemarkLookup =
    Future<List<Placemark>> Function(double latitude, double longitude);
typedef EnterpriseWorkbenchForwardGeocodeLookup =
    Future<List<Location>> Function(String address);

const String enterpriseWorkbenchOrganizationCityTruthLabel = '组织所在城市';
EnterpriseHubWorkbenchCaseItem? _pendingEnterpriseWorkbenchCaseEditorSeed;

EnterpriseWorkbenchPlacemarkLookup enterpriseWorkbenchPlacemarkLookup =
    placemarkFromCoordinates;
EnterpriseWorkbenchForwardGeocodeLookup
enterpriseWorkbenchForwardGeocodeLookup = locationFromAddress;

void installEnterpriseWorkbenchPlacemarkLookup(
  EnterpriseWorkbenchPlacemarkLookup lookup,
) {
  enterpriseWorkbenchPlacemarkLookup = lookup;
}

void resetEnterpriseWorkbenchPlacemarkLookup() {
  enterpriseWorkbenchPlacemarkLookup = placemarkFromCoordinates;
}

void installEnterpriseWorkbenchForwardGeocodeLookup(
  EnterpriseWorkbenchForwardGeocodeLookup lookup,
) {
  enterpriseWorkbenchForwardGeocodeLookup = lookup;
}

void resetEnterpriseWorkbenchForwardGeocodeLookup() {
  enterpriseWorkbenchForwardGeocodeLookup = locationFromAddress;
}

class EnterpriseWorkbenchSubmitDisposition {
  const EnterpriseWorkbenchSubmitDisposition({
    required this.isPostSubmit,
    required this.subtitle,
    required this.showSubmitAction,
    required this.showRecreateDraftAction,
    required this.showViewApplicationStatusAction,
    required this.viewApplicationStatusPrimary,
    required this.showBlockers,
    this.panelTitle,
    this.panelBody,
    this.panelHighlighted = false,
  });

  final bool isPostSubmit;
  final String subtitle;
  final bool showSubmitAction;
  final bool showRecreateDraftAction;
  final bool showViewApplicationStatusAction;
  final bool viewApplicationStatusPrimary;
  final bool showBlockers;
  final String? panelTitle;
  final String? panelBody;
  final bool panelHighlighted;
}

class EnterprisePublishedChangeDisposition {
  const EnterprisePublishedChangeDisposition({
    required this.subtitle,
    required this.panelTitle,
    required this.panelBody,
    required this.panelHighlighted,
    required this.showSubmitAction,
    required this.showViewStatusAction,
    required this.viewStatusPrimary,
    required this.showBlockers,
  });

  final String subtitle;
  final String panelTitle;
  final String panelBody;
  final bool panelHighlighted;
  final bool showSubmitAction;
  final bool showViewStatusAction;
  final bool viewStatusPrimary;
  final bool showBlockers;
}

enum _EnterpriseWorkbenchPageMode { application, publishedChange }

enum _EnterpriseWorkbenchSurfaceMode { full, caseEditor }

enum _EnterpriseStatusPageMode { application, publishedChange }

const String _enterprisePublishedChangeRouteMode = 'published_change';

class EnterpriseApplicationPage extends StatefulWidget {
  const EnterpriseApplicationPage({super.key, this.initialBoardType});

  final EnterpriseBoardType? initialBoardType;

  @override
  State<EnterpriseApplicationPage> createState() =>
      _EnterpriseApplicationPageState();
}

class _EnterpriseApplicationPageState extends State<EnterpriseApplicationPage> {
  late EnterpriseBoardType _boardType;
  _EnterpriseWorkbenchSurfaceMode _surfaceMode =
      _EnterpriseWorkbenchSurfaceMode.full;
  _EnterpriseWorkbenchPageMode _pageMode =
      _EnterpriseWorkbenchPageMode.application;
  bool _routeInitialized = false;
  final _applicantNameController = TextEditingController();
  final _applicantMobileController = TextEditingController();
  final _registeredCityController = TextEditingController();
  final _nameController = TextEditingController();
  final _shortIntroController = TextEditingController();
  final _fullIntroController = TextEditingController();
  final _addressController = TextEditingController();
  final _foundedAtController = TextEditingController();
  final _factoryPlantAreaController = TextEditingController();
  final _factoryNameController = TextEditingController();
  final _factoryUrgentCycleController = TextEditingController();
  final _factoryMaxOrderCapacityController = TextEditingController();
  final _factoryQualificationController = TextEditingController();
  final _profileTwoController = TextEditingController();
  final _profileThreeController = TextEditingController();
  final _profileFourController = TextEditingController();
  final _profileFiveController = TextEditingController();
  final _caseTitleController = TextEditingController();
  final _caseExhibitionTypeController = TextEditingController();
  final _caseCityController = TextEditingController();
  final _caseEventTimeController = TextEditingController();
  final _caseSummaryController = TextEditingController();

  EnterpriseHubLoadResult<EnterpriseHubWorkbenchData>? _workbenchResult;
  EnterpriseHubLoadResult<EnterpriseHubPublishedChangeWorkbenchData>?
  _publishedChangeWorkbenchResult;
  EnterpriseHubLoadResult<EnterpriseHubPublishedChangeStatusData>?
  _publishedChangeStatusResult;
  EnterpriseHubLoadResult<EnterpriseHubDetailData>? _publishedLiveDetailResult;
  _WorkbenchImageItem? _logoImage;
  List<_WorkbenchImageItem> _albumShowcaseItems = const <_WorkbenchImageItem>[];
  List<_WorkbenchImageItem> _factoryShowcaseItems =
      const <_WorkbenchImageItem>[];
  List<_WorkbenchImageItem> _caseComposerImages = const <_WorkbenchImageItem>[];
  List<_FactoryEquipmentEntry> _factoryEquipmentEntries =
      <_FactoryEquipmentEntry>[_FactoryEquipmentEntry()];
  ChinaRegionCatalog? _regionCatalog;
  String? _certificationLegalNameTruth;
  String? _certificationRegisteredLocationTruth;
  String? _organizationContactName;
  String? _organizationContactMobile;
  String? _selectedCityCode;
  String? _selectedTeamSizeRange;
  String? _selectedUrgentCapability;
  String? _selectedTransportCapability;
  Set<String> _selectedProfileOneOptions = <String>{};
  Set<String> _selectedProfileTwoOptions = <String>{};
  Set<String> _selectedCooperationModes = <String>{};
  bool? _warehouseCapability;
  bool _contactVisible = true;
  bool _caseFeatured = false;
  bool _loading = false;
  bool _resolvingLocation = false;
  bool _submittingAction = false;
  bool _profileDraftDirty = false;
  bool _publishedChangeSnapshotExpanded = false;
  bool _publishedChangePreviewExpanded = false;
  String? _locationStatusMessage;
  EnterpriseHubLocationData? _resolvedLocationDraft;
  String? _draftStatusMessage;
  String? _editingCaseId;
  String? _routeCaseId;
  String? _routeEnterpriseId;
  bool _routeCaseSeedHydrated = false;
  String? _publishedEnterpriseId;
  String? _ensuredEnterpriseId;
  EnterpriseHubWorkbenchCertification? _certificationSummary;

  bool get _isCaseEditing => _normalizedText(_editingCaseId) != null;
  String get _caseSaveActionLabel => _isCaseEditing ? '保存修改' : '保存案例';
  bool get _isCaseEditorWorkbench =>
      _surfaceMode == _EnterpriseWorkbenchSurfaceMode.caseEditor;
  bool get _isPublishedChangeMode =>
      _pageMode == _EnterpriseWorkbenchPageMode.publishedChange;

  EnterpriseHubPublishedChangeWorkbenchData? get _publishedWorkbenchData =>
      _publishedChangeWorkbenchResult?.data;

  EnterpriseHubPublishedChangeStatusData? get _publishedChangeStatus =>
      _publishedChangeStatusResult?.data;

  EnterpriseHubWorkbenchBasic? get _currentBasic => _isPublishedChangeMode
      ? _publishedWorkbenchData?.basic
      : _workbenchResult?.data?.basic;

  List<EnterpriseHubWorkbenchCaseItem> get _currentCases =>
      _isPublishedChangeMode
      ? _publishedWorkbenchData?.cases ??
            const <EnterpriseHubWorkbenchCaseItem>[]
      : _workbenchResult?.data?.cases ??
            const <EnterpriseHubWorkbenchCaseItem>[];

  EnterpriseHubWorkbenchCertification? get _currentCertification =>
      _isPublishedChangeMode
      ? _certificationSummary
      : (_workbenchResult?.data?.certification ?? _certificationSummary);

  EnterpriseHubWorkbenchCaseItem? _takePendingCaseEditorSeed(String? caseId) {
    final pending = _pendingEnterpriseWorkbenchCaseEditorSeed;
    if (pending == null) {
      return null;
    }
    if (_normalizedText(pending.caseId) != _normalizedText(caseId)) {
      return null;
    }
    _pendingEnterpriseWorkbenchCaseEditorSeed = null;
    return pending;
  }

  void _primePendingCaseEditorSeed(String? caseId) {
    if (caseId == null) {
      _pendingEnterpriseWorkbenchCaseEditorSeed = null;
      return;
    }
    for (final item in _currentCases) {
      if (_normalizedText(item.caseId) == _normalizedText(caseId)) {
        _pendingEnterpriseWorkbenchCaseEditorSeed = item;
        return;
      }
    }
    _pendingEnterpriseWorkbenchCaseEditorSeed = null;
  }

  String? get _currentEnterpriseId => _isPublishedChangeMode
      ? (_publishedWorkbenchData?.enterpriseId ?? _publishedEnterpriseId)
      : (_workbenchResult?.data?.enterpriseId?.trim() ?? _ensuredEnterpriseId);

  @visibleForTesting
  Future<void> debugSaveBasicForTest() => _saveBasic();

  @visibleForTesting
  Map<String, Object?> debugBasicSaveSnapshotForTest() => <String, Object?>{
    'isPublishedChangeMode': _isPublishedChangeMode,
    'currentEnterpriseId': _currentEnterpriseId,
    'hasBasic': _currentBasic != null,
    'basicProvinceCode': _currentBasic?.provinceCode,
    'basicProvinceName': _currentBasic?.provinceName,
    'basicCityCode': _currentBasic?.cityCode,
    'basicCityName': _currentBasic?.cityName,
    'selectedCityCode': _selectedCityCode,
    'organizationCityTruth': _registeredCityController.text,
    'enterpriseNameTruth': _enterpriseNameTruthValue(),
    'fullIntro': _fullIntroController.text,
    'regionCatalogLoaded': _regionCatalog != null,
  };

  @override
  void initState() {
    super.initState();
    _boardType = widget.initialBoardType ?? EnterpriseBoardType.company;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_routeInitialized) {
      return;
    }
    _routeInitialized = true;
    _hydrateRouteContext();
    _loadWorkbench();
  }

  @override
  void dispose() {
    for (final entry in _factoryEquipmentEntries) {
      entry.dispose();
    }
    for (final controller in <TextEditingController>[
      _applicantNameController,
      _applicantMobileController,
      _registeredCityController,
      _nameController,
      _shortIntroController,
      _fullIntroController,
      _addressController,
      _foundedAtController,
      _factoryNameController,
      _factoryPlantAreaController,
      _factoryUrgentCycleController,
      _factoryMaxOrderCapacityController,
      _factoryQualificationController,
      _profileTwoController,
      _profileThreeController,
      _profileFourController,
      _profileFiveController,
      _caseTitleController,
      _caseExhibitionTypeController,
      _caseCityController,
      _caseEventTimeController,
      _caseSummaryController,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addFactoryEquipmentEntry() {
    setState(() {
      _factoryEquipmentEntries = <_FactoryEquipmentEntry>[
        ..._factoryEquipmentEntries,
        _FactoryEquipmentEntry(),
      ];
      _profileDraftDirty = true;
    });
  }

  void _hydrateRouteContext() {
    final routeUri = _currentRouteUri();
    final fixedBoardType = EnterpriseBoardType.fromRaw(
      ExhibitionRoutes.enterpriseBoardTypeFromPrivatePath(routeUri.path),
    );
    final routeBoardType =
        fixedBoardType ??
        EnterpriseBoardType.fromRaw(routeUri.queryParameters['boardType']);
    final publishedChangeRoute =
        routeUri.queryParameters['mode']?.trim() ==
        _enterprisePublishedChangeRouteMode;
    if (routeBoardType != null) {
      _boardType = routeBoardType;
    }
    _routeEnterpriseId = _normalizedText(
      routeUri.queryParameters['enterpriseId'],
    );
    if (ExhibitionRoutes.isEnterpriseCaseEditorPath(routeUri.path)) {
      _surfaceMode = _EnterpriseWorkbenchSurfaceMode.caseEditor;
      _routeCaseId = _normalizedText(routeUri.queryParameters['caseId']);
      if (!publishedChangeRoute) {
        final seededCase = _takePendingCaseEditorSeed(_routeCaseId);
        _routeCaseSeedHydrated = seededCase != null;
        if (seededCase != null) {
          _hydrateCaseComposerFromWorkbenchCaseItem(seededCase);
        }
      }
    }
    if (publishedChangeRoute) {
      _pageMode = _EnterpriseWorkbenchPageMode.publishedChange;
      _publishedEnterpriseId = _routeEnterpriseId;
    }
  }

  Uri _currentRouteUri() {
    final routeName = ModalRoute.of(context)?.settings.name;
    if (routeName == null || routeName.trim().isEmpty) {
      return Uri(path: '/');
    }
    return Uri.parse(routeName);
  }

  void _updateWorkbenchState(VoidCallback callback) {
    setState(callback);
  }

  void _hydrateRouteCaseComposerFromItems(
    List<EnterpriseHubWorkbenchCaseItem> items,
  ) {
    if (!_isCaseEditorWorkbench) {
      return;
    }
    final routeCaseId = _routeCaseId;
    if (routeCaseId == null) {
      _resetCaseComposer();
      return;
    }
    for (final item in items) {
      if (_normalizedText(item.caseId) == routeCaseId) {
        _hydrateCaseComposerFromWorkbenchCaseItem(item);
        return;
      }
    }
    _resetCaseComposer();
  }

  String _fullWorkbenchRoute() {
    if (_isPublishedChangeMode) {
      final enterpriseId = _currentEnterpriseId ?? _publishedEnterpriseId ?? '';
      return ExhibitionRoutes.enterprisePublishedChangeWorkbenchWithEnterpriseId(
        enterpriseId,
        boardType: _boardType.contractName,
      );
    }
    return ExhibitionRoutes.enterpriseWorkbenchForBoard(
      _boardType.contractName,
    );
  }

  String _caseEditorWorkbenchRoute({String? caseId}) {
    final publishedChange =
        _isPublishedChangeMode ||
        _shouldRouteCaseEditingThroughPublishedChangeCorridor;
    return ExhibitionRoutes.enterpriseCaseEditorWithBoardType(
      _boardType.contractName,
      enterpriseId: _currentEnterpriseId ?? _publishedEnterpriseId,
      caseId: caseId,
      publishedChange: publishedChange,
    );
  }

  Future<void> _openCaseEditorWorkbench({
    String? caseId,
    bool replaceCurrent = false,
  }) async {
    _primePendingCaseEditorSeed(caseId);
    final route = _caseEditorWorkbenchRoute(caseId: caseId);
    if (replaceCurrent) {
      await Navigator.of(context).pushReplacementNamed(route);
      return;
    }
    await Navigator.of(context).pushNamed(route);
  }

  @visibleForTesting
  Future<void> debugContinueEditCaseForTest(String caseId) {
    return _continueEditCase(caseId);
  }

  @visibleForTesting
  void debugHydrateCaseComposerFromWorkbenchCaseItemForTest(
    EnterpriseHubWorkbenchCaseItem item,
  ) {
    _updateWorkbenchState(() {
      _hydrateCaseComposerFromWorkbenchCaseItem(item);
    });
  }

  @visibleForTesting
  String get debugCaseSaveActionLabelForTest => _caseSaveActionLabel;

  @visibleForTesting
  String get debugCaseTitleForTest => _caseTitleController.text;

  @visibleForTesting
  String get debugCaseExhibitionTypeForTest =>
      _caseExhibitionTypeController.text;

  @visibleForTesting
  String get debugCaseCityForTest => _caseCityController.text;

  @visibleForTesting
  String get debugCaseEventTimeForTest => _caseEventTimeController.text;

  @visibleForTesting
  String get debugCaseSummaryForTest => _caseSummaryController.text;

  @visibleForTesting
  bool get debugCaseFeaturedForTest => _caseFeatured;

  @visibleForTesting
  List<String> get debugCaseComposerImageUrlsForTest => _caseComposerImages
      .map((item) => item.imageUrl?.trim() ?? '')
      .where((value) => value.isNotEmpty)
      .toList(growable: false);

  @visibleForTesting
  List<String> get debugCaseComposerImageFileAssetIdsForTest =>
      _caseComposerImages
          .map((item) => item.fileAssetId?.trim() ?? '')
          .where((value) => value.isNotEmpty)
          .toList(growable: false);

  @visibleForTesting
  bool get debugIsPublishedChangeModeForTest => _isPublishedChangeMode;

  bool get _shouldRouteCaseEditingThroughPublishedChangeCorridor {
    final enterpriseId = _normalizedText(_workbenchResult?.data?.enterpriseId);
    final applicationStatus = _normalizedText(
      _workbenchResult?.data?.latestApplication?.applicationStatus,
    );
    return enterpriseId != null &&
        _isPostSubmitApplicationStatus(applicationStatus);
  }

  @visibleForTesting
  String? get debugCurrentEnterpriseIdForTest => _currentEnterpriseId;

  @visibleForTesting
  AppPageState? get debugWorkbenchStateForTest => _workbenchResult?.state;

  @visibleForTesting
  String? get debugWorkbenchMessageForTest => _workbenchResult?.message;

  @visibleForTesting
  bool get debugHasPublishedWorkbenchDataForTest =>
      _publishedWorkbenchData != null;

  @visibleForTesting
  AppPageState? get debugPublishedWorkbenchStateForTest =>
      _publishedChangeWorkbenchResult?.state;

  @visibleForTesting
  String? get debugPublishedWorkbenchMessageForTest =>
      _publishedChangeWorkbenchResult?.message;

  @visibleForTesting
  bool get debugLoadingForTest => _loading;

  @visibleForTesting
  void debugMarkProfileDraftDirtyForTest() {
    _profileDraftDirty = true;
  }

  @visibleForTesting
  void debugHydrateBoardProfileFromWorkbenchForTest(
    Map<String, Object?> boardProfile,
  ) {
    final current = _workbenchResult?.data;
    if (current == null) {
      return;
    }
    _hydrateFromWorkbench(
      EnterpriseHubWorkbenchData(
        organizationId: current.organizationId,
        enterpriseId: current.enterpriseId,
        boardType: current.boardType,
        latestApplication: current.latestApplication,
        basic: current.basic,
        boardProfile: boardProfile,
        primaryContact: current.primaryContact,
        cases: current.cases,
        certification: current.certification,
        readiness: current.readiness,
      ),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) => _buildWorkbenchPage(context);
}
