# Flutter Build & Deploy Workflow Documentation

## Overview

This GitHub Actions workflow automates the building and deployment of a Flutter application. It covers both web and Android builds, deploying the web version to Firebase Hosting and uploading the Android APK to Firebase App Distribution.

## Table of Contents

- [Workflow Overview](#workflow-overview)
- [Prerequisites](#prerequisites)
- [Workflow Configuration](#workflow-configuration)
  - [Triggers](#triggers)
  - [Jobs](#jobs)
  - [Environment Variables](#environment-variables)
- [Setup Instructions](#setup-instructions)
- [Additional Notes](#additional-notes)

## Workflow Overview

The workflow is triggered on push events to the `main` and `uat` branches and consists of two jobs:

1. **Web Deployment (`web-deploy`)**: Builds and deploys the Flutter web app.
2. **Android Build (`android-build`)**: Builds the Android APK and uploads it.

## Prerequisites

- GitHub repository with a Flutter project.
- Firebase project setup for web and Android.
- Firebase CLI token stored in GitHub Secrets.

## Workflow Configuration

### Triggers

- **Push Event**: Activated on pushes to `main` and `uat` branches.

### Jobs

1. **Web Deployment (`web-deploy`)**

   - **Environment**: Ubuntu-latest.
   - **Condition**: Runs on `main` and `uat` branches.
   - **Steps**:
     - Check out code.
     - Set up Flutter.
     - Build for web.
     - Deploy to Firebase Hosting.

2. **Android Build (`android-build`)**

   - **Environment**: Ubuntu-latest.
   - **Condition**: Runs on `main` branch.
   - **Dependency**: Requires `web-deploy` completion.
   - **Steps**:
     - Check out code.
     - Set up Java.
     - Set up required files.
     - Set up Flutter.
     - Build APK.
     - Upload APK to Firebase App Distribution.

### Environment Variables

- `FIREBASE_CI_TOKEN`: Firebase CLI token for authentication.

## Setup Instructions

1. **Firebase CLI Token**:
   - Run `firebase login:ci` locally.
   - Add token to GitHub Secrets as `FIREBASE_CI_TOKEN`.

2. **GitHub Secrets**:
   - Go to repository settings.
   - Add `FIREBASE_CI_TOKEN`, `GOOGLE_SERVICES_JSON`, and `FIREBASE_OPTIONS` to Secrets.

3. **Workflow File**:
   - Place the YAML file in `.github/workflows/`.

4. **Project ID**:
   - Replace `YOUR_PROJECT_ID` with your Firebase project ID in the YAML file.

## Additional Notes

- Keep Firebase CLI token secure.
- Regularly update dependencies and settings.
- Customize the workflow as needed.

---

This documentation is formatted for readability and easy navigation in a GitHub README file. Adjust as necessary to fit the specifics of your project.
