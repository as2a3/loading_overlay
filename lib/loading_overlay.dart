library loading_overlay;

import 'dart:async';

import 'package:flutter/material.dart';

/// Loading Overlay
class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({
    Key? key,
    this.isLoading = false,
    this.isLoadingError = false,
    this.errorText = '',
    this.noDataMessage = '',
    this.isEmptyData = false,
    this.loadingHeight = 300,
    this.retryAction,
    required this.child,
    this.loadingWidget,
    this.loadingErrorWidget,
    this.emptyWidget,
    this.noDataImageSize = 200,
    this.noDataIcon,
  }) : super(key: key);

  /// [bool] value about loading status
  final bool isLoading;

  /// [bool] value about if error occurred during loading
  final bool isLoadingError;

  /// [String] Text contains the error message
  final String errorText;

  /// [bool] Is data empty?
  final bool isEmptyData;

  /// [double] The height of loading widget
  final double loadingHeight;

  /// [Function] Function to re process if error occurred
  final Function? retryAction;

  /// [Widget] Main widget to show, which may be contains
  /// the data from loading process.
  final Widget child;


  final Widget? loadingWidget;
  /// [Widget] Loading widget
  final Widget? loadingErrorWidget;

  /// [Widget] No data widget
  final Widget? emptyWidget;
  /// [String] Text contains the message if no data found
  final String noDataMessage;
  /// [double] No data image size
  final double noDataImageSize;
  /// [Widget] No data Widget
  final Widget? noDataIcon;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return loadingWidget ?? CircularLoadingWidget(height: loadingHeight);
    }
    if (isLoadingError) {
      return loadingErrorWidget ??
          LoadingErrorWidget(
            msg: errorText,
            retryAction: () => retryAction?.call(),
          );
    }
    if (isEmptyData) {
      return emptyWidget ?? NoDataFoundWidget(
        msg: noDataMessage,
        size: noDataImageSize,
        iconWidget: noDataIcon,
      );
    }
    return child;
  }
}

/// Loading Widget
class CircularLoadingWidget extends StatefulWidget {
  final double? height;
  final Function? onComplete;
  final String? onCompleteText;
  final bool autoClose;

  const CircularLoadingWidget({
    Key? key,
    this.height,
    this.onComplete,
    this.onCompleteText,
    this.autoClose = false,
  }) : super(key: key);

  @override
  _CircularLoadingWidgetState createState() => _CircularLoadingWidgetState();
}

class _CircularLoadingWidgetState extends State<CircularLoadingWidget>
    with SingleTickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this);
    final curve =
        CurvedAnimation(parent: animationController, curve: Curves.easeOut);
    animation = Tween<double>(begin: widget.height, end: 0).animate(curve)
      ..addListener(() {
        if (mounted) {
          setState(() {});
        }
      });
    if (widget.autoClose) {
      Timer(const Duration(seconds: 10), () {
        if (mounted) {
          animationController.forward();
        }
        widget.onComplete?.call();
      });
    }
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return animationController.isCompleted
        ? SizedBox(
            height: widget.height,
            child: Center(
              child: Text(
                widget.onCompleteText ?? '',
                style: Theme.of(context).textTheme.caption!.copyWith(
                      fontSize: 14,
                    ),
              ),
            ),
          )
        : Opacity(
            opacity: animation.value / 100 > 1.0 ? 1.0 : animation.value / 100,
            child: SizedBox(
              height: animation.value,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
  }
}

/// Loading Error Widget
class LoadingErrorWidget extends StatelessWidget {
  final String msg;
  final String retryText;
  final Function? retryAction;
  final Widget? retryWidget;

  const LoadingErrorWidget({
    Key? key,
    this.msg = '',
    this.retryText = '',
    this.retryAction,
    this.retryWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(
          16,
        ),
        elevation: 8.0,
        color: Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image(
                image: const AssetImage('assets/loading_error.png'),
                width: MediaQuery.of(context).size.width * 0.2,
              ),
              const SizedBox(
                height: 16.0,
              ),
              Text(
                msg.isNotEmpty ? msg : 'An Error Occurred',
                style: Theme.of(context).textTheme.headline5!.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
              ),
              const SizedBox(
                height: 8.0,
              ),
              if (retryWidget != null) retryWidget!,
              if (retryWidget == null && retryAction != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      child: Text(retryText.isNotEmpty ? retryText : 'Retry'),
                      onPressed: () => retryAction?.call(),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// No Data Widget
class NoDataFoundWidget extends StatelessWidget {
  final String msg;
  final double size;
  final Widget? iconWidget;

  const NoDataFoundWidget({
    Key? key,
    this.msg = '',
    this.size = 200,
    this.iconWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        elevation: 8.0,
        color: Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (iconWidget == null)
              Image(
                image: const AssetImage(
                  'assets/no_data.png',
                ),
                width: size,
              ),
              if (iconWidget != null)
                iconWidget!,
              const SizedBox(
                height: 16.0,
              ),
              Text(
                msg.isNotEmpty ? msg : 'No data found',
                style: Theme.of(context).textTheme.headline5!.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              const SizedBox(
                height: 4.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}