# Expense Tracker

A beautiful, feature-rich expense tracking application built with Flutter. Track your spending, analyze patterns, and make better financial decisions.

## ✅ Production-Ready App!

**Status**: Milestones 1-5 Complete | Full-Featured Expense Tracker

This app has evolved from a learning project into a fully functional expense tracker with comprehensive analytics, budget tracking, and cloud synchronization.

---

## 🚀 Features

### Core Functionality
- ✅ **Complete CRUD Operations**: Create, read, update, and delete expenses
- ✅ **Cloud Sync with Supabase**: Real-time data synchronization across devices
- ✅ **User Authentication**: Secure login with email/password
- ✅ **Category Management**: 8 pre-defined categories (Food, Transportation, Utilities, etc.)
- ✅ **Expense Types**: Classify spending as Must Have, Nice to Have, or Wasted
- ✅ **Form Validation**: Smart input validation with error handling

### Budget Tracking 🆕
- ✅ **Monthly Budget Setting**: Set and edit monthly spending budgets via Settings
- ✅ **Real-Time Progress Tracking**: Visual progress bars with color-coded indicators (green/orange/red)
- ✅ **Smart Alert System**: Warning banners at 70%, 90%, and 100% budget thresholds
- ✅ **Context-Aware Display**: Full budget view for current month, simplified for past months
- ✅ **Intelligent Alerts**: Dismissed banners reappear when budget severity changes
- ✅ **Graceful Degradation**: Works with or without budget set

### Analytics Dashboard
- ✅ **Month-by-Month Navigation**: Browse spending history by month
- ✅ **Monthly Summaries**: Compare current month vs previous month
- ✅ **Percentage Change Indicators**: Visual feedback on spending trends
- ✅ **Category Breakdown Chart**: Interactive bar chart showing spending by category
- ✅ **6-Month Trends**: Beautiful line chart visualizing spending patterns
- ✅ **Touch-Responsive Tooltips**: Tap charts for detailed information

### User Experience
- ✅ **Material Design 3**: Modern, beautiful UI following Google's latest design system
- ✅ **Bottom Navigation**: Seamless switching between Expenses and Analytics
- ✅ **Empty States**: Helpful messages when no data is available
- ✅ **Swipe to Delete**: Intuitive gesture-based deletion with undo
- ✅ **Responsive Layout**: Works great on different screen sizes

---

## 🛠 Tech Stack

- **Framework**: Flutter (latest stable)
- **Language**: Dart
- **State Management**: Provider pattern
- **Backend**: Supabase (PostgreSQL, Authentication, Real-time subscriptions)
- **Charts**: fl_chart (v0.69.0)
- **Design**: Material Design 3
- **Architecture**: Repository pattern with clean separation of concerns
  - Models, Providers, Repositories, Screens, Widgets, Services, Utils

---

## 📱 Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- Xcode (for iOS development)
- An iOS simulator or physical device

### Installation

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd expense_tracker
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### First Launch
The app will automatically load sample data (40+ expenses across 6 months) on first launch to demonstrate all features. You can delete this data and start fresh anytime.

---

## 📂 Project Structure

```
lib/
├── main.dart                          # App entry point with Providers
├── models/
│   ├── expense.dart                  # Expense data model
│   └── user_preferences.dart         # User settings model (budget, etc.)
├── providers/
│   ├── auth_provider.dart            # Authentication state
│   ├── expense_provider.dart         # Expense state management
│   └── user_preferences_provider.dart # Budget & settings state
├── repositories/
│   ├── expense_repository.dart       # Expense data interface
│   ├── user_preferences_repository.dart # Preferences interface
│   └── supabase_*.dart               # Supabase implementations
├── screens/
│   ├── auth_gate.dart                # Authentication routing
│   ├── login_screen.dart             # Login/signup UI
│   ├── expense_list_screen.dart      # Main expense list
│   ├── add_expense_screen.dart       # Add/Edit expense form
│   ├── analytics_screen.dart         # Analytics dashboard
│   └── settings_screen.dart          # Settings & budget config
├── utils/
│   ├── analytics_calculator.dart     # Analytics utilities
│   └── currency_formatter.dart       # VND formatting
└── widgets/
    ├── budget_alert_banner.dart      # Budget warning banners
    ├── category_chart.dart           # Category breakdown chart
    ├── trends_chart.dart             # Spending trends chart
    └── summary_cards/                # Analytics summary cards
        ├── monthly_overview_card.dart # Budget progress card
        └── type_breakdown_card.dart   # Spending type breakdown
```

