import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/data/repositories/profile_repository.dart';

class PhotoController extends ChangeNotifier {
  final ProfileRepository _profileRepository = ProfileRepositoryImpl();

  bool _isUpdating = false;
  String? _error;

  bool get isUpdating => _isUpdating;
  String? get error => _error;


  Future<Map<String, dynamic>> takePhoto(BuildContext context) async {
    // try {
    //   print('PhotoController: Taking photo from camera');

    //   final ImagePicker picker = ImagePicker();
    //   final XFile? image = await picker.pickImage(
    //     source: ImageSource.camera,
    //     maxWidth: 800,
    //     maxHeight: 800,
    //     imageQuality: 85,
    //   );

    //   if (image != null) {
    //     print('PhotoController: Photo taken: ${image.path}');
    //     return await _updateProfilePicture(context, image.path);
    //   } else {
    //     print('PhotoController: No photo taken');
    //     return {'success': false, 'message': 'No photo taken'};
    //   }
    // } catch (e) {
    //   print('PhotoController: Camera error: $e');
    //   _showErrorMessage(context, 'Failed to take photo. Please try again.');
    //   return {'success': false, 'message': 'Camera error: $e'};
    // }
    return {
      'success': false,
      'message': 'Photo taking from camera is not implemented yet.'
    };
  }

  Future<Map<String, dynamic>> choosePhoto(BuildContext context) async {
    // try {
    //   print('PhotoController: Choosing photo from gallery');

    //   final ImagePicker picker = ImagePicker();
    //   final XFile? image = await picker.pickImage(
    //     source: ImageSource.gallery,
    //     maxWidth: 800,
    //     maxHeight: 800,
    //     imageQuality: 85,
    //   );

    //   if (image != null) {
    //     print('PhotoController: Photo selected: ${image.path}');
    //     return await _updateProfilePicture(context, image.path);
    //   } else {
    //     print('PhotoController: No photo selected');
    //     return {'success': false, 'message': 'No photo selected'};
    //   }
    // } catch (e) {
    //   print('PhotoController: Gallery error: $e');
    //   _showErrorMessage(context, 'Failed to select photo. Please try again.');
    //   return {'success': false, 'message': 'Gallery error: $e'};
    // }
    return {
      'success': false,
      'message': 'Photo selection from gallery is not implemented yet.'
    };
  }

  // Future<Map<String, dynamic>> _updateProfilePicture(
  //     BuildContext context, String imagePath) async {
  //   try {
  //     print('PhotoController: Updating profile picture');

  //     _setUpdating(true);
  //     _clearError();

  //     final result = await _profileRepository.updateProfilePicture(imagePath);
  //     print('PhotoController: Update picture result: $result');

  //     if (result['success']) {
  //       print('PhotoController: Profile picture updated successfully');
  //       _showSuccessMessage(context, 'Profile picture updated successfully');
  //       _setUpdating(false);
  //       return result;
  //     } else {
  //       print('PhotoController: Failed to update profile picture: ${result['message']}');
  //       _error = result['message'] ?? 'Failed to update profile picture';
  //       _showErrorMessage(context, _error!);
  //       _setUpdating(false);
  //       return result;
  //     }
  //   } catch (e) {
  //     print('PhotoController: Update error: $e');
  //     _error = 'An unexpected error occurred while updating profile picture.';
  //     _showErrorMessage(context, _error!);
  //     _setUpdating(false);
      
  //     return {
  //       'success': false,
  //       'message': 'Failed to update profile picture: $e',
  //       'type': 'unknown'
  //     };
  //   }
  // }

  void _showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _setUpdating(bool updating) {
    _isUpdating = updating;
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