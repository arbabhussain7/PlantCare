import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plantcare/constant/colors.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<NotificationItem> notifications = [
    NotificationItem(
      id: '1',
      title: 'Time to Water!',
      message: 'Your Monstera Deliciosa needs watering',
      type: NotificationType.watering,
      time: '2 minutes ago',
      isRead: false,
      plantName: 'Monstera Deliciosa',
    ),
    NotificationItem(
      id: '2',
      title: 'Fertilizer Reminder',
      message: 'Snake Plant is ready for monthly fertilizing',
      type: NotificationType.fertilizer,
      time: '1 hour ago',
      isRead: false,
      plantName: 'Snake Plant',
    ),
    NotificationItem(
      id: '3',
      title: 'Sunlight Alert',
      message: 'Move your Peace Lily to a brighter spot',
      type: NotificationType.sunlight,
      time: '3 hours ago',
      isRead: true,
      plantName: 'Peace Lily',
    ),
    NotificationItem(
      id: '4',
      title: 'Repotting Time',
      message: 'Your Fiddle Leaf Fig has outgrown its pot',
      type: NotificationType.repotting,
      time: '1 day ago',
      isRead: true,
      plantName: 'Fiddle Leaf Fig',
    ),
    NotificationItem(
      id: '5',
      title: 'Daily Care Tip',
      message: 'Wipe leaves with damp cloth for better photosynthesis',
      type: NotificationType.tip,
      time: '2 days ago',
      isRead: true,
      plantName: null,
    ),
    NotificationItem(
      id: '6',
      title: 'Pest Alert',
      message: 'Check your Spider Plant for spider mites',
      type: NotificationType.pest,
      time: '3 days ago',
      isRead: true,
      plantName: 'Spider Plant',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final unreadCount = notifications.where((n) => !n.isRead).length;
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
       centerTitle: true,
        title: Text(
          'Notifications',
          style: GoogleFonts.leagueSpartan(
            fontSize: 24.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: Text(
                'Mark all read',
                style: GoogleFonts.leagueSpartan(
                  fontSize: 14.sp,
                  color: greenColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          SizedBox(width: 8.w),
        ],
      ),
      body: notifications.isEmpty
          ? _buildEmptyState()
          : Column(
              children: [
                if (unreadCount > 0) _buildUnreadHeader(unreadCount),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      return _buildNotificationCard(notifications[index], index);
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildUnreadHeader(int count) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: greenColor.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(color: greenColor.withOpacity(0.2)),
        ),
      ),
      child: Text(
        '$count unread notification${count > 1 ? 's' : ''}',
        style: GoogleFonts.leagueSpartan(
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
          color: greenColor,
        ),
      ),
    );
  }

  Widget _buildNotificationCard(NotificationItem notification, int index) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12.r),
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.w),
        child: Icon(
          Icons.delete_outline,
          color: Colors.white,
          size: 24.sp,
        ),
      ),
      onDismissed: (direction) {
        _removeNotification(index);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: notification.isRead 
              ? null 
              : Border.all(color: greenColor.withOpacity(0.3), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: InkWell(
          onTap: () => _markAsRead(notification.id),
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildNotificationIcon(notification.type),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: GoogleFonts.leagueSpartan(
                                fontSize: 16.sp,
                                fontWeight: notification.isRead 
                                    ? FontWeight.w500 
                                    : FontWeight.w600,
                                color: notification.isRead 
                                    ? Colors.grey[700] 
                                    : Colors.grey[900],
                              ),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8.w,
                              height: 8.h,
                              decoration: BoxDecoration(
                                color: greenColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        notification.message,
                        style: GoogleFonts.leagueSpartan(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      if (notification.plantName != null) ...[
                        SizedBox(height: 8.h),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: greenColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            notification.plantName!,
                            style: GoogleFonts.leagueSpartan(
                              fontSize: 12.sp,
                              color: greenColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                      SizedBox(height: 8.h),
                      Text(
                        notification.time,
                        style: GoogleFonts.leagueSpartan(
                          fontSize: 12.sp,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(NotificationType type) {
    IconData iconData;
    Color iconColor;

    switch (type) {
      case NotificationType.watering:
        iconData = Icons.water_drop;
        iconColor = Colors.blue;
        break;
      case NotificationType.fertilizer:
        iconData = Icons.scatter_plot;
        iconColor = Colors.orange;
        break;
      case NotificationType.sunlight:
        iconData = Icons.wb_sunny;
        iconColor = Colors.yellow[700]!;
        break;
      case NotificationType.repotting:
        iconData = Icons.home_work;
        iconColor = Colors.brown;
        break;
      case NotificationType.tip:
        iconData = Icons.lightbulb_outline;
        iconColor = greenColor;
        break;
      case NotificationType.pest:
        iconData = Icons.bug_report;
        iconColor = Colors.red;
        break;
    }

    return Container(
      width: 40.w,
      height: 40.h,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 20.sp,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80.sp,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16.h),
          Text(
            'No notifications yet',
            style: GoogleFonts.leagueSpartan(
              fontSize: 20.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'We\'ll notify you about your plants\' care needs',
            style: GoogleFonts.leagueSpartan(
              fontSize: 14.sp,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _markAsRead(String notificationId) {
    setState(() {
      final index = notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        notifications[index] = notifications[index].copyWith(isRead: true);
      }
    });
  }

  void _markAllAsRead() {
    setState(() {
      notifications = notifications.map((n) => n.copyWith(isRead: true)).toList();
    });
  }

  void _removeNotification(int index) {
    setState(() {
      notifications.removeAt(index);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Notification deleted',
          style: GoogleFonts.leagueSpartan(),
        ),
        backgroundColor: Colors.grey[800],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
      ),
    );
  }
}

enum NotificationType {
  watering,
  fertilizer,
  sunlight,
  repotting,
  tip,
  pest,
}

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final String time;
  final bool isRead;
  final String? plantName;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.time,
    required this.isRead,
    this.plantName,
  });

  NotificationItem copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    String? time,
    bool? isRead,
    String? plantName,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      time: time ?? this.time,
      isRead: isRead ?? this.isRead,
      plantName: plantName ?? this.plantName,
    );
  }
}