import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fortis_app/widgets-global/colors.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeClockInScreen extends StatefulWidget {
  const HomeClockInScreen({Key? key}) : super(key: key);

  @override
  _HomeClockInScreenState createState() => _HomeClockInScreenState();
}

class _HomeClockInScreenState extends State<HomeClockInScreen> {
  // Sample user data
  final String userName = "Ivana Gunawan";
  final String userID = "123456";
  final String userEmail = "ivana.gunawan@salvus.co.id";

  bool isClockedIn = false;

  @override
  Widget build(BuildContext context) {
    // Get current date for the header
    final now = DateTime.now();
    final dateFormatter = DateFormat('E, MMM d yyyy');
    final formattedDate = dateFormatter.format(now);

    // Get device size to make UI responsive
    final size = MediaQuery.of(context).size;

    // Setup default text theme with Roboto font
    final textTheme = GoogleFonts.robotoTextTheme(Theme.of(context).textTheme);

    return Scaffold(
      backgroundColor: whiteMainColor,
      appBar: AppBar(
        backgroundColor: whiteMainColor,
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.only(top: 8.0, left: 8.0),
          child: Image.asset(
            'assets/images/fortis-logo.png',
            height: 37,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: deepNavyMainColor),
            onPressed: () {
              // Handle menu button press
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // User Profile Card
                    Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: blueMainColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              // User avatar
                              Container(
                                padding:
                                    const EdgeInsets.all(2), // border thickness
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
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: blueMainColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
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
                              const SizedBox(height: 16),
                              // Clock In/Out section
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(8),
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
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Material(
                                                color: greenMainColor,
                                                child: InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      isClockedIn = true;
                                                    });
                                                    // Handle clock in action
                                                  },
                                                  child: Container(
                                                    width: 90,
                                                    height: 90,
                                                    alignment: Alignment.center,
                                                    padding: const EdgeInsets
                                                        .symmetric(vertical: 8),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Image.asset(
                                                          'assets/images/timer-start.png',
                                                          width: 50,
                                                          height: 50,
                                                          color: whiteMainColor,
                                                        ),
                                                        const SizedBox(
                                                            height: 4),
                                                        Text(
                                                          'Clock In',
                                                          style: GoogleFonts
                                                              .roboto(
                                                            color:
                                                                whiteMainColor,
                                                            fontWeight:
                                                                FontWeight.bold,
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
                                      // Vertical divider
                                      Container(
                                        height: 100,
                                        width: 1,
                                        color: Colors.grey[400],
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
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Material(
                                                color: isClockedIn
                                                    ? greenMainColor
                                                    : Colors.grey[400],
                                                child: InkWell(
                                                  onTap: isClockedIn
                                                      ? () {
                                                          setState(() {
                                                            isClockedIn = false;
                                                          });
                                                          // Handle clock out action
                                                        }
                                                      : null,
                                                  child: Container(
                                                    width: 90,
                                                    height: 90,
                                                    alignment: Alignment.center,
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Image.asset(
                                                          'assets/images/timer-end.png',
                                                          width: 50,
                                                          height: 50,
                                                          color: whiteMainColor,
                                                        ),
                                                        const SizedBox(
                                                            height: 4),
                                                        Text(
                                                          'Clock Out',
                                                          style: TextStyle(
                                                            color: isClockedIn
                                                                ? whiteMainColor
                                                                : Colors
                                                                    .grey[600],
                                                            fontWeight:
                                                                FontWeight.bold,
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
                      padding: const EdgeInsets.all(32.0),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: blueMainColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.warning_amber_rounded,
                                    color: whiteMainColor,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Remember to keep your distance and wear mask',
                                      style: GoogleFonts.roboto(
                                        color: whiteMainColor,
                                        fontSize: 14,
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
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                'help@salvus.co.id',
                                style: GoogleFonts.roboto(
                                  color: whiteMainColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'by',
                          style: GoogleFonts.roboto(
                            color: Colors.black,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Image.asset(
                          'assets/logo/salvus-logo.png',
                          height: 36,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Navigation Bar
            Container(
              decoration: BoxDecoration(
                color: whiteMainColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, -1),
                  ),
                ],
              ),
              child: Container(
                color: blueMainColor,
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(
                        'assets/icon/home-icon.png', 'HOME', true),
                    _buildNavItem(
                        'assets/icon/leave-icon.png', 'LEAVE', false),
                    _buildNavItem(
                        'assets/icon/calendar-icon.png', 'CALENDAR', false),
                    _buildNavItem(
                        'assets/icon/timesheet-icon.png', 'TIMESHEET', false),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(String assetPath, String label, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          assetPath,
          width: 30,
          height: 30,
          color: whiteMainColor, // jika ingin warnanya putih
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.roboto(
            color: whiteMainColor,
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
