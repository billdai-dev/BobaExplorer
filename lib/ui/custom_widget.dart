import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mark922_flutter_lottie/mark922_flutter_lottie.dart';
import 'package:rxdart/rxdart.dart';

class LoadingWidget extends StatefulWidget {
  final bool isLoading;
  final Stream<bool> isLoadingStream;

  LoadingWidget({this.isLoading, this.isLoadingStream});

  @override
  _LoadingWidgetState createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget>
    with SingleTickerProviderStateMixin {
  BehaviorSubject<bool> _isLoadingController;
  StreamSubscription<bool> _isLoadingStreamSub;
  //AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _isLoadingController = BehaviorSubject(seedValue: widget.isLoading);
    _isLoadingStreamSub =
        widget.isLoadingStream?.listen(_isLoadingController.add);
    /*_controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));*/
  }

  @override
  void didUpdateWidget(LoadingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading != null) {
      _isLoadingController?.add(widget.isLoading);
    }
    if (oldWidget.isLoadingStream == widget.isLoadingStream) {
      return;
    }
    _isLoadingStreamSub?.cancel();
    _isLoadingStreamSub =
        widget.isLoadingStream?.listen((isLoading) => _isLoadingController.add);
  }

  @override
  void dispose() {
    _isLoadingStreamSub?.cancel();
    _isLoadingController?.close();
    //_controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: _isLoadingController.stream.switchMap((isLoading) {
        return Stream.value(isLoading);
      }),
      builder: (context, snapshot) {
        return Center(
          child: Visibility(
            visible: snapshot?.data ?? false,
            child: FractionallySizedBox(
              widthFactor: 0.38,
              heightFactor: 0.2,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                color: Colors.black54,
                child: LottieView.fromFile(
                  onViewCreated: null,
                  filePath: 'assets/lottie/jumpingCup.json',
                  loop: true,
                  autoPlay: true,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
