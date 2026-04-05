# Fiora Backend Integration & Testing Protocol

This document outlines the final steps to launch the Fiora Women's Health App, securely managing API keys, synchronizing databases, and validating real-world inputs.

## 1. Obtaining & Managing API Keys
The application requires external API keys to function fully. These must never be hardcoded into the codebase. 

1. **Magic SDK (Authentication)**
   - Go to [Magic Dashboard](https://dashboard.magic.link/).
   - Create a new App -> copy the `Publishable Key` (for Flutter) and `Secret Key` (for FastAPI).
   - Add `MAGIC_SECRET_KEY` to your `.env` file.
   - For Flutter, update the Magic initialization in `main.dart` with your Publishable Key.

2. **Gemini API (AI Responses)**
   - Go to [Google AI Studio](https://aistudio.google.com/app/apikey).
   - Generate a new API Key.
   - Add it to `.env` as `GEMINI_API_KEY`.

3. **ElevenLabs (Voice Synthesis)**
   - Go to [ElevenLabs](https://elevenlabs.io/).
   - Access Profile -> API Keys and create a new key.
   - Add `ELEVENLABS_API_KEY` to `.env`.

4. **Algorand (Secure Data)**
   - Create an Algorand wallet address for the app's smart contracts.
   - Save the Mnemonic as `ALGORAND_ACCOUNT_MNEMONIC` for the backend Algorand SDK transactions.

## 2. Environment Configuration
A template configuration file (`.env.template`) has been generated in the `backend/` directory.
Run the following to initialize your environment:
```bash
cp .env.template .env
```
Once copied, populate the secrets with the keys obtained above.

## 3. Review of the Fixed Specific Errors
The codebase has already been successfully patched against the issues you flagged:
- **Authentication bypass in `login_screen.dart`**: Mid-file imports were moved to the top of the file allowing compilation. Form calls `FioraApi().login()` with proper payload instead of navigating directly to `/home`.
- **Missing API call in `info_screen.dart`**: Added `_api.patchProfileInfo()` which actively sends `height`, `weight`, `date`, `symptoms`, etc., to the database rather than just popping the navigator context.
- **Hardcoded "Maya" name**: Updated the hero card in `home_screen.dart` to rely on `UserPrefs.readProfileName()` which fetches the exact name from the `fetchProfileMe()` API fetch.
- **Cramp detection mismatch**: Upgraded rules in `app/services/cramps_detection.py` to identify "Cramps", "severe cramps" substrings within the array, accurately lowering the pain slider requirement to trigger the flags. Corresponding validation unit tests were added to `tests/test_cramps_detection.py`.
- **Hardcoded AI insights**: Hooked up `home_screen.dart` to fetch JSON insight summaries from `POST /api/v1/health_analysis/analyze` dynamically.

## 4. End-to-End Testing Protocol (Real User Data)

**Step 1: Database Registration & Profile Creation**
1. Boot up backend (`uvicorn app.main:app --reload`) and Flutter emulator (`flutter run`).
2. Register a new real-world user. Ensure MongoDB Compass reflects a new user document in `fiora.users` collection with populated `height_cm`, `weight_kg`, and `symptoms`.

**Step 2: Period & Cramp Alert Integrity**
1. Navigate to the `TrackerScreen`.
2. Input a standard moderate period log (`Flow: Medium`, `Pain Level: 3`, Symptoms: `Bloating`). Submit the log and verify NO pop-up occurs.
3. Input a specialized period log (`Flow: Heavy`, `Pain Level: 6`, Symptoms: `Cramps`). Submit the log and verify the **"Elevated pain was detected" UIAlert dialog** actively pops up.

**Step 3: Real-time AI Generation**
1. View the `HomeScreen` dashboard.
2. Confirm the greeting features the real first name you signed up with.
3. Check the "AI INSIGHT" card below the hero image. It should shimmer briefly, query your recent tracker database inputs via the Gemini endpoint, and render an personalized actionable summary based on your selected `Cramps`/`Flow` choices.
