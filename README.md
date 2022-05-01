# screen_text_extractor

[![pub version][pub-image]][pub-url] [![][discord-image]][discord-url]

[pub-image]: https://img.shields.io/pub/v/screen_text_extractor.svg
[pub-url]: https://pub.dev/packages/screen_text_extractor

[discord-image]: https://img.shields.io/discord/884679008049037342.svg
[discord-url]: https://discord.gg/zPa6EZ2jqb

This plugin allows Flutter **desktop** apps to extract text from screen.

---

English | [简体中文](./README-ZH.md)

---

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [screen_text_extractor](#screen_text_extractor)
  - [Platform Support](#platform-support)
  - [Quick Start](#quick-start)
    - [Installation](#installation)
    - [Usage](#usage)
  - [Who's using it?](#whos-using-it)
  - [API](#api)
    - [ScreenTextExtractor](#screentextextractor)
  - [License](#license)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Platform Support

| Linux | macOS | Windows |
| :---: | :---: | :-----: |
|   ✔️   |   ✔️   |    ✔️    |

## Quick Start

### Installation

Add this to your package's pubspec.yaml file:

```yaml
dependencies:
  screen_text_extractor: ^0.1.1
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

## Who's using it?

- [Biyi (比译)](https://biyidev.com/) - A convenient translation and dictionary app.

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
