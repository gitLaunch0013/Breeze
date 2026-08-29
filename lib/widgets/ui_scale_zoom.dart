import 'package:flutter/widgets.dart';

/// 暴露当前界面缩放倍率；未启用缩放时为 1.0。
class UiScaleScope extends InheritedWidget {
  const UiScaleScope({super.key, required this.scale, required super.child});

  final double scale;

  static double of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<UiScaleScope>()?.scale ?? 1.0;

  @override
  bool updateShouldNotify(UiScaleScope oldWidget) =>
      oldWidget.scale != scale;
}

/// 全局界面缩放：按 [virtualSize] 布局子组件，再用 [scale] 放大铺满真实屏幕。
///
/// 通过 MediaQuery 覆盖让布局认为屏幕是真实尺寸的 1/scale，
/// 使各处基于 `MediaQuery.size` 的断点与排版随虚拟分辨率自适应；
/// `Transform.scale` 再整体放大，配合 Flutter 的图层栅格化保持文字清晰。
/// 不修改 devicePixelRatio / textScaler，避免图片解码内存成倍放大。
class UiScaleZoom extends StatelessWidget {
  const UiScaleZoom({
    super.key,
    required this.scale,
    required this.virtualSize,
    required this.child,
  });

  final double scale;
  final Size virtualSize;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // 本节点位于自身 MediaQuery 覆盖之上，读到的是真实屏幕尺寸。
    final mq = MediaQuery.of(context);
    return MediaQuery(
      data: mq.copyWith(
        size: virtualSize,
        padding: mq.padding / scale,
        viewPadding: mq.viewPadding / scale,
        viewInsets: mq.viewInsets / scale,
      ),
      child: UiScaleScope(
        scale: scale,
        // OverflowBox 松绑父级约束（根节点为紧约束、桌面 Column 内为松约束），
        // 让虚拟尺寸的 SizedBox 生效；Transform 从左上角放大正好铺满真实区域。
        child: OverflowBox(
          alignment: Alignment.topLeft,
          minWidth: 0,
          maxWidth: mq.size.width,
          minHeight: 0,
          maxHeight: mq.size.height,
          child: Transform.scale(
            scale: scale,
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: virtualSize.width,
              height: virtualSize.height,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
