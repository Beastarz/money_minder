import 'package:flutter/material.dart';

// show the ellipsis at the front instead at the back when the text overflow
class ReverseEllipsisText extends StatelessWidget {
  const ReverseEllipsisText(
      this.text, {
        super.key,
        this.style,
        this.textAlign = TextAlign.end, // Align to end for right-to-left effect
        this.maxLines = 1,
      });

  final String text;
  final TextStyle? style;
  final TextAlign textAlign;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    // Get default text style if not provided
    final defaultTextStyle = DefaultTextStyle.of(context).style;
    final effectiveTextStyle = style ?? defaultTextStyle;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // Create a TextPainter to measure the text
        print(text);
        final TextPainter textPainter = TextPainter(
          text: TextSpan(text: text, style: effectiveTextStyle),
          maxLines: maxLines,
          textDirection: TextDirection.ltr, // Assuming LTR for numbers/paths
        )..layout(maxWidth: constraints.maxWidth - 20); // Layout with available width

        // If text overflows, we need to apply ellipsis
        if (textPainter.didExceedMaxLines) {
          // Calculate available width for the *actual* text (minus ellipsis)
          final String currency = text.split(' ')[0];
          final ellipsisText = TextSpan(text: '$currency ...', style: effectiveTextStyle);
          final ellipsisPainter = TextPainter(
            text: ellipsisText,
            textDirection: TextDirection.ltr,
          )..layout(); // Layout without maxWidth to get its intrinsic width

          final availableWidthForContent = constraints.maxWidth - ellipsisPainter.width;

          // Find the substring that fits the available width
          // We iterate from the end of the string
          String displayString = text;
          for (int i = text.length; i >= 0; i--) {
            final testString = text.substring(i); // Take characters from the end
            final testPainter = TextPainter(
              text: TextSpan(text: testString, style: effectiveTextStyle),
              maxLines: maxLines,
              textDirection: TextDirection.ltr,
            )..layout(maxWidth: double.infinity); // Layout with infinite width to get its true width

            if (testPainter.width > availableWidthForContent) {
              displayString = '$currency ...${testString.substring(1)}';
              break;
            }
            if (i == 0) { // If even '...' doesn't fit, just show '...'
              displayString = '...';
            }
          }

          // In case the loop finishes without finding a fit (e.g., extremely narrow width)
          // or if the text itself is very short and fits after adding ellipsis
          if (displayString == text && textPainter.width > constraints.maxWidth) {
            displayString = '...'; // Fallback if no portion from end fits
          }

          print(text + '\n' + displayString);
          return Text(
            displayString,
            style: effectiveTextStyle,
            textAlign: textAlign,
            maxLines: maxLines,
          );
        } else {
          // No overflow, display original text
          print(text);
          return Text(
            text,
            style: effectiveTextStyle,
            textAlign: textAlign,
            maxLines: maxLines,
          );
        }
      },
    );
  }
}