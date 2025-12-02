import 'package:frontend_smart_presence/services/notification_service.dart';

class ParentNotificationService {
  final NotificationService _notificationService = NotificationService();

  // Send absence notification to parent
  Future<void> sendAbsenceNotification({
    required String parentName,
    required String studentName,
    required DateTime absenceDate,
    String? contactEmail,
    String? contactPhone,
  }) async {
    try {
      // Send mobile notification
      await _notificationService.sendParentAbsenceNotification(
        parentName,
        studentName,
        absenceDate,
      );

      // In a real implementation, you would also send email/SMS here
      // For example:
      // if (contactEmail != null) {
      //   await _sendEmailNotification(contactEmail, studentName, absenceDate);
      // }
      //
      // if (contactPhone != null) {
      //   await _sendSMSNotification(contactPhone, studentName, absenceDate);
      // }

      print('Parent notification sent successfully');
    } catch (e) {
      print('Error sending parent notification: $e');
    }
  }

  // Send lateness notification to parent
  Future<void> sendLatenessNotification({
    required String parentName,
    required String studentName,
    required DateTime latenessDate,
    required String latenessTime,
  }) async {
    try {
      // Send mobile notification
      await _notificationService.sendSystemNotification(
        'Student Lateness Notification',
        'Dear $parentName,\nYour child $studentName was late on ${_formatDate(latenessDate)} at $latenessTime.',
      );

      print('Parent lateness notification sent successfully');
    } catch (e) {
      print('Error sending parent lateness notification: $e');
    }
  }

  // Send academic performance notification to parent
  Future<void> sendAcademicNotification({
    required String parentName,
    required String studentName,
    required String subject,
    required String performance,
  }) async {
    try {
      // Send mobile notification
      await _notificationService.sendSystemNotification(
        'Student Academic Performance',
        'Dear $parentName,\nYour child $studentName has $performance in $subject.',
      );

      print('Parent academic notification sent successfully');
    } catch (e) {
      print('Error sending parent academic notification: $e');
    }
  }

  // Send general notification to parent
  Future<void> sendGeneralNotification({
    required String parentName,
    required String studentName,
    required String message,
  }) async {
    try {
      // Send mobile notification
      await _notificationService.sendSystemNotification(
        'School Notification',
        'Dear $parentName,\n$message\nStudent: $studentName',
      );

      print('Parent general notification sent successfully');
    } catch (e) {
      print('Error sending parent general notification: $e');
    }
  }

  // Format date for display
  static String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // In a real implementation, you would add email and SMS sending methods here
  /*
  Future<void> _sendEmailNotification(
    String emailAddress,
    String studentName,
    DateTime absenceDate,
  ) async {
    // Implementation for sending email
    // This would typically involve calling an email API
  }

  Future<void> _sendSMSNotification(
    String phoneNumber,
    String studentName,
    DateTime absenceDate,
  ) async {
    // Implementation for sending SMS
    // This would typically involve calling an SMS API
  }
  */
}
