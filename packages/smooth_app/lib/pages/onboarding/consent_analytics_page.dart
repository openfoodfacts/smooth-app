import 'package:flutter/material.dart';

class ConsentAnalytics extends StatelessWidget {
  const ConsentAnalytics({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: size.height*0.2,
            width: size.width*0.25,
            child: Image.asset("assets/data.png",
            
            fit: BoxFit.contain,),
          ),
          Align(
            alignment: Alignment.center,
            child: Text(
              'Send anonymous analytics',
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: size.height * 0.025),
            ),
          ),
          SizedBox(
            height: size.height * 0.034,
          ),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: size.width * 0.8,
            ),
            child: Text(
              "Help the Open Food Facts volunteer to improve the app.You decide if you want to send anonymous analytics.",
              textAlign: TextAlign.center,
              style:
                  TextStyle(fontSize: size.height * 0.021, color: Colors.black),
            ),
          ),
          SizedBox(height:size.height*0.03 ,),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: size.width * 0.8,
            ),
            child: Text(
              "If you change your mind this option can be enabled and disabled at any time from the settings.",
              textAlign: TextAlign.center,
              style:
                  TextStyle(fontSize: size.height * 0.021, color: Colors.black),
            ),
          ),
          SizedBox(
            height: size.height*0.03,
          ),
          Ink(
            height: size.height*0.06,
            width: size.width*0.5,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 66, 59, 59),
              borderRadius: BorderRadius.circular(25.0)
            ),
            child: Center(
              child:  Text("Authorize",
              style: TextStyle(
                color:Colors.white,
                fontSize: size.height*0.02
              ),),
            ),
          ),
           SizedBox(
            height: size.height*0.03,
          ),
          Container(
            height: size.height*0.06,
            width: size.width*0.5,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 66, 59, 59),
              borderRadius: BorderRadius.circular(25.0)
            ),
            child: Center(
              child:  Text("Refuse",
              style: TextStyle(
                color:Colors.white,
                fontSize: size.height*0.02
              ),),
            ),
          ),


        ],
      ),
    );
  }
}
