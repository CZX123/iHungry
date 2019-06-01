import 'dart:math' as math;
import 'package:flutter/material.dart';

SliderThemeData customSliderTheme(BuildContext context) =>
    SliderTheme.of(context).copyWith(
      trackHeight: 4,
      thumbShape: RoundSliderThumbShape(
        disabledThumbRadius: 6,
        enabledThumbRadius: 10,
      ),
      showValueIndicator: ShowValueIndicator.always,
      valueIndicatorTextStyle: TextStyle(
        fontFamily: 'Kayak Sans',
        fontSize: 17.0,
        color: Colors.black87,
        fontWeight: FontWeight.bold,
      ),
      tickMarkShape: CustomSliderTick(),
      trackShape: RoundedTrackShape(),
    );



class RoundedTrackShape extends RectangularSliderTrackShape {
  @override
  void paint(PaintingContext context, Offset offset,
      {RenderBox parentBox,
      SliderThemeData sliderTheme,
      Animation<double> enableAnimation,
      TextDirection textDirection,
      Offset thumbCenter,
      bool isDiscrete,
      bool isEnabled}) {
    // Copied from Flutter source

    final ColorTween activeTrackColorTween = ColorTween(
        begin: sliderTheme.disabledActiveTrackColor,
        end: sliderTheme.activeTrackColor);
    final ColorTween inactiveTrackColorTween = ColorTween(
        begin: sliderTheme.disabledInactiveTrackColor,
        end: sliderTheme.inactiveTrackColor);
    final Paint activePaint = Paint()
      ..color = activeTrackColorTween.evaluate(enableAnimation);
    final Paint inactivePaint = Paint()
      ..color = inactiveTrackColorTween.evaluate(enableAnimation);
    Paint leftTrackPaint;
    Paint rightTrackPaint;
    leftTrackPaint = activePaint;
    rightTrackPaint = inactivePaint;

    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    final Rect leftTrackArcRect = Rect.fromLTWH(
        trackRect.left, trackRect.top, trackRect.height, trackRect.height);
    context.canvas
        .drawArc(leftTrackArcRect, math.pi / 2, math.pi, false, leftTrackPaint);
    final Rect rightTrackArcRect = Rect.fromLTWH(
        trackRect.right - trackRect.height / 2,
        trackRect.top,
        trackRect.height,
        trackRect.height);
    context.canvas.drawArc(
        rightTrackArcRect, -math.pi / 2, math.pi, false, rightTrackPaint);

    final Size thumbSize =
        sliderTheme.thumbShape.getPreferredSize(isEnabled, isDiscrete);
    final Rect leftTrackSegment = Rect.fromLTRB(
        trackRect.left + trackRect.height / 2,
        trackRect.top,
        thumbCenter.dx - thumbSize.width / 2,
        trackRect.bottom);
    context.canvas.drawRect(leftTrackSegment, leftTrackPaint);
    final Rect rightTrackSegment = Rect.fromLTRB(
        thumbCenter.dx + thumbSize.width / 2,
        trackRect.top,
        trackRect.right,
        trackRect.bottom);
    context.canvas.drawRect(rightTrackSegment, rightTrackPaint);
  }
}

class CustomSliderTick extends SliderTickMarkShape {
  @override
  Size getPreferredSize({SliderThemeData sliderTheme, bool isEnabled}) {
    return Size(sliderTheme.trackHeight / 2, sliderTheme.trackHeight * 2.5);
  }

  @override
  void paint(PaintingContext context, Offset center,
      {RenderBox parentBox,
      SliderThemeData sliderTheme,
      Animation<double> enableAnimation,
      Offset thumbCenter,
      bool isEnabled,
      TextDirection textDirection}) {
    if (center.dx.toInt() > parentBox.size.width.toInt()) return;
    Color begin;
    Color end;
    final bool isTickMarkRightOfThumb = center.dx > thumbCenter.dx;
    begin = isTickMarkRightOfThumb
        ? sliderTheme.disabledInactiveTickMarkColor
        : sliderTheme.disabledActiveTickMarkColor;
    end = isTickMarkRightOfThumb ? Colors.white54 : Colors.transparent;
    final Paint paint = Paint()
      ..color = ColorTween(begin: begin, end: end).evaluate(enableAnimation);
    context.canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
              center.dx - sliderTheme.trackHeight / 4,
              center.dy - sliderTheme.trackHeight * 2.5 / 2,
              sliderTheme.trackHeight / 2,
              sliderTheme.trackHeight * 2.5),
          Radius.circular(1),
        ),
        paint);
  }
}
