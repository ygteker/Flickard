# Zbam App Analytics & Crash Reporting Guide

## Overview
This guide explains how to access crash reports, device information, regional data, and iOS versions for your Zbam app.

---

## 🔴 CRASH REPORTS

### Where to View Crashes:

#### **1. Xcode Organizer** (Recommended)
**Steps:**
1. Open Xcode
2. Go to **Window → Organizer** (or press `Cmd + Shift + 9`)
3. Select the **Crashes** tab
4. Choose your app from the sidebar
5. View crashes grouped by:
   - Version
   - iOS version
   - Device type
   - Crash type

**What You'll See:**
- Full crash logs with line numbers (symbolicated)
- Stack traces
- Number of occurrences
- Percentage of users affected
- Device models and iOS versions where crash occurred

**Requirements:**
- Keep your Xcode archives (don't delete them!)
- Xcode automatically downloads crash reports from App Store Connect
- Users must opt-in to share analytics with Apple

---

#### **2. App Store Connect** (Web)
**Steps:**
1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Select your app
3. Go to **TestFlight** (for beta) or **App Analytics** (for production)
4. Click on **Crashes**

**What You'll See:**
- Crash rate (percentage)
- Total crashes
- Crashes per version
- Can download individual crash reports

---

### How to Use OSLog for Debugging:

The app now logs important events using OSLog. To view these logs:

#### **During Development (Xcode):**
1. Run your app in Xcode
2. Open Debug Console (bottom panel)
3. Filter by "com.zbam.app" to see only your logs

#### **From TestFlight or Production:**
1. Open **Console.app** on Mac (in `/Applications/Utilities/`)
2. Connect user's device via USB
3. Select the device from sidebar
4. Filter by "Zbam" or "com.zbam.app"
5. Reproduce the crash or issue
6. Export logs: **File → Save**

#### **Log Categories Added:**
- `general` - App lifecycle and navigation
- `cards` - Card operations (create, edit, swipe)
- `data` - Database operations
- `ui` - UI interactions
- `error` - Errors and crashes

---

## 📊 USER DEVICE & REGIONAL DATA

### Where to View User Information:

#### **App Store Connect → App Analytics**

**Steps:**
1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Select your app
3. Go to **App Analytics** tab

**Available Metrics:**

##### **1. Device Information:**
- **Metrics → App Usage → Device**
  - iPhone models (iPhone 15, 14, 13, etc.)
  - iPad models
  - Breakdown by percentage

##### **2. iOS Version:**
- **Metrics → App Usage → Platform Version**
  - iOS 18, iOS 17, iOS 16, etc.
  - Percentage of users on each version

##### **3. Regional Data (App Store Territory):**
- **Metrics → App Store → Sources**
  - Countries where app was downloaded
  - Number of downloads per country
  - Active devices per region

##### **4. Additional Useful Metrics:**
- **Active Devices**: Total users
- **Sessions**: How often app is opened
- **Retention**: Users who return after first use
- **Crashes**: Crash rate and affected users

---

## 📈 METRICS AVAILABLE

### TestFlight (Beta Testing):
- Crashes per build
- Tester feedback
- Session data
- Device types used by testers

### Production (App Store):
- Crashes (by version, device, iOS version)
- Active devices
- Downloads per territory
- User retention
- App usage sessions
- Energy impact

---

## ⚙️ SETUP CHECKLIST

### Before Submitting to App Store:

1. **Archive Your App Properly:**
   - In Xcode: **Product → Archive**
   - Keep all archives (needed for crash symbolication)

2. **Enable Bitcode (if applicable):**
   - Already handled automatically by Xcode

3. **Upload Debug Symbols:**
   - Xcode does this automatically when archiving
   - Ensures crash reports are readable

4. **Keep Archives:**
   - Never delete archives for released versions
   - Store in: `~/Library/Developer/Xcode/Archives/`

---

## 🔍 READING CRASH REPORTS

### Key Information in Crash Reports:

1. **Exception Type**: What went wrong (e.g., `EXC_BAD_ACCESS`, `SIGSEGV`)
2. **Exception Codes**: Memory address causing crash
3. **Crashed Thread**: Which thread crashed
4. **Stack Trace**: Function calls leading to crash
5. **Device Info**: Model, iOS version, disk space
6. **App State**: Foreground/background

### Common Crash Types:
- `EXC_BAD_ACCESS` - Memory access error
- `SIGABRT` - App was terminated (often from assertions)
- `SIGSEGV` - Segmentation fault
- `SIGKILL` - Killed by system (out of memory)

---

## 📱 PRIVACY & USER CONSENT

### Automatic Data Collection:
Apple collects analytics only if users opt-in:
- Settings → Privacy & Security → Analytics & Improvements → Share iPhone Analytics

### What's Collected:
- Crash reports (anonymous)
- Performance metrics
- Device model, iOS version
- App Store territory

### What's NOT Collected (Without Additional Code):
- Personal information
- User content (your flashcards)
- Location data
- Network activity

---

## 🚀 NEXT STEPS

### To Start Seeing Data:

1. **TestFlight:**
   - Upload a build
   - Invite testers
   - Check TestFlight tab in App Store Connect after users test

2. **Production:**
   - Submit to App Store
   - After approval, users download
   - Wait 24-48 hours for data to populate
   - Check Xcode Organizer and App Store Connect

3. **Add More Logging:**
   - Use `AppLogger.error.error("Description")` before potential crash points
   - Log important state changes
   - Log user actions that might lead to crashes

---

## 💡 TIPS

1. **Crash Symbolication:**
   - Always archive through Xcode (don't just build)
   - Keep archives for every released version
   - If crashes aren't symbolicated, re-download them in Xcode Organizer

2. **Best Practices:**
   - Add logging before risky operations (database writes, network calls)
   - Use `do-catch` blocks and log errors
   - Test on multiple iOS versions and devices

3. **Frequency:**
   - Crash reports: Updated multiple times per day
   - Analytics data: Updated once per day
   - Xcode Organizer: Auto-syncs daily

---

## 📞 GETTING LOGS FROM USERS

If a user reports a crash, ask them to:

### Option 1: Device Analytics
1. Settings → Privacy & Security → Analytics & Improvements → Analytics Data
2. Find logs starting with "Zbam"
3. Tap, share via Messages/Mail

### Option 2: Sync to Mac
1. Connect device to Mac
2. Open Console.app
3. Select device
4. Export logs

---

## 🔗 USEFUL LINKS

- [App Store Connect](https://appstoreconnect.apple.com)
- [Apple Crash Reporting Documentation](https://developer.apple.com/documentation/xcode/analyzing-crash-reports)
- [OSLog Documentation](https://developer.apple.com/documentation/oslog)
- [App Analytics Guide](https://developer.apple.com/app-store/measuring-app-performance/)

---

## EXAMPLE: Finding iOS Version Data

1. Log in to App Store Connect
2. Select "Zbam" app
3. Go to "App Analytics"
4. Select "Metrics" tab
5. Choose "Platform Version" from dropdown
6. See: "iOS 18.2: 45%, iOS 17.5: 35%, iOS 16.7: 20%"

---

## EXAMPLE: Finding Regional Downloads

1. App Store Connect → App Analytics
2. Select "Sources" or "Sales and Trends"
3. View by Territory
4. See: "United States: 500 downloads, Germany: 200, Japan: 150"

---

This setup provides comprehensive crash debugging and analytics without requiring any third-party services or compromising user privacy! 🎉
