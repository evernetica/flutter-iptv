import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_iptv/app/widgets/button_tv_compatible.dart';
import 'package:flutter_iptv/misc/app_colors.dart';

enum _DialogTypes {
  yesNo,
  info,
  custom,
}

enum _ControllerEvents {
  setWarning,
  pop,
}

class DialogAction {
  DialogAction({
    required this.label,
    this.callback,
    this.shouldPop = true,
    this.popReturn = false,
  });

  DialogAction.cancel()
      : label = "Cancel",
        callback = null,
        shouldPop = true,
        popReturn = false;

  DialogAction.ok()
      : label = "Ok",
        callback = null,
        shouldPop = true,
        popReturn = true;

  DialogAction.yes()
      : label = "Yes",
        callback = null,
        shouldPop = true,
        popReturn = true;

  DialogAction.no()
      : label = "No",
        callback = null,
        shouldPop = true,
        popReturn = false;

  final String label;
  final VoidCallback? callback;
  final bool shouldPop;
  final dynamic popReturn;
}

class ModalDialog extends StatefulWidget {
  ModalDialog.yesNo({
    super.key,
    String? yesLabel,
    String? noLabel,
    String? titleText,
    String? bodyText,
    List<Widget>? customBodyWidgets,
  })  : _dialogType = _DialogTypes.yesNo,
        _customBodyWidgets = customBodyWidgets,
        _yesLabel = yesLabel ?? "Yes",
        _noLabel = noLabel ?? "No",
        _customButtons = null,
        _titleText = titleText,
        _bodyText = bodyText;

  ModalDialog.info({
    super.key,
    String? titleText,
    String? bodyText,
    List<Widget>? customBodyWidgets,
    String? yesLabel,
  })  : _dialogType = _DialogTypes.info,
        _customBodyWidgets = customBodyWidgets,
        _yesLabel = yesLabel ?? "Ok",
        _noLabel = null,
        _customButtons = null,
        _titleText = titleText,
        _bodyText = bodyText;

  ModalDialog.custom({
    super.key,
    String? titleText,
    String? bodyText,
    List<Widget>? customBodyWidgets,
    List<DialogAction>? customButtons,
  })  : _dialogType = _DialogTypes.custom,
        _customBodyWidgets = customBodyWidgets,
        _yesLabel = null,
        _noLabel = null,
        _customButtons = customButtons,
        _titleText = titleText,
        _bodyText = bodyText;

  final _DialogTypes _dialogType;
  final String? _yesLabel;
  final String? _noLabel;
  final List<Widget>? _customBodyWidgets;
  final List<DialogAction>? _customButtons;
  final String? _titleText;
  final String? _bodyText;

  final StreamController _controller =
      StreamController<Map<_ControllerEvents, dynamic>>();

  void setWarning({String warning = ""}) {
    _controller.add({_ControllerEvents.setWarning: warning});
  }

  void popWithValue({dynamic value = false}) {
    _controller.add({_ControllerEvents.pop: value});
  }

  @override
  State<ModalDialog> createState() => _ModalDialogState();
}

class _ModalDialogState extends State<ModalDialog> {
  @override
  void initState() {
    super.initState();

    eventHandler = widget._controller.stream.listen(
      (event) {
        if (event is! Map<_ControllerEvents, dynamic>) return;

        if (event.keys.contains(_ControllerEvents.setWarning)) {
          _setWarning(event[_ControllerEvents.setWarning]);
        }

        if (event.keys.contains(_ControllerEvents.pop)) {
          _pop(event[_ControllerEvents.pop]);
        }
      },
    );
  }

  @override
  void dispose() {
    eventHandler.cancel();
    super.dispose();
  }

  late StreamSubscription eventHandler;
  String warning = "";

  @override
  Widget build(BuildContext context) {
    switch (widget._dialogType) {
      case _DialogTypes.yesNo:
        return _buildDialogBase(
          actions: [
            DialogAction(
              label: widget._yesLabel!,
              shouldPop: true,
              popReturn: true,
            ),
            DialogAction(
              label: widget._noLabel!,
              shouldPop: true,
              popReturn: false,
            ),
          ],
        );
      case _DialogTypes.info:
        return _buildDialogBase(
          actions: [
            DialogAction(
              label: widget._yesLabel!,
              shouldPop: true,
              popReturn: null,
            ),
          ],
        );
      case _DialogTypes.custom:
        return _buildDialogBase(
          actions: widget._customButtons ?? [],
        );
    }
  }

  Widget _buildDialogBase({
    required List<DialogAction> actions,
  }) {
    return GestureDetector(
      onTap: () {
        _pop(false);
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: StatefulBuilder(
            builder: (context, setState) {
              return DefaultTextStyle(
                style: const TextStyle(
                  color: Colors.black,
                ),
                child: Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if (widget._titleText != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    widget._titleText!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              if (widget._bodyText != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    widget._bodyText!,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              if (widget._customBodyWidgets != null)
                                ...widget._customBodyWidgets!,
                              if (warning.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    warning,
                                    style: const TextStyle(
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Theme(
                                  data: ThemeData(
                                    elevatedButtonTheme:
                                        ElevatedButtonThemeData(
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateColor.resolveWith(
                                          (_) => AppColors.fgMain,
                                        ),
                                        foregroundColor:
                                            MaterialStateColor.resolveWith(
                                          (_) => Colors.white,
                                        ),
                                        overlayColor:
                                            MaterialStateColor.resolveWith(
                                          (_) => Colors.white38,
                                        ),
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(
                                      actions.length,
                                      (i) => Padding(
                                        padding: EdgeInsets.only(
                                          left: (i > 0) ? 16.0 : 0.0,
                                        ),
                                        child: ButtonTvCompatible(
                                          isButtonElevated: true,
                                          callback: () {
                                            actions[i].callback?.call();
                                            if (actions[i].shouldPop) {
                                              _pop(actions[i].popReturn);
                                            }
                                          },
                                          child: Text(actions[i].label),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _setWarning(String newWaring) {
    setState(() {
      warning = newWaring;
    });
  }

  void _pop(dynamic output) {
    Navigator.of(
      context,
      rootNavigator: true,
    ).pop(output);
  }
}
