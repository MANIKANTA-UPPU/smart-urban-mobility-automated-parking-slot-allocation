# 🚗 Smart Urban Mobility & Automated Parking Slot Allocation

A full-stack microservices-based web application for smart parking slot discovery, automated allocation, and booking management — with JWT authentication, role-based access control, and a React frontend.

---

## Table of Contents

- [Overview](#overview)
- [Tech Stack](#tech-stack)
- [System Architecture](#system-architecture)
- [Project Structure](#project-structure)
- [Services](#services)
  - [API Gateway](#1-api-gateway-port-5000)
  - [Auth Service](#2-auth-service-port-5001)
  - [Parking Service](#3-parking-service-port-5002)
  - [Booking Service](#4-booking-service-port-5003)
  - [Frontend](#5-frontend-port-5173)
- [Database Design](#database-design)
- [API Reference](#api-reference)
- [Authentication & Authorization](#authentication--authorization)
- [Frontend Pages](#frontend-pages)
- [Environment Variables](#environment-variables)
- [Installation & Setup](#installation--setup)
- [Running the Project](#running-the-project)
- [Request & Response Examples](#request--response-examples)
- [Role-Based Access Control](#role-based-access-control)
- [Inter-Service Communication](#inter-service-communication)
- [Error Handling](#error-handling)

---

## Overview

Smart Urban Mobility is a backend + frontend system that solves urban parking problems by:

- Allowing users to **register and login** securely with JWT tokens
- Letting users **browse available parking slots** filtered by vehicle type
- Providing **auto-allocation** of the nearest available slot
- Enabling users to **book, complete, and cancel** parking sessions
- Automatically **calculating parking cost** based on duration × price per hour
- Giving admins full control to **create, update, and delete** parking slots
- Giving admins a **full view of all bookings** across all users

---

## Tech Stack

### Backend
| Technology | Version | Purpose |
|---|---|---|
| Node.js | v22.x | Runtime |
| Express.js | ^4.18.2 | HTTP framework |
| MongoDB | Running as Windows Service | Database |
| Mongoose | ^7.3.1 | ODM for MongoDB |
| JSON Web Token (jsonwebtoken) | ^9.0.0 | Authentication tokens |
| bcryptjs | ^2.4.3 | Password hashing |
| http-proxy-middleware | ^2.0.6 | API Gateway proxying |
| axios | ^1.4.0 | Inter-service HTTP calls |
| cors | ^2.8.5 | Cross-origin resource sharing |
| dotenv | ^16.0.3 | Environment variable management |
| nodemon | ^3.0.1 | Dev auto-restart |

### Frontend
| Technology | Version | Purpose |
|---|---|---|
| React | ^19.2.8 | UI framework |
| Vite | ^8.3.0 | Build tool & dev server |
| React Router DOM | ^7.18.4 | Client-side routing |
| Axios | ^1.20.0 | HTTP client |
| react-hot-toast | ^2.6.1 | Toast notifications |
| lucide-react | ^1.48.0 | Icons |

---

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    CLIENT (Browser)                          │
│              React + Vite  →  http://localhost:5173          │
└─────────────────────────┬───────────────────────────────────┘
                          │  All API requests
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                    API GATEWAY                               │
│                  http://localhost:5000                        │
│                                                              │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  CORS Middleware (allows localhost:5173, :3000)      │    │
│  └─────────────────────────────────────────────────────┘    │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  JWT Auth Middleware  (validates Bearer token)       │    │
│  └─────────────────────────────────────────────────────┘    │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  Admin Middleware  (checks x-user-role === admin)    │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                              │
│  /auth/*     ──────────────────────────────────────────►    │
│  /slots/*    ── authMiddleware ── [adminMiddleware] ────►    │
│  /bookings/* ── authMiddleware ─────────────────────────►   │
└──────┬──────────────────┬──────────────────┬───────────────┘
       │                  │                  │
       ▼                  ▼                  ▼
┌────────────┐   ┌────────────────┐   ┌──────────────────┐
│AUTH SERVICE│   │PARKING SERVICE │   │ BOOKING SERVICE  │
│  :5001     │   │    :5002       │   │     :5003        │
│            │   │                │   │                  │
│ MongoDB    │   │  MongoDB       │   │  MongoDB         │
│ auth DB    │   │  parking DB    │   │  booking DB      │
└────────────┘   └────────────────┘   └──────────────────┘
```

---

## Project Structure

```
PS011  Smart Urban Mobility & Automated Parking Slot Allocation/
│
├── api-gateway/                        # Entry point for all requests
│   ├── src/
│   │   ├── middleware/
│   │   │   ├── authMiddleware.js       # JWT token validation
│   │   │   └── adminMiddleware.js      # Admin role guard
│   │   └── index.js                    # Express app + proxy routes
│   ├── .env                            # PORT, JWT_SECRET, service URLs
│   └── package.json
│
├── auth-service/                       # User registration & login
│   ├── src/
│   │   ├── models/
│   │   │   └── User.js                 # Mongoose User schema
│   │   ├── routes/
│   │   │   └── authRoutes.js           # /register, /login, /me
│   │   └── index.js                    # Express app + MongoDB connect
│   ├── .env                            # PORT, MONGO_URI, JWT_SECRET
│   └── package.json
│
├── parking-service/                    # Parking slot management
│   ├── src/
│   │   ├── models/
│   │   │   └── Slot.js                 # Mongoose Slot schema
│   │   ├── routes/
│   │   │   └── slotRoutes.js           # CRUD + /available + /allocate
│   │   └── index.js                    # Express app + MongoDB connect
│   ├── .env                            # PORT, MONGO_URI
│   └── package.json
│
├── booking-service/                    # Booking lifecycle management
│   ├── src/
│   │   ├── models/
│   │   │   └── Booking.js              # Mongoose Booking schema
│   │   ├── routes/
│   │   │   └── bookingRoutes.js        # create, list, complete, cancel
│   │   └── index.js                    # Express app + MongoDB connect
│   ├── .env                            # PORT, MONGO_URI, PARKING_SERVICE_URL
│   └── package.json
│
├── frontend/                           # React + Vite SPA
│   ├── src/
│   │   ├── api/
│   │   │   └── client.js               # Axios instance + interceptors
│   │   ├── context/
│   │   │   └── AuthContext.jsx         # Global auth state (user, login, logout)
│   │   ├── components/
│   │   │   ├── Navbar.jsx              # Top navigation bar
│   │   │   └── ProtectedRoute.jsx      # Route guard (auth + admin)
│   │   ├── pages/
│   │   │   ├── Login.jsx               # Sign in page
│   │   │   ├── Register.jsx            # Create account page
│   │   │   ├── Dashboard.jsx           # Stats + quick actions
│   │   │   ├── Slots.jsx               # Browse & book slots
│   │   │   ├── Bookings.jsx            # User's booking history
│   │   │   ├── AdminSlots.jsx          # Admin: manage slots
│   │   │   └── AdminBookings.jsx       # Admin: view all bookings
│   │   ├── App.jsx                     # Routes definition
│   │   ├── main.jsx                    # React entry point
│   │   └── index.css                   # Global styles
│   ├── .env                            # VITE_API_URL
│   ├── vite.config.js                  # Vite config with fs.allow fix
│   └── package.json
│
├── docs/
│   └── architecture.md                 # Architecture documentation
│
├── start-all.ps1                       # PowerShell: launch all 5 services
├── start-all.bat                       # Batch file launcher
└── README.md                           # This file
```

---

## Services

### 1. API Gateway (Port 5000)

Single entry point for all client requests. Handles:
- **CORS** — allows `http://localhost:5173` and `http://localhost:3000`
- **JWT validation** — verifies `Authorization: Bearer <token>` on protected routes
- **Role enforcement** — blocks non-admins from `POST/PATCH/DELETE /slots`
- **Reverse proxying** — forwards requests to downstream services

**Middleware chain:**
```
Request → CORS → [authMiddleware] → [adminMiddleware] → Proxy → Service
```

**Route mapping:**
```
/auth/*     → http://localhost:5001  (no auth required)
/slots/*    → http://localhost:5002  (auth required; write ops = admin only)
/bookings/* → http://localhost:5003  (auth required)
```

**Dependencies:** `express`, `cors`, `dotenv`, `http-proxy-middleware`, `jsonwebtoken`

---

### 2. Auth Service (Port 5001)

Handles user identity. Connects to MongoDB database `smart_mobility_auth`.

**Endpoints:**
| Method | Path | Description |
|---|---|---|
| POST | /auth/register | Create new user account |
| POST | /auth/login | Login and receive JWT token |
| GET | /auth/me | Get current user profile from token |
| GET | /health | Service health check |

**Password security:** bcryptjs with salt rounds = 10

**JWT payload:**
```json
{
  "id": "user_mongodb_id",
  "email": "user@example.com",
  "role": "user | admin",
  "iat": 1234567890,
  "exp": 1234567890
}
```

**Token expiry:** 1 day (`1d`)

**Dependencies:** `express`, `mongoose`, `bcryptjs`, `jsonwebtoken`, `cors`, `dotenv`

---

### 3. Parking Service (Port 5002)

Manages parking slot inventory. Connects to MongoDB database `smart_mobility_parking`.

**Endpoints:**
| Method | Path | Auth | Description |
|---|---|---|---|
| POST | /slots | Admin | Create a new parking slot |
| GET | /slots | Any | Get all slots |
| GET | /slots/available | Any | Get available slots (filter by vehicleType) |
| GET | /slots/allocate | Any | Auto-allocate nearest available slot |
| GET | /slots/:id | Any | Get slot by ID |
| PATCH | /slots/:id | Admin | Update slot (availability, price, etc.) |
| DELETE | /slots/:id | Admin | Delete a slot |

**Auto-allocation logic:** Finds the first available slot sorted by `createdAt` ascending (oldest first = nearest registered).

**Dependencies:** `express`, `mongoose`, `cors`, `dotenv`

---

### 4. Booking Service (Port 5003)

Manages the full booking lifecycle. Connects to MongoDB database `smart_mobility_booking`. Communicates with parking-service directly via axios.

**Endpoints:**
| Method | Path | Auth | Description |
|---|---|---|---|
| POST | /bookings | Any | Create a booking (checks slot availability) |
| GET | /bookings | Any | Get all bookings (admin use) |
| GET | /bookings/user/:userId | Any | Get bookings for a specific user (enriched with slot info) |
| GET | /bookings/:id | Any | Get single booking by ID |
| PATCH | /bookings/:id/complete | Any | Complete booking + calculate cost |
| PATCH | /bookings/:id/cancel | Any | Cancel active booking |

**Cost calculation:**
```
durationHours = Math.max(1, Math.ceil((endTime - startTime) / 3600000))
totalCost     = durationHours × slot.pricePerHour
```
Minimum charge is 1 hour.

**Slot sync:** On booking creation → marks slot `isAvailable: false`. On complete/cancel → marks slot `isAvailable: true`.

**Dependencies:** `express`, `mongoose`, `axios`, `cors`, `dotenv`

---

### 5. Frontend (Port 5173)

React 19 SPA built with Vite 8. Dark-themed UI.

**Key files:**
- `src/api/client.js` — Axios instance with base URL `http://localhost:5000`, auto-attaches JWT from localStorage, auto-redirects to `/login` on 401
- `src/context/AuthContext.jsx` — React context storing `user` object and `token`, persisted in localStorage
- `src/components/ProtectedRoute.jsx` — Redirects unauthenticated users to `/login`, redirects non-admins away from admin routes
- `src/components/Navbar.jsx` — Sticky top nav with active link highlighting, role badge, logout

**Dependencies:** `react`, `react-dom`, `react-router-dom`, `axios`, `react-hot-toast`, `lucide-react`

---

## Database Design

### Database: `smart_mobility_auth`

**Collection: `users`**
```
{
  _id:        ObjectId       (auto)
  name:       String         required, trimmed
  email:      String         required, unique, lowercase
  password:   String         required, bcrypt hashed
  role:       String         enum: ["user", "admin"], default: "user"
  createdAt:  Date           auto (timestamps)
  updatedAt:  Date           auto (timestamps)
}
```

---

### Database: `smart_mobility_parking`

**Collection: `slots`**
```
{
  _id:          ObjectId     (auto)
  slotNumber:   String       required, unique  (e.g. "A-101")
  area:         String       required          (e.g. "Zone 1")
  isAvailable:  Boolean      default: true
  vehicleType:  String       enum: ["car", "bike", "ev"], default: "car"
  pricePerHour: Number       required          (e.g. 50)
  floor:        String       default: "G"      (e.g. "G", "1", "2")
  createdAt:    Date         auto (timestamps)
  updatedAt:    Date         auto (timestamps)
}
```

---

### Database: `smart_mobility_booking`

**Collection: `bookings`**
```
{
  _id:           ObjectId    (auto)
  userId:        String      required  (User._id as string)
  slotId:        String      required  (Slot._id as string)
  vehicleNumber: String      required  (e.g. "KA01AB1234")
  startTime:     Date        default: Date.now
  endTime:       Date        set on completion
  durationHours: Number      set on completion (min: 1)
  totalCost:     Number      set on completion (durationHours × pricePerHour)
  status:        String      enum: ["active", "completed", "cancelled"], default: "active"
  createdAt:     Date        auto (timestamps)
  updatedAt:     Date        auto (timestamps)
}
```

---

## API Reference

All requests go through the API Gateway at `http://localhost:5000`.

### Auth Routes (Public — No Token Required)

#### Register
```
POST /auth/register
Content-Type: application/json

{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "password123",
  "role": "user"
}

Response 201:
{
  "message": "User registered successfully",
  "user": { "id": "...", "name": "John Doe", "email": "john@example.com", "role": "user" }
}
```

#### Login
```
POST /auth/login
Content-Type: application/json

{
  "email": "john@example.com",
  "password": "password123"
}

Response 200:
{
  "message": "Login successful",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": { "id": "...", "name": "John Doe", "email": "john@example.com", "role": "user" }
}
```

#### Get Profile
```
GET /auth/me
Authorization: Bearer <token>

Response 200:
{ "id": "...", "name": "John Doe", "email": "john@example.com", "role": "user" }
```

---

### Slot Routes (JWT Required)

#### Get All Slots
```
GET /slots
Authorization: Bearer <token>
```

#### Get Available Slots
```
GET /slots/available
GET /slots/available?vehicleType=car
GET /slots/available?vehicleType=bike
GET /slots/available?vehicleType=ev
Authorization: Bearer <token>
```

#### Auto-Allocate Slot
```
GET /slots/allocate
GET /slots/allocate?vehicleType=car
Authorization: Bearer <token>

Response 200: Returns the first available slot sorted by creation date
```

#### Get Slot by ID
```
GET /slots/:id
Authorization: Bearer <token>
```

#### Create Slot (Admin Only)
```
POST /slots
Authorization: Bearer <admin_token>
Content-Type: application/json

{
  "slotNumber": "A-101",
  "area": "Zone 1",
  "vehicleType": "car",
  "pricePerHour": 50,
  "floor": "G"
}
```

#### Update Slot (Admin Only)
```
PATCH /slots/:id
Authorization: Bearer <admin_token>
Content-Type: application/json

{ "isAvailable": false }
{ "pricePerHour": 60 }
```

#### Delete Slot (Admin Only)
```
DELETE /slots/:id
Authorization: Bearer <admin_token>
```

---

### Booking Routes (JWT Required)

#### Create Booking
```
POST /bookings
Authorization: Bearer <token>
Content-Type: application/json

{
  "userId": "<user_id>",
  "slotId": "<slot_id>",
  "vehicleNumber": "KA01AB1234"
}

Response 201: Booking object with status "active"
```

#### Get All Bookings (Admin)
```
GET /bookings
Authorization: Bearer <token>
```

#### Get My Bookings
```
GET /bookings/user/:userId
Authorization: Bearer <token>

Response: Array of bookings enriched with slot details
[
  {
    "_id": "...",
    "userId": "...",
    "slotId": "...",
    "vehicleNumber": "KA01AB1234",
    "startTime": "2024-01-01T10:00:00.000Z",
    "status": "active",
    "slot": {
      "slotNumber": "A-101",
      "area": "Zone 1",
      "floor": "G",
      "vehicleType": "car",
      "pricePerHour": 50
    }
  }
]
```

#### Complete Booking
```
PATCH /bookings/:id/complete
Authorization: Bearer <token>

Response: Updated booking with endTime, durationHours, totalCost, status: "completed"
```

#### Cancel Booking
```
PATCH /bookings/:id/cancel
Authorization: Bearer <token>

Response: Updated booking with status: "cancelled"
```

---

## Authentication & Authorization

### JWT Flow
```
1. User calls POST /auth/login
2. Auth service validates credentials
3. Auth service signs JWT with { id, email, role } payload
4. Token returned to client
5. Client stores token in localStorage
6. Client sends token in every request: Authorization: Bearer <token>
7. API Gateway verifies token using JWT_SECRET
8. Decoded user info forwarded as headers: x-user-id, x-user-role
9. Admin middleware checks x-user-role for protected write operations
```

### Token Storage (Frontend)
- Token stored in `localStorage` under key `"token"`
- User object stored in `localStorage` under key `"user"`
- Axios interceptor auto-attaches token to every request
- On 401 response → auto-clears storage → redirects to `/login`

### Route Protection (Frontend)
```
Public routes:    /login, /register
Protected routes: /dashboard, /slots, /bookings  (any logged-in user)
Admin routes:     /admin/slots, /admin/bookings   (role === "admin" only)
```

---

## Frontend Pages

### /login — Login Page
- Email + password form
- Redirects to `/dashboard` if already logged in
- Shows toast on success/error

### /register — Register Page
- Name, email, password, role (user/admin) form
- Password minimum 6 characters validation
- Redirects to `/login` on success

### /dashboard — Dashboard
- Welcome message with user name and role badge
- Stats cards: Total Slots, Available Slots, My Active Bookings
- Quick action buttons: Find Slot, My Bookings, Manage Slots (admin), All Bookings (admin)
- How it works section

### /slots — Browse & Book Slots
- Filter tabs: All, Car, Bike, EV
- Grid of available slot cards showing: slot number, area, floor, vehicle type, price/hr
- Book Now button → opens booking modal
- Auto-Allocate button → finds nearest slot automatically
- Booking modal: shows slot details, vehicle number input, confirm/cancel

### /bookings — My Bookings
- Summary bar: Total, Active, Completed, Total Spent
- Booking cards with: vehicle number, slot info, start/end time, duration, cost, status badge
- Active bookings show: Complete & Pay button, Cancel button

### /admin/slots — Manage Slots (Admin Only)
- Stats: Total, Available, Occupied
- Add New Slot form: slot number, area, vehicle type, price/hr, floor
- Slots table with: slot number, area, type, floor, price, status
- Per-slot actions: Mark Occupied/Free, Delete (with inline confirm)

### /admin/bookings — All Bookings (Admin Only)
- Stats: Total, Active, Completed, Revenue
- Filter tabs: All, Active, Completed, Cancelled
- Table: vehicle number, user ID, slot ID, date, duration, cost, status

---

## Environment Variables

### api-gateway/.env
```env
PORT=5000
JWT_SECRET=supersecretkey123
AUTH_SERVICE_URL=http://localhost:5001
PARKING_SERVICE_URL=http://localhost:5002
BOOKING_SERVICE_URL=http://localhost:5003
```

### auth-service/.env
```env
PORT=5001
MONGO_URI=mongodb://127.0.0.1:27017/smart_mobility_auth
JWT_SECRET=supersecretkey123
```

> JWT_SECRET must be identical in both api-gateway and auth-service.

### parking-service/.env
```env
PORT=5002
MONGO_URI=mongodb://127.0.0.1:27017/smart_mobility_parking
```

### booking-service/.env
```env
PORT=5003
MONGO_URI=mongodb://127.0.0.1:27017/smart_mobility_booking
PARKING_SERVICE_URL=http://localhost:5002
```

### frontend/.env
```env
VITE_API_URL=http://localhost:5000
```

---

## Installation & Setup

### Prerequisites
- Node.js v18 or higher
- MongoDB installed and running as a service on port 27017

### Verify MongoDB is running (Windows)
```
sc query MongoDB
```
Expected output: `STATE: 4 RUNNING`

### Install dependencies for all services
```bash
cd auth-service    && npm install && cd ..
cd parking-service && npm install && cd ..
cd booking-service && npm install && cd ..
cd api-gateway     && npm install && cd ..
cd frontend        && npm install && cd ..
```

---

## Running the Project

### Option 1 — One command (Recommended)
From the project root, run:
```powershell
powershell -ExecutionPolicy Bypass -File start-all.ps1
```
This opens 5 separate terminal windows, one per service.

### Option 2 — Manual (5 separate terminals)

**Terminal 1 — Auth Service**
```bash
cd auth-service
npm start
# Auth service running on port 5001
# Auth DB connected
```

**Terminal 2 — Parking Service**
```bash
cd parking-service
npm start
# Parking service running on port 5002
# Parking DB connected
```

**Terminal 3 — Booking Service**
```bash
cd booking-service
npm start
# Booking service running on port 5003
# Booking DB connected
```

**Terminal 4 — API Gateway**
```bash
cd api-gateway
npm start
# API Gateway running on port 5000
```

**Terminal 5 — Frontend**
```bash
cd frontend
npm run dev
# Local: http://localhost:5173
```

### Service URLs
| Service | URL |
|---|---|
| Frontend | http://localhost:5173 |
| API Gateway | http://localhost:5000 |
| Auth Service | http://localhost:5001 |
| Parking Service | http://localhost:5002 |
| Booking Service | http://localhost:5003 |

---

## Request & Response Examples

### 1. Register as Admin
```bash
curl -X POST http://localhost:5000/auth/register \
  -H "Content-Type: application/json" \
  -d '{"name":"Admin User","email":"admin@test.com","password":"admin123","role":"admin"}'
```

### 2. Login
```bash
curl -X POST http://localhost:5000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@test.com","password":"admin123"}'
```

### 3. Create a Parking Slot (Admin)
```bash
curl -X POST http://localhost:5000/slots \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <admin_token>" \
  -d '{"slotNumber":"A-101","area":"Zone 1","vehicleType":"car","pricePerHour":50,"floor":"G"}'
```

### 4. Get Available Slots
```bash
curl http://localhost:5000/slots/available?vehicleType=car \
  -H "Authorization: Bearer <token>"
```

### 5. Auto-Allocate
```bash
curl http://localhost:5000/slots/allocate?vehicleType=car \
  -H "Authorization: Bearer <token>"
```

### 6. Create Booking
```bash
curl -X POST http://localhost:5000/bookings \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token>" \
  -d '{"userId":"<user_id>","slotId":"<slot_id>","vehicleNumber":"KA01AB1234"}'
```

### 7. Complete Booking
```bash
curl -X PATCH http://localhost:5000/bookings/<booking_id>/complete \
  -H "Authorization: Bearer <token>"
```

### 8. Cancel Booking
```bash
curl -X PATCH http://localhost:5000/bookings/<booking_id>/cancel \
  -H "Authorization: Bearer <token>"
```

---

## Role-Based Access Control

| Action | User | Admin |
|---|---|---|
| Register / Login | ✅ | ✅ |
| View available slots | ✅ | ✅ |
| Auto-allocate slot | ✅ | ✅ |
| Create booking | ✅ | ✅ |
| View own bookings | ✅ | ✅ |
| Complete booking | ✅ | ✅ |
| Cancel booking | ✅ | ✅ |
| Create parking slot | ❌ | ✅ |
| Update parking slot | ❌ | ✅ |
| Delete parking slot | ❌ | ✅ |
| View all bookings | ❌ | ✅ |
| Access /admin/slots | ❌ | ✅ |
| Access /admin/bookings | ❌ | ✅ |

---

## Inter-Service Communication

```
booking-service  ──axios──►  parking-service
  POST /bookings              GET  /slots/:id        (check availability)
  PATCH /bookings/:id/complete PATCH /slots/:id      (mark occupied/free)
  PATCH /bookings/:id/cancel   PATCH /slots/:id      (mark free)
```

The booking-service calls the parking-service **directly** (not through the gateway) using `PARKING_SERVICE_URL=http://localhost:5002` to avoid JWT overhead on internal calls.

---

## Error Handling

### HTTP Status Codes Used

| Code | Meaning |
|---|---|
| 200 | Success |
| 201 | Created |
| 400 | Bad request (missing fields, slot unavailable, already exists) |
| 401 | Unauthorized (missing or invalid JWT token) |
| 403 | Forbidden (not an admin) |
| 404 | Not found (user, slot, or booking not found) |
| 500 | Internal server error |
| 502 | Bad gateway (downstream service unavailable) |

### Frontend Error Handling
- All API errors shown as toast notifications (top-right)
- 401 responses auto-logout and redirect to `/login`
- Loading states on all buttons during async operations
- Empty states shown when no data is available
