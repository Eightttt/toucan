import 'package:flutter/material.dart';

class FadingOnScroll extends StatefulWidget {
  final ScrollController scrollController;
  final Widget child;
  final double offset;
  const FadingOnScroll({
    required this.scrollController,
    required this.offset,
    required this.child,
    super.key,
  });

  @override
  State<FadingOnScroll> createState() => _FadingOnScrollState();
}

class _FadingOnScrollState extends State<FadingOnScroll> {
  bool lastStatus = true;
  double height = 200;
  final double zeroOpacityOffset = 0;
  final double fullOpacityOffset = 180;

  double _calculateOpacity() {
    if (fullOpacityOffset == zeroOpacityOffset)
      return 1;
    else if (fullOpacityOffset > zeroOpacityOffset) {
      // fading in
      if (widget.offset <= zeroOpacityOffset)
        return 0;
      else if (widget.offset >= fullOpacityOffset)
        return 1;
      else
        return (widget.offset - zeroOpacityOffset) /
            (fullOpacityOffset - zeroOpacityOffset);
    } else {
      // fading out
      if (widget.offset <= fullOpacityOffset)
        return 1;
      else if (widget.offset >= zeroOpacityOffset)
        return 0;
      else
        return 1 -
            (widget.offset - fullOpacityOffset) /
                (zeroOpacityOffset - fullOpacityOffset);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(opacity: _calculateOpacity(), child: widget.child);
  }
}
