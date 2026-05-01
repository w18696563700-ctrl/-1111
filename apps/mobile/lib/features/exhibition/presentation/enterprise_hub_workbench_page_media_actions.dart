part of 'enterprise_hub_workbench_pages.dart';

extension _EnterpriseWorkbenchPageMediaActions
    on _EnterpriseApplicationPageState {
  Future<void> _replaceLogoImage() async {
    final enterpriseId = await _ensureEnterpriseId();
    if (enterpriseId == null || enterpriseId.isEmpty) {
      return;
    }
    final current = await _pickAndUploadImage(
      enterpriseId: enterpriseId,
      fileKind: _enterpriseLogoFileKind,
      successMessage: '企业 Logo 已上传。',
    );
    if (!mounted || current == null) {
      return;
    }
    _updateWorkbenchState(() => _logoImage = current);
    if (current.fileAssetId == null || current.fileAssetId!.trim().isEmpty) {
      return;
    }
    await _runAction(() async {
      final result = _isPublishedChangeMode
          ? await EnterpriseHubPublishedChangeConsumerLayer.instance
                .updateCurrentChangeBasic(
                  boardType: _boardType,
                  enterpriseId: enterpriseId,
                  body: <String, Object?>{
                    'logoFileAssetId': current.fileAssetId,
                  },
                )
          : await EnterpriseHubConsumerLayer.instance.updateBasic(
              boardType: _boardType,
              enterpriseId: enterpriseId,
              body: <String, Object?>{'logoFileAssetId': current.fileAssetId},
            );
      if (!mounted) {
        return;
      }
      if (!result.isSuccess) {
        _showWorkbenchMessage(
          _localizedWorkbenchMessage(
            result.message ?? '企业 Logo 已上传，但暂未绑定到基础资料。',
          ),
        );
        return;
      }
      _showWorkbenchMessage(
        _isPublishedChangeMode
            ? '企业 Logo 已上传并绑定到当前变更内容，线上展示暂未更新。'
            : '企业 Logo 已上传并绑定。',
      );
      await _loadWorkbench();
    });
  }

  Future<void> _addAlbumShowcaseImage() async {
    if (_albumShowcaseItems.length >= _workbenchImageLimit) {
      _showWorkbenchMessage('企业画册最多 6 张。');
      return;
    }
    final enterpriseId = await _ensureEnterpriseId();
    if (enterpriseId == null || enterpriseId.isEmpty) {
      return;
    }
    final item = await _pickAndUploadImage(
      enterpriseId: enterpriseId,
      fileKind: _enterpriseAlbumFileKind,
      successMessage: _isPublishedChangeMode
          ? '画册图片已上传，点击“确认上传”后再写入当前变更内容。'
          : '画册图片已上传，点击“确认上传”后再正式保存。',
    );
    if (!mounted || item == null) {
      return;
    }
    _updateWorkbenchState(() {
      _albumShowcaseItems = <_WorkbenchImageItem>[
        ..._albumShowcaseItems,
        item.copyWith(statusMessage: '已上传，待确认'),
      ];
    });
  }

  Future<void> _addFactoryShowcaseImage() async {
    if (_factoryShowcaseItems.length >= _workbenchImageLimit) {
      _showWorkbenchMessage('工厂实景图最多 6 张。');
      return;
    }
    final enterpriseId = await _ensureEnterpriseId();
    if (enterpriseId == null || enterpriseId.isEmpty) {
      return;
    }
    final item = await _pickAndUploadImage(
      enterpriseId: enterpriseId,
      fileKind: _enterpriseFactoryShowcaseFileKind,
      successMessage: _isPublishedChangeMode
          ? '工厂照片已上传，点击“确认上传”后再写入当前变更内容。'
          : '工厂照片已上传，点击“确认上传”后再统一生效。',
    );
    if (!mounted || item == null) {
      return;
    }
    _updateWorkbenchState(() {
      _factoryShowcaseItems = <_WorkbenchImageItem>[
        ..._factoryShowcaseItems,
        item.copyWith(statusMessage: '已上传，待保存'),
      ];
      _profileDraftDirty = true;
    });
  }

  void _removeAlbumImage(String localId) {
    _updateWorkbenchState(() {
      _albumShowcaseItems = _albumShowcaseItems
          .where((item) => item.localId != localId)
          .toList(growable: false);
    });
  }

  Future<void> _addCaseImage() async {
    if (_caseComposerImages.length >= _workbenchImageLimit) {
      _showWorkbenchMessage('单个案例最多 6 张图片。');
      return;
    }
    final enterpriseId = await _ensureEnterpriseId();
    if (enterpriseId == null || enterpriseId.isEmpty) {
      return;
    }
    final item = await _pickAndUploadImage(
      enterpriseId: enterpriseId,
      fileKind: _enterpriseCaseMediaFileKind,
      successMessage: _isCaseEditing
          ? (_isPublishedChangeMode
                ? '案例图片已上传，点击“保存修改”后再写入当前变更内容。'
                : '案例图片已上传，点击“保存修改”后再正式更新当前案例。')
          : (_isPublishedChangeMode
                ? '案例图片已上传，点击“保存案例”后再写入当前变更内容。'
                : '案例图片已上传，点击“保存案例”后再正式入库。'),
    );
    if (!mounted || item == null) {
      return;
    }
    _updateWorkbenchState(() {
      _caseComposerImages = <_WorkbenchImageItem>[..._caseComposerImages, item];
    });
  }

  Future<_WorkbenchImageItem?> _pickAndUploadImage({
    required String enterpriseId,
    required String fileKind,
    required String successMessage,
  }) async {
    final file = await _pickWorkbenchImageWithEditor(
      title: fileKind == _enterpriseLogoFileKind ? '调整企业 Logo' : '调整图片',
      imageLabel: fileKind == _enterpriseLogoFileKind ? '企业 Logo' : '图片',
      defaultStem: fileKind == _enterpriseLogoFileKind
          ? 'enterprise_logo'
          : 'enterprise_image',
    );
    if (file == null) {
      return null;
    }
    final uploading = _WorkbenchImageItem.local(
      fileName: file.name,
      bytes: file.bytes,
      mimeType: file.mimeType,
      checksum: file.checksum,
      stage: _WorkbenchImageStage.uploading,
      statusMessage: '正在上传到企业展示素材库',
    );
    final uploaded = await _uploadWorkbenchImage(
      enterpriseId: enterpriseId,
      item: uploading,
      fileKind: fileKind,
    );
    if (!mounted) {
      return null;
    }
    if (uploaded.fileAssetId != null) {
      _showWorkbenchMessage(successMessage);
    } else if (uploaded.statusMessage != null) {
      _showWorkbenchMessage(
        _localizedWorkbenchMessage(uploaded.statusMessage!),
      );
    }
    return uploaded;
  }

  Future<String?> _ensureEnterpriseId() async {
    final currentEnterpriseId = _currentEnterpriseId;
    if (currentEnterpriseId != null && currentEnterpriseId.isNotEmpty) {
      return currentEnterpriseId;
    }
    if (_isPublishedChangeMode) {
      _showWorkbenchMessage('缺少 enterpriseId，当前无法进入已发布展示变更通道。');
      return null;
    }
    final result = await EnterpriseHubConsumerLayer.instance.ensureShell(
      boardType: _boardType,
    );
    if (!mounted) {
      return null;
    }
    if (!result.isSuccess) {
      _showWorkbenchMessage(
        _localizedWorkbenchMessage(result.message ?? '当前无法准备企业展示档。'),
      );
      return null;
    }

    await _loadWorkbench();
    final enterpriseId =
        _workbenchResult?.data?.enterpriseId?.trim() ??
        _ensuredEnterpriseId ??
        result.data?.enterpriseId.trim();
    if (enterpriseId == null || enterpriseId.isEmpty) {
      _showWorkbenchMessage('当前展示档已准备，但企业记录尚未就绪，请稍后重试。');
      return null;
    }
    _updateWorkbenchState(() {
      _ensuredEnterpriseId = enterpriseId;
      _draftStatusMessage = '当前板块展示档已就绪，可以继续维护资料、上传图片和后续申请。';
    });
    final shellStatus = _normalizedText(result.data?.shellStatus);
    _showWorkbenchMessage(
      shellStatus == 'created'
          ? '已自动准备展示档，可以继续保存资料和上传图片。'
          : '当前展示档已就绪，可以继续保存资料和上传图片。',
    );
    return enterpriseId;
  }

  Future<_WorkbenchPickedImage?> _pickWorkbenchImageWithEditor({
    required String title,
    required String imageLabel,
    required String defaultStem,
  }) async {
    try {
      final pickResult = await ProfileAvatarPicker.instance.pick(
        source: ProfileAvatarPickSource.gallery,
      );
      if (pickResult.cancelled) {
        return null;
      }
      final picked = pickResult.file;
      if (picked == null) {
        _showWorkbenchMessage(pickResult.message ?? '当前没有读取到可用图片。');
        return null;
      }
      final bytes = picked.bytes;
      final fileName = picked.fileName.trim().isEmpty
          ? '$defaultStem.jpg'
          : picked.fileName.trim();
      if (bytes.isEmpty) {
        _showWorkbenchMessage('当前没有读取到可用图片。');
        return null;
      }
      final mimeType = _workbenchImageMimeType(fileName) ?? picked.mimeType;
      if (!mimeType.startsWith('image/')) {
        _showWorkbenchMessage('当前只支持常见图片格式。');
        return null;
      }
      if (!mounted) {
        return null;
      }
      final edited = await openProfileAvatarEditConfirmationPage(
        context,
        file: ProfileAvatarPickedFile(
          fileName: fileName,
          mimeType: mimeType,
          bytes: bytes,
        ),
        title: title,
        imageLabel: imageLabel,
        defaultStem: defaultStem,
      );
      if (edited == null) {
        return null;
      }
      return _WorkbenchPickedImage(
        name: edited.fileName.trim().isEmpty
            ? '$defaultStem.jpg'
            : edited.fileName.trim(),
        bytes: Uint8List.fromList(edited.bytes),
        mimeType: edited.mimeType,
        checksum: sha256.convert(edited.bytes).toString(),
      );
    } catch (_) {
      _showWorkbenchMessage('当前设备暂时打不开图片选择器，请稍后再试。');
      return null;
    }
  }

  Future<_WorkbenchImageItem> _uploadWorkbenchImage({
    required String enterpriseId,
    required _WorkbenchImageItem item,
    required String fileKind,
  }) async {
    final initResult = await ExhibitionConsumerLayer.instance.uploadInit(
      UploadInitCommand(
        businessType: _enterpriseDisplayBusinessType,
        businessId: enterpriseId,
        fileKind: fileKind,
        mimeType: item.mimeType ?? 'image/jpeg',
        size: item.bytes?.length ?? 0,
        checksum: item.checksum ?? '',
      ),
    );
    final directive = initResult.directive;
    if (initResult.state != AppUploadState.signedReady || directive == null) {
      return item.copyWith(
        stage: _WorkbenchImageStage.failed,
        statusMessage: _localizedWorkbenchMessage(
          initResult.message ?? '图片上传初始化失败，请稍后再试。',
        ),
      );
    }

    final uploadResult = await ExhibitionConsumerLayer.instance.directUpload(
      directive: directive,
      bodyBytes: item.bytes ?? const <int>[],
    );
    if (uploadResult.state != AppUploadState.uploadConfirming) {
      return item.copyWith(
        stage: _WorkbenchImageStage.failed,
        statusMessage: _localizedWorkbenchMessage(
          uploadResult.message ?? '图片上传失败，请重新选择后再试。',
        ),
      );
    }

    final confirmResult = await ExhibitionConsumerLayer.instance.uploadConfirm(
      directive: directive,
    );
    final fileAssetId = confirmResult.fileAssetId?.trim();
    if (confirmResult.state != AppUploadState.uploadBound ||
        fileAssetId == null ||
        fileAssetId.isEmpty) {
      return item.copyWith(
        stage: _WorkbenchImageStage.failed,
        statusMessage: _localizedWorkbenchMessage(
          confirmResult.message ?? '图片上传确认失败，请稍后再试。',
        ),
      );
    }

    return item.copyWith(
      stage: _WorkbenchImageStage.ready,
      fileAssetId: fileAssetId,
      statusMessage: '已上传',
    );
  }

  void _removeFactoryShowcaseImage(String localId) {
    _updateWorkbenchState(() {
      _factoryShowcaseItems = _factoryShowcaseItems
          .where((item) => item.localId != localId)
          .toList(growable: false);
      _profileDraftDirty = true;
    });
  }

  void _markProfileDraftDirty() {
    _profileDraftDirty = true;
  }

  void _removeCaseImage(String localId) {
    _updateWorkbenchState(() {
      _caseComposerImages = _caseComposerImages
          .where((item) => item.localId != localId)
          .toList(growable: false);
    });
  }
}
