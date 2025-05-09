import 'package:flutter/material.dart';
import 'package:fortis_apps/core/navigation/navigation.dart';
import 'package:intl/intl.dart';
import 'package:fortis_apps/core/color/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fortis_apps/core/navigation/navigation.dart';
import 'package:fortis_apps/core/appbar/app_bar_custom.dart';

class HomeClockOutScreen extends StatefulWidget {
  const HomeClockOutScreen({super.key});

  @override
  _HomeClockOutScreenState createState() => _HomeClockOutScreenState();
}

class _HomeClockOutScreenState extends State<HomeClockOutScreen> {
  // Sample user data
  final String userName = "Ivana Gunawan";
  final String userID = "123456";
  final String userEmail = "ivana.gunawan@salvus.co.id";

  bool isClockedIn = false;

  // Method untuk menampilkan pop up Clock In
  void _showClockOutAttendanceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title di tengah
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(width: 40),
                    Expanded(
                      child: Center(
                        child: Text(
                          'CLOCK IN ATTENDANCE',
                          style: GoogleFonts.roboto(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // One Click Card
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                        _showOneClickConfirmationDialog();
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        color: greenMainColor,
                        child: Container(
                          width: 100,
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: [
                              Image.asset(
                                'assets/icon/clock-icon.png',
                                width: 40,
                                height: 40,
                                color: whiteMainColor,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'One Click',
                                style: GoogleFonts.roboto(
                                  fontWeight: FontWeight.bold,
                                  color: whiteMainColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // QR Code Card
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                        _showQrCodeScannerDialog();
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        color: blueMainColor,
                        child: Container(
                          width: 100,
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: [
                              Image.asset(
                                'assets/icon/scan-barcode.png',
                                width: 40,
                                height: 40,
                                color: whiteMainColor,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'QR Code',
                                style: GoogleFonts.roboto(
                                  fontWeight: FontWeight.bold,
                                  color: whiteMainColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Method untuk menampilkan pop up One Click - Clock In
  void _showOneClickConfirmationDialog() {
    final now = DateTime.now();
    final timeFormatter = DateFormat('hh:mm a');
    final formattedTime = timeFormatter.format(now);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                        width: 48), // Ruang kosong sebagai penyeimbang tombol X
                    Expanded(
                      child: Center(
                        child: Text(
                          'CLOCK Out ABSENSI',
                          style: GoogleFonts.roboto(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Clock icon
                SizedBox(
                  width: 100,
                  height: 100,
                  child: Center(
                    child: Image.asset(
                      'assets/icon/timer-pause-big-icon.png',
                      width: 100,
                      height: 100,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Are Sure Clock Out this $formattedTime ?',
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                // Confirmation buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // No button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: BorderSide(color: greenMainColor),
                        minimumSize: Size(100, 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'No',
                        style: GoogleFonts.roboto(
                          color: Colors.black,
                        ),
                      ),
                    ),
                    // Yes button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: greenMainColor,
                        minimumSize: Size(100, 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          isClockedIn = true;
                        });
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Yes!',
                        style: GoogleFonts.roboto(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Method untuk menampilkan pop up QR Code - Clock In
  void _showQrCodeScannerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: double.infinity,
            height: 500,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // QR Scanner frame
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(
                    children: [
                      // Top left corner
                      Positioned(
                        top: 16,
                        left: 16,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(color: Colors.white, width: 2),
                              left: BorderSide(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                      ),
                      // Top right corner
                      Positioned(
                        top: 16,
                        right: 16,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(color: Colors.white, width: 2),
                              right: BorderSide(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                      ),
                      // Bottom left corner
                      Positioned(
                        bottom: 16,
                        left: 16,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.white, width: 2),
                              left: BorderSide(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                      ),
                      // Bottom right corner
                      Positioned(
                        bottom: 16,
                        right: 16,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.white, width: 2),
                              right: BorderSide(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                      ),
                      // QR code boxes in the center
                      Center(
                        child: Container(
                          width: 80,
                          height: 80,
                          child: GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                            children: List.generate(4, (index) {
                              return Container(
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.white, width: 1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateFormatter = DateFormat('E, MMM d yyyy');
    final formattedDate = dateFormatter.format(now);

    return Scaffold(
      backgroundColor: whiteMainColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AppBarCustom(),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 14, 30, 14),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: blueMainColor,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // User avatar
                      Container(
                        padding: const EdgeInsets.all(2), // border thickness
                        decoration: BoxDecoration(
                          color: Colors.white, // border color
                          shape: BoxShape.circle,
                        ),
                        child: CircleAvatar(
                          radius: 40,
                          backgroundImage: const AssetImage(
                              'assets/images/default-profile.png'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // User information
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Image.asset(
                                  'assets/icon/profile-2user-icon.png',
                                  width: 20,
                                  height: 20,
                                  color: whiteMainColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  userName,
                                  style: GoogleFonts.roboto(
                                    color: whiteMainColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Image.asset(
                                  'assets/icon/personalcard-icon.png',
                                  width: 20,
                                  height: 20,
                                  color: whiteMainColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  userID,
                                  style: GoogleFonts.roboto(
                                    color: whiteMainColor,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Image.asset(
                                  'assets/icon/email-icon.png',
                                  width: 20,
                                  height: 20,
                                  color: whiteMainColor,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    userEmail,
                                    style: GoogleFonts.roboto(
                                      color: whiteMainColor,
                                      fontSize: 14,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Clock In/Out Card
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 0, 30, 8),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: blueMainColor,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 15, 8, 8),
                  child: Column(
                    children: [
                      // Date display
                      Text(
                        formattedDate,
                        style: GoogleFonts.roboto(
                          color: whiteMainColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Clock In/Out section
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              // Clock In column
                              Expanded(
                                child: Column(
                                  children: [
                                    Text(
                                      'Clock In:',
                                      style: GoogleFonts.roboto(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '08:00 AM',
                                      style: GoogleFonts.roboto(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    // Clock In button
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: Material(
                                        color: Colors.grey[400],
                                        child: InkWell(
                                          onTap: () {
                                            
                                          },
                                          child: Container(
                                            width: 90,
                                            height: 90,
                                            alignment: Alignment.center,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Image.asset(
                                                  'assets/images/timer-start.png',
                                                  width: 50,
                                                  height: 50,
                                                  color: whiteMainColor,
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Clock In',
                                                  style: GoogleFonts.roboto(
                                                    color: whiteMainColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Clock Out column
                              Expanded(
                                child: Column(
                                  children: [
                                    Text(
                                      'Clock Out:',
                                      style: GoogleFonts.roboto(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '17:31 PM',
                                      style: GoogleFonts.roboto(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    // Clock Out button
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: Material(
                                        color: isClockedIn
                                            ? Colors.grey[400]
                                            : greenMainColor,
                                        child: InkWell(
                                          onTap: () {
                                            // Panggil Fungsi untuk menampilkan pop up Clock In
                                            _showClockOutAttendanceDialog();
                                          },
                                          child: Container(
                                            width: 90,
                                            height: 90,
                                            alignment: Alignment.center,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Image.asset(
                                                  'assets/images/timer-end.png',
                                                  width: 50,
                                                  height: 50,
                                                  color: whiteMainColor,
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Clock Out',
                                                  style: TextStyle(
                                                    color: whiteMainColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Health Notice Card
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 0, 30, 17),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: blueMainColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: whiteMainColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Remember to keep your distance and wear mask',
                              style: GoogleFonts.roboto(
                                color: whiteMainColor,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'More info:',
                        style: GoogleFonts.roboto(
                          color: whiteMainColor,
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        'help@salvus.co.id',
                        style: GoogleFonts.roboto(
                          color: whiteMainColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Center(
              child: Image.asset(
                'assets/logo/salvus-logo.png',
                height: 37,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Navigation(),
    );
  }
}
