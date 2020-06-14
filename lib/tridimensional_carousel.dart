import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'tridimensional_carousel_controller.dart';
export 'tridimensional_carousel_controller.dart';

class TridimensionalCarousel extends StatefulWidget {
  final Duration animationDuration;
  final TridimensionalCarouselController controller;
  final List<Widget> items;
  final Widget backgroundPage;
  final bool enableScroll;
  final bool loopMode;
  final bool autoPlay;
  final Duration autoPlayInterval;
  final double itemsWidth;
  final Function(int index) onPageChanged;

  TridimensionalCarousel({
    Key key,
    @required this.items,
    this.enableScroll = false,
    this.animationDuration = const Duration(milliseconds: 500),
    this.loopMode = false,
    this.autoPlay = false,
    this.autoPlayInterval = const Duration(milliseconds: 2000),
    Widget backgroundPage,
    TridimensionalCarouselController controller,
    this.itemsWidth,
    Function onPageChanged,
  })  : assert(items != null),
        assert(items.length > 1),
        controller = controller ?? TridimensionalCarouselController(),
        onPageChanged = onPageChanged ?? ((int index) {}),
        backgroundPage = backgroundPage ??
            Container(
              color: Colors.transparent,
            ),
        super(key: key);

  @override
  TridimensionalCarouselState createState() => TridimensionalCarouselState();
}

class TridimensionalCarouselState extends State<TridimensionalCarousel>
    with TickerProviderStateMixin {
  AnimationController _animationController;
  bool _isGoingForward;
  int _mainPageIndex;
  int _leftPageIndex;
  int _rightPageIndex;
  bool _isFirstPage;
  bool _isLastPage;
  bool _isDraggable;
  bool _isDragFromLeft;
  bool _isDragFromRight;
  double _itemsWidth;
  Function _updateValues;
  Function goToNextPage;
  Function goToPreviousPage;

  @override
  void initState() {
    super.initState();
    _initValues();
    _initFunctions();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.itemsWidth != null) {
      _itemsWidth = widget.itemsWidth;
    } else {
      _itemsWidth = MediaQuery.of(context).size.width;
    }
  }

  void _initFunctions() {
    if (widget.loopMode) {
      _updateValues = _updateValuesLoopModeEnabled;
      goToNextPage = _goToNextPage;
      goToPreviousPage = _goToPreviousPage;
    } else {
      _updateValues = _updateValuesLoopModeDisabled;
      goToNextPage = _goToNextPageLoopModeDisabled;
      goToPreviousPage = _goToPreviousPageLoopModeDisabled;
    }
  }

  void _initValues() {
    _leftPageIndex = widget.items.length - 1;
    _mainPageIndex = 0;
    _rightPageIndex = 1;
    _isGoingForward = true;
    _isLastPage = false;
    _isFirstPage = !widget.loopMode;
    if (widget.autoPlay) {
      _animationController =
          AnimationController(vsync: this, duration: widget.animationDuration)
            ..addStatusListener(_statusListenerAutoPlayEnabled);
      Future.delayed(
        widget.autoPlayInterval,
        () => _animationController.forward(),
      );
    } else {
      _animationController =
          AnimationController(vsync: this, duration: widget.animationDuration)
            ..addStatusListener(_statusListener);
    }
    widget.controller.tridimensionalCarouselState = this;
    widget.controller.animation = _animationController;
  }

  void _statusListener(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _updateValues();
      _animationController.reset();
      widget.onPageChanged(_mainPageIndex);
    }
  }

  void _statusListenerAutoPlayEnabled(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _updateValues();
      _animationController.reset();
      widget.onPageChanged(_mainPageIndex);
      Future.delayed(
        widget.autoPlayInterval,
        goToNextPage,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: widget.enableScroll ? _onDragStart : (details) {},
      onHorizontalDragUpdate:
          widget.enableScroll ? _onDragUpdate : (details) {},
      onHorizontalDragEnd: widget.enableScroll ? _onDragEnd : (details) {},
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (_, __) {
          return _isGoingForward
              ? GoToNextPage(
                  animationController: _animationController,
                  mainPage: widget.items[_mainPageIndex],
                  rightPage: _rightPageIndex < widget.items.length
                      ? widget.items[_rightPageIndex]
                      : Container(
                          color: Colors.black,
                        ),
                  backgroundPage: widget.backgroundPage,
                  itemsWidth: _itemsWidth,
                )
              : GoToPreviusPage(
                  animationController: _animationController,
                  mainPage: widget.items[_mainPageIndex],
                  leftPage: _leftPageIndex >= 0
                      ? widget.items[_leftPageIndex]
                      : Container(
                          color: Colors.black,
                        ),
                  backgroundPage: widget.backgroundPage,
                  itemsWidth: _itemsWidth,
                );
        },
      ),
    );
  }

  void _updateValuesLoopModeDisabled() {
    if (_isGoingForward) {
      _setPagesChecksAfterGoingForward();
      _incrementPagesIndexes();
    } else {
      _setPagesChecksAfterGoingBackward();
      _decreasePagesIndexes();
    }
  }

  void _updateValuesLoopModeEnabled() {
    if (_isGoingForward) {
      _incrementPagesIndexes();
    } else {
      _decreasePagesIndexes();
    }
  }

  void _setPagesChecksAfterGoingForward() {
    _isFirstPage = false;
    if (_mainPageIndex == widget.items.length - 2) {
      _isLastPage = true;
    } else {
      _isLastPage = false;
    }
  }

  void _setPagesChecksAfterGoingBackward() {
    _isLastPage = false;
    if (_mainPageIndex == 1) {
      _isFirstPage = true;
    } else {
      _isFirstPage = false;
    }
  }

  void _incrementPagesIndexes() {
    setState(() {
      _mainPageIndex = (_mainPageIndex + 1) % widget.items.length;
      _rightPageIndex = (_rightPageIndex + 1) % widget.items.length;
      _leftPageIndex = (_leftPageIndex + 1) % widget.items.length;
    });
  }

  void _decreasePagesIndexes() {
    setState(() {
      _mainPageIndex = (_mainPageIndex - 1) % widget.items.length;
      _leftPageIndex = (_leftPageIndex - 1) % widget.items.length;
      _rightPageIndex = (_rightPageIndex - 1) % widget.items.length;
    });
  }

  void _goToNextPage() {
    if (!_animationController.isAnimating) {
      setState(() {
        _isGoingForward = true;
      });
      _animationController.forward();
    }
  }

  void _goToPreviousPage() {
    if (!_animationController.isAnimating) {
      setState(() {
        _isGoingForward = false;
      });
      _animationController.forward();
    }
  }

  void _goToNextPageLoopModeDisabled() {
    if (!_isLastPage) {
      _goToNextPage();
    }
  }

  void _goToPreviousPageLoopModeDisabled() {
    if (!_isFirstPage) {
      _goToPreviousPage();
    }
  }

  void _onDragStart(DragStartDetails details) {
    _isDragFromLeft = !_animationController.isAnimating &&
        details.localPosition.dx < _itemsWidth / 2;
    _isDragFromRight = !_animationController.isAnimating &&
        details.localPosition.dx > _itemsWidth / 2;
    _isDraggable = _isDragFromLeft || _isDragFromRight;
    if (_isDragFromLeft) {
      _isDraggable &= !_isFirstPage;
      setState(() {
        _isGoingForward = false;
      });
    } else {
      _isDraggable &= !_isLastPage;
      setState(() {
        _isGoingForward = true;
      });
    }
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_isDraggable) {
      double delta = details.primaryDelta / _itemsWidth;
      if (_isDragFromLeft) {
        _animationController.value += delta;
      } else {
        _animationController.value -= delta;
      }
    }
  }

  void _onDragEnd(DragEndDetails details) {
    if (_animationController.isDismissed || _animationController.isCompleted) {
      return;
    }
    if (details.velocity.pixelsPerSecond.dx.abs() >= _itemsWidth) {
      double visualVelocity =
          details.velocity.pixelsPerSecond.dx.abs() / _itemsWidth;
      _animationController.fling(velocity: visualVelocity);
    } else if (_animationController.value > 0.5) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }
}

