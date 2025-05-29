import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Locationpin extends StatelessWidget {
  const Locationpin({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 150,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: 0,
            child: ClipOval(
              child: Container(
                height: 20,
                width: 30,
                color: Colors.grey.withOpacity(0.3),
              ),
            ),
          ),
          Positioned(
            top: 0,
            child: SvgPicture.asset(
              'assets/icons/locate.svg',
              width: 100,
              height: 100,
              colorFilter: const ColorFilter.mode(
                Colors.yellow,
                BlendMode.srcIn,
              ),
            ),
          ),
          const Positioned(
            top: 20,
            child: Icon(Icons.delete, size: 40, color: Colors.black),
          ),
        ],
      ),
    );
  }
}
