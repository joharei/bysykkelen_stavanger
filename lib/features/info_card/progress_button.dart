import 'package:flutter/material.dart';

class ProgressButton extends StatefulWidget {
  ProgressButton({
    Key key,
    @required this.text,
    @required this.state,
    @required this.onPressed,
  }) : super(key: key);

  final String text;
  final ProgressState state;
  final VoidCallback onPressed;

  @override
  _ProgressButtonState createState() => new _ProgressButtonState();
}

class _ProgressButtonState extends State<ProgressButton>
    with TickerProviderStateMixin {
  Animation _animation;
  AnimationController _controller;
  GlobalKey _globalKey = GlobalKey();
  static final double initialWidth = 300;
  double _width = initialWidth;

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  void didUpdateWidget(ProgressButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state == ProgressState.loading) {
      animateButton(true);
    } else if (widget.state == ProgressState.idle &&
        oldWidget.state == ProgressState.loading) {
      animateButton(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: _globalKey,
      height: 48.0,
      width: _width,
      child: new RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            widget.state == ProgressState.idle ? 4 : 30,
          ),
        ),
        padding: EdgeInsets.all(0.0),
        child: setUpButtonChild(),
        onPressed: () => widget.onPressed(),
        elevation: 4.0,
        color: widget.state == ProgressState.done
            ? Colors.lightGreen
            : Colors.blue,
      ),
    );
  }

  ///
  /// Set up the child widget for the RaisedButton
  ///
  setUpButtonChild() {
    if (widget.state == ProgressState.idle) {
      return new Text(
        widget.text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16.0,
        ),
      );
    } else if (widget.state == ProgressState.loading) {
      return CircularProgressIndicator(
        value: null,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        strokeWidth: 2,
      );
    } else {
      return Icon(Icons.check, color: Colors.white);
    }
  }

  void animateButton(bool toLoading) {
    final begin = toLoading ? 0.0 : 1.0;
    final end = toLoading ? 1.0 : 0.0;
    _controller =
        AnimationController(duration: Duration(milliseconds: 300), vsync: this);
    _animation = Tween(begin: begin, end: end).animate(_controller)
      ..addListener(() {
        setState(() {
          _width = initialWidth - ((initialWidth - 48.0) * _animation.value);
        });
      });
    _controller.forward();
  }
}

enum ProgressState {
  idle,
  loading,
  done,
}
