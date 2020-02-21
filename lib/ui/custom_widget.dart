import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
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
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _isLoadingController = BehaviorSubject(seedValue: widget.isLoading);
    _isLoadingStreamSub =
        widget.isLoadingStream?.listen(_isLoadingController.add);
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
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
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: _isLoadingController.stream.switchMap((isLoading) {
        return Stream.value(isLoading);
        /*return Observable.timer(
            isLoading, Duration(milliseconds: isLoading ? 300 : 300));*/
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
                child: Lottie.asset('assets/lottie/jumpingCup.json'),
              ),
            ),
          ),
        );

        /*return Center(
          child: Visibility(
            visible: snapshot.data ?? false,
            child: Container(
              width: 100,
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: Lottie.asset(
                'assets/lottie/jumpingCup.json',
                controller: _controller,
                onLoaded: (composition) {
                  // Configure the AnimationController with the duration of the
                  // Lottie file and start the animation.
                  _controller
                    ..duration = composition.duration
                    ..forward();
                },
              ),
              */ /*child: SpinKitRotatingCircle(
                color: Colors.blueAccent,
                size: 30,
                controller: _controller,
              ),*/ /*
            ),
          ),
        );*/
      },
    );
  }
}
