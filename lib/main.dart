import 'package:flutter/material.dart';
import 'package:sim_tchad/utils/database_helper.dart';
import 'app.dart';

void main() async{ 
   WidgetsFlutterBinding.ensureInitialized();
  await openDatabaseConnection(); 
  runApp(const MyApp()); 
}
