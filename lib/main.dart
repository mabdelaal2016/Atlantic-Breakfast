import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Atlantic Breakfast',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int page = 0;
  int last = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Atlantic Breakfast'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: IndexedStack(
          index: page,
          children: [
            Login(onGo: () {
              setState(() {
                page = 1;
              });
            }),
            Menu(onDone: () {
              setState(() {
                last = 0;
                page = 2;
              });
            }),
            Done(
              order: last,
              onBack: () {
                setState(() {
                  page = 1;
                });
              },
              onOut: () {
                setState(() {
                  page = 0;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

class Login extends StatelessWidget {
  final Function onGo;

  Login({required this.onGo});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextButton(
          onPressed: () {
            onGo();
          },
          child: Text('admin_login'),
          style: TextStyle(color: Colors.white),
        ),
      ],
    );
  }
}

class Menu extends StatelessWidget {
  final Function onDone;

  Menu({required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextButton(
          onPressed: () {
            onDone();  // This will execute the onDone function
          },
          child: Text('Go to next page'),
          style: TextStyle(color: Colors.white),
        ),
      ],
    );
  }
}

class Done extends StatelessWidget {
  final int order;
  final Function onBack;
  final Function onOut;

  Done({required this.order, required this.onBack, required this.onOut});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Order: $order'),
        TextButton(
          onPressed: () {
            onBack();
          },
          child: Text('Back to menu'),
          style: TextStyle(color: Colors.white),
        ),
        TextButton(
          onPressed: () {
            onOut();
          },
          child: Text('Exit'),
          style: TextStyle(color: Colors.white),
        ),
      ],
    );
  }
}
