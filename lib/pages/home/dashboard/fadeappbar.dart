import 'package:flutter/material.dart';

class FadingAppBar extends StatefulWidget {
  final ScrollController scrollController;
  final Widget child;
  const FadingAppBar({
    required this.scrollController,
    required this.child,
    super.key,
  });

  @override
  State<FadingAppBar> createState() => _FadingAppBarState();
}

class _FadingAppBarState extends State<FadingAppBar> {
  bool lastStatus = true;
  double height = 200;
  final double zeroOpacityOffset = 0;
  final double fullOpacityOffset = 180;
  late double _offset;

  void _setOffset() {
    _offset = widget.scrollController.offset;
    setState(() {});
  }

  double _calculateOpacity() {
    if (fullOpacityOffset == zeroOpacityOffset)
      return 1;
    else if (fullOpacityOffset > zeroOpacityOffset) {
      // fading in
      if (_offset <= zeroOpacityOffset)
        return 0;
      else if (_offset >= fullOpacityOffset)
        return 1;
      else
        return (_offset - zeroOpacityOffset) /
            (fullOpacityOffset - zeroOpacityOffset);
    } else {
      // fading out
      if (_offset <= fullOpacityOffset)
        return 1;
      else if (_offset >= zeroOpacityOffset)
        return 0;
      else
        return 1 -
            (_offset - fullOpacityOffset) /
                (zeroOpacityOffset - fullOpacityOffset);
    }
  }

  @override
  void initState() {
    super.initState();
    _offset = widget.scrollController.offset;
    widget.scrollController.addListener(_setOffset);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_setOffset);
    widget.scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(opacity: _calculateOpacity(), child: widget.child);
  }
}