# screen_text_extractor

[![pub version][pub-image]][pub-url]

[pub-image]: https://img.shields.io/pub/v/screen_text_extractor.svg
[pub-url]: https://pub.dev/packages/screen_text_extractor

This plugin allows Flutter **desktop** apps to extract text from screen.

[![Discord](https://img.shields.io/badge/discord-%237289DA.svg?style=for-the-badge&logo=discord&logoColor=white)](https://discord.gg/zPa6EZ2jqb)

---

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [screen_text_extractor](#screen_text_extractor)
  - [Platform Support](#platform-support)
  - [Quick Start](#quick-start)
    - [Installation](#installation)
    - [Usage](#usage)
  - [API](#api)
    - [ScreenTextExtractor](#screentextextractor)
  - [License](#license)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Platform Support

| MacOS | Linux | Windows |
| :---: | :---: | :-----: |
|   ✔️   |   ✔️   |    ✔️    |

## Quick Start

### Installation

Add this to your package's pubspec.yaml file:

```yaml
dependencies:
  screen_text_extractor: ^0.1.0
```

Or

```yaml
dependencies:
  screen_text_extractor:
    git:
      url: https://github.com/leanflutter/screen_text_extractor.git
      ref: main
```

### Usage

```dart
import 'package:screen_text_extractor/screen_text_extractor.dart';

ExtractedData data;

data = await ScreenTextExtractor.instance.extractFromClipboard();
data = await ScreenTextExtractor.instance.extractFromScreenSelection();
```

> Please see the example app of this plugin for a full example.

## API

### ScreenTextExtractor

| Method                     | Description  | Linux | MacOS | Windows |
| -------------------------- | ------------ | ----- | ----- | ------- |
| isAccessAllowed            | `macOS` only | ➖     | ✔️     | ➖       |
| requestAccess              | `macOS` only | ➖     | ✔️     | ➖       |
| extractFromClipboard       |              | ✔️     | ✔️     | ✔️       |
| extractFromScreenSelection |              | ✔️     | ✔️     | ✔️       |

## License

[MIT](./LICENSE)
