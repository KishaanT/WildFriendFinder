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
        title: Text("Account ",style: TextStyle(color: Colors.deepPurple),),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width: 100, child: Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black,),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person, size: 50,),
                    ],
                  ),
                ),
                ),
                SizedBox(height: 20,),
                Text('Username: john ',style: TextStyle(fontSize: 20),),
                Text('First Name: John ',style: TextStyle(fontSize: 20),),
                Text('Last Name: Doe ',style: TextStyle(fontSize: 20),),
                Text('Password: ********* ',style: TextStyle(fontSize: 20),),
                Text('Date of Birth: 01/01/2000',style: TextStyle(fontSize: 20),),
                Text('Phone Number: 514-658-7896 ',style: TextStyle(fontSize: 20),),
                Text('Address: 123 Main Street ',style: TextStyle(fontSize: 20),),
              ],
            ),
          ],
        ),
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
