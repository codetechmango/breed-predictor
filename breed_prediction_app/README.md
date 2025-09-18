# Breed Prediction App

A Flutter mobile app that uses AI to predict pet breeds from photos.

## Features

- **User Authentication**: Email signup/login using Supabase Auth
- **Multi-language Support**: Tamil, Hindi, English, Telugu, Marathi
- **Image Capture/Upload**: Camera capture and gallery upload
- **AI Breed Prediction**: External ML API integration for breed recognition
- **Feedback System**: Users can provide feedback on predictions
- **Cloud Storage**: Images stored in Supabase Storage

## Setup Instructions

### 1. Environment Configuration

Create a `.env` file in the root directory with the following variables:

```env
# Supabase Configuration
SUPABASE_URL=your_supabase_url_here
SUPABASE_ANON_KEY=your_supabase_anon_key_here

# ML API Configuration  
MODEL_API_URL=your_model_api_url_here
MODEL_API_KEY=your_model_api_key_here
```

### 2. Supabase Database Schema

Create the following tables in your Supabase database:

#### Profiles Table
```sql
CREATE TABLE profiles (
  id UUID REFERENCES auth.users ON DELETE CASCADE,
  email TEXT NOT NULL,
  language TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  PRIMARY KEY (id)
);
```

#### Feedbacks Table
```sql
CREATE TABLE feedbacks (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users ON DELETE CASCADE,
  image_url TEXT NOT NULL,
  predicted_breed TEXT NOT NULL,
  confidence DECIMAL NOT NULL,
  feedback TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### Storage Bucket
Create a storage bucket named `images` in your Supabase project.

### 3. Running the App

1. Install dependencies:
```bash
flutter pub get
```

2. Run the app:
```bash
flutter run
```

### 4. Building APK

To build the Android APK:

```bash
flutter build apk --release
```

The APK will be generated at: `build/app/outputs/flutter-apk/app-release.apk`

## App Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── user_profile.dart
│   └── prediction_result.dart
├── screens/                  # UI screens
│   ├── splash_screen.dart
│   ├── auth_screen.dart
│   ├── language_selection_screen.dart
│   ├── home_screen.dart
│   └── prediction_result_screen.dart
├── services/                 # Backend services
│   ├── supabase_service.dart
│   └── ml_api_service.dart
└── utils/                    # Utilities
    └── app_localizations.dart
```

## User Flow

1. **Splash Screen**: Shows app logo and checks authentication status
2. **Authentication**: User signup/login with email and password
3. **Language Selection**: Choose preferred language from 5 options
4. **Home Screen**: Take photo or upload from gallery
5. **Prediction**: AI analyzes image and shows breed prediction
6. **Feedback**: User provides feedback on prediction accuracy

## Key Dependencies

- `supabase_flutter`: Authentication and database
- `image_picker`: Camera and gallery access
- `http`: ML API requests
- `flutter_dotenv`: Environment variables
- `flutter_spinkit`: Loading indicators
- `intl`: Internationalization

## Notes

- The app requires camera and storage permissions on Android
- Images are uploaded to Supabase Storage and get public URLs
- ML API should accept multipart/form-data with image file
- Expected ML API response format: `{"breed": "...", "confidence": 0.92}`
- All text is localized for 5 supported languages
- Clean, modern Material Design UI throughout the app