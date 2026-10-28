import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'package:eldivex_app/app/core/values/color_constants.dart';

/// Shared chart styling for the dashboard's Syncfusion charts.
///
/// Thin marks, hairline solid gridlines, no axis rules or ticks, text in text
/// tokens (never the series colour), and a value-first tooltip. Colours come
/// from the app palette only: primary, then accent, then the AppTone hues.
class DashChart {
  DashChart._();

  // ── Axis chrome ──────────────────────────────────────────────────────────

  /// Value-axis tick labels: muted, tabular so the column of numbers aligns.
  static TextStyle get valueLabel => TextStyle(
        fontSize: 11.5,
        color: AppColor.textTertiary,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  /// Category labels (days, service names).
  static TextStyle get categoryLabel =>
      TextStyle(fontSize: 12, color: AppColor.textSecondary);

  /// Direct value label beside a mark.
  static TextStyle get dataLabel => TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColor.textSecondary,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  /// Recessive grid: one step off the surface, 1px, solid.
  static MajorGridLines get grid =>
      MajorGridLines(width: 1, color: AppColor.borderSubtle);

  /// The single baseline bars grow from.
  static AxisLine get baseline => AxisLine(width: 1, color: AppColor.divColor);

  static const MajorGridLines noGrid = MajorGridLines(width: 0);
  static const MajorTickLines noTicks = MajorTickLines(size: 0, width: 0);
  static const AxisLine noAxisLine = AxisLine(width: 0);

  // ── Marks ────────────────────────────────────────────────────────────────

  /// Converts a pixel cap (bars are at most [maxPx] thick) into Syncfusion's
  /// band fraction, so bars never fill their slot on wide cards.
  static double barFraction({
    required double extent,
    required int count,
    double maxPx = 24,
  }) {
    if (count <= 0 || extent <= 0) return 0.6;
    final band = extent / count;
    return (maxPx / band).clamp(0.12, 0.8).toDouble();
  }

  /// Clean integer axis: steps of 1/2/5 × 10ⁿ, about [ticks] intervals, with
  /// headroom above the tallest mark for its direct label.
  static ({double max, double interval}) niceAxis(
    double maxValue, {
    int ticks = 4,
  }) {
    if (maxValue <= 0) return (max: ticks.toDouble(), interval: 1);
    final raw = maxValue / ticks;
    final mag = math.pow(10, (math.log(raw) / math.ln10).floor()).toDouble();
    final norm = raw / mag;
    final step = math.max(
      1.0,
      (norm <= 1
              ? 1
              : norm <= 2
                  ? 2
                  : norm <= 5
                      ? 5
                      : 10) *
          mag,
    );
    var max = (maxValue / step).ceil() * step;
    if (max - maxValue < step * 0.25) max += step;
    return (max: max, interval: step);
  }

  // ── Tooltip ──────────────────────────────────────────────────────────────

  /// Inverted tooltip (dark on light, light on dark). The value leads; the
  /// category follows in a quieter weight.
  static TooltipBehavior tooltip({
    required String Function(dynamic data) value,
    required String Function(dynamic data) label,
  }) {
    return TooltipBehavior(
      enable: true,
      color: AppColor.textPrimary,
      borderWidth: 0,
      elevation: 0,
      animationDuration: 150,
      duration: 2500,
      builder: (dynamic data, ChartPoint<dynamic> point,
          ChartSeries<dynamic, dynamic> series, int pointIndex,
          int seriesIndex) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value(data),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColor.whiteColor,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 1),
              Text(
                label(data),
                style: TextStyle(
                  fontSize: 12,
                  color: AppColor.whiteColor.withValues(alpha: 0.72),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Colour ───────────────────────────────────────────────────────────────

  /// Categorical hues in fixed order: primary, accent, then info / success /
  /// warning / violet. A hue too close to an earlier one (e.g. info equals
  /// primary in the Blue palette) is dropped instead of shown twice.
  static List<Color> get categorical {
    final out = <Color>[];
    for (final c in [
      AppColor.cAppPrimaryColor,
      AppColor.accentColor,
      AppColor.info,
      AppColor.success,
      AppColor.warning,
      AppColor.violet,
    ]) {
      if (out.every((u) => _deltaE(u, c) >= _minDeltaE)) out.add(c);
    }
    return out;
  }

  /// Canonical booking lifecycle, used to order the status breakdown so
  /// neighbouring slices are always the same (validated) colour pairs.
  static const List<String> _statusOrder = [
    'booking submitted',
    'hp assigned',
    'service started',
    'on hold',
    'suspended',
    'booking cancelled',
    'service cancelled',
  ];

  static String _key(String label) => label.trim().toLowerCase();

  /// Sorts booking-status rows into lifecycle order; unknown statuses keep
  /// their incoming order after the known ones. Returns a new list.
  static List<T> orderByStatus<T>(List<T> items, String Function(T) label) {
    int rank(T item) {
      final i = _statusOrder.indexOf(_key(label(item)));
      return i < 0 ? _statusOrder.length : i;
    }

    final indexed = items.asMap().entries.toList()
      ..sort((a, b) {
        final r = rank(a.value).compareTo(rank(b.value));
        return r != 0 ? r : a.key.compareTo(b.key);
      });
    return [for (final e in indexed) e.value];
  }

  /// Colour per booking status, keyed by label so a colour follows its
  /// status rather than its rank. States that carry meaning use the status
  /// tokens (started → success, on hold → warning, cancelled → danger); the
  /// rest use primary / accent / violet. Every known status is reserved even
  /// when absent, so filters never repaint the survivors. If the active brand
  /// palette collides with a status hue, the next candidate is used.
  static Map<String, Color> statusColors(Iterable<String> labels) {
    final candidates = <String, List<Color>>{
      // Assigned first: meaning beats brand when they collide.
      'service started': [AppColor.success],
      'on hold': [AppColor.warning],
      'booking cancelled': [AppColor.danger],
      'service cancelled': [AppColor.textTertiary],
      'hp assigned': [
        AppColor.cAppPrimaryColor,
        AppColor.info,
        AppColor.accentColor,
      ],
      'booking submitted': [
        AppColor.accentColor,
        AppColor.info,
        AppColor.violet,
      ],
      'suspended': [AppColor.violet, AppColor.info, AppColor.lightGrey],
    };

    final used = <Color>[];
    Color pick(List<Color> options) {
      for (final c in options) {
        if (used.every((u) => _deltaE(u, c) >= _minDeltaE)) return c;
      }
      return options.first;
    }

    final byKey = <String, Color>{};
    candidates.forEach((key, options) {
      final c = pick(options);
      used.add(c);
      byKey[key] = c;
    });

    final out = <String, Color>{};
    final spare = [...categorical, AppColor.lightGrey];
    for (final label in labels) {
      final known = byKey[_key(label)];
      if (known != null) {
        out[label] = known;
        continue;
      }
      final c = pick(spare);
      used.add(c);
      out[label] = c;
    }
    return out;
  }

  /// Normal-vision floor (OKLab ΔE × 100) for telling two fills apart.
  static const double _minDeltaE = 15;

  static double _deltaE(Color a, Color b) {
    final x = _oklab(a);
    final y = _oklab(b);
    final dl = x[0] - y[0];
    final da = x[1] - y[1];
    final db = x[2] - y[2];
    return 100 * math.sqrt(dl * dl + da * da + db * db);
  }

  static List<double> _oklab(Color c) {
    double lin(double v) => v <= 0.04045
        ? v / 12.92
        : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
    double cbrt(double v) =>
        v < 0 ? -math.pow(-v, 1 / 3).toDouble() : math.pow(v, 1 / 3).toDouble();

    final r = lin(c.r);
    final g = lin(c.g);
    final b = lin(c.b);
    final l = cbrt(0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b);
    final m = cbrt(0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b);
    final s = cbrt(0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b);
    return [
      0.2104542553 * l + 0.7936177850 * m - 0.0040720468 * s,
      1.9779984951 * l - 2.4285922050 * m + 0.4505937099 * s,
      0.0259040371 * l + 0.7827717662 * m - 0.8086757660 * s,
    ];
  }
}
