import 'package:flutter/material.dart';

class ChangePhotoProfile extends StatelessWidget {
  final VoidCallback? onTakePhoto;
  final VoidCallback? onChoosePhoto;
  final VoidCallback? onClose;

  const ChangePhotoProfile({
    Key? key,
    this.onTakePhoto,
    this.onChoosePhoto,
    this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.5),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFE4E4E4),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Center(
                      child: Text(
                        'Edit profile photo',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      child: GestureDetector(
                        onTap: onClose ?? () => Navigator.of(context).pop(),
                        child: Icon(
                          Icons.close,
                          size: 15,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                        onTakePhoto?.call();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Take photo',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                                letterSpacing: 0.2 / 100 * 10,
                                color: Colors.black,
                              ),
                            ),
                            Image.asset(
                              'icon/camera.png',
                              width: 25,
                              height: 25,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.camera_alt,
                                  size: 25,
                                  color: Colors.grey[600],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      height: 1.5,
                      color: const Color(0xFFE4E4E4),
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                        onChoosePhoto?.call();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Choose photo',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                                letterSpacing: 0.2 / 100 * 10,
                                color: Colors.black,
                              ),
                            ),
                            Image.asset(
                              'icon/galery.png',
                              width: 25,
                              height: 25,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.photo_library,
                                  size: 25,
                                  color: Colors.grey[600],
                                );
                              },
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

  static void show(
    BuildContext context, {
    VoidCallback? onTakePhoto,
    VoidCallback? onChoosePhoto,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return ChangePhotoProfile(
          onTakePhoto: onTakePhoto,
          onChoosePhoto: onChoosePhoto,
        );
      },
    );
  }
}
