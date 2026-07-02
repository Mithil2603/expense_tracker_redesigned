/// tools/crop_finny.dart
/// 
/// One-time build tool to slice assets/Finny.png into individual pose PNGs.
/// Run with: dart run tools/crop_finny.dart
/// 
/// NOT shipped in the app. Uses the `image` dev dependency.
/// Source image: 1254x1254 px (verified).

import 'dart:io';
import 'package:image/image.dart' as img;

void main() async {
  final srcPath = 'assets/Finny.png';
  final outDir = Directory('assets/finny');

  // ── Load source ──────────────────────────────────────────────────────────────
  final srcBytes = File(srcPath).readAsBytesSync();
  final src = img.decodeImage(srcBytes);
  if (src == null) {
    print('ERROR: Could not decode $srcPath');
    exit(1);
  }

  final w = src.width;
  final h = src.height;
  print('Source image: ${w}x${h} px');

  // ── Create output dir ────────────────────────────────────────────────────────
  if (!outDir.existsSync()) outDir.createSync(recursive: true);

  // ── Crop definitions ─────────────────────────────────────────────────────────
  // Pixel coordinates calibrated for the 1254×1254 Finny.png character sheet.
  //
  // EXPRESSIONS section (2×2 grid, top-right):
  //   happy   → top-left expression box     ~(757,55)  248×265
  //   excited → top-right expression box    ~(1005,55) 248×265
  //   focused → bottom-left expression box  ~(757,320) 248×265
  //   cheerup → bottom-right expression box ~(1005,320)248×265
  //
  // IN ACTION section (3-up row, mid-right ~y=620-815):
  //   "IN ACTION" header is at y≈620; card content starts at ~y=660.
  //   Each action card: ~152px wide. Three cards side by side starting at x~=757.
  //   Characters are in lower portion of each card.
  //
  // TURNAROUND section (4-up row, bottom-left ~y=900-1250):
  //   Four small standing poses, each ~175px wide, starting at x~=18.

  final crops = <(String, int, int, int, int)>[
    // ── EXPRESSIONS (top-right) ─────────────────────────────────────────────
    //   (name,        x,    y,    width, height)
    ('finny_happy',    757,  55,   248,   265),
    ('finny_excited',  1005, 55,   248,   265),
    ('finny_focused',  757,  320,  248,   265),
    ('finny_cheerup',  1005, 320,  248,   265),

    // ── IN ACTION (mid-right) — skip the "IN ACTION" header, start in card ──
    // Cards start after header ~y=660; character visible in lower half ~y=700+
    ('finny_saving',      757,  665, 152,  150),
    ('finny_celebrating', 912,  665, 152,  150),
    ('finny_levelup',     1067, 665, 185,  150),

    // ── TURNAROUND (bottom-left) ─────────────────────────────────────────────
    ('finny_front',    18,   900, 175,  350),
    ('finny_side',     195,  900, 175,  350),
    ('finny_back',     372,  900, 175,  350),
    ('finny_34view',   549,  900, 175,  350),
  ];

  // ── Crop and save ────────────────────────────────────────────────────────────
  for (final (name, x, y, cw, ch) in crops) {
    // Clamp to image bounds
    final safeX = x.clamp(0, w - 1);
    final safeY = y.clamp(0, h - 1);
    final safeCW = (safeX + cw > w) ? w - safeX : cw;
    final safeCH = (safeY + ch > h) ? h - safeY : ch;

    final cropped = img.copyCrop(
      src,
      x: safeX,
      y: safeY,
      width: safeCW,
      height: safeCH,
    );

    final outPath = '${outDir.path}/$name.png';
    File(outPath).writeAsBytesSync(img.encodePng(cropped));
    print('  ✓  $outPath  (${cropped.width}×${cropped.height})');
  }

  print('\nDone! ${crops.length} poses written to ${outDir.path}/');
}
