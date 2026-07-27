# App Store Submission Guide - Version 1.2.1

## Current Version Info
- **Marketing Version:** 1.2.1
- **Build Number:** 4
- **Bundle ID:** com.mattsthomek.canvasspoolprogrammer
- **App Name:** Spool Programmer (Display: Canvas RFID)
- **Deployment Target:** iOS 18.0
- **Swift Version:** 5.0

## Status: Testing / Setup Phase

This app has **not yet been submitted to the App Store**. No archive has been uploaded to App Store Connect. This document is the runbook for when that's ready.

## ✅ Pre-Submission Checklist

### 1. Code & Build Status
- ✅ All files committed to git
- ✅ No compilation errors
- ✅ BUILD SUCCEEDED
- ✅ Pushed to origin/main

### 2. Version Numbers
- ✅ Version 1.2.1 (PATCH bump)
- ✅ Build 4 (incremented from previous)

### 3. Outstanding Before Submission
- [ ] App Store Connect record created for this bundle ID (if not already)
- [ ] Additional screenshots captured (only `screenshots/01_main_screen.png` exists; need 3-5 covering main screen, color picker, Settings, About, tag details)
- [ ] App Privacy / Nutrition Label questionnaire completed in App Store Connect
- [ ] Age rating questionnaire completed
- [ ] Export compliance answered (app does not use custom encryption — answer "No")
- [ ] App description, keywords, support URL, marketing URL entered
- [ ] Pricing and availability set
- [ ] Apple Developer Program membership confirmed active (required for Automatic signing / archiving)
- [ ] TestFlight pass on a physical device with real NTAG213/215/216 tags (NFC cannot be tested in Simulator)

## 🚀 Step-by-Step Submission Process

### Step 1: Push to GitHub
```bash
cd /Users/mattst/Developer/canvasspoolrfidprogrammer
git push origin main
```

### Step 2: Archive the App in Xcode

1. **Open Xcode:**
   ```bash
   open ACE_RFID_iOS.xcodeproj
   ```

2. **Select "Any iOS Device (arm64)" as target:**
   - At the top of Xcode, click the device selector
   - Choose "Any iOS Device (arm64)" NOT a simulator

3. **Create Archive:**
   - Menu: **Product → Archive**
   - Wait for build to complete (may take 2-5 minutes)
   - Archive window will open automatically

### Step 3: Validate the Archive

In the Organizer window (after archive completes):

1. **Select your archive** (should show version 1.2.1, build 4)

2. **Click "Validate App"**
   - Choose your Apple ID/Team
   - Select "Automatically manage signing"
   - Click "Validate"
   - Wait for validation (checks for issues)
   - ✅ Should say "Validation Successful"

3. **If validation fails:**
   - Read error messages carefully
   - Common issues:
     - Missing signing certificate
     - Provisioning profile issues
     - Missing required icons
     - Info.plist issues

### Step 4: Distribute to App Store Connect

1. **Click "Distribute App"**
   
2. **Choose Distribution Method:**
   - Select: **"App Store Connect"**
   - Click "Next"

3. **Upload Options:**
   - Select: **"Upload"**
   - Click "Next"

4. **App Store Connect Distribution Options:**
   - ✅ Include bitcode for iOS content: NO (deprecated)
   - ✅ Upload your app's symbols: YES
   - ✅ Manage Version and Build Number: Automatic
   - Click "Next"

5. **Signing:**
   - Select: **"Automatically manage signing"**
   - Click "Next"

6. **Review Info:**
   - Verify everything looks correct
   - Click "Upload"

7. **Wait for Upload:**
   - Progress bar will show upload status
   - Takes 2-10 minutes depending on internet speed
   - ✅ "Upload Successful" when done

### Step 5: Wait for Processing

1. **Go to App Store Connect:**
   - Visit: https://appstoreconnect.apple.com
   - Sign in with your Apple ID

2. **Navigate to Your App:**
   - Click "My Apps"
   - Select "Spool Programmer"

3. **Check Build Status:**
   - Click "TestFlight" tab or "App Store" tab
   - Look for build 4
   - Status will show: "Processing" (10-30 minutes)
   - Email notification when processing complete

### Step 6: Create App Store Version (if needed)

**If this is a new version:**

1. **In App Store Connect → App Store tab:**
   - Click the "+" button next to "iOS App"
   - Enter version: **1.2.1**

2. **Fill Required Fields:**

   **What's New in This Version:**
   ```
   Version 1.2.1

   • Renamed to Canvas RFID
   • Minor fixes and polish
   ```

   **Promotional Text (Optional):**
   ```
   Canvas RFID programs NTAG213/215/216 tags for Elegoo Canvas
   filament spools — read, write, and verify spool data right
   from your iPhone.
   ```

3. **Select Your Build:**
   - Under "Build" section, click the "+" button
   - Select build 4
   - Click "Done"

4. **Review Other Sections:**
   - App Information
   - Pricing and Availability
   - App Privacy (update if needed)
   - Age Rating

### Step 7: Submit for Review

