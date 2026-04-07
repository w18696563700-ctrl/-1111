import 'package:flutter/widgets.dart';
import 'package:mobile/shared/widgets/building_skeleton_page.dart';

class RenovationPage extends StatelessWidget {
  const RenovationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const BuildingSkeletonPage(
      buildingCode: 'renovation',
      title: '装修楼预埋骨架',
      description: '装修楼已真实存在于工程与路由中，但首期默认隐藏，仅保留未来接入所需的 Shell 承载面。',
      highlights: <String>['真实路由已注册', '默认可见性为 false', '可由 manifest 打开'],
      statusNote: '本阶段不实现装修业务闭环，不引入未冻结 DTO、权限规则或交易页面。',
    );
  }
}
