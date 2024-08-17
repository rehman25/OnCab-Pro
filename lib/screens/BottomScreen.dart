import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:taxi_driver/screens/DashboardScreen.dart';
import 'package:taxi_driver/screens/RidesListScreen.dart';
import 'package:taxi_driver/screens/WalletScreen.dart';
import 'package:taxi_driver/utils/Extensions/app_common.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Bottom Navigation',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BottomScreen(),
    );
  }
}

class BottomScreen extends StatefulWidget {
  @override
  _BottomScreenState createState() => _BottomScreenState();
}

class _BottomScreenState extends State<BottomScreen> {
  int _selectedIndex = 1;

  static final List<Widget> _widgetOptions = <Widget>[
    WalletScreen(),
    DashboardScreen(),
    RidesListScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color(0xFFCAA928),

        // Set the background color of the entire screen to white
        child: Center(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Container(
          //   // color: Color(0xFFEAEAEA),
          //   decoration: BoxDecoration(
          //     borderRadius: BorderRadius.only(
          //         topLeft: radiusCircular(12), topRight: radiusCircular(12)),
          //   ),
          //   padding: EdgeInsets.all(5.0),
          //   child: Row(
          //     children: [
          //       Expanded(
          //         child: Container(
          //           height: 85,
          //           // color: Colors.green[50],
          //           decoration: BoxDecoration(
          //             color: Colors.red[50],
          //             borderRadius:
          //                 BorderRadius.circular(12), // Add border radius here
          //             // boxShadow: [
          //             //   BoxShadow(
          //             //     color: Colors.black12,
          //             //     spreadRadius: 5,
          //             //     blurRadius: 10,
          //             //     offset: Offset(0, 3), // changes position of shadow
          //             //   ),
          //             // ],
          //           ),
          //           child: Container(
          //             padding: EdgeInsets.all(5.0),
          //             child: Row(
          //               mainAxisAlignment: MainAxisAlignment.start,
          //               crossAxisAlignment: CrossAxisAlignment.start,
          //               children: [
          //                 Icon(
          //                   Icons.info,
          //                   size: 20,
          //                 ),
          //                 SizedBox(width: 2),
          //                 Text(
          //                   "Pro",
          //                   style: TextStyle(
          //                     fontSize: 20,
          //                     fontWeight: FontWeight.bold,
          //                   ),
          //                 )
          //               ],
          //             ),
          //           ),
          //         ),
          //       ),
          //       SizedBox(width: 8),
          //       Expanded(
          //         child: Container(
          //           height: 75,
          //           decoration: BoxDecoration(
          //             color: Colors.blue[50],
          //             borderRadius:
          //                 BorderRadius.circular(12), // Add border radius here
          //             // boxShadow: [
          //             //   BoxShadow(
          //             //     color: Colors.black12,
          //             //     spreadRadius: 5,
          //             //     blurRadius: 10,
          //             //     offset: Offset(0, 3), // changes position of shadow
          //             //   ),
          //             // ],
          //           ),
          //           child: Container(
          //             child: Column(
          //               children: [
          //                 Container(
          //                   padding: EdgeInsets.only(left: 5.0),
          //                   child: Row(
          //                     children: [
          //                       Icon(
          //                         Icons.wallet,
          //                         size: 20,
          //                       ),
          //                       SizedBox(width: 2),
          //                       Text(
          //                         "Earnings",
          //                         style: TextStyle(
          //                           fontSize: 20,
          //                           fontWeight: FontWeight.bold,
          //                         ),
          //                       )
          //                     ],
          //                   ),
          //                 ),
          //                 Container(
          //                   padding: EdgeInsets.only(right: 10.0),
          //                   child: Row(
          //                     mainAxisAlignment: MainAxisAlignment.end,
          //                     crossAxisAlignment: CrossAxisAlignment.end,
          //                     children: [
          //                       Container(
          //                         child: Column(
          //                           mainAxisAlignment: MainAxisAlignment.start,
          //                           crossAxisAlignment:
          //                               CrossAxisAlignment.start,
          //                           children: [
          //                             SizedBox(width: 2),
          //                             Text(
          //                               "Monthly",
          //                               style: TextStyle(
          //                                 fontSize: 10,
          //                                 fontWeight: FontWeight.bold,
          //                               ),
          //                             ),
          //                             Text(
          //                               "Rs:5000",
          //                               style: TextStyle(
          //                                 fontSize: 16,
          //                                 fontWeight: FontWeight.bold,
          //                               ),
          //                             )
          //                           ],
          //                         ),
          //                       )
          //                     ],
          //                   ),
          //                 )
          //               ],
          //             ),
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          Container(
            height: 70, // Set the desired height
            decoration: BoxDecoration(
              // borderRadius: BorderRadius.only(
              //   topLeft: Radius.elliptical(10, 10),
              //   topRight: Radius.circular(10),
              // ),
              // color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  spreadRadius: 5,
                  blurRadius: 10,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.account_balance_wallet),
                  label: 'Wallet',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.car_rental,
                    size: 30,
                  ),
                  label: 'Rides',
                ),
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: Color(0xFF000000),
              unselectedItemColor: Color.fromARGB(231, 196, 195, 195),
              selectedIconTheme: IconThemeData(color: Color(0xFF000000)),
              unselectedIconTheme:
                  IconThemeData(color: Color.fromARGB(231, 196, 195, 195)),
              onTap: _onItemTapped,
            ),
          ),
        ],
      ),
    );
  }
}
