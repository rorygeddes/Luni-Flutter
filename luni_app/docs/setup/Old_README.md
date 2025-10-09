# Luni Flutter App 🌙

A comprehensive financial management Flutter application with Plaid integration, intelligent transaction categorization, and social splitting features.

## 🚀 Features

### Core Functionality
- **Authentication & Onboarding**
  - Google Sign-In integration with Supabase
  - Email/password authentication
  - Multi-step onboarding flow with personalized questions

- **Bank Integration**
  - Plaid integration for secure bank account connections
  - Real-time transaction syncing
  - Multiple account management

- **Smart Transaction Management**
  - AI-powered merchant name normalization (OpenAI)
  - Automatic transaction categorization
  - Transaction queue for reviewing and categorizing expenses
  - Split transaction functionality

- **Financial Tracking**
  - Real-time account balances
  - Budget tracking and alerts
  - Daily financial reports
  - Customizable spending categories

- **Social Features**
  - Group expense splitting
  - Direct messaging between users
  - Settle-up functionality
  - Shared expense tracking

### User Interface
- **Modern Design**
  - Responsive UI with `flutter_screenutil`
  - Dark/Light mode support
  - Custom yellow-themed interface
  - Smooth animations and transitions

- **Key Screens**
  - Home Dashboard
  - Transaction Queue
  - Split Expenses
  - Social/Messaging
  - Accounts Overview
  - Editable Profile

## 📋 Prerequisites

