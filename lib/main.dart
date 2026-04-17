import 'package:flutter/material.dart';

void main() => runApp(
  MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Homepage(),
    ),
);

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            colors: [
              const Color.fromARGB(255, 237, 136, 254),
               const Color.fromARGB(255, 88, 154, 209),
               const Color.fromARGB(31, 218, 208, 208)
               ],
            
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: <Widget>[
            SizedBox(height: 80,),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text("Login", style: TextStyle(
                    color: Colors.white,
                    fontSize: 40
                    ),
                    ),
                    SizedBox(height: 10,),

                    Text("Welcome Back", style: TextStyle(
                    color: Colors.white,
                    fontSize: 18
                    ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(60),
                    topRight: Radius.circular(60),
                  )
                ),

              ),
              )
          ],
        ),
      ),);
  }
}