const List<MapEntry<String, String>> enterpriseHubSupplierCategoryOptions =
    <MapEntry<String, String>>[
      MapEntry<String, String>('广告喷绘公司', '广告喷绘公司'),
      MapEntry<String, String>('发光字工厂', '发光字工厂'),
      MapEntry<String, String>('泡雕/玻璃钢工厂', '泡雕/玻璃钢工厂'),
      MapEntry<String, String>('桁架舞台搭建厂', '桁架舞台搭建厂'),
      MapEntry<String, String>('灯光音响屏幕音响', '灯光音响屏幕音响'),
      MapEntry<String, String>('玻璃厂', '玻璃厂'),
      MapEntry<String, String>('地台租赁', '地台租赁'),
      MapEntry<String, String>('脚手架租赁', '脚手架租赁'),
      MapEntry<String, String>('升降机租赁', '升降机租赁'),
      MapEntry<String, String>('家具租赁', '家具租赁'),
      MapEntry<String, String>('植物租赁', '植物租赁'),
      MapEntry<String, String>('地毯铺设', '地毯铺设'),
      MapEntry<String, String>('软膜安装', '软膜安装'),
      MapEntry<String, String>('电视机/触摸屏租赁', '电视机/触摸屏租赁'),
      MapEntry<String, String>('木地板铺设', '木地板铺设'),
      MapEntry<String, String>('搭建餐饮配送', '搭建餐饮配送'),
      MapEntry<String, String>('礼仪模特摄影', '礼仪模特摄影'),
      MapEntry<String, String>('现场保洁服务', '现场保洁服务'),
      MapEntry<String, String>('展柜制作/纯喷漆服务', '展柜制作/纯喷漆服务'),
    ];

String? enterpriseHubSupplierCategoryLabel(String? value) {
  final normalized = value?.trim();
  if (normalized == null || normalized.isEmpty) {
    return null;
  }
  for (final option in enterpriseHubSupplierCategoryOptions) {
    if (option.key == normalized) {
      return option.value;
    }
  }
  return normalized;
}
