import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:rxdart/rxdart.dart';

class LoadingWidget extends StatefulWidget {
  final bool isLoading;

  LoadingWidget(this.isLoading);

  @override
  _LoadingWidgetState createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget>
    with SingleTickerProviderStateMixin {
  BehaviorSubject<bool> _isLoadingController;
  AnimationController _controller;

  @override
  void initState() {
    _isLoadingController = BehaviorSubject(seedValue: widget.isLoading);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    super.initState();
  }

  @override
  void didUpdateWidget(LoadingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isLoading == widget.isLoading) {
      return;
    }
    _isLoadingController?.add(widget.isLoading);
  }

  @override
  void dispose() {
    _isLoadingController?.close();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: _isLoadingController.stream.switchMap((isLoading) =>
          Observable.timer(isLoading, const Duration(milliseconds: 500))),
      builder: (context, snapshot) {
        return Center(
          child: Visibility(
            visible: snapshot.data ?? false,
            child: Container(
              child: SpinKitRotatingCircle(
                color: Colors.blueAccent,
                size: 40,
                controller: _controller,
              ),
            ),
          ),
        );
      },
    );
  }
}
