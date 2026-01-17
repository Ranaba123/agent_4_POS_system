# POS Debtor App

A comprehensive, offline-first Point of Sale (POS) debtor management application built with Flutter. This application allows business owners to track debtors, manage settlements, view transaction history, and generate reports, all with a modern, intuitive, and responsive user interface.

## 🚀 Features

*   **Dashboard Overview**: Get a quick summary of total outstanding debts, debtors due today, and recent activities.
*   **Debtor Management**: Add, edit, and delete debtor profiles with details like name, phone number, and due dates.
*   **Transaction Tracking**: Record debts (increase outstanding) and payments (decrease outstanding) with notes.
*   **History & Logs**: View detailed transaction history for each debtor.
*   **Settlement Management**: Track settlements and payments efficiently.
*   **Search & Filter**: Easily find debtors by name, due date, or outstanding balance.
*   **Reports**: View top debtors and financial insights.
*   **Dark Mode**: Fully supported dark theme for low-light environments.
*   **Localization**: Support for multiple languages (English, Tamil, Sinhala) - *In Progress*.
*   **Offline First**: Built with Hive for localized, fast, and offline-capable data storage.

## 🛠️ Technology Stack

*   **Framework**: [Flutter](https://flutter.dev/) (SDK >=3.0.0 <4.0.0)
*   **Language**: [Dart](https://dart.dev/)
*   **State Management**: [Provider](https://pub.dev/packages/provider) (^6.1.2)
*   **Local Database**: [Hive](https://pub.dev/packages/hive) (^2.2.3) & [Hive Flutter](https://pub.dev/packages/hive_flutter)
*   **UI Components**: Material Design 3
*   **Charts**: [fl_chart](https://pub.dev/packages/fl_chart) (^0.68.0)
*   **Formatting**: [intl](https://pub.dev/packages/intl) (^0.19.0)
*   **Fonts**: [google_fonts](https://pub.dev/packages/google_fonts) (^6.2.1)
*   **Utilities**: [uuid](https://pub.dev/packages/uuid), [url_launcher](https://pub.dev/packages/url_launcher)

## 📂 Project Structure

```
lib/
├── core/                   # Core utilities (Theme, Localization)
├── data/                   # Data layer
│   ├── models/             # Hive Models (Debtor, Settlement)
│   └── ...
├── presentation/           # UI Layer
│   ├── screens/            # Application Screens
│   │   ├── dashboard/      # Dashboard Logic
│   │   ├── debtors/        # Debtor List, Detail, Add
│   │   ├── reports/        # Reports & Charts
│   │   ├── settings/       # App Settings
│   │   └── main_screen.dart # Root Navigation
│   └── viewmodels/         # ViewModels (Provider)
└── main.dart               # Entry Point
```

## ⚡ Getting Started

### Prerequisites

*   Flutter SDK installed and configured.
*   An IDE (VS Code or Android Studio) with Flutter plugins.

### Installation

1.  **Clone the repository**:
    ```bash
    git clone https://github.com/Thiveya-Ratnarajah/POS_System.git
    cd pos_debtor_app
    ```

2.  **Install dependencies**:
    ```bash
    flutter pub get
    ```

3.  **Run the application**:
    ```bash
    flutter run
    ```
