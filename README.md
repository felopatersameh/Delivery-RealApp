# 🚀 Real-Time Delivery Management System

A comprehensive delivery management application built with Flutter, Firebase Realtime Database, and Firebase Cloud Messaging (FCM). The app manages complex workflows between three user types: Vendors, Customers, and Delivery Drivers with real-time synchronization and instant notifications.

## 📱 Demo

[Watch Demo Video on LinkedIn](https://www.linkedin.com/posts/felopatersameh_flutter-firebase-mobileappdevelopment-activity-7379036445925273600-l_sX?utm_source=share&utm_medium=member_desktop)

## ✨ Features

### For Vendors
- **Product Management**: Add, edit, and delete products in real-time
- **Order Management**: Accept or reject incoming orders
- **Instant Notifications**: Get notified immediately when new orders arrive
- **Order Tracking**: Monitor order status from placement to completion

### For Customers
- **Browse Products**: View all available products with real-time stock updates
- **Place Orders**: Add products to cart and place orders seamlessly
- **Order Tracking**: Track order status in real-time
- **OTP Verification**: Receive secure OTP code for order completion
- **Order History**: View past orders with detailed information

### For Delivery Drivers
- **Available Orders**: View all orders awaiting delivery assignment
- **Accept Orders**: Accept delivery requests instantly
- **Order Details**: Access customer and order information
- **OTP Completion**: Complete deliveries using customer OTP verification

## 🛠️ Tech Stack

- **Frontend**: Flutter with flutter_screenutil for responsive UI
- **State Management**: Bloc/Cubit pattern
- **Backend**: Firebase Realtime Database
- **Notifications**: Firebase Cloud Messaging (FCM)
- **Local Storage**: Hive for offline data persistence
- **Authentication**: Firebase Authentication

## 🏗️ Architecture

### State Management
- **Cubit Pattern**: Clean separation of business logic and UI
- **Single State**: Each feature manages its state independently
- **Real-time Listeners**: Automatic UI updates on data changes

### Order Status States
- **pending**: Order placed, waiting for vendor approval
- **removed**: Cancelled by customer (only before acceptance)
- **rejected**: Rejected by vendor with reason
- **searching**: Approved by vendor, visible to all drivers
- **running**: Accepted by driver, out for delivery
- **finished**: Delivered and completed with OTP verification

## 🔐 Security Features

- **Role-Based Access Control**: Users only see data relevant to their role
- **OTP Verification**: Secure 4-digit code for order completion
- **Firebase Security Rules**: Database access controlled by user authentication
- **Data Validation**: All inputs validated before database operations

## 🎨 Key UI Features

- **Responsive Design**: Adapts to different screen sizes using flutter_screenutil
- **Real-time Updates**: Live data synchronization across all users
- **Alphabetical Sorting**: Users and products organized alphabetically
- **Search & Filter**: Quick search through products and orders
- **Badge Notifications**: Visual indicators for new items
- **Invoice-Style Orders**: Professional order display with detailed information
- **Expandable Product Lists**: Show more/less functionality for multiple products
- **Status Indicators**: Color-coded status badges with progress tracking

## 📦 Key Packages
```yaml
dependencies:
  flutter_bloc: ^8.1.3
  flutter_screenutil: ^5.9.0
  firebase_core: ^2.24.2
  firebase_database: ^10.4.0
  firebase_messaging: ^14.7.9
  hive: ^2.2.3
  hive_flutter: ^1.1.0
