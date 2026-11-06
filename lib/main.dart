import 'package:flutter/material.dart';

/*
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: .center,
          children: [
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
*/

import 'config/app_config.dart';
import 'controllers/yaku_controller.dart';
import 'screens/activity_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/configuration_screen.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/subscriptions_screen.dart';
import 'screens/upcoming_screen.dart';

void main() => runApp(const YakuApp());

class YakuApp extends StatefulWidget {
  const YakuApp({super.key});

  @override
  State<YakuApp> createState() => _YakuAppState();
}

class _YakuAppState extends State<YakuApp> {
  late final YakuController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YakuController();
    if (AppConfig.isApiConfigured) _controller.restoreSession();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => MaterialApp(
        title: 'Yaku',
        debugShowCheckedModeBanner: false,
        themeMode: _themeModeFor(_controller.profile?.theme),
        theme: _theme(Brightness.light),
        darkTheme: _theme(Brightness.dark),
        home: _home(),
      ),
    );
  }

  Widget _home() {
    if (!AppConfig.isApiConfigured) return const ConfigurationScreen();
    return switch (_controller.sessionStatus) {
      SessionStatus.checking => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      SessionStatus.signedOut => AuthScreen(controller: _controller),
      SessionStatus.signedIn => AppShell(controller: _controller),
    };
  }

  ThemeMode _themeModeFor(String? theme) => switch (theme) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };

  ThemeData _theme(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF6750A4),
      brightness: brightness,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.controller});
  final YakuController controller;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(
        subscriptions: widget.controller.subscriptions,
        summary: widget.controller.summary,
        isLoading: widget.controller.isLoadingData,
        error: widget.controller.dataError,
        onRefresh: widget.controller.refresh,
        onUpdateSubscription: widget.controller.updateSubscription,
        onOpenSubscriptions: () => setState(() => _index = 1),
        onOpenSettings: _openSettings,
      ),
      SubscriptionsScreen(
  subscriptions: widget.controller.subscriptions,
  isLoading: widget.controller.isLoadingData,
  error: widget.controller.dataError,
  onRefresh: widget.controller.refresh,
  onAddSubscription: widget.controller.addSubscription,
  onUpdateSubscription: widget.controller.updateSubscription,
  onDeleteSubscription: widget.controller.deleteSubscription,
),
      UpcomingScreen(
        subscriptions: widget.controller.subscriptions,
        summary: widget.controller.summary,
        isLoading: widget.controller.isLoadingData,
        error: widget.controller.dataError,
        onRefresh: widget.controller.refresh,
      ),
      ActivityScreen(
        attempts: widget.controller.attempts,
        subscriptions: widget.controller.subscriptions,
        isLoading: widget.controller.isLoadingData,
        error: widget.controller.dataError,
        onRefresh: widget.controller.refresh,
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(index: _index, children: pages),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) => setState(() => _index = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.credit_card_outlined),
            selectedIcon: Icon(Icons.credit_card),
            label: 'Subscriptions',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Upcoming',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'Activity',
          ),
        ],
      ),
    );
  }

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SettingsScreen(controller: widget.controller),
      ),
    );
  }
}
