import 'package:flutter/material.dart';
import 'package:wildfriendfinder/AccountPage.dart';

class HomePage extends StatefulWidget {
  final String? userId;
  const HomePage({super.key, required this.userId,});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {



  @override
  Widget build(BuildContext context) {

    // final Map<String, dynamic> index = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    int _selectIndex = 0;
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
              'userId' : widget.userId
            }
        );
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Wild Friend Finder",style: TextStyle(color: Colors.deepPurple),),
      ),
      body: Center(
        child: Column(
          children: [
            Text("Home Page",style: TextStyle(fontSize: 35,fontWeight: FontWeight.bold),),
            Text("Our bottom navigation for account doesn't work. Please press the button to go to the account page. ↓",style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold, color: Colors.red),),
            // Text("User ID: ${widget.userId}",style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),),
            SizedBox(height: 30,),
            ElevatedButton(onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AccountPage(userId: widget.userId,), // Pass ownerId here
                ),
              );
            }, child: Text('Go to Account'))
          ],
        )
      ),
      bottomNavigationBar: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home,color: Colors.deepPurple,),label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.list,color: Colors.deepPurple,),label: "List"),
            BottomNavigationBarItem(icon: Icon(Icons.account_circle,color: Colors.deepPurple,),label: "Account")
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
