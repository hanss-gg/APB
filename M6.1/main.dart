import 'package:flutter/material.dart';
import 'main.dart';

void main() {
  runApp(const MyApp11_1());
}

class MyApp11_1 extends StatelessWidget {
  const MyApp11_1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'APB',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ), // ThemeData
      home: MyHomePage(title: 'APB'),
      debugShowCheckedModeBanner: false,
    ); // MaterialApp
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int selected = 0;
  PageController pc = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: PageView(
          controller: pc,
          onPageChanged: (index) {
            setState(() {
              selected = index;
            });
          },
          children: [
            Center(
              child: InkWell(
                child: Text('Go to Home page', style: TextStyle(fontSize: 30)),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) => const MyApp()
                  )); // MaterialPageRoute
                },
              ) // InkWell
            ), // Center
            Center(
              child: Text('Email page', style: TextStyle(fontSize: 30)),
            ), // Center
            Center(
              child: Text('Profile page', style: TextStyle(fontSize: 30)),
            ), // Center
          ],
        ), // PageView
      ), // SafeArea
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.blue,
        selectedItemColor: Colors.deepOrange,
        unselectedItemColor: Colors.white,
        currentIndex: selected,
        onTap: (index) {
          setState(() {
            selected = index;
          });
          pc.animateToPage(
            index,
            duration: Duration(milliseconds: 200),
            curve: Curves.linear,
          );
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Home',
          ), // BottomNavigationBarItem
          BottomNavigationBarItem(
            icon: Icon(Icons.email),
            label: 'Email',
          ), // BottomNavigationBarItem
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ), // BottomNavigationBarItem
        ],
      ), // BottomNavigationBar
    ); // Scaffold
  }
}

// MyApp dummy agar kode bisa di-compile karena dipanggil di Navigator.push di atas
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Home')));
  }
}
