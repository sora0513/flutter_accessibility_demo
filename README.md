# Flutter Accessibility Demo

iOSのVoiceOverとAndroidのTalkBackに対応したシンプルなFlutterアプリケーションです。

## 概要

このプロジェクトは、Flutterアプリケーションでのアクセシビリティ機能の実装方法を示しています。特別なライブラリを使用せず、Flutterの標準機能のみで、スクリーンリーダーに対応したUIを構築する例を提供します。

## 主な機能

- 基本的なテキスト読み上げ
- セマンティクスラベルによる追加情報の提供
- 要素の除外機能
- カスタムアクション
- アクセシビリティフォーカスの制御

## 動作確認方法

**重要**: アクセシビリティ機能のテストは実機で行うことを強く推奨します。エミュレータやシミュレータでは一部の機能が正しく動作しない場合があります。

### 実機転送方法

#### Android
1. Android端末のUSBデバッグを有効にする (設定 > 開発者向けオプション > USBデバッグ)
2. USBケーブルで端末をPCに接続
3. `flutter devices` コマンドで端末が認識されていることを確認
4. `flutter run` コマンドでアプリをインストール

#### iOS
1. Apple Developerアカウント（無料または有料）が必要
2. Xcodeで実行デバイスとして接続したiPhone/iPadを選択
3. 端末で開発者モードを有効にする (設定 > 開発者向けオプション)
4. USBケーブルで端末をMacに接続
5. `flutter run` コマンドでアプリをインストール

### iOSでVoiceOverを有効にする
1. 設定 > アクセシビリティ > VoiceOver
2. VoiceOverをオンにする
3. **基本操作**:
   - 1回タップ: アイテムを選択（読み上げ）
   - ダブルタップ: 選択したアイテムを実行
   - 3本指で画面を上下にスワイプ: スクロール
   - 2本指でダブルタップ: 操作開始/停止

### AndroidでTalkBackを有効にする
1. 設定 > アクセシビリティ > TalkBack
2. TalkBackをオンにする
3. **基本操作**:
   - 1回タップ: アイテムを選択（読み上げ）
   - ダブルタップ: 選択したアイテムを実行
   - 2本指でスワイプ: スクロール
   - 3本指で画面をタップ: コンテキストメニューを開く
   - 2本指でタップ: 操作を一時停止

### スクリーンリーダーを無効に戻す方法

#### iOS
- 3回ホームボタンまたはサイドボタンをクリック
- または設定画面から直接オフに切り替え

#### Android
- 音量アップキーと音量ダウンキーを同時に3秒間長押し
- または設定画面から直接オフに切り替え

## プロジェクトの構造

- `lib/main.dart` - アプリケーションのメインコード
- スクリーンリーダーで読み上げられるウィジェット
- セマンティクス情報が追加されたカスタムウィジェット
- アクセシビリティから除外されたウィジェット

## インストールと実行

```bash
# プロジェクトのクローン
git clone https://github.com/yourusername/flutter_accessibility_demo.git

# ディレクトリに移動
cd flutter_accessibility_demo

# 依存関係のインストール
flutter pub get

# アプリケーションの実行 (接続された実機にインストール)
flutter run
```

## シミュレータでのテスト制限事項

- **iOS Simulator**: VoiceOverの完全な機能セットが利用できない場合があります。実機テストを推奨します。
- **Android Emulator**: TalkBackは利用できますが、一部のタッチジェスチャーが正しく機能しないことがあります。

シミュレータ/エミュレータでテストする場合は、XcodeのAccessibility Inspectorなどのツールを使用して、基本的なアクセシビリティ属性（ラベル、ヒントなど）が正しく設定されているかを確認することができます。

## 拡張方法

より高度なアクセシビリティ機能が必要な場合は、以下のライブラリの追加を検討してください：

```yaml
dependencies:
  flutter_accessibility_service: ^0.1.1
```

## ライセンス

MIT