# Architecture Decisions

## Tech Stack Choices

### Local Storage: shared_preferences
**Why**: 
- Beginner-friendly API
- No complex setup
- Suitable for small datasets
- Built-in JSON serialization support

### State Management: setState → Provider
**Phase 1-2**: Built-in setState
- Simplest to learn
- No external dependencies

**Phase 3**: Migrate to Provider
- Official recommendation
- Scales better

### Charts: fl_chart
**Why**:
- Most popular Flutter charting library
- Highly customizable
- Good documentation

### UI: Material Design 3
**Why**:
- Modern, clean aesthetics
- Built into Flutter

## Project Structure
```
lib/
├── main.dart           # App entry point
├── models/             # Data models
├── screens/            # Full-screen pages
└── widgets/            # Reusable components
```

## Coding Conventions
- Files: `snake_case.dart`
- Classes: `PascalCase`
- Variables/functions: `camelCase`
- Constants: `SCREAMING_SNAKE_CASE`
