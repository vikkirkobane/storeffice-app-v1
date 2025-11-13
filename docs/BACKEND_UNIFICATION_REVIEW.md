# Storeffice Backend Unification Review

## Overview
This document reviews the alignment between the Storeffice Flutter app and the unified backend schema to ensure seamless integration with a NextJS frontend.

## Current Flutter App vs Unified Schema Analysis

### 1. Table Structure Alignment

#### Profiles Table
**Current Flutter App:**
- Basic fields: id, email, role
- Missing: first_name, last_name, profile_photo, device_tokens, preferences, etc.

**Unified Schema:**
- Comprehensive user profile with mobile-optimized fields
- Device tokens for push notifications
- Preferences JSONB for app settings
- Online status tracking
- Platform identification

**Action Required:** Update User model to include all relevant fields

#### Office Spaces Table
**Current Flutter App:**
- Basic fields: id, owner_id, title, description, location, pricing, capacity
- Location as separate latitude/longitude fields
- Pricing as simple map

**Unified Schema:**
- Additional mobile-optimized fields: thumbnail_photo, search_keywords
- Location as JSONB: {address, city, state, zipCode, country, coordinates: [lng, lat]}
- Pricing as structured JSONB with multiple pricing tiers
- Additional metrics: rating, review_count, view_count, favorite_count
- Verification status and featured status

**Action Required:** Update OfficeSpace model and database queries

#### Products Table
**Current Flutter App:**
- Basic fields: id, seller_id, name, description, price, image_url

**Unified Schema:**
- Additional fields: merchant_id, storage_id, category, subcategory, inventory, sku
- Mobile-optimized: thumbnail_image, search_keywords, tags
- Shipping info: weight, dimensions, shipping_info
- Metrics: rating, review_count, sales_count, etc.

**Action Required:** Update Product model to match unified schema

#### Bookings Table
**Current Flutter App:**
- Basic fields: id, user_id, office_space_id, start_time, end_time, total_price, status

**Unified Schema:**
- Additional mobile fields: check_in_time, check_out_time, qr_code, special_requests
- Cancellation information
- Payment integration

**Action Required:** Update Booking model and service

### 2. Missing Features in Current Flutter App

#### Push Notifications
- Device token management missing
- Notification table integration missing

#### Real-time Messaging
- Conversations and messages tables not implemented
- Real-time chat functionality missing

#### Reviews System
- Reviews table not implemented
- Rating and review functionality missing

#### Favorites
- Favorites system not implemented

#### Analytics
- Analytics events table not implemented

#### App Feedback
- Feedback system not implemented

### 3. Required Updates to Align with Unified Schema

#### Update Models

**UserProfile Model Changes:**
- Add missing fields: first_name, last_name, profile_photo, phone
- Add device_tokens, preferences JSONB
- Add last_seen, app_version, platform, is_online
- Add verification and active status flags

**OfficeSpace Model Changes:**
- Change location from separate lat/lon to JSONB structure
- Add thumbnail_photo, search_keywords
- Update pricing to support multiple pricing tiers
- Add metrics: rating, review_count, etc.
- Add verification and featured status

**Product Model Changes:**
- Add category, subcategory, inventory, sku fields
- Add thumbnail_image, search_keywords, tags
- Add shipping info: weight, dimensions
- Add metrics: rating, sales_count, etc.

**Booking Model Changes:**
- Add check_in_time, check_out_time, qr_code
- Add special_requests and cancellation fields

#### Update Services

**SupabaseService Updates:**
- Add methods for new unified schema tables
- Update existing methods to work with extended schema
- Add review management
- Add favorites management
- Add messaging functionality
- Add analytics tracking
- Add feedback functionality

#### Add New Services

**NotificationService:** For push notifications
**MessageService:** For real-time messaging
**ReviewService:** For review management
**AnalyticsService:** For tracking user behavior

### 4. Database Query Updates

All current database queries need to be updated to:
- Handle new column names and structures
- Support mobile-optimized fields
- Work with JSONB data types
- Implement proper filtering and searching

### 5. Real-time Features

Current implementation doesn't include real-time features like:
- Live online status updates
- Real-time messaging
- Live notifications
- Live booking updates

### 6. Security Policies

RLS policies are already implemented in the schema, so we need to ensure:
- All queries respect the policies
- Proper authentication is in place
- No bypassing of security measures

## Implementation Plan

### Phase 1: Model Updates
1. Update all data models to match unified schema
2. Ensure proper serialization/deserialization
3. Add missing fields and remove deprecated ones

### Phase 2: Service Updates
1. Update SupabaseService to handle new schema
2. Add new service classes for missing functionality
3. Ensure all queries work with new schema

### Phase 3: UI Updates
1. Update screens to display new fields
2. Add new features like favorites, reviews, messaging
3. Implement push notifications

### Phase 4: Testing
1. Test database queries with new schema
2. Verify RLS policies work correctly
3. Ensure cross-platform compatibility

## Next Steps

1. Update data models to match unified schema
2. Modify services to work with new table structures
3. Add missing backend functionality to Flutter app
4. Test integration with NextJS to ensure seamless sharing