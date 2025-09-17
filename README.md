# Chela

**Chela** is a next-generation, AI-powered productivity tool designed to be the ultimate academic strategist for college students. It moves beyond simple calendars and to-do lists, providing an intelligent, dynamic, and persistent dashboard to help students manage their complex academic and personal lives.

![Status](https://img.shields.io/badge/status-in%20development-blue)

---
## 🚀 About The Project

In the fast-paced, high-pressure environment of college, students are often overwhelmed by a chaotic mix of classes, assignments, competitive contests, personal projects, and hobbies. Standard productivity tools fail to provide a holistic and intelligent overview.

**Chela** solves this by acting as a personal AI guide (`Chela` means 'disciple'). It unifies a student's entire schedule and uses data-driven insights to help them stay focused, track progress, and achieve their academic goals without burning out.



---
## ✨ Key Features

* **Live, Data-Rich Dashboard:** A premium, interactive UI that provides an at-a-glance overview of your day, including progress rings, key stats, and a weekly performance graph.
* **Intelligent Timeline:** Automatically groups your schedule into `MORNING`, `AFTERNOON`, and `EVENING` for clarity.
* **Full Persistence:** A full-stack architecture ensures all your data (users, tasks, schedule) is permanently saved to a cloud database.
* **Secure Authentication:** Users can create secure accounts using Firebase Authentication.
* **Interactive UI:** Satisfying, gesture-driven interactions like "swipe-to-complete" make managing your schedule a delight.

---
## 🛠️ Tech Stack

This project is a full-stack application built with a modern, production-ready tech stack.

### Frontend (Mobile & Web)
* **[Flutter](https://flutter.dev/):** For building a beautiful, high-performance, cross-platform UI from a single codebase.
* **[Riverpod](https://riverpod.dev/):** For robust and scalable state management.
* **[fl_chart](https://pub.dev/packages/fl_chart):** For creating beautiful and interactive graphs.

### Backend
* **[Python](https://www.python.org/):** For the core backend logic and future AI/ML integrations.
* **[FastAPI](https://fastapi.tiangolo.com/):** A high-performance, modern Python framework for building APIs.
* **[Firebase](https://firebase.google.com/):** Used for both secure user **Authentication** and the **Firestore** NoSQL database.

---
## ⚙️ Getting Started

To get a local copy up and running, follow these simple steps.

### Prerequisites
* Flutter SDK installed.
* Python 3.9+ installed.
* A Firebase project created with a `serviceAccountKey.json`.
* Your local machine's IP address.

### Installation

1.  **Clone the repo:**
    ```bash
    git clone [https://github.com/raoamogh/chela.git](https://github.com/raoamogh/chela.git)
    ```
2.  **Backend Setup:**
    ```bash
    cd chela/backend
    python -m venv venv
    source venv/bin/activate  # On Windows, use `venv\Scripts\activate`
    pip install -r requirements.txt # You can create this file with `pip freeze > requirements.txt`
    # Place your serviceAccountKey.json in this folder
    uvicorn main:app --reload --host 0.0.0.0
    ```
3.  **Frontend Setup:**
    ```bash
    cd ../frontend
    flutter pub get
    # Update the _baseUrl in lib/api/api_service.dart with your computer's IP
    flutter run
    ```

---
## 🗺️ Roadmap

The core MVP is complete. Future development will focus on the AI features:
- [ ] **The Smart Scheduler:** AI-generated daily plans.
- [ ] **Persistent Task Management:** Full CRUD for tasks in the database.
- [ ] **AI "Brain Dump":** NLP to categorize and link quick notes.
- [ ] **Burnout Protector:** AI monitoring of cognitive load.

---
## 👤 Author

**Amogh Rao**
* GitHub: [@raoamogh](https://github.com/raoamogh)
* LinkedIn: [Amogh Rao](https://linkedin.com/in/raoamogha)

Feel free to reach out with any questions or suggestions!
