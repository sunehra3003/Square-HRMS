
---

#  Square HRMS

A cross-platform mobile Human Resource Management System developed during an industrial attachment at Square InformatiX Limited. Built with Flutter and Supabase, the app automates employee leave management and attendance tracking, replacing manual email-based processes and physical punch-in terminals.

---

##  Features

### Employee
- View personal dashboard with attendance summary and leave balance
- Submit leave applications with file attachments
- Track leave history with filtering by type, status, and month
- Punch in and out using biometric fingerprint authentication
- View monthly attendance calendar with color-coded status dots

###  Authentication
- Email and password based login
- OTP email verification for new account registration
- Secure session management through Supabase Auth

###  Automated HR Statistics
- Leave balance automatically updated through PostgreSQL trigger functions
- Attendance summary automatically recalculated on every punch in and out
- Absent marking automated through pg_cron scheduled jobs after shift end

---

##  Tech Stack

| Technology | Purpose |
|------------|---------|
| Flutter & Dart | Cross-platform mobile frontend |
| Riverpod | State management |
| Supabase | Backend, database, authentication, file storage |
| PostgreSQL | Relational database with trigger functions |
| pg_cron | Scheduled jobs for automated absent marking |

---

## Flutter Packages

| Package | Purpose |
|---------|---------|
| `supabase_flutter` | Supabase API communication |
| `flutter_riverpod` | State management |
| `geolocator` | GPS location verification |
| `local_auth` | Biometric fingerprint authentication |
| `device_info_plus` | Device ID binding |
| `image_picker` | File selection for leave attachments |

---

## Database Schema

The system uses 9 interconnected PostgreSQL tables:

| Table | Purpose |
|-------|---------|
| `employees` | Employee profiles with self-referencing supervisor |
| `leave_type` | Master table for leave categories |
| `leave_applications` | All leave requests and their status |
| `leave_stats` | Leave balance and usage per employee |
| `attendance_group_master` | Shift group definitions |
| `attendance_group_detail` | Employee to shift group mapping |
| `attendance_location` | Authorized office locations for GPS check |
| `attendance_records` | Daily punch in and punch out records |
| `attendance_summary` | Monthly attendance statistics |

---

##  Attendance Security

Attendance recording is protected by two layers of security:

1. **Biometric Authentication** — Employee must authenticate using their registered fingerprint or face ID via `local_auth` before any attendance action is processed
2. **GPS Location Verification** — Employee must be physically within the authorized office radius before punch in is allowed, verified using `geolocator`

---

##  Getting Started

1. Clone the repository:
```bash
git clone https://github.com/yourusername/square-hrms.git
cd square-hrms
```

2. Install dependencies:
```bash
flutter pub get
```

3. Create a Supabase project at [supabase.com](https://supabase.com) and set up the database schema

4. Add your Supabase credentials in `lib/providers/`:
```dart
final supabase = Supabase.instance.client;
```

5. Initialize Supabase in `main.dart`:
```dart
await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL',
  anonKey: 'YOUR_SUPABASE_ANON_KEY',
);
```

6. Run the app:
```bash
flutter run
```

---

##  Requirements

- Flutter SDK 3.x or higher
- Android SDK 36
- Supabase account
- Android device with biometric authentication enabled

---

##  Developer

| Name | Role |
|------|------|
| Sunehra Tabassum | Flutter Developer Intern |

Developed during industrial attachment at **Square InformatiX Limited**
April 2026 – June 2026

---



---

