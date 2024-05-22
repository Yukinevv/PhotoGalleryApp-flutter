import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClearCacheButton extends StatelessWidget {
  const ClearCacheButton({Key? key}) : super(key: key);

  Future<void> clearCache() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    print('Cache cleared');
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: clearCache,
      child: const Text('Wyczyść pamięć podręczną'),
    );
  }
}
