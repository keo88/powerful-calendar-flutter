import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'dart:async';
import 'dart:math';

class ClockView extends StatefulWidget {
  @override
  _ClockViewState createState() => _ClockViewState();
}

class _ClockViewState extends State<ClockView> {
  var dateTime = DateTime.now();
  var formattedTime, formattedDate;

  @override
  void initState() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    formattedTime = intl.DateFormat('HH:mm').format(dateTime);
    formattedDate = intl.DateFormat('EEE, d MMM').format(dateTime);

    return Stack(
      alignment: AlignmentDirectional.topStart,
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          height: 300,
          child: CustomPaint(
            painter: ClockPainter(),
          )
        ),
        Container(
          width: 200.0,
          height: 100.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(formattedTime,
                style: TextStyle(color: Colors.grey[900], fontSize: 36),
              ),
              Text(formattedDate,
                style: TextStyle(color: Colors.grey[900], fontSize: 18),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ClockPainter extends CustomPainter {
  var dateTime = DateTime.now();

  @override
  void paint(Canvas canvas, Size size) {
    var centerX = size.width / 2;
    var centerY = size.height / 2;
    var center = Offset(centerX, centerY);
    var radius = centerX > centerY ? centerY : centerX;

    var fillBrush = Paint()..color = Color(0xFF444974);
    //var fillBrush = Paint()..color = Colors.blueGrey[100];
    
    var outlineBrush = Paint()
      ..color = Color(0xFFEAECFF)
      //..color = Colors.blueGrey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16;

    var centerFillBrush = Paint()..color = Color(0xFFEAECFF);

    var secHandBrush = Paint()
      ..color = Colors.orange[300]
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 8;

    var minHandBrush = Paint()
      ..shader = RadialGradient(colors: [Color(0xFF748EF6), Color(0xFF77DDFF)])
          .createShader((Rect.fromCircle(center: center, radius: radius)))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 12;

    var hourHandBrush = Paint()
      ..shader = RadialGradient(colors: [Color(0xFFEA74AB), Color(0xFFC279FB)])
          .createShader((Rect.fromCircle(center: center, radius: radius)))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 16;

    canvas.drawCircle(center, radius - 60, fillBrush);
    canvas.drawCircle(center, radius - 60, outlineBrush);

    var hourHandX = centerX +
        40 * cos(pi * (0.5 - (dateTime.hour % 12) / 6) - dateTime.minute / 360);
    var hourHandY = centerY -
        40 * sin(pi * (0.5 - (dateTime.hour % 12) / 6) - dateTime.minute / 360);
    canvas.drawLine(center, Offset(hourHandX, hourHandY), hourHandBrush);

    var minHandX = centerX +
        60 * cos(pi * (0.5 - dateTime.minute / 30 - dateTime.second / 1800));
    var minHandY = centerY -
        60 * sin(pi * (0.5 - dateTime.minute / 30 - dateTime.second / 1800));
    canvas.drawLine(center, Offset(minHandX, minHandY), minHandBrush);

    var secHandX = centerX + 80 * cos(pi * (0.5 - dateTime.second / 30));
    var secHandY = centerY - 80 * sin(pi * (0.5 - dateTime.second / 30));
    canvas.drawLine(center, Offset(secHandX, secHandY), secHandBrush);

    canvas.drawCircle(center, 16, centerFillBrush);

    var clockLineRadius = radius - 40;
    var clockLineLength = 10;
    var clockDotX, clockDotY;
    var clockLineBrush = Paint()
      ..color = Color(0xFFEAECFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    for (double i = 0; i < 2 * pi; i += pi / 12) {
      clockDotX = centerX + clockLineRadius * cos(i);
      clockDotY = centerY + clockLineRadius * sin(i);
      canvas.drawLine(
          Offset(clockDotX, clockDotY),
          Offset(clockDotX + clockLineLength * cos(i),
              clockDotY + clockLineLength * sin(i)),
          clockLineBrush);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
