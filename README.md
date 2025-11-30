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

### 4. Liveness Detection (Anti-spoofing)
- **Eye Blink Detection**: Students must blink to prove they are live
- **Head Movement Challenges**: 
  - Turn head left/right challenges
  - Smile detection
- **Multi-frame Verification**: Multiple frame analysis to prevent photo/video spoofing

### 5. Geofencing & Location Verification
- **Location-based Attendance**: 
  - GPS verification to ensure students are at the correct location
  - Configurable radius for attendance zones
- **Location Tracking**: 
  - Address resolution for attendance locations
  - Location history for verification

### 6. Attendance Reports & Analytics
- **Comprehensive Reporting**:
  - Daily/weekly/monthly attendance summaries
  - Individual student attendance tracking
  - Class-wise attendance analytics
- **Export Functionality**:
  - CSV export for spreadsheet analysis
  - PDF reports for formal documentation
- **Statistics Dashboard**:
  - Attendance rates and trends
  - Confidence score analysis
  - Present/late/absent breakdowns

## Technology Stack

- **Frontend**: Flutter with Dart
- **Backend**: Python (separate repository)
- **API Communication**: HTTP REST API
- **Data Storage**: Shared Preferences for local caching
- **Camera Integration**: Flutter camera plugin
- **Image Processing**: Image picker for file handling
- **File Handling**: File picker for CSV imports
- **PDF Generation**: PDF package for report generation
- **Geolocation**: Geolocator and Geocoding packages
- **Permissions**: Permission handler for camera, location, and storage

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
- `pdf`: For PDF report generation
- `printing`: For PDF sharing functionality
- `geolocator`: For location services
- `geocoding`: For address resolution

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

## Security Features

- **Liveness Detection**: Prevents spoofing through photo/video attacks
- **Geofencing**: Ensures attendance is marked from authorized locations
- **OTP Authentication**: Secure login for students
- **Role-based Access**: Controlled access based on user roles

## Future Enhancements

- Push notifications for attendance reminders
- Offline mode with sync capability
- Enhanced analytics and insights
- Multi-language support
- Integration with school management systems

## Contributing

This project is developed as part of a learning exercise. Contributions are welcome for educational purposes.

## License

This project is open-source for educational purposes.