# Storeffice - Office Space Booking & Product Storage Platform

<div align="center">

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Flutter](https://img.shields.io/badge/Flutter-Framework-blue.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-Language-blue.svg)](https://dart.dev/)
[![Build Status](https://img.shields.io/badge/Status-Development-orange)](https://github.com/)

</div>

## 🚀 Executive Summary

Storeffice is a revolutionary dual-purpose marketplace platform that transforms underutilized office spaces into flexible rental resources while providing merchants with cost-effective product storage and advertising solutions. Our hybrid model combines the best of Airbnb's space booking experience with Alibaba/Amazon's marketplace functionality, creating an innovative ecosystem where office owners can monetize their spaces, merchants can store and sell their products, and customers can discover and purchase goods seamlessly.

**Target Launch:** Q2 2026  
**Primary Markets:** Urban business districts, co-working hubs, commercial zones  
**Platform Strategy:** Web, iOS, Android with unified experience

## 💡 Vision & Mission

### Vision
To revolutionize the commercial real estate and e-commerce landscape by creating an integrated platform that maximizes space utilization and enhances business opportunities for entrepreneurs and property owners alike.

### Mission
We are committed to building a technology-driven marketplace that:
- Empowers property owners to monetize underutilized spaces
- Provides flexible, affordable storage solutions for merchants
- Creates seamless booking and purchasing experiences for customers
- Drives innovation in the sharing economy through our unique hybrid model

## 📊 Market Opportunity

### Market Size
- Commercial real estate market: $1.7 trillion globally
- E-commerce market: $5.2 trillion with 14.7% annual growth
- Flexible workspace market: $138 billion with 20% CAGR
- Shared storage market: $47 billion growing at 8% annually

### Target Audience
- **Office Owners**: Property managers, co-working spaces, commercial real estate owners
- **Merchants**: Small to medium-sized businesses, e-commerce sellers, retail entrepreneurs
- **Customers**: Business professionals, remote workers, product shoppers

## 🎯 Key Features

### For Office Owners
- **Space Listing**: Easy-to-use platform for listing office spaces with photos, amenities, and pricing
- **Calendar Management**: Real-time booking calendar with availability control
- **Revenue Optimization**: Competitive pricing tools and analytics dashboard
- **Multi-Platform Access**: Manage your spaces from anywhere, any device

### For Merchants
- **Flexible Storage**: Rent shelf and storage spaces with multiple pricing options
- **Product Marketplace**: Advertise and sell products directly on our platform
- **Inventory Management**: Track products across multiple storage locations
- **Business Analytics**: Detailed performance metrics and insights

### For Customers
- **Seamless Booking**: Discover and book office spaces in under 3 minutes
- **Product Discovery**: Browse and purchase products with secure payment options
- **Real-Time Availability**: Instant confirmation with live inventory tracking
- **Quality Assurance**: Verified spaces and products with user reviews

## 🛠️ Technical Architecture

### Technology Stack
- **Frontend**: Flutter (Cross-platform mobile), React (Web)
- **Backend**: Node.js with Express.js
- **Database**: MongoDB with Mongoose ODM
- **Authentication**: Supabase Auth and JWT
- **File Storage**: AWS S3
- **Map Integration**: Google Maps API
- **Payment Processing**: Stripe
- **Notifications**: Firebase Cloud Messaging

### System Architecture
```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Web App       │    │   Mobile App     │    │   Admin Panel   │
│   (React)       │    │   (Flutter)      │    │   (React)       │
└─────────┬───────┘    └─────────┬────────┘    └─────────┬───────┘
          │                      │                       │
          │                      │                       │
          └──────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────▼─────────────┐
                    │      API Gateway          │
                    │    (Node.js/Express)      │
                    └─────────────┬─────────────┘
                                 │
        ┌─────────────────────────┼─────────────────────────┐
        │                         │                         │
┌───────▼────────┐    ┌───────────▼───────────┐    ┌───────▼────────┐
│ Authentication │    │      Booking API      │    │ Marketplace    │
│     Service    │    │                       │    │     API        │
└────────────────┘    └───────────────────────┘    └────────────────┘
        │                         │                         │
        │                         │                         │
        └─────────────────────────┼─────────────────────────┘
                                 │
                    ┌─────────────▼─────────────┐
                    │        Database           │
                    │        (MongoDB)          │
                    └───────────────────────────┘
```

### Key Technical Features
- **Responsive Design**: Optimized for all screen sizes
- **Real-time Updates**: Live availability and inventory tracking
- **Secure Payments**: PCI-DSS compliant payment processing
- **Cloud Infrastructure**: Scalable AWS deployment
- **API-First Design**: RESTful APIs with comprehensive documentation
- **Caching Strategy**: Redis for improved performance
- **Monitoring**: Real-time metrics and alerting

## 📈 Business Model

### Revenue Streams
1. **Booking Commissions**: Percentage of office space booking values
2. **Storage Fees**: Monthly rental fees for storage spaces
3. **Listing Fees**: Premium product listing charges
4. **Service Fees**: Transaction processing fees

### Financial Projections
- **Year 1**: 10,000+ active users, $500K revenue
- **Year 2**: Market expansion to 5 metropolitan areas, $2M revenue
- **Year 3**: Feature enhancement and enterprise solutions, $8M revenue

## 🏗️ Development Roadmap

### Phase 1: Foundation (Months 1-3)
- ✅ User authentication and profile management
- ✅ Office space listing and booking system
- ✅ Basic payment integration
- ✅ Admin panel development

### Phase 2: Marketplace Development (Months 4-6)
- Storage space rental functionality
- Product listing and marketplace features
- Shopping cart and checkout flow
- Mobile app development

### Phase 3: Enhancement and Testing (Months 7-9)
- Advanced features and optimization
- Comprehensive testing and quality assurance
- Security audit and performance optimization

### Phase 4: Launch and Growth (Months 10-12)
- Soft launch in selected markets
- Marketing and user acquisition
- Full public launch with 10,000+ users

## 📊 Success Metrics

### Key Performance Indicators
- **User Growth**: 10,000+ active users within 12 months
- **Booking Volume**: Sub-3 minute average transaction time
- **Platform Uptime**: 99.9% reliability
- **Page Load Time**: Under 2 seconds across platforms
- **Payment Success Rate**: 99%+ transaction completion
- **User Satisfaction**: 4.2+ average rating

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- Dart SDK
- Node.js (v16+)
- MongoDB
- Git

### Installation

1. Clone the repository:
```bash
git clone https://github.com/your-organization/storeffice.git
cd storeffice
```

2. Install Flutter dependencies:
```bash
flutter pub get
```

3. Install backend dependencies:
```bash
cd backend
npm install
```

4. Set up environment variables (see `.env.example`)

5. Run the application:
```bash
# For Flutter app
flutter run

# For backend server
npm start
```

### Configuration
Create a `.env` file in the backend directory with the following:
```
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
MONGODB_URI=your_mongodb_connection_string
STRIPE_SECRET_KEY=your_stripe_secret_key
GOOGLE_MAPS_API_KEY=your_google_maps_api_key
```

## 🧪 Testing

### Unit Tests
```bash
flutter test
```

### Integration Tests
```bash
flutter drive --target=test_driver/app.dart
```

### Backend Tests
```bash
cd backend
npm test
```

## 🎯 Demo User Access

Storeffice includes a convenient demo user feature that allows potential users to explore the platform without creating an account.

### Demo Account Credentials
- **Email**: `demo@storeffice.com`
- **Password**: `DemoPassword123!`

### Demo User Features
- Access to sample office spaces with realistic details
- Browse sample products from various categories
- Experience core booking and purchasing workflows
- View sample user dashboard and functionality

### Quick Access
On the login screen, you can click the **"Continue as Demo User"** button to access the platform immediately without entering credentials.

The demo account is pre-populated with realistic sample data including office spaces, products, and other content to provide an authentic experience of the Storeffice platform.

## 🤝 Contributing

We welcome contributions from the community! Please read our [Contributing Guide](CONTRIBUTING.md) to learn about our development process and how to submit pull requests.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Support

- **Documentation**: [Storeffice Documentation](link-to-docs)
- **Issues**: [GitHub Issues](https://github.com/your-organization/storeffice/issues)
- **Email**: support@storeffice.com
- **Community**: [Discord](link-to-discord) | [Slack](link-to-slack)

## 🚨 Important Deployment Notes

When deploying Storeffice, please note the following requirements:

### Supabase Edge Functions
- The OTP authentication system requires two deployed Edge Functions: `otp-auth` and `otp-verify`
- These functions handle OTP generation, verification, and email delivery
- Functions must be deployed to your Supabase project using the Supabase CLI

### CORS Configuration 
- For web applications, configure CORS settings in your Supabase dashboard
- Add your domain (including localhost for development) to allowed origins
- For development: add `http://localhost:[PORT]` to allowed origins

### Environment Variables
- Set up required environment variables in Supabase: `RESEND_API_KEY`, `FROM_EMAIL`, `SUPABASE_SERVICE_ROLE_KEY`
- Configure email provider (Resend or SendGrid) for OTP delivery

### Database Setup
- Run the provided schema.sql or SCHEMA_OPTIMIZED.sql to set up required tables and functions
- Ensure Row Level Security (RLS) policies are properly configured

---

## 🏆 Awards & Recognition

*Coming soon - Our journey to revolutionize the commercial space and e-commerce industry*

---

<div align="center">

**Storeffice** - *Transforming Spaces, Enabling Businesses*

[Website](https://storeffice.com) | [Twitter](https://twitter.com/storeffice) | [LinkedIn](https://linkedin.com/company/storeffice) | [Blog](https://blog.storeffice.com)

*© 2025 Storeffice. All rights reserved.*

</div>