# Final Flutter Folder Structure

> **Architecture:** Clean Architecture · Feature-First · Riverpod · Firebase
> **Platforms:** Android · iOS · Web
> **Languages:** Arabic (RTL) · English (LTR)

---

```
fresh_market/
│
├── android/                                    # Android platform (auto-generated)
│   ├── app/
│   │   ├── src/main/
│   │   │   ├── AndroidManifest.xml
│   │   │   └── res/
│   │   └── google-services.json
│   └── build.gradle
│
├── ios/                                        # iOS platform (auto-generated)
│   ├── Runner/
│   │   └── GoogleService-Info.plist
│   └── Podfile
│
├── web/                                        # Web platform (auto-generated)
│   └── firebase-messaging-sw.js
│
├── assets/
│   ├── fonts/
│   │   ├── Cairo-Regular.ttf                   # Arabic font (Cairo)
│   │   ├── Cairo-Bold.ttf
│   │   ├── Poppins-Regular.ttf                 # English font (Poppins)
│   │   └── Poppins-Bold.ttf
│   ├── images/
│   │   ├── logo.svg
│   │   ├── logo_ar.svg
│   │   ├── empty_state.svg                     # Illustrations
│   │   ├── error_state.svg
│   │   └── placeholder_product.jpg              # Image placeholder
│   └── lottie/                                 # Lottie animations (optional)
│       ├── loading.json
│       └── empty.json
│
├── lib/
│   │
│   # ──── CORE LAYER ───────────────────────────────────────────
│   │
│   ├── core/
│   │   ├── constants/
│   │   │   ├── api_constants.dart               # API base URLs, timeouts
│   │   │   ├── app_constants.dart               # App-wide magic values
│   │   │   ├── firestore_constants.dart          # All collection & field paths
│   │   │   └── route_constants.dart              # Route path strings
│   │   │
│   │   ├── enums/
│   │   │   ├── user_role.enum.dart              # admin, customer
│   │   │   ├── request_state.enum.dart           # idle, loading, success, failure
│   │   │   ├── notification_type.enum.dart       # offer, product, system, order
│   │   │   └── setting_type.enum.dart            # string, number, bool, json
│   │   │
│   │   ├── errors/
│   │   │   ├── app_exception.dart               # Base app exception class
│   │   │   ├── auth_exception.dart               # Auth-specific errors
│   │   │   ├── firestore_exception.dart          # Firestore-specific errors
│   │   │   ├── storage_exception.dart            # Storage upload/download errors
│   │   │   ├── validation_exception.dart         # Input validation errors
│   │   │   └── error_code.dart                   # Error code constants
│   │   │
│   │   ├── extensions/
│   │   │   ├── context_extensions.dart            # BuildContext helpers (theme, l10n, media)
│   │   │   ├── datetime_extensions.dart           # Date formatting helpers
│   │   │   ├── num_extensions.dart                # Price/currency formatting
│   │   │   ├── string_extensions.dart             # Capitalization, trimming
│   │   │   └── list_extensions.dart               # Collection helpers
│   │   │
│   │   ├── infrastructure/
│   │   │   ├── connectivity_service.dart          # Network state monitoring
│   │   │   └── logger_service.dart                # Structured logging wrapper
│   │   │
│   │   ├── providers/
│   │   │   ├── firebase_providers.dart            # FirebaseCore, Firestore, Auth, Storage
│   │   │   ├── connectivity_provider.dart         # Network state provider
│   │   │   └── locale_provider.dart               # Active locale state
│   │   │
│   │   ├── theme/
│   │   │   ├── app_theme.dart                     # ThemeData (light + dark)
│   │   │   ├── app_colors.dart                    # Color palette constants
│   │   │   ├── app_typography.dart                # TextStyle definitions
│   │   │   ├── app_dimensions.dart                # Spacing, radius, elevation tokens
│   │   │   └── app_decorations.dart               # Reusable box/fade decorations
│   │   │
│   │   └── utils/
│   │       ├── validators.dart                    # Form field validators
│   │       ├── image_utils.dart                   # Image picker, compression
│   │       ├── debouncer.dart                     # Search debounce utility
│   │       └── result.dart                        # Result<T> / Either pattern
│   │
│   # ──── DOMAIN LAYER ─────────────────────────────────────────
│   │
│   ├── domain/
│   │   ├── entities/
│   │   │   ├── user.entity.dart                   # User domain model
│   │   │   ├── role.entity.dart                   # Role domain model
│   │   │   ├── category.entity.dart               # Category domain model
│   │   │   ├── product.entity.dart                # Product domain model
│   │   │   ├── offer.entity.dart                  # Offer domain model
│   │   │   ├── offer_product.entity.dart          # Offer-Product junction
│   │   │   ├── weight_unit.entity.dart            # Weight unit domain model
│   │   │   ├── banner.entity.dart                 # Banner domain model
│   │   │   ├── notification.entity.dart           # Notification domain model
│   │   │   └── setting.entity.dart                # Setting domain model
│   │   │
│   │   ├── repositories/
│   │   │   ├── auth_repository.dart               # Auth operations contract
│   │   │   ├── user_repository.dart               # User CRUD contract
│   │   │   ├── category_repository.dart           # Category CRUD contract
│   │   │   ├── product_repository.dart            # Product CRUD contract
│   │   │   ├── offer_repository.dart              # Offer CRUD contract
│   │   │   ├── banner_repository.dart             # Banner CRUD contract
│   │   │   ├── weight_unit_repository.dart        # Weight unit lookup contract
│   │   │   ├── notification_repository.dart       # Notification contract
│   │   │   └── settings_repository.dart           # Settings CRUD contract
│   │   │
│   │   └── usecases/
│   │       ├── auth/
│   │       │   ├── sign_in.usecase.dart
│   │       │   ├── sign_up.usecase.dart
│   │       │   ├── sign_out.usecase.dart
│   │       │   ├── get_current_user.usecase.dart
│   │       │   └── watch_auth_state.usecase.dart
│   │       │
│   │       ├── user/
│   │       │   ├── get_users.usecase.dart          # Admin: list all users
│   │       │   ├── get_user.usecase.dart           # Get single user
│   │       │   ├── update_user_role.usecase.dart   # Admin: change role
│   │       │   ├── update_profile.usecase.dart     # Self: update profile
│   │       │   └── toggle_user_active.usecase.dart # Admin: activate/deactivate
│   │       │
│   │       ├── category/
│   │       │   ├── get_categories.usecase.dart     # Admin: all categories
│   │       │   ├── get_visible_categories.usecase.dart  # Customer: visible only
│   │       │   ├── watch_categories.usecase.dart   # Real-time stream
│   │       │   ├── create_category.usecase.dart
│   │       │   ├── update_category.usecase.dart
│   │       │   ├── toggle_category_visibility.usecase.dart
│   │       │   └── reorder_categories.usecase.dart
│   │       │
│   │       ├── product/
│   │       │   ├── get_products.usecase.dart       # Paginated product list
│   │       │   ├── get_product.usecase.dart        # Single product by ID
│   │       │   ├── get_featured_products.usecase.dart  # Home screen
│   │       │   ├── get_products_by_category.usecase.dart
│   │       │   ├── watch_products.usecase.dart     # Real-time stream
│   │       │   ├── create_product.usecase.dart
│   │       │   ├── update_product.usecase.dart
│   │       │   ├── delete_product.usecase.dart
│   │       │   ├── toggle_featured.usecase.dart
│   │       │   └── toggle_availability.usecase.dart
│   │       │
│   │       ├── offer/
│   │       │   ├── get_offers.usecase.dart         # Admin: all offers
│   │       │   ├── get_active_offers.usecase.dart  # Customer: active only
│   │       │   ├── get_offer.usecase.dart          # Single offer with products
│   │       │   ├── watch_active_offers.usecase.dart
│   │       │   ├── create_offer.usecase.dart
│   │       │   ├── update_offer.usecase.dart
│   │       │   └── toggle_offer_active.usecase.dart
│   │       │
│   │       ├── banner/
│   │       │   ├── get_active_banners.usecase.dart
│   │       │   ├── watch_banners.usecase.dart
│   │       │   ├── create_banner.usecase.dart
│   │       │   ├── update_banner.usecase.dart
│   │       │   └── reorder_banners.usecase.dart
│   │       │
│   │       ├── search/
│   │       │   ├── search_products.usecase.dart
│   │       │   └── get_search_suggestions.usecase.dart
│   │       │
│   │       ├── notification/
│   │       │   ├── get_notifications.usecase.dart
│   │       │   ├── watch_notifications.usecase.dart
│   │       │   └── mark_notification_read.usecase.dart
│   │       │
│   │       └── settings/
│   │           ├── get_settings.usecase.dart
│   │           ├── get_setting.usecase.dart
│   │           └── update_setting.usecase.dart
│   │
│   # ──── DATA LAYER ───────────────────────────────────────────
│   │
│   ├── data/
│   │   ├── datasources/
│   │   │   ├── firebase/
│   │   │   │   ├── auth_firebase_datasource.dart
│   │   │   │   ├── user_firebase_datasource.dart
│   │   │   │   ├── category_firebase_datasource.dart
│   │   │   │   ├── product_firebase_datasource.dart
│   │   │   │   ├── offer_firebase_datasource.dart
│   │   │   │   ├── banner_firebase_datasource.dart
│   │   │   │   ├── weight_unit_firebase_datasource.dart
│   │   │   │   ├── notification_firebase_datasource.dart
│   │   │   │   └── settings_firebase_datasource.dart
│   │   │   │
│   │   │   └── local/
│   │   │       ├── auth_local_datasource.dart          # Secure storage for tokens
│   │   │       ├── product_local_datasource.dart       # Offline product cache
│   │   │       ├── category_local_datasource.dart      # Offline category cache
│   │   │       ├── offer_local_datasource.dart         # Offline offer cache
│   │   │       └── settings_local_datasource.dart      # Locale, theme prefs
│   │   │
│   │   ├── dto/
│   │   │   ├── auth/
│   │   │   │   └── auth_response.dto.dart              # Auth response mapping
│   │   │   ├── user.dto.dart                           # JSON serialization
│   │   │   ├── role.dto.dart
│   │   │   ├── category.dto.dart
│   │   │   ├── product.dto.dart
│   │   │   ├── offer.dto.dart
│   │   │   ├── offer_product.dto.dart
│   │   │   ├── weight_unit.dto.dart
│   │   │   ├── banner.dto.dart
│   │   │   ├── notification.dto.dart
│   │   │   └── setting.dto.dart
│   │   │
│   │   ├── models/
│   │   │   ├── user_model.dart                         # DTO + toEntity() + fromEntity()
│   │   │   ├── role_model.dart
│   │   │   ├── category_model.dart
│   │   │   ├── product_model.dart
│   │   │   ├── offer_model.dart
│   │   │   ├── offer_product_model.dart
│   │   │   ├── weight_unit_model.dart
│   │   │   ├── banner_model.dart
│   │   │   ├── notification_model.dart
│   │   │   └── setting_model.dart
│   │   │
│   │   ├── repositories/
│   │   │   ├── auth_repository_impl.dart
│   │   │   ├── user_repository_impl.dart
│   │   │   ├── category_repository_impl.dart
│   │   │   ├── product_repository_impl.dart
│   │   │   ├── offer_repository_impl.dart
│   │   │   ├── banner_repository_impl.dart
│   │   │   ├── weight_unit_repository_impl.dart
│   │   │   ├── notification_repository_impl.dart
│   │   │   └── settings_repository_impl.dart
│   │   │
│   │   └── providers/
│   │       ├── auth_repository_provider.dart            # Riverpod provider bindings
│   │       ├── user_repository_provider.dart
│   │       ├── category_repository_provider.dart
│   │       ├── product_repository_provider.dart
│   │       ├── offer_repository_provider.dart
│   │       ├── banner_repository_provider.dart
│   │       ├── weight_unit_repository_provider.dart
│   │       ├── notification_repository_provider.dart
│   │       └── settings_repository_provider.dart
│   │
│   # ──── PRESENTATION LAYER ────────────────────────────────────
│   │
│   ├── presentation/
│   │   ├── common/
│   │   │   ├── widgets/
│   │   │   │   ├── app_scaffold.dart                   # Responsive scaffold wrapper
│   │   │   │   ├── app_bar_widget.dart                 # Shared app bar
│   │   │   │   ├── bottom_nav_bar.dart                 # Customer bottom navigation
│   │   │   │   ├── loading_widget.dart                 # Centered spinner
│   │   │   │   ├── error_widget.dart                   # Error with retry
│   │   │   │   ├── empty_state_widget.dart             # Empty state illustration
│   │   │   │   ├── localized_text.dart                 # Locale-aware text widget
│   │   │   │   ├── app_image.dart                      # Cached network image
│   │   │   │   ├── shimmer_loading.dart                # Shimmer skeleton
│   │   │   │   ├── responsive_builder.dart             # Mobile/tablet/web switch
│   │   │   │   ├── confirm_dialog.dart                 # Reusable confirmation
│   │   │   │   ├── search_bar_widget.dart              # Global search input
│   │   │   │   ├── paginated_grid.dart                 # Paginated grid builder
│   │   │   │   ├── paginated_list.dart                 # Paginated list builder
│   │   │   │   ├── image_picker_widget.dart            # Camera/gallery picker
│   │   │   │   ├── toggle_chip.dart                    # On/off toggle chip
│   │   │   │   ├── badge_widget.dart                   # Notification badge
│   │   │   │   ├── offline_banner.dart                 # Offline indicator
│   │   │   │   ├── refresh_wrapper.dart                # Pull-to-refresh wrapper
│   │   │   │   └── rtl_provider_widget.dart            # RTL-aware wrapper
│   │   │   │
│   │   │   └── extensions/
│   │   │       ├── context_extensions.dart              # Theme, localization shortcuts
│   │   │       └── widget_extensions.dart               # Padding, alignment helpers
│   │   │
│   │   ├── splash/
│   │   │   ├── splash_page.dart
│   │   │   └── providers/
│   │   │       └── splash_provider.dart
│   │   │
│   │   ├── features/
│   │   │   │
│   │   │   ├── auth/
│   │   │   │   ├── pages/
│   │   │   │   │   ├── sign_in_page.dart
│   │   │   │   │   ├── sign_up_page.dart
│   │   │   │   │   └── forgot_password_page.dart
│   │   │   │   ├── providers/
│   │   │   │   │   ├── auth_state_provider.dart          # Auth stream provider
│   │   │   │   │   └── auth_form_provider.dart           # Sign in/up form state
│   │   │   │   └── widgets/
│   │   │   │       ├── sign_in_form.dart
│   │   │   │       ├── sign_up_form.dart
│   │   │   │       ├── social_login_buttons.dart
│   │   │   │       └── auth_divider.dart
│   │   │   │
│   │   │   ├── home/
│   │   │   │   ├── pages/
│   │   │   │   │   └── home_page.dart
│   │   │   │   ├── providers/
│   │   │   │   │   ├── home_provider.dart                # Composed home state
│   │   │   │   │   └── banner_provider.dart              # Banner section state
│   │   │   │   └── widgets/
│   │   │   │       ├── banner_slider.dart
│   │   │   │       ├── offers_section.dart
│   │   │   │       ├── featured_categories.dart
│   │   │   │       ├── featured_products.dart
│   │   │   │       ├── section_header.dart
│   │   │   │       └── home_shimmer.dart
│   │   │   │
│   │   │   ├── categories/
│   │   │   │   ├── pages/
│   │   │   │   │   └── category_products_page.dart       # Products by category
│   │   │   │   ├── providers/
│   │   │   │   │   └── category_products_provider.dart
│   │   │   │   └── widgets/
│   │   │   │       └── category_card.dart
│   │   │   │
│   │   │   ├── products/
│   │   │   │   ├── pages/
│   │   │   │   │   ├── product_list_page.dart
│   │   │   │   │   └── product_detail_page.dart
│   │   │   │   ├── providers/
│   │   │   │   │   ├── product_list_provider.dart
│   │   │   │   │   ├── product_detail_provider.dart
│   │   │   │   │   └── product_form_provider.dart
│   │   │   │   └── widgets/
│   │   │   │       ├── product_card.dart
│   │   │   │       ├── product_grid.dart
│   │   │   │       ├── product_detail_sheet.dart
│   │   │   │       ├── product_info_section.dart
│   │   │   │       └── product_image_viewer.dart
│   │   │   │
│   │   │   ├── offers/
│   │   │   │   ├── pages/
│   │   │   │   │   ├── offer_list_page.dart
│   │   │   │   │   └── offer_detail_page.dart
│   │   │   │   ├── providers/
│   │   │   │   │   ├── offer_list_provider.dart
│   │   │   │   │   └── offer_detail_provider.dart
│   │   │   │   └── widgets/
│   │   │   │       ├── offer_card.dart
│   │   │   │       ├── offer_countdown_timer.dart
│   │   │   │       └── offer_product_list.dart
│   │   │   │
│   │   │   ├── search/
│   │   │   │   ├── pages/
│   │   │   │   │   └── search_page.dart
│   │   │   │   ├── providers/
│   │   │   │   │   └── search_provider.dart
│   │   │   │   └── widgets/
│   │   │   │       ├── search_result_card.dart
│   │   │   │       ├── search_filters.dart
│   │   │   │       └── search_suggestions.dart
│   │   │   │
│   │   │   ├── notifications/
│   │   │   │   ├── pages/
│   │   │   │   │   └── notification_list_page.dart
│   │   │   │   ├── providers/
│   │   │   │   │   └── notification_provider.dart
│   │   │   │   └── widgets/
│   │   │   │       └── notification_tile.dart
│   │   │   │
│   │   │   ├── profile/
│   │   │   │   ├── pages/
│   │   │   │   │   └── profile_page.dart
│   │   │   │   ├── providers/
│   │   │   │   │   └── profile_provider.dart
│   │   │   │   └── widgets/
│   │   │   │       ├── profile_header.dart
│   │   │   │       └── profile_edit_form.dart
│   │   │   │
│   │   │   ├── settings/
│   │   │   │   ├── pages/
│   │   │   │   │   └── settings_page.dart
│   │   │   │   ├── providers/
│   │   │   │   │   └── settings_provider.dart
│   │   │   │   └── widgets/
│   │   │   │       ├── language_selector.dart
│   │   │   │       └── theme_selector.dart
│   │   │   │
│   │   │   └── admin/
│   │   │       ├── pages/
│   │   │       │   ├── admin_dashboard_page.dart
│   │   │       │   ├── admin_products_page.dart
│   │   │       │   ├── admin_product_form_page.dart
│   │   │       │   ├── admin_categories_page.dart
│   │   │       │   ├── admin_category_form_page.dart
│   │   │       │   ├── admin_offers_page.dart
│   │   │       │   ├── admin_offer_form_page.dart
│   │   │       │   ├── admin_banners_page.dart
│   │   │       │   ├── admin_banner_form_page.dart
│   │   │       │   ├── admin_users_page.dart
│   │   │       │   └── admin_settings_page.dart
│   │   │       ├── providers/
│   │   │       │   ├── admin_dashboard_provider.dart
│   │   │       │   ├── admin_products_provider.dart
│   │   │       │   ├── admin_categories_provider.dart
│   │   │       │   ├── admin_offers_provider.dart
│   │   │       │   ├── admin_banners_provider.dart
│   │   │       │   ├── admin_users_provider.dart
│   │   │       │   └── admin_settings_provider.dart
│   │   │       └── widgets/
│   │   │           ├── admin_sidebar.dart
│   │   │           ├── admin_app_bar.dart
│   │   │           ├── admin_stats_card.dart
│   │   │           ├── admin_data_table.dart
│   │   │           ├── admin_search_field.dart
│   │   │           ├── admin_image_uploader.dart
│   │   │           ├── product_list_tile.dart
│   │   │           ├── category_list_tile.dart
│   │   │           ├── offer_list_tile.dart
│   │   │           ├── banner_list_tile.dart
│   │   │           ├── user_list_tile.dart
│   │   │           ├── role_selector.dart
│   │   │           ├── product_selector_dialog.dart
│   │   │           └── settings_field_editor.dart
│   │   │
│   │   └── routing/
│   │       ├── app_router.dart                       # GoRouter definition
│   │       ├── route_names.dart                      # Named route constants
│   │       ├── auth_guard.dart                       # Auth redirect logic
│   │       └── admin_guard.dart                      # Role-based redirect
│   │
│   # ──── LOCALIZATION ─────────────────────────────────────────
│   │
│   ├── l10n/
│   │   ├── app_en.arb                                # English strings
│   │   └── app_ar.arb                                # Arabic strings
│   │
│   # ──── APP ENTRY ────────────────────────────────────────────
│   │
│   ├── app.dart                                      # MaterialApp.router setup
│   └── main.dart                                     # Firebase init + runApp
│
├── test/
│   ├── unit/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── product_entity_test.dart
│   │   │   │   ├── category_entity_test.dart
│   │   │   │   ├── offer_entity_test.dart
│   │   │   │   ├── user_entity_test.dart
│   │   │   │   ├── banner_entity_test.dart
│   │   │   │   ├── weight_unit_entity_test.dart
│   │   │   │   └── notification_entity_test.dart
│   │   │   └── usecases/
│   │   │       ├── auth/
│   │   │       │   ├── sign_in_usecase_test.dart
│   │   │       │   ├── sign_up_usecase_test.dart
│   │   │       │   └── sign_out_usecase_test.dart
│   │   │       ├── product/
│   │   │       │   ├── get_products_usecase_test.dart
│   │   │       │   ├── create_product_usecase_test.dart
│   │   │       │   ├── update_product_usecase_test.dart
│   │   │       │   └── delete_product_usecase_test.dart
│   │   │       ├── category/
│   │   │       │   ├── get_categories_usecase_test.dart
│   │   │       │   ├── create_category_usecase_test.dart
│   │   │       │   ├── toggle_visibility_usecase_test.dart
│   │   │       │   └── reorder_categories_usecase_test.dart
│   │   │       ├── offer/
│   │   │       │   ├── get_active_offers_usecase_test.dart
│   │   │       │   ├── create_offer_usecase_test.dart
│   │   │       │   └── toggle_offer_active_usecase_test.dart
│   │   │       └── banner/
│   │   │           └── get_active_banners_usecase_test.dart
│   │   └── data/
│   │       ├── dto/
│   │       │   ├── product_dto_test.dart
│   │       │   ├── category_dto_test.dart
│   │       │   ├── offer_dto_test.dart
│   │       │   ├── banner_dto_test.dart
│   │       │   └── user_dto_test.dart
│   │       └── repositories/
│   │           ├── auth_repository_impl_test.dart
│   │           ├── product_repository_impl_test.dart
│   │           ├── category_repository_impl_test.dart
│   │           ├── offer_repository_impl_test.dart
│   │           ├── banner_repository_impl_test.dart
│   │           └── user_repository_impl_test.dart
│   │
│   ├── widget/
│   │   ├── home_page_test.dart
│   │   ├── product_list_page_test.dart
│   │   ├── product_detail_page_test.dart
│   │   ├── sign_in_page_test.dart
│   │   ├── category_products_page_test.dart
│   │   ├── offer_list_page_test.dart
│   │   └── common/
│   │       ├── loading_widget_test.dart
│   │       ├── error_widget_test.dart
│   │       ├── empty_state_widget_test.dart
│   │       └── shimmer_loading_test.dart
│   │
│   ├── integration/
│   │   ├── auth_flow_test.dart
│   │   ├── product_crud_test.dart
│   │   └── home_screen_load_test.dart
│   │
│   └── mocks/
│       ├── mock_auth_repository.dart
│       ├── mock_product_repository.dart
│       ├── mock_category_repository.dart
│       ├── mock_offer_repository.dart
│       ├── mock_banner_repository.dart
│       ├── mock_user_repository.dart
│       ├── mock_settings_repository.dart
│       ├── mock_notification_repository.dart
│       ├── mock_connectivity_service.dart
│       └── mock_firebase.dart                       # Fake Firebase instances
│
├── scripts/
│   ├── seed_data.dart                               # Firestore seed script
│   ├── deploy_rules.sh                              # Deploy security rules
│   └── deploy_indexes.sh                            # Deploy composite indexes
│
├── firestore.indexes.json                           # Composite indexes config
├── firestore.rules                                  # Security rules file
├── firebase.json                                    # Firebase project config
├── l10n.yaml                                        # Localization config
├── pubspec.yaml                                     # Dependencies
├── analysis_options.yaml                            # Dart lint rules
└── README.md
```

