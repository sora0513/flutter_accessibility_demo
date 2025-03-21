import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart'; // CustomSemanticsActionのために追加

void main() {
  runApp(const MyAccessibilityApp());
}

class MyAccessibilityApp extends StatelessWidget {
  const MyAccessibilityApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'アクセシビリティデモ',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'アクセシビリティデモホーム'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // 通常のテキスト (スクリーンリーダーで読み上げられる)
            const Text(
              'ボタンを押した回数:',
            ),
            // カウンターの値 (スクリーンリーダーで読み上げられる)
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),

            const SizedBox(height: 20),

            // カスタムセマンティクスを持つボタン
            Semantics(
              label: '例のボタン',
              hint: 'タップするとメッセージが表示されます',
              button: true,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('セマンティクス付きボタンが押されました')),
                  );
                },
                child: const Text('例のボタン'),
              ),
            ),

            // アクセシビリティ専用の説明を持つ画像
            const SizedBox(height: 20),
            Semantics(
              label: 'Flutterロゴ',
              image: true,
              child: const FlutterLogo(size: 100),
            ),

            // スクリーンリーダーから除外する要素
            const SizedBox(height: 20),
            const ExcludeSemantics(
              child: Text('このテキストはスクリーンリーダーで読み上げられません'),
            ),

            // カスタムアクション付きのウィジェット
            const SizedBox(height: 20),
            Semantics(
              customSemanticsActions: {
                const CustomSemanticsAction(label: 'カスタムアクション'): () {
                  // カスタムアクション実行時の処理を記述
                  debugPrint('カスタムアクションが実行されました');
                },
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                color: Colors.amber,
                child: const Text('カスタムアクション付きのエリア'),
              ),
            ),

            // アクセシビリティフォーカスを変更するボタン
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // フォーカスを特定のウィジェットに移動させる例
                // 実際のアプリではGlobalKeyなどを使用してターゲットを特定する
                SemanticsService.announce('フォーカスが移動しました', TextDirection.ltr);
              },
              child: const Text('フォーカスを移動'),
            ),
          ],
        ),
      ),

      // アクセシビリティラベルを持つFAB
      floatingActionButton: Semantics(
        label: 'カウンターを増やす',
        hint: 'タップするとカウンターが1増加します',
        button: true,
        child: FloatingActionButton(
          onPressed: _incrementCounter,
          tooltip: 'Increment',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
