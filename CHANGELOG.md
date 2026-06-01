# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] — Unreleased

### Added

- **Authentication**: Sign in, sign up, password reset with role-based access (admin/customer)
- **Product Management**: Full CRUD with soft delete, visibility toggle, image support
- **Category Management**: Hierarchical categories with drag-reorder, soft delete, restore, visibility toggle
- **Offer Management**: Time-bound offers with product linking, enable/disable toggle
- **Weight Unit Management**: Configurable weight units per product
- **Bilingual Support**: Arabic (primary) and English with RTL layout
- **Offline-First Architecture**: SQLite caching with Firestore sync
- **Material 3 Design**: Custom theming with Cairo (Arabic) + Poppins (English) fonts
- **Admin Dashboard**: Protected admin routes with role-based guards
- **Firebase Integration**: Authentication, Firestore, Storage, Cloud Messaging, Crashlytics
- **CI/CD**: GitHub Actions for analyze, test, build web, build APK
- **Seed Data Scripts**: Node.js scripts for populating initial Firestore data
- **Architecture Documentation**: ADRs, system context, ERD, flow diagrams
