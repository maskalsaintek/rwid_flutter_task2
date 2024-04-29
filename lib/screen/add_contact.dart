import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:rwid_task_2/model/contact.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class AddContactPage extends StatefulWidget {
  final Contact? passedContact;

  const AddContactPage({super.key, this.passedContact});

  @override
  State<AddContactPage> createState() => _AddContactPageState(passedContact);
}

class _AddContactPageState extends State<AddContactPage> {
  int _selectedRadio = 0;
  bool _isProfileImageVisible = true;
  bool _isAliasImageVisible = false;
  String _fullName = "";
  XFile? _selectedImage;
  String? _selectedImageBase64;
  Contact? _passedContact;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  DateTime _selectedDate = DateTime.now();
  late Color _selectedColor = Colors.black87;
  var logger = Logger();
  var uuid = Uuid();

  _AddContactPageState(Contact? passedContact) {
    _passedContact = passedContact;
  }

  @override
  void initState() {
    super.initState();

    if (_passedContact != null) {
      setState(() {
        _nameController.text = _passedContact!.fullName;
        _fullName = _nameController.text;
        _phoneNumberController.text = _passedContact!.phoneNumber;
        _emailController.text = _passedContact!.email != null ? _passedContact!.email! : "";
        _birthDateController.text = _passedContact!.birthDate != null ? _passedContact!.birthDate! : "";
        _selectedDate = _passedContact!.birthDate != null 
        ? DateFormat("dd MMMM yyyy").parse(_passedContact!.birthDate!) 
        : DateTime.now();
        _selectedColor = _passedContact!.profileColor != null 
        ? Color(int.parse(_passedContact!.profileColor!) ?? Colors.black87.value) 
        : Colors.black87;
        _selectedImageBase64 = _passedContact!.profileImage != null ? _passedContact!.profileImage! : null;
        _selectedRadio = _passedContact!.covertType == "ProfileImage" ? 0 : 1;
        _isAliasImageVisible = _selectedRadio == 1;
        _isProfileImageVisible = _selectedRadio == 0;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1970),
      lastDate: DateTime(2050),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _birthDateController.text =
            DateFormat('dd MMMM yyyy').format(_selectedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              title: Text(_passedContact != null ? "Edit Contact" : 'Add Contact'),
              backgroundColor: Colors.black87,
              foregroundColor: Colors.white,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: 'Close Page',
                  onPressed: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    } else {
                      SystemNavigator.pop();
                    }
                  },
                ),
              ],
            ),
            body: Form(
                key: _formKey,
                child: GestureDetector(
                    onTap: () {
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: SingleChildScrollView(
                          child: Column(
                        children: [
                          const SizedBox(height: 24),
                          Stack(
                            children: [
                              Visibility(
                                  visible: _isProfileImageVisible,
                                  child: Ink(
                                      decoration: const ShapeDecoration(
                                        color: Colors.black87,
                                        shape: CircleBorder(),
                                      ),
                                      child: IconButton(
                                          icon: const Icon(Icons.person),
                                          iconSize: 72,
                                          color: Colors.white,
                                          onPressed: () {}))),
                              Visibility(
                                  visible: _selectedImageBase64 != null &&
                                      _isProfileImageVisible,
                                  child: SizedBox(
                                      width: 88,
                                      height: 88,
                                      child: _selectedImageBase64 == null
                                          ? const SizedBox()
                                          : ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(44.0),
                                              child: Image.memory(
                                                  base64Decode(
                                                      _selectedImageBase64!),
                                                  height: 88,
                                                  width: 88,
                                                  fit: BoxFit.cover),
                                            ))),
                              Visibility(
                                  visible: _isAliasImageVisible,
                                  child: SizedBox(
                                      width: 88,
                                      height: 88,
                                      child: CircleAvatar(
                                          backgroundColor: _selectedColor,
                                          child: Text(
                                              _fullName.isEmpty
                                                  ? "?"
                                                  : _fullName
                                                      .substring(0, 1)
                                                      .toUpperCase(),
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 32))))),
                              Visibility(
                                  visible: true,
                                  child: Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Stack(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                                color: Colors.grey,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                    color: Colors.white)),
                                            child: const SizedBox(
                                                width: 30, height: 30),
                                          ),
                                          Container(
                                            width: 30,
                                            height: 30,
                                            alignment: Alignment.center,
                                            child: Icon(
                                              _isAliasImageVisible
                                                  ? Icons.colorize_outlined
                                                  : Icons.edit,
                                              color: Colors.white,
                                              size: 15.0,
                                            ),
                                          ),
                                          SizedBox(
                                              width: 30, // <-- match_parent
                                              height: 30, // <-- match-parent
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    shadowColor:
                                                        Colors.transparent),
                                                child: const Text(""),
                                                onPressed: () {
                                                  if (_isAliasImageVisible) {
                                                    _selectColor();
                                                  } else if (_isProfileImageVisible) {
                                                    _pickImage();
                                                  }
                                                },
                                              ))
                                        ],
                                      )))
                            ],
                          ),
                          const SizedBox(height: 16),
                          Column(
                            children: [
                              Container(
                                  alignment: Alignment.topLeft,
                                  child: const Text("Cover Type")),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                      alignment: Alignment.topLeft,
                                      child: Radio(
                                        value: 0,
                                        groupValue: _selectedRadio,
                                        onChanged: (int? value) {
                                          setState(() {
                                            _selectedRadio = value!;
                                            _isProfileImageVisible = true;
                                            _isAliasImageVisible = false;
                                          });
                                        },
                                        activeColor: Colors.grey[800],
                                        visualDensity: const VisualDensity(
                                            horizontal:
                                                VisualDensity.minimumDensity,
                                            vertical:
                                                VisualDensity.minimumDensity),
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      )),
                                  const SizedBox(width: 6),
                                  const Text("Profile Image"),
                                  const SizedBox(width: 12),
                                  Radio(
                                    value: 1,
                                    groupValue: _selectedRadio,
                                    onChanged: (int? value) {
                                      setState(() {
                                        _selectedRadio = value!;
                                        _isProfileImageVisible = false;
                                        _isAliasImageVisible = true;
                                      });
                                    },
                                    activeColor: Colors.grey[800],
                                    visualDensity: const VisualDensity(
                                        horizontal:
                                            VisualDensity.minimumDensity,
                                        vertical: VisualDensity.minimumDensity),
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  const SizedBox(width: 6),
                                  const Text("Alias Avatar")
                                ],
                              )
                            ],
                          ),
                          const SizedBox(height: 16),
                          Column(
                            children: [
                              Container(
                                  alignment: Alignment.topLeft,
                                  child: const Text("Full Name (Required)")),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _nameController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Full Name can't be Empty";
                                  }
                                  return null;
                                },
                                onChanged: (text) {
                                  setState(() {
                                    _fullName = text;
                                  });
                                },
                                style: const TextStyle(color: Colors.black),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: const BorderSide(
                                        width: 1, color: Colors.black87),
                                  ),
                                  filled: true,
                                  isDense: true,
                                  contentPadding: const EdgeInsets.all(14),
                                  hintStyle: TextStyle(color: Colors.grey[400]),
                                  hintText: "Enter The Name",
                                  fillColor: Colors.white,
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 16),
                          Column(
                            children: [
                              Container(
                                  alignment: Alignment.topLeft,
                                  child: const Text("Phone Number (Required)")),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _phoneNumberController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Phone Number can't be Empty";
                                  }
                                  return null;
                                },
                                style: const TextStyle(color: Colors.black),
                                keyboardType: TextInputType.phone,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: const BorderSide(
                                        width: 1, color: Colors.black87),
                                  ),
                                  filled: true,
                                  isDense: true,
                                  contentPadding: const EdgeInsets.all(14),
                                  hintStyle: TextStyle(color: Colors.grey[400]),
                                  hintText: "+62",
                                  fillColor: Colors.white70,
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 16),
                          Column(
                            children: [
                              Container(
                                  alignment: Alignment.topLeft,
                                  child: const Text("Email (Optional)")),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _emailController,
                                validator: (value) {
                                  if (value != null &&
                                      value.isNotEmpty &&
                                      !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                          .hasMatch(value)) {
                                    return 'Invalid Email Address';
                                  }
                                  return null;
                                },
                                style: const TextStyle(color: Colors.black),
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: const BorderSide(
                                        width: 1, color: Colors.black87),
                                  ),
                                  filled: true,
                                  isDense: true,
                                  contentPadding: const EdgeInsets.all(14),
                                  hintStyle: TextStyle(color: Colors.grey[400]),
                                  hintText: "example@domain.com",
                                  fillColor: Colors.white70,
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 16),
                          Column(
                            children: [
                              Container(
                                  alignment: Alignment.topLeft,
                                  child: const Text("Birth Date (Optional)")),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _birthDateController,
                                onTap: () {
                                  _selectDate(context);
                                },
                                readOnly: true,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: const BorderSide(
                                        width: 1, color: Colors.black87),
                                  ),
                                  suffixIcon: IconButton(
                                      onPressed: () => setState(() {}),
                                      icon: const Icon(
                                          Icons.chevron_right_sharp)),
                                  filled: true,
                                  isDense: true,
                                  contentPadding: const EdgeInsets.all(14),
                                  hintStyle:
                                      const TextStyle(color: Colors.black),
                                  hintText: "Select Date",
                                  fillColor: Colors.white70,
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.black87,
                                elevation: 0,
                                minimumSize: const Size.fromHeight(46),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(8), // <-- Radius
                                )),
                            onPressed: () {
                              setState(() {});
                              if (_formKey.currentState!.validate()) {
                                if (_passedContact == null) {
                                  Contact contact = Contact(
                                    uuid.v4(),
                                    _nameController.text, 
                                    _phoneNumberController.text, 
                                    _emailController.text.isNotEmpty ? _emailController.text : null, 
                                    _birthDateController.text.isNotEmpty ? _birthDateController.text : null, 
                                    _selectedRadio == 0 ? "ProfileImage" : "ProfileAlias", 
                                    _selectedColor.value.toString(), 
                                    _selectedImageBase64);
                                    insertData(contact);
                                } else {
                                  _passedContact = Contact(
                                    _passedContact!.id,
                                    _nameController.text, 
                                    _phoneNumberController.text, 
                                    _emailController.text.isNotEmpty ? _emailController.text : null, 
                                    _birthDateController.text.isNotEmpty ? _birthDateController.text : null, 
                                    _selectedRadio == 0 ? "ProfileImage" : "ProfileAlias", 
                                    _selectedColor.value.toString(), 
                                    _selectedImageBase64);
                                    updateData(_passedContact!);
                                  logger.d("json to save = " + jsonEncode(_passedContact));
                                }
                                
                                if (Navigator.canPop(context)) {
                                    Navigator.pop(context);
                                  } else {
                                    SystemNavigator.pop();
                                  }
                              }
                            },
                            child: const Text("Save"),
                          ),
                        ],
                      )),
                    )))));
  }

  void _selectColor() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: _selectedColor,
              onColorChanged: (Color color) {
                setState(() {
                  _selectedColor = color;
                });
              },
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = pickedFile;
        _selectedImageBase64 = _getBase64OfImagePath(_selectedImage!);
      });
    }
  }

  String _getBase64OfImagePath(XFile source) {
    File file = File(source.path);
    Uint8List bytes = file.readAsBytesSync();
    return base64Encode(bytes);
  }

  Future<void> insertData(Contact contact) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String fetchedData = prefs.getString('contact_data') ?? '[]';
    logger.d("json contact list source = " + fetchedData);
    List<Contact> contactList = (json.decode(fetchedData) as List)
      .map((data) => Contact.fromJson(data))
      .toList();
    
    contactList.add(contact);
    logger.d("json contact list to save = " + fetchedData);
    prefs.setString("contact_data", jsonEncode(contactList));
  }

  Future<void> updateData(Contact contact) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String fetchedData = prefs.getString('contact_data') ?? '[]';
    logger.d("json contact list source = " + fetchedData);
    List<Contact> contactList = (json.decode(fetchedData) as List)
      .map((data) => Contact.fromJson(data))
      .toList();
    
    int? index;

    for (var i = 0; i < contactList.length; i++) {
      if (contactList[i].id == contact.id) {
        index = i;
        break;
      }
    }

    if (index != null) {
      contactList[index!] = contact;
    }

    logger.d("json contact list to save = " + fetchedData);
    prefs.setString("contact_data", jsonEncode(contactList));
  }
}
