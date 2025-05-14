import 'package:flutter/material.dart';
import 'package:inner_shadow_widget/inner_shadow_widget.dart';
import 'edit_profile_photo.dart'; // Import the new screen

class MenuSettingsPage extends StatefulWidget {
  const MenuSettingsPage({Key? key}) : super(key: key);

  @override
  State<MenuSettingsPage> createState() => _MenuSettingsPageState();
}

class _MenuSettingsPageState extends State<MenuSettingsPage> {
  // User data
  late String userName;
  late String userNumber;
  late String userEmail;
  late String userProfileImage;

  @override
  void initState() {
    super.initState();
    // Initialize user data
    userName = "Ivana Gunawan";
    userNumber = "123456";
    userEmail = "ivana.gunawan@salvus.co.id";
    userProfileImage = "assets/image/Ellipse 39.png"; // Path to profile image
  }

  // Navigate to edit profile photo screen
  Future<void> _navigateToEditProfilePhoto() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePhotoScreen(
          initialProfileImage: userProfileImage,
        ),
      ),
    );
    
    // Update profile image if a new one was selected
    if (result != null) {
      setState(() {
        userProfileImage = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Custom colors matching the design
    final primaryBlue = const Color(0xFF335AAC);
    
    return Scaffold(
      backgroundColor: Color(0xFF335AAC),
      // Menghilangkan AppBar bawaan
      body: Stack(
        children: [
          // Background putih untuk AppBar
          Container(
            color: Colors.white,
            height: MediaQuery.of(context).size.height * 0.30, // Hanya cover bagian atas
          ),
          
          // Konten utama
          Column(
            children: [
              // Custom AppBar
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Logo dan title
                      Row(
                        children: [
                          Image.asset(
                            'assets/logo/Picture1.png', // Path ke file logo PNG
                            height: 60, // Sesuaikan ukuran tinggi logo
                            width: 110, // Sesuaikan ukuran lebar logo
                          ),
                          const SizedBox(width: 20),
                        ],
                      ),
                      // Menu button dengan box decoration circle
                      InnerShadow(
                        blur: 4,
                        color: Colors.black.withOpacity(0.2),
                        offset: const Offset(0, 4),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 255, 255, 255),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.menu, color: Colors.black54),
                            onPressed: () {},
                            padding: const EdgeInsets.all(10),
                            constraints: const BoxConstraints(),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              
              // Content area with blue card starting from middle
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        
                        // Blue card with rounded corners - seperti pada gambar
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: primaryBlue,
                            borderRadius: BorderRadius.circular(46),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Menu Settings Header
                              Padding(
                                padding: const EdgeInsets.only(top: 25.0),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Shadow for text
                                    Text(
                                      "Menu Settings",
                                      style: TextStyle(
                                        color: Colors.black.withOpacity(0.2),
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    // Main text with slightly offset for shadow effect
                                    const Text(
                                      "Menu Settings",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 30),
                              
                              // User profile section
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Profile image
                                    CircleAvatar(
                                      radius: 40,
                                      backgroundImage: AssetImage(userProfileImage),
                                    ),
                                    const SizedBox(width: 20),
                                    
                                    // User info with icons in vertical column
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 10),
                                          // Name with icon
                                          Row(
                                            children: [
                                              Image.asset(
                                                'assets/icon/profile-2user.png',
                                                width: 20,
                                                height: 20,
                                                color: Colors.white,
                                              ),
                                              const SizedBox(width: 10),
                                              Text(
                                                userName,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 15),
                                          
                                          // User number with icon
                                          Row(
                                            children: [
                                              Image.asset(
                                                'assets/icon/personalcard.png',
                                                width: 20,
                                                height: 20,
                                                color: Colors.white,
                                              ),
                                              const SizedBox(width: 10),
                                              Text(
                                                userNumber,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 15),
                                          
                                          // Email with icon
                                          Row(
                                            children: [
                                              Image.asset(
                                                'assets/icon/sms.png',
                                                width: 20,
                                                height: 20,
                                                color: Colors.white,
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Text(
                                                  userEmail,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w700,
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
                              const SizedBox(height: 30),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 50),
                        
                        // User Profile Section
                        Container(
                          width: 320,
                          alignment: Alignment.centerLeft,
                          child: const Text(
                            "User Profile",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildSettingsItemWithImage(
                          imagePath: 'assets/icon/user-hexagon.png',
                          title: "Edit Photo Profile",
                          onTap: _navigateToEditProfilePhoto, // Connected to the new function
                          textLeftPadding: 0.0,
                        ),

                        // Notifications Section
                        const SizedBox(height: 16),
                        Container(
                          width: 320,
                          alignment: Alignment.centerLeft,
                          child: const Text(
                            "Notifications",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildSettingsItemWithImage(
                          imagePath: 'assets/icon/notification.png',
                          title: "Active Reminder",
                          onTap: () {},
                          textLeftPadding: 0.0,
                        ),

                        // Log Out Section
                        const SizedBox(height: 16),
                        Container(
                          width: 320,
                          alignment: Alignment.centerLeft,
                          child: const Text(
                            "Log Out",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildSettingsItemWithImage(
                          imagePath: 'assets/icon/logout-02.png',
                          title: "Sign Out My Account",
                          onTap: () {},
                          textLeftPadding: 0.0,
                        ),
                        
                        const SizedBox(height: 50), // Extra space for bottom indicator
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  
  // Fungsi baru dengan image PNG
  Widget _buildSettingsItemWithImage({
    required String imagePath,
    required String title,
    required VoidCallback onTap,
    double textLeftPadding = 2.0, // Reduced default padding to bring text closer to icon
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0),
        child: Row(
          children: [
            // Image container with fixed width
            SizedBox(
              width: 100, // Reduced width to bring text closer to icon
              child: Image.asset(
                imagePath,
                width: 24,
                height: 24,
                color: Colors.white,
              ),
            ),
            // Adjustable padding before text
            SizedBox(width: textLeftPadding),
            // Text with expanded width
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            // Right arrow with padding
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Image.asset(
                'assets/icon/arrow-right-1.png',
                width: 24,
                height: 24,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}