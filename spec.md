# Expense Tracker - Project Specification

## 📋 Requirements

### Core Features
- **Add Expenses**: Create new expense entries with detailed information
  - Description (required)
  - Amount (required, numeric)
  - Category (required, predefined list)
  - Type (required): Must Have / Nice to Have / Wasted
  - Date (required, with date picker)
  - Note (optional, for additional context)

- **Edit Expenses**: Modify existing expense entries

- **Delete Expenses**: Remove unwanted expense entries

- **View Expenses**: Display list of all expenses with key information

- **Monthly Summary**:
  - Total spending for selected month
  - Breakdown by category (bar chart)
  - Breakdown by type (bar chart)

- **Data Persistence**: All data survives app restarts via local storage

---

## 🛠️ Tech Stack

### Framework & Language
- **Flutter**: Latest stable version
- **Dart**: Latest stable version

### Storage & State
- **Local Storage**: `shared_preferences` package
  - Simple key-value storage
  - JSON serialization for complex data
  - Suitable for small to medium datasets

### Visualization
- **Charts**: `fl_chart` package
  - Bar charts for category breakdown
  - Bar charts for type breakdown
  - Customizable and performant

### State Management Evolution
- **Milestone 1-2**: `setState` (built-in, simple)
- **Milestone 3**: `provider` package (scalable, recommended by Flutter team)

### UI Framework
- **Material Design 3**: Modern Flutter Material library
- **Material Icons**: Built-in icon set

---

## 🎨 Design Guidelines

### Visual Principles
- **Material Design 3**: Follow latest Material Design specifications
- **Clean UI**: Minimalist interface, focus on content
- **Visual Hierarchy**: Clear information structure
- **Intuitive Navigation**: Easy to understand flow

### Color Scheme
- **Expense Types Color Coding**:
  - Must Have: Green (essential spending)
  - Nice to Have: Yellow/Orange (discretionary spending)
  - Wasted: Red (regrettable spending)

### Accessibility
- Sufficient color contrast (WCAG AA minimum)
- Readable font sizes (16sp minimum for body text)
- Clear touch targets (48x48 minimum)
- Descriptive labels for all interactive elements

### Responsive Design
- Support various screen sizes (phones, tablets)
- Adaptive layouts
- Safe area handling (notches, rounded corners)

---

## 🎯 Milestones

### Milestone 1: Basic UI with Dummy Data (Weeks 1-2)
**Goal**: Learn Flutter basics and build functional UI

**Deliverables**:
- Expense list screen displaying sample data
- Add expense form with all required fields
- Basic navigation between screens
- Material Design 3 theming applied
- Form validation

**Data**: Hardcoded dummy expenses (no persistence)

**Learning Focus**:
- Flutter widget system
- Layouts and navigation
- Forms and validation
- Stateful vs Stateless widgets

---

### Milestone 2: Local Data Persistence (Week 3)
**Goal**: Implement data storage and CRUD operations

**Deliverables**:
- Integration of `shared_preferences` package
- Save expenses to local storage
- Load expenses on app start
- Edit existing expenses
- Delete expenses
- Data survives app restart

**Learning Focus**:
- JSON serialization/deserialization
- Asynchronous programming (async/await)
- Local storage patterns
- Data lifecycle management

---

### Milestone 3: Analytics & Polish (Weeks 4-5)
**Goal**: Add visualizations and enhance user experience

**Deliverables**:
- Monthly summary screen
- Bar chart for category breakdown
- Bar chart for type breakdown
- Month filter/selector
- Smooth animations and transitions
- Error handling and empty states
- Code cleanup and documentation

**Upgrade**: Migrate to `provider` for better state management

**Learning Focus**:
- Data visualization
- State management with Provider
- Date/time manipulation
- Performance optimization
- Flutter animations

---

## 🚀 Future Enhancements (Post-MVP)
- Supabase integration for cloud backup
- Multi-device sync
- Budget tracking and alerts
- Recurring expenses
- Export to CSV/PDF
- Dark mode
- Localization (multiple languages)

---

## 📝 Development Practices

### Version Control
- Commit after each logical feature
- Meaningful commit messages
- Tag milestone completions

### Code Quality
- Clear comments explaining concepts
- Consistent naming conventions
- Organized file structure
- No hardcoded strings (use constants)

### Testing Strategy
- Manual testing per feature
- Future: Unit tests for models
- Future: Widget tests for UI
- Future: Integration tests for workflows

---

## 📚 Learning Objectives

By the end of this project, you will understand:

1. **Flutter Fundamentals**
   - Widget tree and composition
   - State management patterns
   - Navigation and routing
   - Material Design implementation

2. **Dart Language**
   - Classes and objects
   - Asynchronous programming
   - Null safety
   - JSON handling

3. **App Architecture**
   - Separation of concerns (models, screens, widgets)
   - Data persistence patterns
   - State management strategies

4. **Production Readiness**
   - Error handling
   - User experience patterns
   - Performance considerations
   - Deployment preparation

---

**Last Updated**: 2025-10-25
**Status**: Ready to begin Milestone 1
