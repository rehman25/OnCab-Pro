// import 'package:flutter/material.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Bottom Sheet Example',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: MyHomePage(),
//     );
//   }
// }

// class MyHomePage extends StatelessWidget {
//   void _showModalBottomSheet(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       builder: (BuildContext context) {
//         return Container(
//           height: 200,
//           child: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               mainAxisSize: MainAxisSize.min,
//               children: <Widget>[
//                 Text('Modal Bottom Sheet'),
//                 ElevatedButton(
//                   child: const Text('Close Bottom Sheet'),
//                   onPressed: () {
//                     Navigator.pop(context);
//                   },
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   void _showPersistentBottomSheet(BuildContext context) {
//     Scaffold.of(context).showBottomSheet(
//       (BuildContext context) {
//         return Container(
//           color: Colors.white,
//           child: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               mainAxisSize: MainAxisSize.min,
//               children: <Widget>[
//                 Text('Persistent Bottom Sheet'),
//                 ElevatedButton(
//                   child: const Text('Close Bottom Sheet'),
//                   onPressed: () {
//                     Navigator.pop(context);
//                   },
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Flutter Bottom Sheet Example'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             ElevatedButton(
//               onPressed: () => _showModalBottomSheet(context),
//               child: Text('Show Modal Bottom Sheet'),
//             ),
//             ElevatedButton(
//               onPressed: () => _showPersistentBottomSheet(context),
//               child: Text('Show Persistent Bottom Sheet'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
