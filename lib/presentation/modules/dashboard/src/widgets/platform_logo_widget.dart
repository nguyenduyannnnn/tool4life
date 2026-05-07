import 'package:flutter/material.dart';

class PlatformLogoWidget extends StatelessWidget {
  final String platform;
  final double size;

  const PlatformLogoWidget({
    super.key,
    required this.platform,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: _buildLogo(),
    );
  }

  Widget _buildLogo() {
    final platformLower = platform.toLowerCase();
    
    // Debug log
    print('🎯 Platform Logo: "$platform" -> "$platformLower"');

    // Google Meet
    if (platformLower.contains('google-meet') || platformLower.contains('google meet')) {
      print('🎯 Using Google Meet logo');
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade200, width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(size / 2),
          child: Image.asset(
            'assets/icon/icon-google-meet.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade400, Colors.blue.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(
                  Icons.video_call,
                  color: Colors.white,
                  size: 20,
                ),
              );
            },
          ),
        ),
      );
    }
    
    // Webex
    if (platformLower.contains('webex')) {
      print('🎯 Using Webex logo');
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade200, width: 1),
        ),
        child: ClipRRect(
          // borderRadius: BorderRadius.circular(size / 2),
          child: Image.asset(
            'assets/icon/icon-webex.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.green.shade400, Colors.green.shade600],
                    // begin: Alignment.topLeft,
                    // end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(
                  Icons.meeting_room,
                  color: Colors.white,
                  size: 20,
                ),
              );
            },
          ),
        ),
      );
    }
    
    // Microsoft Teams
    if (platformLower.contains('teams')) {
      print('🎯 Using Teams logo');
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade200, width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(size / 2),
          child: Image.asset(
            'assets/icon/icon-teams.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.purple.shade400, Colors.purple.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(
                  Icons.groups,
                  color: Colors.white,
                  size: 20,
                ),
              );
            },
          ),
        ),
      );
    }
    
    // Zoom
    if (platformLower.contains('zoom')) {
      print('🎯 Using Zoom logo');
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade200, width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(size / 2),
          child: Image.asset(
            'assets/icon/icon-zoom.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.indigo.shade400, Colors.indigo.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(
                  Icons.video_camera_front,
                  color: Colors.white,
                  size: 20,
                ),
              );
            },
          ),
        ),
      );
    }
    
    // File Upload
    if (platformLower.contains('file upload')) {
      print('🎯 Using File Upload logo');
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade200, width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(size / 2),
          child: Image.asset(
            'assets/icon/icon-upload.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.orange.shade400, Colors.orange.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(
                  Icons.upload_file,
                  color: Colors.white,
                  size: 20,
                ),
              );
            },
          ),
        ),
      );
    }
    
    // Default - Chang Meeting logo
    print('🎯 Using default Chang Meeting logo');
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: Image.asset(
          'assets/image/chang_logo.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.orange.shade400, Colors.orange.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Icon(
                Icons.pets,
                color: Colors.white,
                size: 20,
              ),
            );
          },
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    final platformLower = platform.toLowerCase();

    if (platformLower.contains('google-meet') || platformLower.contains('google meet')) {
      return Colors.blue;
    } else if (platformLower.contains('webex')) {
      return Colors.green;
    } else if (platformLower.contains('zoom')) {
      return Colors.indigo;
    } else if (platformLower.contains('teams')) {
      return Colors.purple;
    } else if (platformLower.contains('file upload')) {
      return Colors.orange;
    } else {
      return Colors.blue; // Default Chang Meeting color
    }
  }
}