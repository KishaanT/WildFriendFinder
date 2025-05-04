import 'package:flutter/material.dart';
import 'package:wildfriendfinder/AccountPage.dart';

class HomePage extends StatefulWidget {
  final String? userId;
  final int index;
  const HomePage({super.key, required this.userId,required this.index});


  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {



  @override  Widget build(BuildContext context) {

    // final Map<String, dynamic> data = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;

    int _selectIndex = widget.index;
    print(_selectIndex);
    List<String> _widgetOption = [
      'homePage',
      'listingPage',
      'accountPage'
    ];

    void pageChange(int index){
      setState(() {
        _selectIndex = index;
        Navigator.pushNamed(
            context,
            _widgetOption[index],
            arguments: {
              'index': _selectIndex,
              'userId' :widget.userId,
            }
        );
      });
    }

    return Scaffold(

      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Wild Friend Finder",style: TextStyle(color: Colors.deepPurple),),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Home Page",style: TextStyle(fontSize: 35,fontWeight: FontWeight.bold),),
          ],
        )
      ),
      bottomNavigationBar: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home,color: Colors.deepPurple,),label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.list,color: Colors.deepPurple,),label: "List"),
            BottomNavigationBarItem(icon: Icon(Icons.account_circle,color: Colors.deepPurple,),label: "Account")
          ],
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectIndex,
        selectedItemColor: Colors.indigoAccent,
        onTap: pageChange,
        iconSize: 35,

      ),
    );
  }
}
