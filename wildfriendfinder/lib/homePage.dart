import 'package:flutter/material.dart';
// import 'listingPage.dart';

class homePage extends StatefulWidget {
  const homePage({super.key});

  @override
  State<homePage> createState() => _homePageState();
}

class _homePageState extends State<homePage> {
  int _selectIndex = 0;
  List<StatefulWidget> _widgetOption = [
    homePage(),
    // listingPage()
  ];

  void pageChange(int index){
    setState(() {
      _selectIndex = index;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Wild Friend Finder",style: TextStyle(color: Colors.deepPurple),),
      ),
      body: Center(
        child: Text("Home Page",style: TextStyle(fontSize: 35,fontWeight: FontWeight.bold),)
      ),
      bottomNavigationBar: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home),label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.list),label: "List")
          ],
        type: BottomNavigationBarType.shifting,
        currentIndex: _selectIndex,
        selectedItemColor: Colors.indigoAccent,
        onTap: pageChange,
        iconSize: 35,

      ),
    );
  }
}
