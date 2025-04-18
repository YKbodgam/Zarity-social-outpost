import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/theme/app_theme.dart';

class StoryCircle extends StatelessWidget {
  final String imageUrl;
  final String username;
  final bool isViewed;
  final VoidCallback onTap;

  const StoryCircle({
    Key? key,
    required this.imageUrl,
    required this.username,
    this.isViewed = false,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient:
                  isViewed
                      ? null
                      : LinearGradient(
                        colors: [
                          Color(0xFFFF5722),
                          Color(0xFFFF8A65),
                          Color(0xFFFFA726),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
              border:
                  isViewed
                      ? Border.all(
                        color: Colors.grey.withOpacity(0.5),
                        width: 2,
                      )
                      : null,
            ),
            padding: EdgeInsets.all(3),
            child: CircleAvatar(
              radius: 32,
              backgroundColor: Colors.grey[300],
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                  placeholder:
                      (context, url) => Container(
                        color: Colors.grey[300],
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.primaryColor,
                            ),
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                  errorWidget:
                      (context, url, error) =>
                          Icon(Icons.person, size: 32, color: Colors.grey[600]),
                ),
              ),
            ),
          ),
          SizedBox(height: 4),
          Text(
            username,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
