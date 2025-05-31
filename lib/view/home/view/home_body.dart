import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fortis_apps/core/color/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:async';

class HomeBody extends StatefulWidget {
  const HomeBody({super.key});

  @override
  State<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  // Sample user data
  final String userName = "Sawadikap";
  final String location = "Malang, East Java";

  bool isClockedIn = false;
  bool isClockedOut = true;

  // Attendance statistics
  int presentsCount = 17;
  int absentCount = 30;
  int lateInCount = 27;

  Timer? _timer;
  DateTime _currentTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Start timer to update time every second
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

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
                              ? 'Clock In Present'
                              : 'Clock On Present',
                          style: GoogleFonts.roboto(
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
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
                                'assets/icon/one-click.png',
                                width: 66,
                                height: 66,
                                color: whiteMainColor,
                              ),
                              const SizedBox(height: 5),
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
                                'assets/icon/qr-code.png',
                                width: 66,
                                height: 66,
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
                    const SizedBox(width: 24),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
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
    final dateFormatter = DateFormat('EEEE, d MMMM yyyy');
    final timeFormatter = DateFormat('HH:mm:ss');
    final formattedDate = dateFormatter.format(_currentTime);
    final formattedTime = timeFormatter.format(_currentTime);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: blueMainColor,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with location and notification
              Padding(
                padding: EdgeInsets.fromLTRB(
                    screenWidth * 0.05, 16, screenWidth * 0.05, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: whiteWithOpacity,
                                  shape: BoxShape.circle,
                                ),
                                padding: EdgeInsets.all(4),
                                child: ClipOval(
                                  child: Image.asset(
                                    'assets/icon/location.png',
                                    color: whiteMainColor,
                                    fit: BoxFit.contain,
                                    width: 17,
                                    height: 19,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Location',
                                style: GoogleFonts.roboto(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            location,
                            style: GoogleFonts.roboto(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: whiteWithOpacity,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Image.asset(
                        'assets/icon/notification.png',
                        width: 28,
                        height: 28,
                        color: whiteMainColor,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 5),

              // Welcome message with Set Reminder button
              Padding(
                padding: EdgeInsets.fromLTRB(
                    screenWidth * 0.05, 16, screenWidth * 0.05, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      flex: 2,
                      child: Text(
                        'Welcome, $userName',
                        style: GoogleFonts.roboto(
                          color: whiteMainColor,
                          fontSize: screenWidth < 360 ? 18 : 24,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: GestureDetector(
                        onTap: () {
                          // Handle set reminder tap
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: screenWidth < 360 ? 8 : 12,
                              vertical: 8),
                          decoration: BoxDecoration(
                            color: whiteMainColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset('assets/icon/alarm-clock.png',
                                  width: 15, height: 15, color: blueMainColor),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  'Set Reminder',
                                  style: GoogleFonts.roboto(
                                    fontSize: screenWidth < 360 ? 10 : 12,
                                    color: blueMainColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Main white container
              Expanded(
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    // White container
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 120),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                      ),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                            screenWidth * 0.05, 120, screenWidth * 0.05, 20),
                        child: Column(
                          children: [
                            // Attendance for this month with updated design
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    spreadRadius: 1,
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          'Attendance for this month',
                                          style: GoogleFonts.roboto(
                                            fontSize:
                                                screenWidth < 360 ? 14 : 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF4285F4),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'APR',
                                              style: GoogleFonts.roboto(
                                                fontSize: 12,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            const Icon(
                                              Icons.keyboard_arrow_down,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildAttendanceCard(
                                          'Presents',
                                          presentsCount.toString(),
                                          const Color(0xFF34C759), // Green
                                          screenWidth,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: _buildAttendanceCard(
                                          'Absent',
                                          absentCount.toString(),
                                          const Color(0xFFFF3B30), // Red
                                          screenWidth,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: _buildAttendanceCard(
                                          'Late In',
                                          lateInCount.toString(),
                                          const Color(0xFFFF9500), // Orange
                                          screenWidth,
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

                    // Floating card with date, time, and work hours - Positioned in center
                    Positioned(
                      top: 0,
                      left: screenWidth * 0.05,
                      right: screenWidth * 0.05,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Date
                            Text(
                              formattedDate,
                              style: GoogleFonts.roboto(
                                fontSize: 14,
                                color: pureBlack,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Time and Clock In button row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Flexible(
                                  flex: 2,
                                  child: Text(
                                    '$formattedTime AM',
                                    style: GoogleFonts.roboto(
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                      color: pureBlack,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Flexible(
                                  flex: 2,
                                  child: SizedBox(
                                    width: screenWidth * 0.3,
                                    child: ElevatedButton(
                                      onPressed: isClockedIn
                                          ? null
                                          : () => _showClockDialog(),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: blueMainColor,
                                        foregroundColor: whiteMainColor,
                                        disabledBackgroundColor:
                                            Colors.grey[300],
                                        disabledForegroundColor:
                                            Colors.grey[600],
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          horizontal:
                                              screenWidth < 360 ? 16 : 24,
                                          vertical:
                                              8, // vertical padding dikurangi agar pas tinggi tombol
                                        ),
                                        minimumSize: const Size.fromHeight(
                                            40), // tinggi tombol supaya sejajar dengan teks
                                        elevation: 0,
                                      ),
                                      child: Text(
                                        isClockedIn ? 'Clocked In' : 'Clock In',
                                        style: GoogleFonts.roboto(
                                          fontWeight: FontWeight.w600,
                                          fontSize: screenWidth < 360 ? 12 : 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            Center(
                              child: Container(
                                width: screenWidth * 0.8,
                                height: 1,
                                color: Colors.grey[300],
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Time status icons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildTimeStatusCard(
                                  imagePath: 'assets/icon/clock_fill.png',
                                  time: '08:00 AM',
                                  label: 'Clock In',
                                  screenWidth: screenWidth,
                                ),
                                _buildTimeStatusCard(
                                  imagePath: 'assets/icon/clock_fill.png',
                                  time: '04:00 PM',
                                  label: 'Clock Out',
                                  screenWidth: screenWidth,
                                ),
                                _buildTimeStatusCard(
                                  imagePath: 'assets/icon/clock_fill.png',
                                  time: '00:00:00',
                                  label: 'Working Hrs',
                                  screenWidth: screenWidth,
                                ),
                              ],
                            ),
                          ],
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
    );
  }

  Widget _buildTimeStatusCard({
    required String imagePath,
    required String time,
    required String label,
    required double screenWidth,
  }) {
    return Column(
      children: [
        Image.asset(
          imagePath,
          width: 24,
          height: 24,
          color: blueMainColor,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 8),
        Text(
          time,
          style: GoogleFonts.roboto(
            fontSize: 12,
            color: pureBlack,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.roboto(
            fontSize: 12,
            color: greyText,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceCard(
      String title, String count, Color color, double screenWidth) {
    return Container(
      padding: EdgeInsets.all(screenWidth < 360 ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border(
          top: BorderSide(color: color, width: 4),
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: GoogleFonts.roboto(
              fontSize: screenWidth < 360 ? 10 : 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            count,
            style: GoogleFonts.roboto(
              fontSize: screenWidth < 360 ? 16 : 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
