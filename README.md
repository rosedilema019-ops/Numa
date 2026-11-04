# Numa

A responsive Flutter calculator for quick everyday arithmetic. Numa uses a
standalone expression engine, follows standard operator precedence, and adapts
to the system light or dark theme.

## Features

- Addition, subtraction, multiplication, and division with chained expressions
- Decimal input, percentage, sign toggle, clear, delete, and equals controls
- Correct multiplication/division precedence and unary negative values
- Clear division-by-zero feedback and recovery with the clear button
- Decimal artifact cleanup and scientific notation for extreme values
- Five-by-four Material 3 keypad, right-aligned scrollable display, and
	accessible button labels
- Responsive portrait and landscape layouts, including tablet and desktop sizes

## Requirements

- Flutter stable with Dart 3.3 or later
- Android, iOS, web, Windows, macOS, or Linux Flutter runner/toolchain as needed

## Setup and run

```sh
flutter create --platforms=android,ios,web,windows,macos,linux .
flutter pub get
flutter run
```

The first command generates the platform runner folders. To run on a specific
device, list available targets with `flutter devices`, then use
`flutter run -d <device-id>`. Android and iOS builds require their respective
platform toolchains; iOS builds require macOS and Xcode.

## Tests and analysis

```sh
flutter analyze
flutter test
```

## Design decisions

- Uses `ChangeNotifier` for calculator state, without an additional state
	management dependency.
- Uses a shunting-yard expression parser instead of evaluating source strings.
- Percentage converts the current entry to its fractional value, so `50 + 10%`
	evaluates as `50.1`.
- Generates runner folders on setup for Android, iOS, web, Windows, macOS, and
	Linux; each build still requires its platform toolchain.