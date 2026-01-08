# Personal Expense Tracker

A full-stack personal finance application built with Flutter (Frontend) and Node.js + MongoDB (Backend).

## Features
- **Dashboard**: Smart balance calculation, spending trends, and category breakdown.
- **Expenses**: Add, edit, delete expenses with recurrence support.
- **Income**: Track multiple income sources.
- **Upcoming Payments**: Manage future financial obligations.
- **Categories**: Custom and default category management.

## Tech Stack
- **Frontend**: Flutter, GetX, Clean Architecture.
- **Backend**: Node.js, Express, MongoDB (Mongoose).
- **Styling**: Material 3 (Google Fonts - Inter).

## Setup Instructions

### Backend
1. Navigate to the backend directory:
   ```bash
   cd backend
   ```
2. Install dependencies:
   ```bash
   npm install
   ```
3. Set up environment variables (optional, defaults provided in code):
   - Create `.env` file (see `server.js` for used vars).
4. Run the server:
   ```bash
   npm run dev
   ```
   Server runs on `http://localhost:5000`.

### Frontend
1. Navigate to the root directory (where `pubspec.yaml` is).
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run
   ```
   **Note**: For Android Emulator, the API URL is set to `http://10.0.2.2:5000/api`. For iOS/Web, it uses `localhost`. Check `lib/app/core/utils/api_constants.dart` if you need to change this.

## Architecture
- **Backend**: MVC (Models, Views/Routes, Controllers).
- **Frontend**: Clean Architecture split into `data` (Providers), `domain` (Entities/Models logic), and `presentation` (Modules with GetX Controller/View/Binding).

## Smart Balance Logic
The dashboard calculates:
- **Current Balance**: Total Income - Total Expenses.
- **Projected Balance**: Current Balance - Upcoming Payments (for the month).
- **Daily Average**: Monthly Expenses / Days Passed.
