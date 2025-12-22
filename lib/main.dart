import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'game_selection.dart';

void main() => runApp(const ProviderScope(child: MyApp()));

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Kids Games',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(fontFamily: 'Nunito', primarySwatch: Colors.blue, useMaterial3: true),
    home: const GameSelectionScreen(),
  );
}
