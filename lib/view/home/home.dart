import 'package:flutter/material.dart';
import 'package:fortis_apps/core/navigation/navigation.dart';
import 'package:intl/intl.dart';
import 'package:fortis_apps/core/color/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fortis_apps/core/appbar/app_bar_custom.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Sample user data
  final String userName = "Ivana Gunawan";
  final String userID = "123456";
  final String userEmail = "ivana.gunawan@salvus.co.id";

  bool isClockedIn = false;
  bool isClockedOut = true;

  // Method untuk menampilkan pop up Clock In
  void _showClockDialog() {
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
                    const SizedBox(width: 24),
                    Expanded(
                      child: Center(
                        child: Text(
                          !isClockedIn
                              ? 'CLOCK IN ABSENSI'
                              : 'CLOCK OUT ABSENSI',
                          style: GoogleFonts.roboto(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 24,
                      child: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
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

  void _showQrCodeScannerDialog() {
    final MobileScannerController cameraController = MobileScannerController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: double.infinity,
            height: 350,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: MobileScanner(
                                controller: cameraController,
                                onDetect: (capture) {
                                  final List<Barcode> barcodes =
                                      capture.barcodes;
                                  for (final barcode in barcodes) {
                                    if (barcode.rawValue != null) {
                                      cameraController.dispose();
                                      Navigator.pop(context);
                                      setState(() {
                                        if (!isClockedIn) {
                                          isClockedIn = true;
                                          isClockedOut = false;
                                        } else {
                                          isClockedIn = true;
                                          isClockedOut = true;
                                        }
                                      });
                                      return;
                                    }
                                  }
                                },
                              ),
                            ),
                            // QR Code overlay
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ImageIcon(
                                  AssetImage('assets/icon/scan-barcode.png'),
                                  color: Colors.white,
                                  size: 150,
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Column(
                        children: [
                          Text(
                            'Scan QR Code',
                            style: GoogleFonts.roboto(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Align QR code within the frame',
                            style: GoogleFonts.roboto(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Close button
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      cameraController.dispose();
                      Navigator.pop(context);
                    },
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
  void dispose() {
    super.dispose();
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
                        width: 24), // Ruang kosong sebagai penyeimbang tombol X
                    Expanded(
                      child: Center(
                        child: Text(
                          !isClockedIn
                              ? 'CLOCK IN ABSENSI'
                              : 'CLOCK OUT ABSENSI',
                          style: GoogleFonts.roboto(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 24,
                      child: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
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
                      !isClockedIn
                          ? 'assets/icon/timer-start-big-icon.png'
                          : 'assets/icon/timer-pause-big-icon.png',
                      width: 100,
                      height: 100,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  !isClockedIn
                      ? 'Are Sure Clock In this $formattedTime ?'
                      : 'Are Sure Clock Out this $formattedTime ?',
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
                          if (!isClockedIn) {
                            isClockedIn = true;
                            isClockedOut = false;
                          } else {
                            isClockedIn = true;
                            isClockedOut = true;
                          }
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
                                        color: isClockedIn
                                            ? Colors.grey[400]
                                            : greenMainColor,
                                        child: InkWell(
                                          onTap: isClockedIn 
                                          ? null 
                                          : () {
                                            _showClockDialog();
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
                                        color: isClockedOut
                                            ? Colors.grey[400]
                                            : greenMainColor,
                                        child: InkWell(
                                          onTap: isClockedOut 
                                          ? null 
                                          : () {
                                            _showClockDialog();
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: whiteMainColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Remember to keep your distance and wear mask',
                            style: GoogleFonts.roboto(
                              color: whiteMainColor,
                              fontSize: 10,
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
