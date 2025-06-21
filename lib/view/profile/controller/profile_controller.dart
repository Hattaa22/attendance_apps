import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/data/repositories/profile_repository.dart';

class ProfileController extends ChangeNotifier {
  final ProfileRepository _profileRepository = ProfileRepositoryImpl();

  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _profile;

  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get profile => _profile;
  bool get hasProfileData => _profile != null;

  String get userId => _profile?['employee_id'] ?? _profile?['nip'] ?? '12345';
  String get email => _profile?['email'] ?? 'No email';
  String get phoneNumber => _profile?['phone'] ?? 'No phone number';
  String get name => _profile?['display_name'] ?? _profile?['name'] ?? 'User';
  String get department =>
      _profile?['department'] ?? _profile?['division'] ?? 'Department';

  Future<void> initialize() async {
    print('ProfileController: Initializing...');
    await loadProfile();
  }

  Future<Map<String, dynamic>> loadProfile() async {
    if (_isLoading) return {'success': false, 'message': 'Load in progress'};

    _setLoading(true);
    _clearError();

    try {
      print('ProfileController: Loading profile from repository');

      final result = await _profileRepository.getProfile();
      print('ProfileController: Repository result: $result');

      if (!result['success']) {
        _error = result['message'] ?? 'Failed to load profile';

        if (result['requiresLogin'] == true) {
          _error = 'Please login to view your profile';
        }

        _setLoading(false);
        notifyListeners();
        return result;
      }

      _profile = result['profile'];
      print('ProfileController: Profile loaded successfully');

      _setLoading(false);
      return result;
    } catch (e) {
      print('ProfileController: Load profile error - $e');
      _error = 'An unexpected error occurred while loading profile.';
      _setLoading(false);
      notifyListeners();

      return {
        'success': false,
        'message': 'Failed to load profile: $e',
        'type': 'unknown'
      };
    }
  }


  Future<void> refreshProfile() async {
    print('ProfileController: Refreshing profile data');
    await loadProfile();
  }

  void updateProfileData(Map<String, dynamic> newProfileData) {
    _profile = newProfileData;
    notifyListeners();
    print('ProfileController: Profile data updated');
  }

  Widget buildProfileImage() {
    if (_isLoading) {
      return _buildLoadingWidget();
    }

    if (_error != null) {
      return _buildErrorWidget();
    }

    final profilePicture = _profile?['profile_picture'];
    if (profilePicture != null && profilePicture.toString().isNotEmpty) {
      return _buildNetworkImage(profilePicture);
    }

    return _buildInitialsAvatar();
  }

  Widget _buildLoadingWidget() {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[300],
      ),
      child: Center(
        child: CircularProgressIndicator(
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[300],
      ),
      child: Icon(
        Icons.person,
        size: 70,
        color: Colors.grey[600],
      ),
    );
  }

  Widget _buildNetworkImage(String imageUrl) {
    return Image.network(
      imageUrl,
      width: 140,
      height: 140,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey[300],
          ),
          child: Center(
            child: CircularProgressIndicator(
              color: Colors.grey[600],
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return _buildInitialsAvatar();
      },
    );
  }

  // Build initials avatar
  Widget _buildInitialsAvatar() {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade300,
            Colors.blue.shade600,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          _getInitials(),
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }

  String _getInitials() {
    if (name.isEmpty || name == 'Loading...' || name == 'User') return 'U';

    final words = name.trim().split(' ');
    if (words.length >= 2) {
      return (words[0][0] + words[1][0]).toUpperCase();
    } else if (words.length == 1) {
      return words[0][0].toUpperCase();
    }

    return 'U';
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