class GoToPreviusPage extends StatelessWidget {
  final AnimationController animationController;
  final Widget mainPage;
  final Widget leftPage;
  final Widget backgroundPage;
  final double itemsWidth;
  GoToPreviusPage(
      {this.animationController,
      this.mainPage,
      this.leftPage,
      this.itemsWidth,
      this.backgroundPage});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        backgroundPage,
        Transform.translate(
          offset:
              Offset(-itemsWidth + itemsWidth * animationController.value, 0),
          child: Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(
                math.pi / 2 * (1 - animationController.value),
              ),
            alignment: Alignment.centerRight,
            child: leftPage,
          ),
        ),
        Transform.translate(
          offset: Offset(itemsWidth * animationController.value, 0),
          child: Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(-math.pi / 2 * animationController.value),
            alignment: Alignment.centerLeft,
            child: mainPage,
          ),
        )
      ],
    );
  }
}

class GoToNextPage extends StatelessWidget {
  final AnimationController animationController;
  final Widget mainPage;
  final Widget rightPage;
  final Widget backgroundPage;
  final double itemsWidth;
  GoToNextPage({
    this.animationController,
    this.mainPage,
    this.rightPage,
    this.itemsWidth,
    this.backgroundPage,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        backgroundPage,
        Transform.translate(
          offset: Offset(-itemsWidth * animationController.value, 0),
          child: Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(
                math.pi / 2 * animationController.value,
              ),
            alignment: Alignment.centerRight,
            child: mainPage,
          ),
        ),
        Transform.translate(
          offset: Offset(itemsWidth * (1 - animationController.value), 0),
          child: Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(-math.pi / 2 * (1 - animationController.value)),
            alignment: Alignment.centerLeft,
            child: rightPage,
          ),
        )
      ],
    );
  }
}
