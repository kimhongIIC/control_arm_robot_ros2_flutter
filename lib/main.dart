import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const ROSFlutterApp());
}

class ROSFlutterApp extends StatelessWidget {
  const ROSFlutterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ROS2 Robot Controller',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.grey[200],
        textTheme: const TextTheme(
          headlineSmall: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
          bodyMedium: TextStyle(color: Colors.black87),
        ),
      ),
      home: const PublisherHomePage(),
    );
  }
}

class PublisherHomePage extends StatefulWidget {
  const PublisherHomePage({super.key});

  @override
  _PublisherHomePageState createState() => _PublisherHomePageState();
}

class _PublisherHomePageState extends State<PublisherHomePage> {
  final String serverUrl = 'http://100.110.254.108:8000/publish';
  String _status = 'Idle';
  bool _isLoading = false;

  Future<void> sendCommand(String command) async {
    setState(() {
      _status = 'Sending "$command"...';
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(serverUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'command': command}),
      );

      if (response.statusCode == 200) {
        setState(() {
          _status = 'Command "$command" sent successfully!';
        });
      } else {
        final error = jsonDecode(response.body)['detail'];
        setState(() {
          _status = 'Failed to send command: $error';
        });
      }
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget buildCommandButton(String label, String command, Color color, IconData icon) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      ),
      onPressed: () => sendCommand(command),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 40, color: Colors.white),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildStatusSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            spreadRadius: 2,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.teal),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _status,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          if (_isLoading)
            const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        ],
      ),
    );
  }

  Widget buildHeader() {
    return Column(
      children: [
        Text(
          'ROS2 Robot Controller',
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          'Control your ROS2-powered robotic arm effortlessly with intuitive commands.',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    int columns = MediaQuery.of(context).size.width > 600 ? 2 : 1;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Robot Arm Controller'),
        centerTitle: true,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            buildHeader(),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: columns,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  buildCommandButton('Pick Apple', 'pick_apple', Colors.green, Icons.apple),
                  buildCommandButton('Pick Orange', 'pick_orange', Colors.orange, Icons.circle),
                ],
              ),
            ),
            buildStatusSection(),
          ],
        ),
      ),
    );
  }
}
