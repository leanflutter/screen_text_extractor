> **🚀 快速发布您的应用**: 试试 [Fastforge](https://fastforge.dev) - 构建、打包和分发您的 Flutter 应用最简单的方式。

# screen_text_extractor

[![pub version][pub-image]][pub-url] [![][discord-image]][discord-url] ![][visits-count-image] 

[pub-image]: https://img.shields.io/pub/v/screen_text_extractor.svg
[pub-url]: https://pub.dev/packages/screen_text_extractor

[discord-image]: https://img.shields.io/discord/884679008049037342.svg
[discord-url]: https://discord.gg/zPa6EZ2jqb

[visits-count-image]: https://img.shields.io/badge/dynamic/json?label=Visits%20Count&query=value&url=https://api.countapi.xyz/hit/leanflutter.screen_text_extractor/visits

这个插件允许 Flutter 桌面应用从屏幕上提取文本。

---

[English](./README.md) | 简体中文

---

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [screen_text_extractor](#screen_text_extractor)
  - [平台支持](#平台支持)
  - [快速开始](#快速开始)
    - [安装](#安装)
    - [用法](#用法)
  - [谁在用使用它？](#谁在用使用它)
  - [API](#api)
    - [ScreenTextExtractor](#screentextextractor)
  - [许可证](#许可证)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## 平台支持

| Linux | macOS | Windows |
| :---: | :---: | :-----: |
|   ✔️   |   ✔️   |    ✔️    |

## 快速开始

### 安装

将此添加到你的软件包的 pubspec.yaml 文件：

```yaml
dependencies:
  screen_text_extractor: ^0.1.3
```

或

```yaml
dependencies:
  screen_text_extractor:
    git:
      url: https://github.com/leanflutter/screen_text_extractor.git
      ref: main
```

### 用法

```dart
import 'package:screen_text_extractor/screen_text_extractor.dart';

ExtractedData data;

data = await ScreenTextExtractor.instance.extractFromClipboard();
data = await ScreenTextExtractor.instance.extractFromScreenSelection();
```

> 请看这个插件的示例应用，以了解完整的例子。

## 谁在用使用它？

- [Biyi (比译)](https://biyidev.com/) - 一个便捷的翻译和词典应用。

## API

### ScreenTextExtractor

| Method                     | Description  | Linux | MacOS | Windows |
| -------------------------- | ------------ | ----- | ----- | ------- |
| isAccessAllowed            | `macOS` only | ➖     | ✔️     | ➖       |
| requestAccess              | `macOS` only | ➖     | ✔️     | ➖       |
| extractFromClipboard       |              | ✔️     | ✔️     | ✔️       |
| extractFromScreenSelection |              | ✔️     | ✔️     | ✔️       |

## 许可证

[MIT](./LICENSE)
