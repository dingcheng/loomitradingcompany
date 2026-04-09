# Privacy Policy

**Effective Date:** February 28, 2026

## Overview

This privacy policy covers all apps published by Loomi Trading Company LLC: **Golfiasta**, **DollyCam**, and **MakeLive** (collectively, "our Apps"). Your privacy is important to us. This policy explains how our Apps handle your data.

**The short version:** Our Apps do not collect, store, or transmit any personal information. All processing happens on your device. There are no accounts, no analytics, no ads, and no third-party tracking SDKs.

---

## Golfiasta

Golfiasta is a golf course finder and GPS distance app.

### Permissions

- **Location** — Used solely to calculate distances on the golf course in real time. Location data is processed entirely on your device and is never sent to any server, stored, or shared with any third party. Location access is only active while the app is in use and only when you enter play mode. You can revoke location permission at any time through your device's Settings.

### Network Requests

The app may make requests to the OpenStreetMap Overpass API to retrieve golf course map data when searching for courses not available in the offline database. These requests contain only geographic coordinates and search terms — no personal or device-identifying information is included.

### Data Storage

Course data is stored locally on your device in a bundled database. Your score history is stored on your device and synced across your Apple devices via iCloud Key-Value Storage, which is tied to your Apple ID. This data contains only golf scores, course names, and course coordinates — no personal information. You can disable iCloud sync for the app in your device's iCloud settings. The app does not use any external databases or remote storage beyond Apple's iCloud service.

---

## DollyCam

DollyCam is a cinematic video camera app with dolly zoom, dual camera, and pro video controls.

### Permissions

- **Camera** — Required to record video. Camera data is used only for the live viewfinder and video recording. It is never transmitted off your device.
- **Microphone** — Required to record audio with your videos. Audio data is only written to the local video file.
- **Photo Library** — Used to save recorded videos and to display your recordings in the built-in video library.

### Face Detection

DollyCam uses Apple's on-device Vision framework to detect and track faces for the dolly zoom feature. Face detection runs entirely on your device. Face data is used only for real-time zoom adjustment and is never stored, logged, or transmitted.

### Network Requests

DollyCam makes no network requests. The only external communication is with Apple's servers for in-app purchase verification, handled entirely by Apple's StoreKit framework.

### Data Storage

App settings (resolution, frame rate, codec, LUT selection, zoom parameters, etc.) are stored locally via UserDefaults. User-imported LUT files are stored in the app's local Documents directory. Recorded videos are saved to the Photos library or to a user-chosen folder. No data is stored in iCloud or any remote server by the app.

---

## MakeLive

MakeLive is a video to Live Photo converter.

### Permissions

- **Photo Library** — Used to select videos and save the generated Live Photos. Photo library data is accessed only for the content you select and is never transmitted off your device.

### Network Requests

MakeLive makes no network requests. The only external communication is with Apple's servers for in-app purchase verification, handled entirely by Apple's StoreKit framework. When you select a video stored in iCloud, Apple's Photos framework may download it through Apple's infrastructure — the app itself does not initiate any network connections.

### Data Storage

A security-scoped bookmark for your selected folder is stored locally via UserDefaults. Temporary files are created during Live Photo generation and are not persisted. No data is stored in iCloud or any remote server by the app.

---

## General — All Apps

### Third-Party Services

Our Apps do not use any third-party analytics, advertising, or tracking services. There are no third-party SDKs embedded in any of our Apps. All code uses only Apple's native frameworks.

### In-App Purchases

DollyCam and MakeLive each offer a single optional non-consumable in-app purchase (custom folder save). Purchase transactions are handled entirely by Apple's StoreKit framework. We do not receive or store any payment information.

### Children's Privacy

Our Apps do not collect any data from any user, including children under the age of 13.

### Changes to This Policy

If we update this privacy policy, the revised version will be posted here with an updated effective date.

### Contact

If you have questions about this privacy policy, contact us at:

loomitradingcompany@gmail.com
