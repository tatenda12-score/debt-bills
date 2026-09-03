# Financial Reminder App

## 1. Overview
The Financial Reminder App is a comprehensive solution for tracking financial obligations, including money owed, debts, bills, and subscriptions. This project is structured as a full-stack application with a Python FastAPI backend and a cross-platform Flutter mobile application.

## 2. Backend Technology Stack
- **Framework**: Python 3.12+ with FastAPI
- **Database**: PostgreSQL (managed via SQLAlchemy ORM and Alembic migrations)
- **Authentication**: JWT (JSON Web Tokens) with Passlib & bcrypt
- **Validation**: Pydantic

## 3. Flutter Technology Stack
- **Framework**: Flutter 3+ (Dart 3+)
- **State Management**: Provider
- **Routing**: GoRouter
- **Networking**: Dio
- **Security**: Flutter Secure Storage (for JWT tokens)

## 4. Repository Structure
The repository contains both the backend service and the Flutter mobile application:
```text
financial-reminder-app/
├── backend/            # FastAPI Backend application
│   ├── app/            # Main application code (routes, models, schemas)
│   ├── alembic/        # Database migrations
│   ├── tests/          # Pytest automated test suite
│   ├── .env.example    # Environment variable placeholders
│   └── requirements.txt# Python dependencies
│
├── flutter_app/        # Flutter Mobile Application
│   ├── lib/            # Main Dart application code
│   ├── test/           # Flutter widget & integration tests
│   ├── pubspec.yaml    # Flutter dependencies
│   └── android/ & ios/ # Native platform projects
│
└── README.md           # This documentation
```

## 5. How to run the FastAPI backend locally
1. Navigate to the backend directory:
   ```bash
   cd backend
   ```
2. Create and activate a virtual environment:
   ```bash
   python -m venv venv
   # Windows
   .\venv\Scripts\activate
   # macOS/Linux
   source venv/bin/activate
   ```
3. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```
4. Copy the environment file and configure local values (or use default SQLite):
   ```bash
   cp .env.example .env
   ```
5. Apply database migrations:
   ```bash
   alembic upgrade head
   ```
6. Run the local development server:
   ```bash
   uvicorn app.main:app --reload --host 127.0.0.1 --port 8000
   ```

## 6. How to run the Flutter application locally
1. Ensure the backend is running locally.
2. Navigate to the Flutter directory:
   ```bash
   cd flutter_app
   ```
3. Fetch dependencies:
   ```bash
   flutter pub get
   ```
4. Run the application on an emulator or connected device:
   ```bash
   flutter run
   ```

## 7. API Communication
The Flutter application communicates with the FastAPI backend over standard HTTP REST calls. 
By default, the Flutter application is configured to connect to `http://127.0.0.1:8000` (configurable via `--dart-define=API_BASE_URL=...`). All authenticated routes require the JWT token to be passed in the `Authorization: Bearer <token>` header, which is managed securely by the internal `ApiClient` interceptor.

## 8. Render Deployment (Backend only)
**Important**: The `backend/` directory is designed to be deployed as a **Render Web Service**. 
- Configure Render's Root Directory setting to `backend`.
- The Web Service will execute `uvicorn app.main:app --host 0.0.0.0 --port $PORT`.

## 9. PostgreSQL Hosting
The production PostgreSQL database will be hosted separately on Render as a **Render PostgreSQL Database**. Provide the connection string to the Web Service via the `DATABASE_URL` environment variable.

## 10. Mobile App Deployment
The Flutter mobile application (`flutter_app/`) is **NOT** deployed to Render. The mobile application will be compiled into an Android APK / iOS IPA and distributed via app stores or directly to users.
