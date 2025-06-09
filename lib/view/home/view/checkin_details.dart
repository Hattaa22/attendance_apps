import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fortis_apps/core/color/colors.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';

class CheckInDetailsPage extends StatefulWidget {
  const CheckInDetailsPage({super.key});

  @override
  State<CheckInDetailsPage> createState() => _CheckInDetailsPageState();
}

class _CheckInDetailsPageState extends State<CheckInDetailsPage> {
  DateTime selectedDate = DateTime.now();

  bool isClockedIn = true;
  bool isClockedOut = false;

  void _pickDate() async {
    await showCustomCalendarDialog(context, selectedDate, (picked) {
      setState(() {
        selectedDate = picked;
      });
    });
  }

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
                  'Clock Out Confirmed!',
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
                      context.go('/');
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
                      Navigator.of(context).pop(isClockedOut);
                      context.go('/');
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

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('EEEE, d MMMM yyyy').format(selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clock Out details'),
        leading: const BackButton(),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(dateStr,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _showClockDialog(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        minimumSize: const Size.fromHeight(40),
                        elevation: 0,
                      ),
                      child: Text(
                        'Clock Out',
                        style: GoogleFonts.roboto(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _ClockInfo(
                        iconWidget: Image.asset(
                          'assets/icon/Clock_fill.png',
                          width: 24,
                          height: 24,
                        ),
                        label: '08:00 AM',
                        subLabel: 'Clock In',
                      ),
                      _ClockInfo(
                        iconWidget: Image.asset(
                          'assets/icon/Clock_fill.png',
                          width: 24,
                          height: 24,
                        ),
                        label: '04:00 PM',
                        subLabel: 'Clock Out',
                      ),
                      _ClockInfo(
                        iconWidget: Image.asset(
                          'assets/icon/Clock_fill.png',
                          width: 24,
                          height: 24,
                        ),
                        label: '00:00:00 AM',
                        subLabel: 'Working HR\'s',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Schedule',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextButton.icon(
                  onPressed: _pickDate,
                  label: const Text('Today'),
                  icon: const Icon(
                    Icons.calendar_today,
                    size: 18,
                    color: Color(0xFF2463EB),
                  ),
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: ListView(
                children: const [
                  _ScheduleItem(
                      time: '08:00',
                      label: 'Check In time',
                      color: Colors.green,
                      timeBox: '07:50'),
                  _ScheduleItem(time: '09:00', label: '', color: Colors.grey),
                  _ScheduleItem(time: '10:00', label: '', color: Colors.grey),
                  _ScheduleItem(
                      time: '11:00',
                      label: 'Break time',
                      color: Colors.amber,
                      timeBox: '07:50'),
                  _ScheduleItem(
                      time: '16:00',
                      label: 'Clock Out time',
                      color: Colors.red,
                      timeBox: '07:50'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showCustomCalendarDialog(BuildContext context,
    DateTime selectedDate, Function(DateTime) onDateSelected) async {
  DateTime tempPicked = selectedDate;

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TableCalendar(
                    focusedDay: tempPicked,
                    firstDay: DateTime(2020),
                    lastDay: DateTime(2030),
                    selectedDayPredicate: (day) => isSameDay(day, tempPicked),
                    onDaySelected: (selected, _) {
                      setState(() => tempPicked = selected);
                    },
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                    ),
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF2463EB),
                          width: 2,
                        ),
                      ),
                      selectedDecoration: BoxDecoration(
                        color: const Color.fromRGBO(36, 99, 235, 1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Color.fromRGBO(36, 99, 235, 1),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.8),
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      todayTextStyle: const TextStyle(
                        color: Color(0xFF2463EB),
                      ),
                      selectedTextStyle: const TextStyle(color: Colors.white),
                      weekendTextStyle: const TextStyle(color: Colors.red),
                    ),
                    daysOfWeekStyle: const DaysOfWeekStyle(
                      weekendStyle: TextStyle(color: Colors.red),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          DateFormat('dd/MM/yyyy').format(tempPicked),
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromRGBO(36, 99, 235, 1),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {
                          onDateSelected(tempPicked);
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          'Apply',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            );
          },
        ),
      );
    },
  );
}

class _ClockInfo extends StatelessWidget {
  final Widget iconWidget;
  final String label;
  final String subLabel;

  const _ClockInfo({
    required this.iconWidget,
    required this.label,
    required this.subLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        iconWidget,
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(subLabel, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _ScheduleItem extends StatelessWidget {
  final String time;
  final String label;
  final Color color;
  final String? timeBox;

  const _ScheduleItem(
      {required this.time,
      required this.label,
      required this.color,
      this.timeBox});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 50,
            alignment: Alignment.center,
            child: Text(
              time,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label.isEmpty ? '—' : label,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  if (timeBox != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '($timeBox)',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
