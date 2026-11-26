import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triiq/theme/app_theme.dart';
import 'package:triiq/theme/design_tokens.dart';

double _radius(ShapeBorder? s) =>
    ((s as RoundedRectangleBorder).borderRadius as BorderRadius).topLeft.x;

void main() {
  final light = buildAppTheme(Brightness.light);
  final dark = buildAppTheme(Brightness.dark);

  test('colours come from Design.md', () {
    expect(light.colorScheme.primary, DesignColors.primary);
    expect(light.colorScheme.error, DesignColors.error);
    expect(light.colorScheme.onSurface, DesignColors.textPrimary);
    expect(light.colorScheme.onSurfaceVariant, DesignColors.textSecondary);
    expect(light.colorScheme.outlineVariant, DesignColors.border);
    expect(light.scaffoldBackgroundColor, DesignColors.background);
    expect(light.cardTheme.color, DesignColors.surface);
  });

  test('radii: 12 cards, 6 buttons and inputs, pill chips', () {
    expect(_radius(light.cardTheme.shape), DesignRadius.card);
    expect(
      _radius(light.filledButtonTheme.style!.shape!.resolve({})),
      DesignRadius.control,
    );
    final input =
        light.inputDecorationTheme.enabledBorder as OutlineInputBorder;
    expect(input.borderRadius.topLeft.x, DesignRadius.control);
    expect(light.chipTheme.shape, isA<StadiumBorder>());
  });

  test('flat: cards and app bars carry no shadow, cards a 1 px border', () {
    expect(light.cardTheme.elevation, 0);
    expect(light.appBarTheme.scrolledUnderElevation, 0);
    final side = (light.cardTheme.shape as RoundedRectangleBorder).side;
    expect(side.color, DesignColors.border);
    expect(side.width, 1);
  });

  test('fonts: DM Sans, bold tight headings', () {
    expect(light.textTheme.bodyMedium!.fontFamily, DesignFonts.body);
    final h = light.textTheme.headlineLarge!;
    expect(h.fontWeight, FontWeight.w700);
    expect(h.letterSpacing, lessThan(0));
  });

  test('no pure black or white text in either mode', () {
    for (final t in [light, dark]) {
      expect(t.colorScheme.onSurface, isNot(const Color(0xFF000000)));
      expect(t.colorScheme.onSurface, isNot(const Color(0xFFFFFFFF)));
    }
  });

  test('dark text has enough contrast on its surface', () {
    double lum(Color c) => c.computeLuminance();
    final fg = lum(dark.colorScheme.onSurface);
    final bg = lum(dark.colorScheme.surface);
    expect((fg + 0.05) / (bg + 0.05), greaterThan(7));
    final muted = lum(dark.colorScheme.onSurfaceVariant);
    expect((muted + 0.05) / (bg + 0.05), greaterThan(4.5));
  });
}
