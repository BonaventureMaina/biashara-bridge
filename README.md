# Biashara Bridge

**Empowering Kenyan SMEs with a digital identity, payment gateway, and business management platform.**

A production‑grade, multi‑tenant SaaS platform built to solve three critical market failures in Kenya:
- **80% of Kenyans lack a formal address**, crippling e‑commerce and logistics.
- **SMEs are invisible** to financial services and supply chains without a centralised digital identity.
- **No unified platform** combines digital addressing, payments, and business tools.

Biashara Bridge provides every registered business with a unique **Biashara Code**, a mapped physical location, an integrated M‑Pesa payment gateway, and a geospatial analytics dashboard — unlocking Kenya’s $1B+ e‑commerce potential.

---

## 🚀 Live Demo

**https://biashara-bridge-dev.web.app**

> Test credentials: `portfolio@biasharabridge.dev` / `test999`

---

## 📸 Features

### 🔐 Authentication
- Email/password sign‑up and sign‑in
- Stream‑driven auth state management (Riverpod + Firebase Auth)

### 🏢 Digital Identity & Addressing
- Map‑based business registration (tap‑to‑select location)
- Reverse geocoding via OpenStreetMap Nominatim
- Unique human‑readable **Biashara Code** (e.g. `BSH-NAI-3816`)
- Public business profile at `/#/business/BSH-XXXX`

### 💰 Payments & Procurement (M‑Pesa)
- Invoice generator with STK Push integration
- Secure server‑side payment processing via Firebase Cloud Function
- Sandbox‑tested against the Safaricom Daraja API

### 🗺️ Geospatial Analytics
- Live map showing all registered businesses
- Category filters (retail, agritech, logistics, other)
- Ready for heatmap overlays showing underserved areas

### 🧭 Progressive Web App (PWA)
- Built with Flutter Web – fast, responsive, and installable
- Offline‑capable asset caching (service worker)

---

## 🧱 Architecture

* lib/
  * main.dart                     Entry point, Firebase & Riverpod init
  * app.dart                      Root widget, auth‑gated routing
  * core/
    * constants/                 App‑wide constants (Biashara Code pattern)
    * errors/                    Failure sealed class (Freezed)
    * services/                  Abstract interfaces (IAuthService, IBusinessRepository, IPaymentService)
    * utils/                     Biashara code generator, location utils, validators
    * theme/                     Kenyan‑inspired Material 3 theme
  * data/
    * datasources/remote/        Firebase Auth, Firestore, Daraja API implementations
    * models/                    Data models (UserModel, BusinessModel)
    * repositories/              Repository implementations (clean architecture pattern)
  * features/
    * auth/                      Login, sign‑up, auth providers
    * registration/              Business registration, map picker, Biashara Code generation
    * dashboard/                 User's business list
    * payments/                  Invoice generator, payment providers
    * analytics/                 Geospatial map with filters

### Design Patterns
- **Clean Architecture** – Domain entities, abstract interfaces, datasources, repositories
- **Riverpod** – State management with `StreamProvider`, `FutureProvider.family`, `Provider`
- **Repository Pattern** – Backend‑agnostic; Firebase today, custom backend tomorrow
- **Freezed** – Immutable entities with union types for errors

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|------------|
| Frontend | Flutter Web (PWA) |
| State Management | Riverpod |
| Backend | Firebase (Auth, Firestore, Cloud Functions) |
| Maps | flutter_map (OpenStreetMap) |
| Payments | Safaricom Daraja API (M‑Pesa STK Push) |
| Testing | Flutter Test, mocktail |
| CI/CD | GitHub Actions (planned) |
| Hosting | Firebase Hosting |
| Build System | Dart, build_runner, freezed, json_serializable |

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (≥3.35)
- Firebase CLI
- Node.js (for Cloud Functions emulator)

### Installation

    git clone https://github.com/BonaventureMaina/biashara-bridge.git
    cd biashara_bridge
    flutter pub get
    flutter run -d chrome

### Firebase Emulator (for payment testing)

    cd functions && npm install
    cd ..
    firebase emulators:start --project biashara-bridge-dev

Then in a second terminal:

    flutter run -d chrome

### Deploy to Firebase Hosting

    flutter build web --no-wasm-dry-run
    firebase deploy --only hosting --project biashara-bridge-dev

---

## 📊 Testing

    flutter test
    flutter test test/registration_test.dart

---

## 🧪 Sandbox Credentials

The project includes a **temporary** Biashara Code generator (client‑side).  
The M‑Pesa integration uses the Safaricom Daraja sandbox:

- Shortcode: `174379`
- Passkey: (standard sandbox passkey)
- Consumer Key/Secret: stored in `functions/.env` (not committed)

---

## 🗺️ Roadmap

- [x] Authentication (email/password)
- [x] Business registration with map picker
- [x] Biashara Code generation
- [x] Public business profile + deep link
- [x] M‑Pesa STK Push integration
- [x] Geospatial analytics map
- [ ] Heatmap overlay for underserved areas
- [ ] Procurement module (bulk deals)
- [ ] Integration tests for core flows
- [ ] CI/CD with GitHub Actions
- [ ] Offline inventory management

---

## 📄 License

This project is part of a professional portfolio and is not licensed for commercial use.

---

**Built by [Bonaventure Maina]** — *Lead Flutter/Dart Engineer & Architect*
