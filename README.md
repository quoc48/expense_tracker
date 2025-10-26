# Expense Tracker

A beautiful, feature-rich expense tracking application built with Flutter. Track your spending, analyze patterns, and make better financial decisions.

## ✅ MVP Complete!

**Status**: Milestones 1-3 Complete | Production-Ready MVP

This app has evolved from a learning project into a fully functional expense tracker with comprehensive analytics and data visualization.

---

## 🚀 Features

### Core Functionality
- ✅ **Complete CRUD Operations**: Create, read, update, and delete expenses
- ✅ **Local Data Persistence**: All data saved locally using shared_preferences
- ✅ **Category Management**: 8 pre-defined categories (Food, Transportation, Utilities, etc.)
- ✅ **Expense Types**: Classify spending as Must Have, Nice to Have, or Wasted
- ✅ **Form Validation**: Smart input validation with error handling

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
- **Local Storage**: shared_preferences
- **Charts**: fl_chart (v0.69.0)
- **Design**: Material Design 3
- **Architecture**: Clean separation of concerns (Models, Providers, Screens, Widgets, Services, Utils)

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
├── main.dart                          # App entry point with Provider setup
├── models/
│   ├── expense.dart                  # Expense data model with enums
│   ├── month_total.dart              # Monthly analytics model
│   └── dummy_data.dart               # Sample data for testing
├── providers/
│   └── expense_provider.dart         # Global state management
├── screens/
│   ├── main_navigation_screen.dart   # Bottom navigation container
│   ├── expense_list_screen.dart      # Main expense list view
│   ├── add_expense_screen.dart       # Add/Edit expense form
│   └── analytics_screen.dart         # Analytics dashboard
├── services/
│   └── storage_service.dart          # Local data persistence
├── utils/
│   └── analytics_calculator.dart     # Analytics calculation utilities
└── widgets/
    ├── category_chart.dart           # Category breakdown bar chart
    └── trends_chart.dart             # Spending trends line chart
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

---

## 🔮 Future Roadmap

### Potential Next Features
- **Budget Tracking**: Set monthly budgets with alerts
- **Advanced Filtering**: Search and filter expenses
- **Data Export**: Export to CSV/PDF
- **Custom Categories**: Create your own expense categories
- **Recurring Expenses**: Set up repeating transactions
- **Cloud Sync**: Firebase integration for multi-device sync
- **Multi-Currency**: Support for different currencies
- **Reports**: Advanced analytics and insights
- **Widgets**: Home screen widgets for quick expense entry

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
**Last Updated**: October 26, 2025
**Status**: MVP Complete - Ready for Advanced Features
