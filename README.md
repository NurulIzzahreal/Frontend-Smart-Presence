# Smart Presence - Absensi Cerdas

A Flutter mobile application for smart attendance management with AI-powered face recognition for student identification.

## Features

### 1. Authentication & Authorization
- **Teacher/Admin Login**: Email and password authentication
- **Student Login**: 
  - Direct login with Student ID
  - OTP-based login for enhanced security
- **Role-based Access Control**: 
  - Admin: Full system access
  - Teacher: Class and student management, attendance tracking
  - Student: Personal attendance viewing, face recognition

### 2. Student & Class Management
- **Student Management**:
  - Create, read, update, and delete student records
  - CSV import functionality for bulk student data upload
  - Face enrollment for attendance recognition
- **Class Management**:
  - Create, read, update, and delete class records
  - Schedule management

### 3. AI-Powered Face Recognition Attendance
- **Face Enrollment**: 
  - Initial face registration for each student
  - Multi-angle capture for better recognition accuracy
- **Attendance Marking**:
  - Real-time face recognition via mobile camera
  - Confidence scoring for attendance verification
  - Manual attendance backup option for teachers

### 4. Attendance Tracking
- **Student View**:
  - Attendance history with date, status, and confidence scores
  - Visual indicators for present/late/absent status
- **Teacher View**:
  - Class-wise attendance tracking
  - Manual attendance marking interface
  - Attendance reports generation (planned)

## Technology Stack

- **Frontend**: Flutter with Dart
- **Backend**: Python (separate repository)
- **API Communication**: HTTP REST API
- **Data Storage**: Shared Preferences for local caching
- **Camera Integration**: Flutter camera plugin
- **File Handling**: File picker for CSV imports

## Setup Instructions

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Ensure the Python backend is running on `http://localhost:8000`
4. Run the app using `flutter run`

## Dependencies

- `http`: For API communication
- `shared_preferences`: For local data storage
- `camera`: For face recognition functionality
- `image_picker`: For image handling
- `file_picker`: For CSV import functionality
- `permission_handler`: For camera and storage permissions

## Project Structure

```
lib/
├── models/              # Data models (User, Student, Class, Attendance)
├── screens/             # UI screens organized by user role
│   ├── admin/           # Admin-specific screens
│   ├── auth/            # Authentication screens
│   ├── student/         # Student-specific screens
│   └── teacher/         # Teacher-specific screens
├── services/            # Business logic and API integration
├── utils/               # Utility functions and helpers
└── main.dart            # Entry point
```

## API Integration

The app communicates with a Python backend via REST APIs. All endpoints are configured to work with `http://localhost:8000/api` by default.

## Future Enhancements

- Attendance reports generation
- Push notifications for attendance reminders
- Offline mode with sync capability
- Enhanced analytics and insights
- Multi-language support

## Contributing

This project is developed as part of a learning exercise. Contributions are welcome for educational purposes.

## License

This project is open-source for educational purposes.