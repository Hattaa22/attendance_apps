import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:fortis_apps/core/color/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';

import 'dart:async';

import '../controller/home_controller.dart';

class HomeBody extends StatefulWidget {
  const HomeBody({super.key});

  @override
  State<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  final HomeController homeController = HomeController();

  Position? _currentLocation;
  late bool servicePermission = false;
  late LocationPermission permission;

  String currentAdress = "";

  Future<Position> _getCurrentLocation() async {
    servicePermission = await Geolocator.isLocationServiceEnabled();
    if (!servicePermission) {
      debugPrint("service disabled");
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  _getAdressFromCoordinates() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          _currentLocation!.latitude, _currentLocation!.longitude,
          localeIdentifier: 'id_ID');
      Placemark place = placemarks[0];

      setState(() {
        currentAdress = "${place.locality}, ${place.country}";
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  // Sample user data

  String userName = '';
  String selectedMonth = DateFormat('MMM').format(DateTime.now()).toUpperCase();

  String? clockInTime;
  String? clockOutTime;
  String workingHours = '00:00:00';
  Timer? _workingHoursTimer;

  bool isClockedIn = false;
  bool isClockedOut = true;

  bool isReminderActive = false;

  // Attendance statistics
  int presentsCount = 17;
  int absentCount = 30;
  int lateInCount = 27;

  final DateFormat timeFormat = DateFormat('hh:mm a');
  final DateFormat dateFormat = DateFormat('EEEE dd MMMM yyyy');
  Timer? _timer;
  DateTime _currentTime = DateTime.now();

  @override

  // Membuat timer yang berjalan terus - menerus perdetik
  void initState() {
    super.initState();
    _initializeLocation();
    _loadUserProfile();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
  }

    void _loadUserProfile() async {
    final result = await homeController.loadProfile();
    if (result['success'] == true && result['profile'] != null) {
      setState(() {
        userName = result['profile']['name'] ?? 'User';
      });
    }
  }

  void _initializeLocation() async {
    _currentLocation = await _getCurrentLocation();
    await _getAdressFromCoordinates();
  }

  // Membatalkan timer saat widget dihapus agar tidak terus berjalan di background
  @override
  void dispose() {
    _timer?.cancel();
    _workingHoursTimer?.cancel();
    super.dispose();
  }

  void _updateWorkingHours() {
    if (clockInTime == null) return;

    final clockIn = DateTime.parse(clockInTime!);
    final now =
        clockOutTime != null ? DateTime.parse(clockOutTime!) : DateTime.now();

    final difference = now.difference(clockIn);

    setState(() {
      workingHours = _formatDuration(difference);
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
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
    final now = DateTime.now();
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
                  'You have successfully clocked in at\n${timeFormat.format(now)} on ${dateFormat.format(now)}.\nHave a good day and have a productive\nday!',
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
    final now = DateTime.now();
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
                  'Clock Out Confirmed!',
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: pureBlack,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'You have successfully clocked out at\n${timeFormat.format(now)} on ${dateFormat.format(now)}.\nThank you for your hard work today!',
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
                      onPressed: () async {
                        Navigator.of(context).pop();
                        bool wasClockIn = !isClockedIn;

                        try {
                          // Dapatkan posisi saat ini
                          Position position = await _getCurrentLocation();
                          final now = DateTime.now();

                          Map<String, dynamic> result;

                          if (!isClockedIn) {
                            // Proses Clock In
                            result = await homeController.clockIn(
                              latitude: position.latitude,
                              longitude: position.longitude,
                              waktu: now,
                            );
                          } else {
                            // Proses Clock Out
                            result = await homeController.clockOut(
                              latitude: position.latitude,
                              longitude: position.longitude,
                              waktu: now,
                            );
                          }

                          if (result['success'] == true) {
                            setState(() {
                              if (!isClockedIn) {
                                isClockedIn = true;
                                isClockedOut = false;
                                clockInTime = now.toIso8601String();

                                // Start timer for working hours
                                _workingHoursTimer = Timer.periodic(
                                    Duration(seconds: 1), (timer) {
                                  _updateWorkingHours();
                                });
                              } else {
                                isClockedIn = false;
                                isClockedOut = true;
                                clockOutTime = now.toIso8601String();
                                _workingHoursTimer?.cancel();
                                _updateWorkingHours();
                              }
                            });

                            // Tampilkan dialog sukses
                            Future.delayed(Duration(milliseconds: 100), () {
                              if (wasClockIn) {
                                _showSuccessClockInDialog();
                              } else {
                                _showSuccessClockOutDialog();
                              }
                            });
                          } else {
                            // Tampilkan error message
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(result['message'] ??
                                    'Failed to process attendance'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        } catch (e) {
                          debugPrint('Error processing attendance: $e');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to process attendance: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
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
                            child: SvgPicture.asset(
                              'assets/icon/Pin_fill.svg',
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
                                "${_currentLocation?.longitude}, ${_currentLocation?.latitude}",
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
                    GestureDetector(
                      onTap: () {
                        context.push('/notification');
                      },
                      child: SizedBox(
                        width: 35,
                        height: 35,
                        child: SvgPicture.asset(
                          'assets/icon/Bell_pin_fill.svg',
                          fit: BoxFit.contain,
                        ),
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
                        onTap: () async {
                          final result = await context.push('/reminder');
                          if (result == true) {
                            setState(() {
                              isReminderActive = true;
                            });
                          }
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
                              SvgPicture.asset('assets/icon/Alarm_clock.svg',
                                  width: 15, height: 15, fit: BoxFit.contain),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  isReminderActive
                                      ? 'Reminder Active'
                                      : 'Set Reminder',
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
                      child: GestureDetector(
                        onTap: () {
                          if (isClockedIn) {
                            context.push('/checkinDetails');
                          }
                        },
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                          minimumSize:
                                              const Size.fromHeight(40),
                                          elevation: 0,
                                        ),
                                        child: Text(
                                          isClockedIn
                                              ? 'Clock Out'
                                              : 'Clock In',
                                          style: GoogleFonts.roboto(
                                            fontWeight: FontWeight.w600,
                                            fontSize:
                                                screenWidth < 360 ? 12 : 14,
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
                              // Replace the existing time status cards section
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildTimeStatusCard(
                                    imagePath: 'assets/icon/Clock_fill.svg',
                                    time: clockInTime != null
                                        ? DateFormat('hh:mm a').format(
                                            DateTime.parse(clockInTime!))
                                        : '--:--',
                                    label: 'Clock In',
                                    screenWidth: screenWidth,
                                  ),
                                  _buildTimeStatusCard(
                                    imagePath: 'assets/icon/Clock_fill.svg',
                                    time: clockOutTime != null
                                        ? DateFormat('hh:mm a').format(
                                            DateTime.parse(clockOutTime!))
                                        : '--:--',
                                    label: 'Clock Out',
                                    screenWidth: screenWidth,
                                  ),
                                  _buildTimeStatusCard(
                                    imagePath: 'assets/icon/Clock_fill.svg',
                                    time: workingHours,
                                    label: 'Working Hrs',
                                    screenWidth: screenWidth,
                                  ),
                                ],
                              ),
                            ],
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
        SvgPicture.asset(
          imagePath,
          width: 24,
          height: 24,
          colorFilter: ColorFilter.mode(blueMainColor, BlendMode.srcIn),
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
