import 'package:flutter/material.dart';
import 'package:fortis_apps/view/home/view/checkin_details.dart';
import 'package:fortis_apps/view/home/view/notification.dart';
import 'package:fortis_apps/view/home/view/reminder.dart';
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
  final String userName = "sawaw";
  final String location = "Malang, East Java";

  String selectedMonth = DateFormat('MMM').format(DateTime.now()).toUpperCase();

  bool isClockedIn = false;
  bool isClockedOut = true;

  // Attendance statistics
  int presentsCount = 17;
  int absentCount = 30;
  int lateInCount = 27;

  Timer? _timer;
  DateTime _currentTime = DateTime.now();

  @override

  // Membuat timer yang berjalan terus - menerus perdetik
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
  }

  // Membatalkan timer saat widget dihapus agar tidak terus berjalan di background
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Menampilkan dialog pilihan metode clock in/out dengan dua opsi tombol:
  // "One Click" dan "QR Code", warna tombol berubah sesuai status clock.
  void _showClockDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header dialog dengan judul dinamis dan tombol close
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 24),
                    Expanded(
                      child: Center(
                        child: Text(
                          !isClockedIn
                              ? 'Clock In Present'
                              : 'Clock Out Present',
                          style: GoogleFonts.roboto(
                              fontWeight: FontWeight.w500, fontSize: 18),
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
                // Tombol metode clock
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                        _showOneClickConfirmationDialog();
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        color: isClockedIn ? Colors.red : blueMainColor,
                        child: Container(
                          width: 110,
                          height: 110,
                          padding: const EdgeInsets.all(5),
                          child: Column(
                            children: [
                              Image.asset('assets/icon/one-click.png',
                                  width: 66, height: 66, color: whiteMainColor),
                              const SizedBox(height: 5),
                              Text('One Click',
                                  style: GoogleFonts.roboto(
                                      fontWeight: FontWeight.w500,
                                      color: whiteMainColor)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                        _showQrCodeScannerDialog();
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        color: isClockedIn ? Colors.red : blueMainColor,
                        child: Container(
                          width: 110,
                          height: 110,
                          padding: const EdgeInsets.all(5),
                          child: Column(
                            children: [
                              Image.asset('assets/icon/qr-code.png',
                                  width: 66, height: 66, color: whiteMainColor),
                              const SizedBox(height: 5),
                              Text('QR Code',
                                  style: GoogleFonts.roboto(
                                      fontWeight: FontWeight.bold,
                                      color: whiteMainColor)),
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

  // Menampilkan dialog konfirmasi sukses clock in
  void _showSuccessClockInDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Image.asset(
                    'assets/icon/tick-circle.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Clock In Confirmed!',
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: pureBlack,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'You have successfully clocked in at\n08:00 AM on Monday 16 June 2025.\nHave a good day and have a productive\nday!',
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: blueMainColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Okey!',
                      style: GoogleFonts.roboto(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Menampilkan dialog konfirmasi sukses clock out
  void _showSuccessClockOutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Image.asset(
                    'assets/icon/tick-circle.png',
                    width: 24,
                    height: 25,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Clock In Confirmed!',
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: pureBlack,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'You have successfully clocked out at\n04:00 PM on Monday 16 June 2025.\nThank you for your hard work today!',
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: blueMainColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Okay!',
                      style: GoogleFonts.roboto(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Menampilkan dialog scan qr code
  void _showQrCodeScannerDialog() {
    final MobileScannerController cameraController = MobileScannerController();
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
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

                                      bool wasClockIn = !isClockedIn;

                                      setState(() {
                                        if (!isClockedIn) {
                                          isClockedIn = true;
                                          isClockedOut = false;
                                        } else {
                                          // Untuk Clock Out, kembali ke state awal
                                          isClockedIn = false;
                                          isClockedOut = true;
                                        }
                                      });

                                      Future.delayed(
                                          Duration(milliseconds: 100), () {
                                        // Tampilkan dialog berdasarkan aksi yang dilakukan
                                        if (wasClockIn) {
                                          _showSuccessClockInDialog();
                                        } else {
                                          _showSuccessClockOutDialog();
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

  // Menampilkan dialog konfirmasi saat one click
  void _showOneClickConfirmationDialog() {
    final now = DateTime.now();
    final timeFormatter = DateFormat('hh:mm a');
    final formattedTime = timeFormatter.format(now);

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
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
                              : 'Want to Clock Out ?',
                          style: GoogleFonts.roboto(
                            fontWeight: FontWeight.w500,
                            fontSize: 22,
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
                !isClockedIn
                    ? Image.asset(
                        'assets/icon/clock-in-present.png',
                        width: 80,
                        height: 80,
                        color: blueMainColor,
                      )
                    : const SizedBox.shrink(),
                !isClockedIn
                    ? Text(
                        'One Click',
                        style: GoogleFonts.roboto(
                          fontWeight: FontWeight.w500,
                          color: blueMainColor,
                        ),
                      )
                    : const SizedBox.shrink(),
                const SizedBox(height: 15),
                Text(
                  !isClockedIn
                      ? 'Are Sure Clock In this at \n$formattedTime ?'
                      : 'Are Sure Clock Out this at \n$formattedTime ?',
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: BorderSide(color: whiteMainColor),
                        minimumSize: Size(140, 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'No',
                        style: GoogleFonts.roboto(
                          color: blueMainColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isClockedIn ? Colors.red : blueMainColor,
                        minimumSize: Size(140, 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();

                        bool wasClockIn = !isClockedIn;

                        setState(() {
                          if (!isClockedIn) {
                            isClockedIn = true;
                            isClockedOut = false;
                          } else {
                            // Untuk Clock Out, kembali ke state awal
                            isClockedIn = false;
                            isClockedOut = true;
                          }
                        });

                        Future.delayed(Duration(milliseconds: 100), () {
                          // Tampilkan dialog berdasarkan aksi yang dilakukan
                          if (wasClockIn) {
                            _showSuccessClockInDialog();
                          } else {
                            _showSuccessClockOutDialog();
                          }
                        });
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
  

  // Menampilkan dialog pemilihan bulan dengan navigasi tahun
  void _showMonthSelectionDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios, size: 18),
                      onPressed: () {
                        // Logic untuk tahun sebelumnya
                      },
                    ),
                    Text(
                      '2025',
                      style: GoogleFonts.roboto(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.arrow_forward_ios, size: 18),
                      onPressed: () {
                        // Logic untuk tahun selanjutnya
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 3,
                  childAspectRatio: 2.5,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  children: [
                    _buildMonthButton('Jan', false),
                    _buildMonthButton('Feb', false),
                    _buildMonthButton('Mar', false),
                    _buildMonthButton('Apr', false),
                    _buildMonthButton('May', false),
                    _buildMonthButton('Jun', true),
                    _buildMonthButton('Jul', false),
                    _buildMonthButton('Aug', false),
                    _buildMonthButton('Sep', false),
                    _buildMonthButton('Oct', false),
                    _buildMonthButton('Nov', false),
                    _buildMonthButton('Dec', false),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: blueMainColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Apply',
                      style: GoogleFonts.roboto(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Membuat tombol bulan dengan style berbeda jika dipilih atau tidak
  Widget _buildMonthButton(String month, bool isSelected) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? blueMainColor : Colors.grey[100],
        foregroundColor: isSelected ? Colors.white : Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
      ),
      onPressed: () {
        // Logic untuk memilih bulan
      },
      child: Text(
        month,
        style: GoogleFonts.roboto(
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('EEEE, d MMMM yyyy');
    final timeFormatter = DateFormat('HH:mm:ss a');
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
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: whiteWithOpacity,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(8),
                            child: Image.asset(
                              'assets/icon/location.png',
                              color: whiteMainColor,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Location',
                                style: GoogleFonts.roboto(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 2),
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
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 35,
                      height: 35,
                      child: Image.asset(
                        'assets/icon/bell_pin_fill.png',
                        color: whiteMainColor,
                        fit: BoxFit.contain,
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
                        color: whiteHome,
                      ),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                            screenWidth * 0.02, 120, screenWidth * 0.02, 20),
                        child: Column(
                          children: [
                            // Attendance for this month with updated design
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
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
                                            color: pureBlack,
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () =>
                                            _showMonthSelectionDialog(),
                                        child: Container(
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
                                              const Icon(
                                                Icons.calendar_month,
                                                color: Colors.white,
                                                size: 14,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                selectedMonth,
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
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 25),
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
                                // Tampilkan waktu hanya jika belum clock in
                                if (!isClockedIn) ...[
                                  Flexible(
                                    flex: 2,
                                    child: Text(
                                      formattedTime,
                                      style: GoogleFonts.roboto(
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                        color: pureBlack,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                ],
                                // Tombol Clock In/Out
                                Flexible(
                                  flex: isClockedIn ? 1 : 2,
                                  child: SizedBox(
                                    width: isClockedIn
                                        ? double.infinity
                                        : screenWidth * 0.3,
                                    child: ElevatedButton(
                                      onPressed: () => _showClockDialog(),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isClockedIn
                                            ? Colors.red
                                            : blueMainColor,
                                        foregroundColor: whiteMainColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          horizontal:
                                              screenWidth < 360 ? 16 : 24,
                                          vertical: 8,
                                        ),
                                        minimumSize: const Size.fromHeight(40),
                                        elevation: 0,
                                      ),
                                      child: Text(
                                        isClockedIn ? 'Clock Out' : 'Clock In',
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
        const SizedBox(height: 3),
        Text(
          time,
          style: GoogleFonts.roboto(
            fontSize: 12,
            color: pureBlack,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
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
      padding: EdgeInsets.only(
        right: 10,
        left: 10,
        bottom: 8,
        top: 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border(
          top: BorderSide(color: color, width: 4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              style: GoogleFonts.roboto(
                fontSize: 16,
                color: pureBlack,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              count,
              style: GoogleFonts.roboto(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
