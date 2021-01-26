import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Box box;
  Future openbox() async {
    var dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
    box = await Hive.openBox('data');
    return;
  }

  Map myData;
  //get the data from json
  List myList;
  //get the data from local storage
  List myList2;

  Future<bool> getJson() async {
    await openbox();

    http.Response response =
        await http.get('https://reqres.in/api/users?page=2');
    myData = jsonDecode(response.body);
    myList = myData['data'];
    print(myList);
    //store data to local storage
    await putdata(myList);

    //get data from local storage
    var mydata = box.values;
    myList2 = mydata;

    return Future.value(true);
  }

  Future putdata(data2) async {
    await box.clear();
    for (var data1 in data2) {
      box.add(data1);
    }
  }

  @override
  void initState() {
    getJson();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.black,
          title: Text('FETCH DATA'),
        ),
        body: ListView.builder(
          itemCount: myList2.length,
          itemBuilder: (context, index) {
            return Card(
              color: Colors.black,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      //get the image data from local storage
                      backgroundImage: NetworkImage(myList2[index]['avatar']),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text(
                            "${myList2[index]['first_name']} ${myList2[index]['last_name']}",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "${myList2[index]['email']}",
                            style: TextStyle(
                              color: Colors.teal,
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        ));
  }
}
