import 'package:flutter/material.dart';

enum PetType { cat, dog, hamster }

class PetDisplay extends StatelessWidget {
  final PetType type;
  final List<String> accessories;
  final double size;

  const PetDisplay({
    super.key,
    required this.type,
    this.accessories = const [],
    this.size = 200,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _PetPainter(type: type, accessories: accessories),
      ),
    );
  }
}

class _PetPainter extends CustomPainter {
  final PetType type;
  final List<String> accessories;

  _PetPainter({required this.type, required this.accessories});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    // final h = size.height; // <--- HAPUS variable ini (unused)
    final scale = w / 200; 
    canvas.scale(scale);

    final Paint paint = Paint()..style = PaintingStyle.fill;
    final Paint strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = const Color(0xFFFFD700);

    if (type == PetType.cat) {
      _drawCat(canvas, paint, strokePaint);
    } else if (type == PetType.dog) {
      _drawDog(canvas, paint, strokePaint);
    } else {
      _drawHamster(canvas, paint, strokePaint);
    }

    if (accessories.contains('bandana')) _drawBandana(canvas, type);
    if (accessories.contains('topeng')) _drawMask(canvas);
  }

  void _drawCat(Canvas canvas, Paint paint, Paint stroke) {
    final gradient = const LinearGradient(
      colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ).createShader(const Rect.fromLTWH(0, 0, 200, 200));

    paint.shader = gradient;
    stroke.color = const Color(0xFFFFD700);

    final pathEars = Path()
      ..moveTo(60, 50)..lineTo(70, 20)..lineTo(80, 50)
      ..moveTo(120, 50)..lineTo(130, 20)..lineTo(140, 50);
    canvas.drawPath(pathEars, paint);
    canvas.drawPath(pathEars, stroke);

    canvas.drawCircle(const Offset(100, 80), 35, paint);
    canvas.drawCircle(const Offset(100, 80), 35, stroke);

    canvas.drawOval(Rect.fromCenter(center: const Offset(100, 140), width: 60, height: 80), paint);
    canvas.drawOval(Rect.fromCenter(center: const Offset(100, 140), width: 60, height: 80), stroke);

    paint.shader = null;
    paint.color = Colors.black;
    canvas.drawCircle(const Offset(90, 75), 4, paint);
    canvas.drawCircle(const Offset(110, 75), 4, paint);

    final smilePath = Path()
      ..moveTo(100, 80)
      ..quadraticBezierTo(95, 85, 100, 90)
      ..quadraticBezierTo(105, 85, 100, 80);
    canvas.drawPath(smilePath, Paint()..style=PaintingStyle.stroke..color=Colors.black);
  }

  void _drawDog(Canvas canvas, Paint paint, Paint stroke) {
    final gradient = const LinearGradient(
      colors: [Color(0xFF8B4513), Color(0xFF654321)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ).createShader(const Rect.fromLTWH(0, 0, 200, 200));
    paint.shader = gradient;
    canvas.drawCircle(const Offset(100, 85), 35, paint);
  }

  void _drawHamster(Canvas canvas, Paint paint, Paint stroke) {
     final gradient = const LinearGradient(
      colors: [Color(0xFFD2B48C), Color(0xFFA0826D)],
    ).createShader(const Rect.fromLTWH(0, 0, 200, 200));
    paint.shader = gradient;
    canvas.drawCircle(const Offset(100, 85), 35, paint);
  }

  void _drawBandana(Canvas canvas, PetType type) {
    final path = Path();
    path.moveTo(65, 70);
    path.quadraticBezierTo(100, 50, 135, 70);
    path.lineTo(130, 90);
    path.quadraticBezierTo(100, 75, 70, 90);
    path.close();

    final paint = Paint()
      // Gunakan withValues(alpha: 0.9) alih-alih withOpacity
      ..color = const Color(0xFFFF6B6B).withValues(alpha: 0.9)
      ..style = PaintingStyle.fill;
    
    canvas.drawPath(path, paint);
  }

  void _drawMask(Canvas canvas) {
     final paint = Paint()
      // Gunakan withValues(alpha: 0.7)
      ..color = const Color(0xFF2F4F4F).withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;
    
    canvas.drawOval(Rect.fromCenter(center: const Offset(100, 85), width: 64, height: 60), paint);
    
    // Gunakan withValues(alpha: 0.3)
    final eyeHole = Paint()..color = Colors.black.withValues(alpha: 0.3);
    canvas.drawCircle(const Offset(90, 80), 5, eyeHole);
    canvas.drawCircle(const Offset(110, 80), 5, eyeHole);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}