- Flutter SDK (3.0 or higher)
- Dart SDK
- Xcode (for iOS development)
- Android Studio (for Android development)
- A Plaid account ([Sign up here](https://dashboard.plaid.com/))
- A Supabase account ([Sign up here](https://supabase.com/))
- OpenAI API key (optional, for AI features)

## 🏗 Architecture

**Important:** This app uses a **backend-first architecture** for security.

- **Frontend (Flutter)**: User interface only, no direct database access
- **Backend (Node.js)**: Handles all Supabase operations using SECRET keys
- **Security**: All sensitive credentials stay server-side

See [ARCHITECTURE_SUMMARY.md](ARCHITECTURE_SUMMARY.md) for details.

## 🛠 Setup Instructions

### 1. Clone the Repository

```bash
git clone https://github.com/rorygeddes/Luni-Flutter.git
cd Luni-Flutter
```

### 2. Backend Setup (Required First)

```bash
# Navigate to backend
cd backend

# Install dependencies
npm install

# Create .env file
cat > .env << EOF
PORT=3000
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_SECRET_KEY=your_service_role_secret_key  # ⚠️ Use SECRET key, NOT anon key
JWT_SECRET=your-random-jwt-secret
PLAID_CLIENT_ID=your_plaid_client_id
PLAID_SECRET=your_plaid_secret
PLAID_ENVIRONMENT=sandbox
NODE_ENV=development
EOF

# Start backend server
npm run dev
```

**Get Supabase SECRET Key:**
1. Go to: https://supabase.com/dashboard/project/YOUR_PROJECT/settings/api
2. Find "**service_role**" section (NOT anon/public)
3. Copy the "**secret**" value
4. Paste as `SUPABASE_SECRET_KEY` in backend `.env`

See [backend/README.md](backend/README.md) for detailed backend setup.

### 3. Flutter Setup

```bash
# Navigate to Flutter app
cd luni_app

# Install dependencies
flutter pub get
```

### 4. Configure Flutter Environment

Create a `.env` file in the `luni_app/assets/` directory:

```bash
# Backend Configuration (Required)
BACKEND_URL=http://localhost:3000  # Or your deployed backend URL

# Plaid Configuration (Optional - backend can handle this)
PLAID_CLIENT_ID=your_plaid_client_id
PLAID_SECRET=your_plaid_secret
PLAID_ENVIRONMENT=sandbox

# App Configuration
APP_ENVIRONMENT=development
```

**Important:** 
- Never commit the `.env` file to version control
- Supabase keys are NOT in Flutter - backend handles them
- Use SECRET keys in backend, NOT anon keys

See [ENV_TEMPLATE.md](luni_app/ENV_TEMPLATE.md) for detailed configuration.

### 5. Configure Supabase Database

1. Create a new Supabase project
2. Run the SQL setup script: `luni_app/new_supabase_setup.sql`
3. Get your SECRET key (service_role) for the backend
4. Add to backend `.env` file

See [SUPABASE_SETUP_INSTRUCTIONS.md](luni_app/SUPABASE_SETUP_INSTRUCTIONS.md) for detailed instructions.

### 6. Configure Plaid

1. Sign up at [Plaid Dashboard](https://dashboard.plaid.com/)
2. Get your Sandbox credentials (Client ID and Secret)
3. Add them to your **backend** `.env` file
4. For production, update to production credentials

See [PLAID_CREDENTIALS_SETUP.md](luni_app/PLAID_CREDENTIALS_SETUP.md) for detailed instructions.

## 🏃‍♂️ Running the App

**Important:** Backend must be running first!

### Step 1: Start Backend (Required)
```bash
cd backend
npm run dev
# Server running on http://localhost:3000
```

### Step 2: Run Flutter App

**Web**
```bash
cd luni_app
flutter run -d chrome
```

**iOS**
```bash
cd luni_app
flutter run -d ios
```

**Android**
```bash
cd luni_app
flutter run -d android
```

## 📱 Testing with Plaid Sandbox

When using Plaid's sandbox environment, use these test credentials:

- **Username:** `user_good`
- **Password:** `pass_good`

These credentials simulate a successful bank connection for testing.

## 🧪 Testing

Run the test suite:

```bash
flutter test
```

## 📚 Documentation

### Architecture & Setup
- **[ARCHITECTURE_SUMMARY.md](ARCHITECTURE_SUMMARY.md)** - ⭐ Architecture overview
- **[BACKEND_MIGRATION_GUIDE.md](BACKEND_MIGRATION_GUIDE.md)** - ⭐ Backend setup guide
- **[backend/README.md](backend/README.md)** - Backend API documentation
- **[ENV_TEMPLATE.md](luni_app/ENV_TEMPLATE.md)** - Environment variables

### Security
- **[SUPABASE_KEY_SECURITY.md](SUPABASE_KEY_SECURITY.md)** - Key security best practices
- **[SECURITY_INCIDENT_RESPONSE.md](SECURITY_INCIDENT_RESPONSE.md)** - Security notes

### Integration Guides
- [PLAID_INTEGRATION_GUIDE.md](luni_app/PLAID_INTEGRATION_GUIDE.md) - Plaid integration
- [PLAID_CREDENTIALS_SETUP.md](luni_app/PLAID_CREDENTIALS_SETUP.md) - Plaid setup
- [SUPABASE_SETUP_INSTRUCTIONS.md](luni_app/SUPABASE_SETUP_INSTRUCTIONS.md) - Supabase setup
- [GOOGLE_SIGNIN_COMPLETE_GUIDE.md](luni_app/GOOGLE_SIGNIN_COMPLETE_GUIDE.md) - Google Sign-In

### Design & Features
- [FIGMA_INTEGRATION_GUIDE.md](luni_app/FIGMA_INTEGRATION_GUIDE.md) - Design system
- [Product Documentation](Product/) - Feature specifications

## 🏗 Project Structure

```
luni_app/
├── lib/
│   ├── config/          # App configuration
│   ├── models/          # Data models
│   ├── providers/       # State management (Provider)
│   ├── screens/         # UI screens
│   │   ├── auth/        # Authentication screens
│   │   └── onboarding/  # Onboarding flow
│   ├── services/        # API services (Plaid, Supabase, OpenAI)
│   ├── theme/           # App theming
│   └── main.dart        # Entry point
├── assets/              # Images, fonts, .env
├── ios/                 # iOS native code
├── android/             # Android native code
└── web/                 # Web-specific files
```

## 🔐 Security Notes

1. **Never commit sensitive data:**
   - `.env` files are git-ignored
   - Keep API keys secure
   - Don't share production credentials

2. **Production Checklist:**
   - Use production Plaid credentials
   - Enable Supabase RLS policies
   - Update Supabase redirect URLs
   - Configure proper OAuth settings

3. **Environment Variables:**
   - Development: Use sandbox/test credentials
   - Production: Use production credentials
   - Keep separate `.env` files for each environment

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is private and proprietary.

## 🐛 Known Issues

- **Plaid Integration:** Requires valid sandbox credentials to test (see setup docs)
- **Google Sign-In on Web:** Requires proper redirect URL configuration
- **iOS OAuth:** Must use deep links (not localhost) for mobile

## 📞 Support

For issues or questions:
1. Check the documentation in the `luni_app/` directory
2. Review the [Product Documentation](Product/)
3. Open an issue on GitHub

## 🎨 Design

The app design is based on Figma mockups included in the `Luni_Home_Figma/` directory.

## 🚧 Roadmap

- [ ] Complete Plaid integration with real credentials
- [ ] Implement OpenAI transaction categorization
- [ ] Add webhook support for real-time updates
- [ ] Enhanced social features
- [ ] Push notifications
- [ ] Advanced budgeting tools

---

Built with ❤️ using Flutter

