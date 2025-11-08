# Blueprint: Storeffice Flutter App

## Overview

This document outlines the plan and progress for building the "Storeffice" application, a dual-purpose marketplace for office space booking and product storage/sales.

The application has been built using Flutter for the cross-platform (iOS, Android, Web) frontend and Firebase for the backend services (Authentication, Firestore Database, Storage, etc.), as requested.

## Completed Features

### 1. Core & Foundation
- **Environment & Project Setup**: Configured Firebase and set up the Flutter project with necessary dependencies.
- **Application Structure**: Implemented theming (light/dark mode with `provider`), an authentication wrapper, and initial screen routing.

### 2. Role-Based Access Control
- **User Roles**: Implemented a role-based system with three distinct user groups: `Owner`, `Merchant`, and `Customer`.
- **Registration**: Updated the registration screen to include a role selection dropdown, storing the user's role in Firestore.
- **Dynamic UI**: The home page now dynamically displays different UI elements and navigation options based on the logged-in user's role, ensuring a tailored experience for each user group.

### 3. Authentication System
- **UI Screens & Functionality**: Created separate, functional screens for Login (`login_screen.dart`) and Registration (`registration_screen.dart`) with email/password authentication using `FirebaseAuth`.
- **Navigation & Error Handling**: Set up named routes and basic error handling for the authentication flow.

### 4. Office Space Management & Booking
- **Data Models**: Defined the `OfficeSpace` and `Booking` classes.
- **Firestore Service**: Created a `FirestoreService` with methods to add and retrieve office spaces and bookings. Implemented a Firestore transaction to prevent conflicting bookings.
- **User Interface (UI)**:
    - Built a screen to add new office spaces (`add_office_space_screen.dart`), accessible only to `Owner` roles.
    - Built a screen to display a list of all available spaces (`office_space_list_screen.dart`) with a "Book Now" button, accessible to all roles.
    - Built a `BookingScreen` to allow users to select dates and times for their reservations.
    - Built a `MyBookingsScreen` for `Customer` roles to view their booking history.
- **Navigation**: Integrated all office space and booking screens for a seamless user flow.

### 5. Marketplace & Shopping Cart
- **Data Models**: Defined `Product`, `CartItem`, and `Cart` classes.
- **Firestore Service**: Extended the `FirestoreService` to include functions for adding and retrieving products.
- **State Management**: Implemented a `CartProvider` using the `provider` package to manage the application's shopping cart state globally.
- **User Interface (UI)**:
    - Built a screen to add new products (`add_product_screen.dart`), accessible only to `Merchant` roles.
    - Built a `ProductListScreen` displaying available products with an "Add to Cart" button for `Customer` roles.
    - Created a `CartScreen` to display items in the cart, show the total price, and allow users to remove items.
    - Added a cart icon with a badge to the main app bar for `Customer` roles, showing the number of items in the cart.
- **Navigation**: Integrated product and cart screens into the main application.

## Project Complete

All core features have been successfully implemented. The Storeffice application now includes:
- User authentication (Login & Registration).
- A complete office space booking system.
- A functional product marketplace with a shopping cart.
- A user profile section to view past bookings.
- Role-based access control to tailor the experience for different user groups.

The application is now feature-complete based on the initial requirements. Future work could include UI refinement, payment gateway integration, and more advanced error handling.