1. **Add/Update Required Items:**
   - App Preview (video - optional but recommended)
   - Screenshots (required - at least 3 for 6.7" display)
   - App Icon (should already be in assets)

   **Screenshots (6.7" iPhone - 1290x2796):**

   One screenshot is pre-generated in `screenshots/01_main_screen.png`.
   To capture additional screenshots in the Simulator:

   a. Run the app on iPhone 15 Pro Max simulator
   b. Navigate to the screen you want (Settings, About, Color Picker, etc.)
   c. Press Cmd+S in the Simulator to save a screenshot
   d. Screenshots land in ~/Desktop by default

   Recommended set (3-5 screenshots):
   - Main screen (provided: `screenshots/01_main_screen.png`)
   - Filament profile selected with color picker
   - Settings screen
   - About screen
   - Tag details view (if available from a previous read)

2. **App Review Information:**
   - Contact Name
   - Contact Phone
   - Contact Email
   - **Demo Account:** If NFC testing needed, explain in notes

3. **Notes for Review:**
   ```
   This app requires a physical iPhone with NFC capability and 
   NTAG213/215/216 NFC tags to test fully. The app reads and 
   writes filament spool information to NFC tags for 3D printing.

   Key features to test:
   • Main screen UI layout and navigation
   • Settings screen - customization options  
   • About screen - app information
   • NFC operations require physical tags (expected to fail on simulator)
   ```

4. **Click "Add for Review"**

5. **Click "Submit to App Review"**

### Step 8: Wait for Review

- **Review Time:** Usually 24-48 hours
- **Status Updates:**
  - "Waiting for Review" → Your app is in queue
  - "In Review" → Apple is testing
  - "Pending Developer Release" → Approved! Ready to publish
  - "Ready for Sale" → Live on App Store

## 📱 TestFlight (Recommended Before First Submission)

**Before submitting to App Store, test with TestFlight:**

1. **In App Store Connect → TestFlight tab:**
   - Build 4 should appear after processing
   - Click on build 4

2. **Add Internal Testers:**
   - Click "Internal Testing"
   - Add yourself and other App Store Connect users
   - They'll get email with TestFlight link

3. **Add External Testers (Optional):**
   - Create a test group
   - Add beta testers by email
   - Requires beta app review (1-2 days)

4. **Test Thoroughly:**
   - Install via TestFlight on physical device
   - Verify NFC scanning works
   - Test tag read/write with NTAG213/215/216
   - Check Settings persistence
   - Verify haptic feedback toggle
   - Verify auto-verify toggle

5. **Fix Any Issues:**
   - If bugs found, fix them
   - Increment build number
   - Archive and upload again
   - TestFlight testers get automatic update

## 🎯 Quick Command Reference

```bash
# Push commits to GitHub
git push origin main

# Open Xcode project
open ACE_RFID_iOS.xcodeproj

# Build for release (in Xcode)
Product → Archive

# Check version
grep -E "(MARKETING_VERSION|CURRENT_PROJECT_VERSION)" ACE_RFID_iOS.xcodeproj/project.pbxproj
```

## ⚠️ Common Issues & Solutions

### Issue: "No signing identity found"
**Solution:** 
- Xcode → Settings → Accounts
- Select your Apple ID
- Download Manual Profiles
- Ensure you have an Apple Developer Program membership ($99/year)

### Issue: "Missing required icon"
**Solution:**
- Check Assets.xcassets/AppIcon.appiconset
- Ensure all required sizes present
- Currently have: AppIcon-1024.png ✅

### Issue: "Invalid bundle"
**Solution:**
- Check Info.plist for required keys
- Verify CFBundleVersion is integer
- Ensure all required permissions present

### Issue: "Export compliance missing"
**Solution:**
- In App Store Connect, answer encryption questions
- Your app likely doesn't use encryption (answer "No")

## 📊 Version History

- **1.0.1 (build 1):** Initial release with core NFC functionality
- **1.1.0 (build 2):** Added Settings Screen and Tag Details Display
- **1.2.0 (build 3):** iOS 26 NFC scanning fixes, broader tag protocol support, NavigationStack migration
- **1.2.1 (build 4):** Renamed to Canvas RFID (Home Screen name + About screen)

## 🔄 After Approval

1. **Release to App Store:**
   - Can release immediately or schedule
   - Choose "Manually release this version"
   - Click "Release this Version" when ready

2. **Monitor:**
   - Check App Analytics in App Store Connect
   - Monitor crash reports
   - Read user reviews

3. **Plan Next Update:**
   - VoiceOver labels + temperature warnings
   - Widget support?

## ✅ Current Status

- [x] Code complete
- [x] Version set to 1.2.1 (build 4)
- [x] All commits in git
- [x] Pushed to GitHub
- [ ] App Store Connect record created
- [ ] Additional screenshots captured
- [ ] TestFlight internal testing pass
- [ ] Archived in Xcode
- [ ] Uploaded to App Store Connect
- [ ] Submitted for review

**Next Step:** Capture remaining screenshots, then archive in Xcode and validate.
