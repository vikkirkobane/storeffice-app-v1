# Storeffice App - Development Blueprint

## Project Overview
Storeffice is a Flutter application that allows users to book office spaces and purchase products. The project was initially configured with Firebase but has been migrated to use Supabase as the backend.

## Development Progress

### Initial State
- The project was a Flutter app with Firebase integration
- Dependencies included firebase_core, firebase_auth, cloud_firestore
- Multiple screens for office space booking and product purchasing
- Authentication and data storage handled through Firebase

### Actions Taken

1. **Project Analysis & Setup**
   - Reviewed project structure and dependencies
   - Identified all Firebase references across the codebase
   - Upgraded Flutter and Dart SDK to required versions (Flutter 3.35.7, Dart 3.9.2)

2. **Firebase to Supabase Migration**
   - Removed Firebase dependencies from pubspec.yaml
   - Added Supabase dependencies (supabase_flutter: ^2.8.0)
   - Updated all authentication logic to use Supabase Auth
   - Replaced Firestore database calls with Supabase database calls
   - Updated all data models to work with Supabase
   - Modified all screens to use Supabase services instead of Firebase services

3. **Codebase Updates**
   - Updated main.dart to initialize Supabase instead of Firebase
   - Modified authentication flow to use Supabase AuthState
   - Updated user management with Supabase Auth
   - Revised all database operations to use Supabase RLS-protected tables
   - Created SupabaseService to handle all database operations
   - Added configuration file for Supabase credentials

4. **Data Model Refactoring**
   - Updated User model to work with Supabase auth
   - Modified Office Space model to use Supabase fields
   - Updated Product model for Supabase integration
   - Revised Booking model to work with Supabase tables
   - Updated Cart model to remove Firebase dependencies

5. **Screen Updates**
   - Updated Login screen to use Supabase authentication
   - Modified Registration screen for Supabase auth
   - Updated Office Space List screen to fetch from Supabase
   - Modified Product List screen for Supabase integration
   - Revised Add Office Space screen for Supabase
   - Updated Add Product screen to use Supabase
   - Modified My Bookings screen to retrieve from Supabase
   - Updated Booking screen for Supabase integration

6. **Database Schema Creation**
   - Created comprehensive schema.sql file
   - Defined tables for users, office spaces, products, bookings, and carts
   - Implemented Row Level Security (RLS) policies
   - Added custom functions for business logic
   - Created triggers for data validation
   - Added performance indexes
   - Set up real-time subscriptions

### Key Changes Made

#### Dependencies
- Removed: firebase_core, firebase_auth, cloud_firestore
- Added: supabase_flutter, supabase

#### Authentication
- Switched from FirebaseAuth to Supabase Auth
- Updated auth state management
- Modified login and registration flows

#### Database Operations
- Replaced Firestore calls with Supabase database operations
- Updated all data retrieval and storage methods
- Implemented RLS policies for security

#### Configuration
- Created configuration file for Supabase credentials
- Updated initialization logic

### Files Modified
- pubspec.yaml: Updated dependencies
- lib/main.dart: Changed initialization and imports
- lib/login_screen.dart: Updated to use Supabase auth
- lib/registration_screen.dart: Updated to use Supabase auth
- lib/screens/*: All screens updated to use Supabase
- lib/models/*: All models updated for Supabase
- lib/services/*: Firestore service replaced with Supabase service
- lib/config.dart: Added for Supabase configuration

### Files Created
- lib/services/supabase_service.dart: New service for Supabase operations
- lib/config.dart: Configuration file for Supabase credentials
- schema.sql: Complete Supabase database schema

### Database Schema Overview
The schema includes:
- **profiles** table: User profiles with roles (customer, owner, merchant)
- **office_spaces** table: Office spaces with location, pricing, and availability
- **products** table: Products available for purchase
- **bookings** table: Office space bookings with time ranges
- **user_carts** table: Temporary storage for shopping cart items

All tables have appropriate RLS policies ensuring users can only access their own data where appropriate, while allowing public read access for office spaces and products.

### Next Steps
1. Test the application with actual Supabase credentials
2. Deploy the database schema to a Supabase project
3. Configure proper authentication providers (email, Google, etc.)
4. Implement additional features like payment processing
5. Add more comprehensive error handling
6. Implement push notifications if needed
7. Add offline support if required

### Notes
- The application should be tested with actual Supabase project credentials
- Ensure CORS settings are properly configured for web deployment
- Consider implementing Supabase Functions for more complex server-side logic
- Monitor performance and add additional indexes as needed