---

## Layer Dependency Rules

```
Presentation ───► Domain ◄─── Data
     │                           │
     │    (no Firebase imports)  │
     └───────────────────────────┘
```

| Layer | Can Import | Cannot Import |
|-------|-----------|---------------|
| **domain/** | Dart SDK only, `dart:` | Any package, Flutter, Firebase |
| **data/** | `domain/`, `package:` | Flutter widgets, `presentation/` |
| **presentation/** | `domain/`, `package:flutter`, Riverpod | `data/` directly, Firebase directly |
| **core/** | `package:` only | `domain/`, `data/`, `presentation/` |
| **l10n/** | Nothing | Nothing |

## Key Design Decisions

1. **DTO vs Model**: DTOs handle raw JSON serialization. Models extend DTOs with `toEntity()`/`fromEntity()` mapping. This keeps serialization separate from domain mapping.

2. **Data providers**: Repository provider bindings live in `data/providers/` (not `core/providers/`) because they depend on data layer implementations.

3. **No barrel exports**: Each file imports the specific file it needs. No `all_providers.dart` or `all_entities.dart` barrel files.

4. **Usecase naming**: Use cases are verbs in present tense (`sign_in`, `get_products`, `create_category`). File names are `snake_case` without "usecase" suffix in the file name (directory provides context).

5. **Feature modules**: Each customer feature under `features/` follows the same pattern:
   - `pages/` — screen-level widgets (one per route)
   - `providers/` — Riverpod state providers for that feature
   - `widgets/` — reusable widgets scoped to that feature

6. **Admin feature**: The `admin/` feature is a single module under `features/` containing all admin pages, providers, and widgets. Admin pages share the admin sidebar layout.
