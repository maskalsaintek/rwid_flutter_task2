import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:rwid_task_2/model/contact.dart';
import 'package:rwid_task_2/screen/add_contact.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RWID TASK 2',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black87),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'RWID TASK 2'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Contact> _contactList = List.empty();
  var logger = Logger();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String fetchedData = prefs.getString('contact_data') ?? '[]';
    logger.d("json source = " + fetchedData);
    setState(() {
      _contactList = (json.decode(fetchedData) as List)
          .map((data) => Contact.fromJson(data))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
            appBar: AppBar(
              title: const Text('RWID TASK 2'),
              backgroundColor: Colors.black87,
              foregroundColor: Colors.white,
              actions: [
                IconButton(
                  icon: const Icon(Icons.add),
                  tooltip: 'Add Contact',
                  onPressed: () async {
                    await Navigator.of(context).push(
                      CupertinoPageRoute(
                        fullscreenDialog: true,
                        builder: (context) => const AddContactPage(),
                      ),
                    );

                    fetchData();
                  },
                ),
              ],
            ),
            bottomNavigationBar: Container(
              color: Colors.black,
              child: const TabBar(
                labelColor: Colors.green,
                unselectedLabelColor: Colors.white,
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: EdgeInsets.all(5.0),
                indicatorColor: Colors.transparent,
                tabs: [
                  Tab(
                    text: "Home",
                    icon: Icon(Icons.home),
                  ),
                  Tab(
                    text: "Setting",
                    icon: Icon(Icons.settings),
                  )
                ],
              ),
            ),
            body: TabBarView(
              children: [
                _contactList.isEmpty
                    ? Container(
                        alignment: Alignment.center, child: Text("No Data"))
                    : ListView.builder(
                        itemCount: _contactList.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(_contactList[index].fullName,
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(_contactList[index].phoneNumber),
                            onTap: () async {
                              await Navigator.of(context).push(
                      CupertinoPageRoute(
                        fullscreenDialog: true,
                        builder: (context) => AddContactPage(passedContact: _contactList[index]),
                      ),
                    );

                    fetchData();
                            },
                            trailing: Wrap(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  tooltip: 'Delete Contact',
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Delete Contact'),
                                        content: const Text(
                                            'Are you sure you want to delete this contact?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              _contactList.removeAt(index);
                                              SharedPreferences prefs =
                                                  await SharedPreferences
                                                      .getInstance();
                                              prefs.setString("contact_data",
                                                  jsonEncode(_contactList));
                                              fetchData();
                                              Navigator.pop(context);
                                            },
                                            child: const Text('Delete'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                )
                              ],
                            ),
                            leading: _contactList[index].covertType ==
                                    "ProfileAlias"
                                ? CircleAvatar(
                                    backgroundColor:
                                        _contactList[index].profileColor != null &&
                                                _contactList[index]
                                                    .profileColor!
                                                    .isNotEmpty
                                            ? Color(
                                                int.parse(_contactList[index].profileColor!) ??
                                                    Colors.black87.value)
                                            : Colors.black87,
                                    child: Text(_contactList[index].fullName.substring(0, 1),
                                        style: TextStyle(color: Colors.white)))
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(44.0),
                                    child: _contactList[index].profileImage !=
                                                null &&
                                            _contactList[index]
                                                .profileImage!
                                                .isNotEmpty
                                        ? Image.memory(
                                            base64Decode(_contactList[index].profileImage!),
                                            height: 42,
                                            width: 42,
                                            fit: BoxFit.cover)
                                        : Stack(children: [
                                            Container(
                                              decoration: const BoxDecoration(
                                                  color: Colors.black87,
                                                  shape: BoxShape.circle),
                                              child: const SizedBox(
                                                  width: 42, height: 42),
                                            ),
                                            Container(
                                              width: 42,
                                              height: 42,
                                              alignment: Alignment.center,
                                              child: const Icon(
                                                Icons.person,
                                                color: Colors.white,
                                                size: 24.0,
                                              ),
                                            )
                                          ])),
                          );
                        },
                      ),
                Icon(Icons.settings),
              ],
            )),
      ),
    );
  }
}
