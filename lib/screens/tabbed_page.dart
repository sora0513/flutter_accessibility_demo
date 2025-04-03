import 'package:flutter/material.dart';

import 'accessibility_page.dart';
import 'bluetooth_page.dart';
import 'map_page.dart';

class MyTabbedPage extends StatefulWidget {
  const MyTabbedPage({Key? key}) : super(key: key);

  @override
  State<MyTabbedPage> createState() => _MyTabbedPageState();
}

class _MyTabbedPageState extends State<MyTabbedPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Demo App'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.accessibility), text: 'アクセシビリティ'),
            Tab(icon: Icon(Icons.bluetooth), text: 'Bluetooth'),
            Tab(icon: Icon(Icons.map), text: 'マップ'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          AccessibilityPage(title: 'アクセシビリティデモ'),
          BluetoothPage(),
          MapPage(),
        ],
      ),
    );
  }
}
