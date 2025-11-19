📚 Clustrr – Centralized Academic Collaboration Platform

A modern Flutter-based mobile application built for students, Class Representatives (CRs), and teachers to manage academic communication, materials, and collaboration in a unified platform.

---

🚀 Features

👨‍🎓 Student Module

- View announcements and updates
- Access subject-wise study materials
- Receive messages and notifications
- Join batch-wise discussions

🧑‍🏫 Teacher Module

- Upload study materials (PDFs, PPTs, Docs)
- Class announcements & updates
- Manage batches and content

👨‍🏫 Class Representative (CR) Module

- Share updates with students
- Upload materials
- Coordinate between teachers and students

---

🔥 Technology Stack

Frontend (Mobile App)

- Flutter 3.x
- Dart
- Material Design 3 (Dark Theme + Neon Accents)

Backend & Services

- Firebase Authentication
- Firebase Firestore (Database)
- Firebase Storage (Materials Uploads)
- Firebase Cloud Messaging (Notifications)
- WebRTC (For real-time communication module)

---

 🗂 Project Folder Structure
lib/
├── main.dart
├── firebase_options.dart
├── screens/
│ ├── login_screen.dart
│ ├── signup_screen.dart
│ ├── student_home.dart
│ ├── cr_home.dart
│ ├── teacher_home.dart
│ ├── chat/
│ ├── materials/
│ └── notifications/
├── widgets/
├── models/
├── services/
assets/
├── images/
├── icons/
android/
ios/


---

🔐 Firebase Configuration

Clustrr uses the following Firebase services:

- Firebase Authentication  
- Cloud Firestore  
- Firebase Storage  
- Firebase Cloud Messaging  
- Firebase Core  

To configure Firebase:

1. Create a project at: https://console.firebase.google.com  
2. Add an Android app and download the `google-services.json`  
3. Place it under:  


android/app/google-services.json

4. Enable Email/Password Authentication  
5. Create `users` collection with fields:
- `uid`
- `name`
- `email`
- `role` → Student / CR / Teacher  
- `batchId`
- `createdAt`

---

🛠️ Setup Instructions

1. Clone the repo
```bash
git clone https://github.com/yourusername/clustrr.git
cd clustrr

2. Install dependencies
flutter pub get

3. Run the app
flutter run

4. Build release APK
flutter build apk --release

📸 Screenshots 
login
<img width="640" height="1128" alt="localhost_56953_" src="https://github.com/user-attachments/assets/b81a8166-433f-4966-88ca-fdc55f66b36c" />
Registrations
<img width="640" height="1128" alt="localhost_56953_ (1)" src="https://github.com/user-attachments/assets/5853b22e-783a-4b41-9ddc-52ae6e41aef1" />
Student dashboard
<img width="640" height="1128" alt="localhost_56953_ (2)" src="https://github.com/user-attachments/assets/2026207d-07c4-4756-b350-b2071f6174c8" />
Teacher dashboard
<img width="640" height="1128" alt="localhost_56953_ (3)" src="https://github.com/user-attachments/assets/86ed791d-f5af-42df-adb7-2f9d26113a47" />
CR dashboard
<img width="640" height="1128" alt="localhost_56953_ (4)" src="https://github.com/user-attachments/assets/9ecba749-c1f9-4287-8472-ca2f11ce8fb7" />

🤝 Contributors

Mishal KS
Hashir Muhammed
Faheem K
MCA – Jain University

📜 License
This project is for educational & portfolio purposes. All rights reserved.
