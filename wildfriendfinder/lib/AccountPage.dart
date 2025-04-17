import 'package:flutter/material.dart';

class AccountPage extends StatefulWidget {
  // final String? userId;
  const AccountPage({super.key,});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {



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
              'index': _selectIndex
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

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
