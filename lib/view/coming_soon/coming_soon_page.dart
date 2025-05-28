import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ComingSoonPage extends StatelessWidget {
  const ComingSoonPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF0E0F0F)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'Oops!',
            style: GoogleFonts.roboto(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              height: 20 / 18,
              letterSpacing: 0.02,
              color: const Color(0xFF0E0F0F),
            ),
          ),
          centerTitle: false,
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 0),
          Center(
            child: Image.asset(
              'assets/images/logo-fortis.png',
              width: 175,
              height: 100,
            ),
          ),
          const SizedBox(height: 0),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF3055A0),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 24),
                    Text(
                      'Coming Soon !',
                      style: GoogleFonts.roboto(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        height: 20 / 18,
                        letterSpacing: 0.02,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: 293,
                      height: 210.72,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0EBFF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/images/coming_soon.png',
                          width: 293,
                          height: 210.72,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                    SizedBox(
                      width: 239,
                      child: Text(
                        'Wait for the latest update from us. This feature is still under development and will be coming soon.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          height: 18 / 14,
                          letterSpacing: 0.02,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                    SizedBox(
                      width: 178,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacementNamed('/menu');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF008037),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Get Back to Menu!',
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            height: 20 / 14,
                            letterSpacing: 0.02,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
