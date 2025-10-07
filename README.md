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

## 🛠 Setup Instructions

### 1. Clone the Repository

```bash
git clone https://github.com/rorygeddes/Luni-Flutter.git
cd Luni-Flutter/luni_app
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Configure Environment Variables

Create a `.env` file in the `luni_app/assets/` directory:

```bash
# Supabase Configuration
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key

# Plaid Configuration
PLAID_CLIENT_ID=your_plaid_client_id
PLAID_SECRET=your_plaid_secret
PLAID_ENVIRONMENT=sandbox  # Use 'sandbox' for testing, 'production' for live

# OpenAI Configuration (Optional)
OPENAI_API_KEY=your_openai_api_key

# App Configuration
APP_ENVIRONMENT=development
```

**Important:** Never commit the `.env` file to version control. It's already included in `.gitignore`.

### 4. Configure Supabase

1. Create a new Supabase project
2. Run the SQL setup script: `luni_app/new_supabase_setup.sql`
3. Enable Google OAuth in Supabase Authentication settings
4. Add your redirect URLs in Supabase settings

See [SUPABASE_SETUP_INSTRUCTIONS.md](luni_app/SUPABASE_SETUP_INSTRUCTIONS.md) for detailed instructions.

### 5. Configure Plaid

1. Sign up at [Plaid Dashboard](https://dashboard.plaid.com/)
2. Get your Sandbox credentials (Client ID and Secret)
3. Add them to your `.env` file
4. For production, update to production credentials and environment

See [PLAID_CREDENTIALS_SETUP.md](luni_app/PLAID_CREDENTIALS_SETUP.md) for detailed instructions.

### 6. Configure Google Sign-In

Follow the platform-specific setup:

**iOS:**
- Add redirect URL to `Info.plist`
- Configure URL schemes
- See [GOOGLE_SIGNIN_SETUP.md](luni_app/GOOGLE_SIGNIN_SETUP.md)

**Android:**
- Update `AndroidManifest.xml`
- Add app links configuration
- See [GOOGLE_SIGNIN_SETUP.md](luni_app/GOOGLE_SIGNIN_SETUP.md)

## 🏃‍♂️ Running the App

### Web
```bash
flutter run -d chrome
```

### iOS
```bash
flutter run -d ios
```

### Android
```bash
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

- [PLAID_INTEGRATION_GUIDE.md](luni_app/PLAID_INTEGRATION_GUIDE.md) - Plaid integration details
- [AUTHENTICATION_FIX_SUMMARY.md](luni_app/AUTHENTICATION_FIX_SUMMARY.md) - Authentication setup
- [GOOGLE_SIGNIN_COMPLETE_GUIDE.md](luni_app/GOOGLE_SIGNIN_COMPLETE_GUIDE.md) - Google Sign-In guide
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