---

## 🎯 Usage

### Adding an Expense
1. Tap the **+** button in the app bar
2. Fill in the expense details:
   - **Description**: What you spent money on
   - **Amount**: How much you spent
   - **Category**: Select from 8 categories
   - **Type**: Must Have, Nice to Have, or Wasted
   - **Date**: When the expense occurred
   - **Note** (optional): Additional details
3. Tap **Save**

### Editing an Expense
- Tap on any expense in the list to edit its details

### Deleting an Expense
- Swipe left on an expense
- Confirm deletion or tap **Undo** within 3 seconds

### Viewing Analytics
1. Tap the **Analytics** tab in the bottom navigation
2. Use ◀ ▶ arrows to navigate between months
3. View category breakdown and spending trends
4. Tap on charts for detailed tooltips

### Managing Monthly Budget
1. Tap the **Settings** icon (⚙️) in the top-right corner
2. Under "Budget", tap **Monthly Budget**
3. Enter your desired budget amount (e.g., 20,000,000 VND)
4. Tap **Save**
5. Budget progress will appear in Analytics and alert banners in Expense List

**Alert Thresholds:**
- **Green** (< 70%): On track
- **Orange** (70-90%): ⚠️ "Approaching budget limit"
- **Red** (90-100%): 🚨 "Near budget limit"
- **Dark Red** (> 100%): 🚨 "Budget exceeded"

---

## 📊 Milestones Completed

### Milestone 1: Basic UI with Dummy Data ✅
- Expense model and data structures
- Expense list screen with Material Design 3
- Add expense form with validation
- Navigation and state management basics

### Milestone 2: Local Data Persistence ✅
- SharedPreferences integration
- Storage service layer
- Full CRUD operations
- Edit and delete with confirmation/undo

### Milestone 3: Analytics & Charts ✅
- Bottom navigation with two tabs
- Provider state management pattern
- Analytics calculation utilities
- Month navigation and summaries
- Interactive fl_chart visualizations

### Milestone 4: Supabase Integration ✅
- User authentication (email/password)
- Cloud database migration
- Real-time data synchronization
- Row Level Security (RLS) policies
- Repository pattern implementation

### Milestone 5: Budget Tracking ✅
- Monthly budget settings
- Budget progress visualization
- Smart alert banners (70%, 90%, 100%)
- Context-aware displays
- Alert level change detection
- Production-ready with comprehensive testing

---

## 🔮 Future Roadmap

### Potential Next Features
- **Advanced Filtering**: Search and filter expenses by category, type, or date range
- **Data Export**: Export to CSV/PDF for external analysis
- **Custom Categories**: Create your own expense categories beyond the 8 defaults
- **Recurring Expenses**: Set up repeating transactions (subscriptions, rent, etc.)
- **Multi-Currency**: Support for different currencies with conversion rates
- **Advanced Reports**: Deeper insights and trend analysis
- **Home Screen Widgets**: Quick expense entry widgets
- **Category-Level Budgets**: Set separate budgets for each category

See `spec.md` for detailed feature planning.

---

## 📝 Documentation

- **MVP Archive**: See `docs/mvp/` for original specification and development history
- **Task Planning**: See `todo.md` for current and upcoming tasks
- **Feature Specs**: See `spec.md` for detailed feature specifications

---

## 🤝 Contributing

This is a personal learning project, but suggestions and feedback are welcome!

---

## 📄 License

This project is for educational purposes.

---

## 🙏 Acknowledgments

Built as a learning project to master Flutter development, from basics to production-ready features.

**Created**: October 2025
**Last Updated**: November 4, 2025
**Status**: Production-Ready - Budget Tracking Complete
