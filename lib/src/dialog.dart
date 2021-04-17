import 'package:flutter/material.dart';

import 'dialog_view_wrapper.dart';

abstract class FDialogView {
  void applyDialog(FDialog dialog);
}

mixin FDialogViewMixin implements FDialogView {
  FDialog? dialog;

  @override
  void applyDialog(FDialog dialog) {
    this.dialog = dialog;
    if (dialog.dialogViewWrapper == null) {
      dialog.dialogViewWrapper = FDialogViewWrapper.defaultWrapper;
    }
  }
}

abstract class FDialogViewWrapper {
  static final FDialogViewWrapper defaultWrapper = FSimpleDialogViewWrapper();

  Widget wrap(BuildContext context, Widget widget);
}

class FDialog {
  final GlobalKey<_InternalWidgetState> _globalKey = GlobalKey();

  /// 触摸到非内容区域是否关闭窗口
  bool dismissOnTouchOutside = false;

  /// 窗口关闭监听
  VoidCallback? onDismissListener;

  /// 窗口View包裹
  FDialogViewWrapper? dialogViewWrapper = FDialogViewWrapper.defaultWrapper;

  Widget? _widget;
  Widget? _showingWidget;

  bool _isShowing = false;

  /// 窗口是否正在显示
  bool get isShowing => _isShowing;

  Widget _widgetBuilder(BuildContext context) {
    return _InternalWidget(
      key: _globalKey,
      builder: (context) {
        _showingWidget = _widget!;
        Widget current = _widget!;

        if (current is FDialogView) {
          final FDialogView dialogView = current as FDialogView;
          dialogView.applyDialog(this);
        }

        if (dialogViewWrapper != null) {
          current = dialogViewWrapper!.wrap(context, current);
        }

        if (dismissOnTouchOutside) {
          return current;
        }

        return Container(
          color: Colors.transparent,
          child: current,
          width: double.infinity,
          height: double.infinity,
        );
      },
    );
  }

  /// 显示窗口
  void show(BuildContext context, {required Widget widget}) {
    dismiss();

    _isShowing = true;
    _widget = widget;

    showDialog(context: context, builder: _widgetBuilder).whenComplete(() {
      _isShowing = false;

      if (_showingWidget == _widget) {
        _widget = null;
        _showingWidget = null;
      }

      if (onDismissListener != null) {
        onDismissListener!();
      }
    });
  }

  /// 关闭窗口
  bool dismiss() {
    if (!_isShowing) return false;

    _isShowing = false;
    final _InternalWidgetState? state = _checkState();
    if (state != null) {
      Navigator.of(state.context).pop();
    }
    return true;
  }

  _InternalWidgetState? _checkState() {
    _InternalWidgetState? state = _globalKey.currentState;
    if (state != null && state.mounted) {
      return state;
    }
    return null;
  }
}

class _InternalWidget extends StatefulWidget {
  final WidgetBuilder builder;

  _InternalWidget({required Key key, required this.builder}) : super(key: key);

  @override
  _InternalWidgetState createState() => _InternalWidgetState();
}

class _InternalWidgetState extends State<_InternalWidget> {
  @override
  Widget build(BuildContext context) {
    return widget.builder(context);
  }
}
