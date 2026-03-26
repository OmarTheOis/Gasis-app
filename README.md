# 🚀 Gas Service App

A complete Flutter application for managing gas services, emergency reports, billing, and technician workflows.

The app supports two roles:
- 👤 Customer
- 🛠 Technician

---

## 📱 Screenshots

---

### 🚀 Onboarding
![Onboarding](assets/readme_pics/onboarding.png)

---

### 🔐 Authentication

#### Login
![Login](assets/readme_pics/login.png)

#### Register
![Register](assets/readme_pics/register.png)

---

# 👤 Customer App

---

### 🏠 Home Dashboard
![Home](assets/readme_pics/customer_home.png)

---

### 👤 Profile & Settings

#### Profile
![Profile](assets/readme_pics/profile.png)

#### Notifications (UI only)
![Notifications](assets/readme_pics/notifications.png)

---

### 💡 Meter Reading
#### reads the numbers from the pics
![Meter Reading](assets/readme_pics/meter_reading.png)

---

### 💳 Billing

#### Pay Bill
![Pay Bill](assets/readme_pics/pay_bill.png)

#### Bill History
![Bill History](assets/readme_pics/bill_history.png)

#### Payment Success
![Payment Success](assets/readme_pics/payment_success.png)

---

### 🛠 Service Requests

#### Request Service
![Request Service](assets/readme_pics/request_service.png)

#### Pick Location (Google Maps)
![Map Picker](assets/readme_pics/map_picker.png)

#### Service Status
![Service Status](assets/readme_pics/service_status.png)

---

### 🚨 Emergency

#### Emergency Report
![Emergency](assets/readme_pics/emergency.png)

---

### 📋 Requests List
![My Requests](assets/readme_pics/my_requests.png)

---

# 🛠 Technician App

---

### 🏠 Dashboard
![Technician Dashboard](assets/readme_pics/tech_dashboard.png)

---

### 📄 Request Details (Pending)
![Pending](assets/readme_pics/tech_pending.png)

---

### 🔄 Request In Progress
![In Progress](assets/readme_pics/tech_in_progress.png)

---

### ✅ Request Completed
![Completed](assets/readme_pics/tech_completed.png)

---

## ✨ Features

- 🔐 Authentication with role-based access (Customer / Technician)
- 🚫 Prevent login to wrong portal
- 🛠 Create service requests with map location
- 🚨 Emergency reporting with GPS location
- 📍 Google Maps integration (customer + technician)
- 📊 Submit gas meter readings
- 💳 Pay bills and view history
- 📋 Track requests with real-time updates
- 🧑‍🔧 Technician job management (Accept / Complete)
- 🌐 Full Arabic & English localization
- 💾 Persistent language (saved across app restarts)
- ⚡ Real-time updates using Firebase Firestore
- 🧠 State management using Cubit (Bloc)

---

## 🏗 Architecture
