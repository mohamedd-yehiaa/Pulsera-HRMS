<div align="center">

# Pulsera
**A Flutter-Based Human Resource Management System**

![License](https://img.shields.io/badge/License-MIT-blue.svg)

[![Flutter Build](https://github.com/Mohamed-Yehiaaa/pulsera/actions/workflows/flutter-build.yml/badge.svg)](https://github.comMohamed-Yehiaaa/pulsera/actions/workflows/flutter-build.yml)

![Version](https://img.shields.io/badge/version-1.0.0-success)

<img width="1720" height="1080" alt="PULSERA UI" src="https://github.com/user-attachments/assets/d778526c-cda8-41a4-b130-77facf123e56" />

</div>

## 📖 Table of Contents
- [About The Project](#about-the-project)
- [Key Features](#key-features)
- [App Interface](#app-interface)
- [System Architecture](#system-architecture)
- [Built With](#built-with)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation & Backend Setup](#installation--backend-setup)
- [Usage](#usage)
- [Contact & Acknowledgments](#contact--acknowledgments)

---

<a id="about-the-project"></a>
## 🎯 About The Project

Small and Medium-sized Enterprises often struggle with traditional HR management processes. Manual calculations, paper-based leave requests, and disjointed attendance tracking create significant data silos, increasing the risk of computation errors and operational bottlenecks. 

**Pulsera** is a cross-platform mobile application engineered to solve these exact problems. Designed to replace slow, error-prone manual workflows, Pulsera provides a single, unified platform for both employees and managers. It empowers organizations to handle essential HR tasks quickly, transparently, and efficiently, right from their mobile devices or desktops. By centralizing attendance, leave management, and automated payroll, Pulsera ensures accurate data management and significantly reduces administrative overhead.

---

<a id="key-features"></a>
## ✨ Key Features

* **👥 Employee Management:** Seamlessly add, update, and delete employee profiles. Enforce robust access control by assigning system roles such as Admin, Manager, and Employee.
* **⏱️ Cryptographic Attendance Management:** Eliminates "buddy punching" and location spoofing using a custom Time-Based One-Time Password (TOTP) algorithm. Employees scan a dynamic, offline-capable QR code at a physical kiosk that refreshes every 5 seconds.
* **🏖️ Leave Management:** A streamlined workflow allows employees to apply for annual, sick, or emergency leave smoothly. Managers can instantly review, approve, or reject requests while the system automatically tracks remaining leave balances.
* **💰 Automated Payroll Engine:** Dynamically converts base salaries into exact hourly rates based on logged attendance. It automatically calculates overtime bonuses, enforces lateness deductions, and generates clear, itemized payslips
* **🔒 Security:** Enterprise-grade security featuring secure user authentication, role-based access control (RBAC), and fully encrypted communication between the application client and the database.

---

<a id="app-interface"></a>
## 📸 App Interface

<table align="center">
  <tr>
    <th align="center">Attendance Verification</th>
    <th align="center">Leave Management</th>
    <th align="center">Automated Payroll</th>
  </tr>
  <tr>
    <td align="center" valign="middle">
      <img src="https://github.com/user-attachments/assets/b7f7689f-6ff5-4c9a-b966-5f62b6739657" alt="Attendance Verification UI" width="380"/>
    </td>
    <td align="center" valign="middle">
      <img src="https://github.com/user-attachments/assets/9ffe2e19-7e33-46fc-ae94-930ed594102b" alt="Leave Management UI" width="380"/>
    </td>
    <td align="center" valign="middle">
      <img src="https://github.com/user-attachments/assets/1db04b3e-dc7f-4fc1-a117-ec543892196b" alt="Automated Payroll UI" width="195"/>
    </td>
  </tr>
</table>

---

<a id="system-architecture"></a>
## 🏗️ System Architecture

*Cross-platform deployment supporting iOS, Android, and Desktop environments.*

### Diagrams
* **Use Case Diagram:**

  <img width="700" height="500" alt="useCase Diagram" src="https://github.com/user-attachments/assets/4e668a22-d802-4a0d-a76b-35f94b7e2d2f" />

* **Activity Diagram:**

  <img width="700" height="500" alt="Activity Diagram" src="https://github.com/user-attachments/assets/13b1e1ee-ee05-49e0-8e8b-5c74180115fe" />

* **Sequence Diagram:**

    <img width="700" height="500" alt="Sequence Diagram" src="https://github.com/user-attachments/assets/035dae9c-782b-4819-a6b1-224f26ed8e43" />

* **Class Diagram:**

    <img width="700" height="500" alt="Class Diagram" src="https://github.com/user-attachments/assets/4f765ca8-b164-44d4-999c-274b4d8e72c7" />
    
---

<a id="built-with"></a>
## 🛠️ Built With

* **Frontend:** Google Flutter framework (Dart) 
* **Architecture:** Clean Architecture & Repository Pattern
* **State Management:** Bloc / Cubit Pattern
* **Backend & Storage:** Firebase (Firestore, Authentication) & Supabase

---

<a id="getting-started"></a>
## 🚀 Getting Started

Follow these simple instructions to set up your local development environment and get Pulsera up and running.

<a id="prerequisites"></a>
### Prerequisites

Ensure you have the following installed on your local machine:
* **Flutter SDK:** The latest stable release of the Flutter development kit.
* **IDE:** Android Studio, Xcode, or Visual Studio Code configured with the Flutter and Dart plugins.
* **Connected Device:** An active emulator, simulator, or a physical device connected via USB/Wi-Fi to deploy the application.

<a id="installation--backend-setup"></a>
### Installation & Backend Setup

For security purposes, this repository does not include the backend API keys or native configuration files. You must link the project to your own Firebase and Supabase instances.

1. **Clone the repository:**
   ```bash
   git clone https://github.com/mohamedd-yehiaa/Pulsera-HRMS.git
2. **Navigate to the project directory:**
   ```bash
   cd pulsera
3. **Install dependencies:** Fetch all required Dart packages and plugins.
   ```bash
   flutter pub get
4. **Configure Firebase:** Create a project in your Firebase Console, install the FlutterFire CLI, and run the configuration command to generate your native keys:
   ```bash
   flutterfire configure
5. **Configure Environment Variables:** Create a new file named `.env` in the root directory of the project (this file is gitignored) and add your external configurations:
   ```env
   SERVER_CLIENT_ID=YOUR_SERVER_CLIENT_ID
   SUPABASE_URL=YOUR_SUPABASE_URL
   SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY
6. **Run the application:** Launch the app on your connected device or emulator.
   ```bash
   flutter run
   
<a id="usage"></a>
## 💡 Usage
Employee Workflow Example:

Open the Pulsera app and log in using your credentials.
Navigate to the Attendance tab to Check-In at the start of your shift.
Access the Leave section to request upcoming time off, selecting the appropriate leave category.
Check-Out at the end of the day.
Manager Workflow Example:

Log in with Manager credentials.
Review pending leave requests from your team on the Dashboard.
Generate the monthly Payroll Summary to automatically calculate wages based on the month's verified attendance logs.

<a id="contact--acknowledgments"></a>
## 📬 Contact & Acknowledgments
Developer: Mohamed Yehia Ali
(Student ID: 22511402)
Information Technology and Computing Department, Arab Open University - Egypt.

*Pulsera was entirely developed as a solo graduation project.*

### Dedication & Acknowledgments

**To my Mother:** This work is dedicated to my mother, whom I will always love. Although she is not here to see it, her spirit and belief in me were my motivation. I hope I made her proud, as her memory is in every late night and every line of code.

**Acknowledgments:**
* **Dr. Ramadan Babers:** For his invaluable mentorship, guidance, and supervision throughout the development of this project.
* **My Maternal Aunt:** For her unwavering support and deep belief in my academic journey.
* **My Sister:** For her constant encouragement and motivation to help me achieve my goals.
