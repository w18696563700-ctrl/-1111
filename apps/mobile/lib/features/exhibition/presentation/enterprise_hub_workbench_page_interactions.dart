part of 'enterprise_hub_workbench_pages.dart';

extension _EnterpriseWorkbenchPageInteractions
    on _EnterpriseApplicationPageState {
  void _showWorkbenchMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_localizedWorkbenchMessage(message))),
    );
  }

  Future<void> _selectCaseCity() async {
    final catalog = _regionCatalog ?? await ChinaRegionCatalogLoader.load();
    if (!mounted) {
      return;
    }
    final picked = await showChinaCityPicker(
      context: context,
      catalog: catalog,
      title: '选择案例城市',
      initialCityCode: catalog.cityByName(_caseCityController.text)?.cityCode,
    );
    if (!mounted || picked == null) {
      return;
    }
    _updateWorkbenchState(() => _caseCityController.text = picked.cityName);
  }

  Future<void> _selectCaseEventTime() async {
    final picked = await showChinaDatePicker(
      context: context,
      title: '选择举办时间',
      initialDate: _parseIsoDate(_caseEventTimeController.text),
      minimumDate: DateTime(2000, 1, 1),
      maximumDate: DateTime(2100, 12, 31),
    );
    if (!mounted || picked == null) {
      return;
    }
    _updateWorkbenchState(
      () => _caseEventTimeController.text = _formatIsoDate(picked),
    );
  }
}
