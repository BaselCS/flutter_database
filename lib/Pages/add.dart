import 'data_table_page.dart';
// import 'list.dart';
import '../db_Helper.dart';
import 'package:flutter/material.dart';

class AddScreen extends StatefulWidget {
  const AddScreen({Key? key}) : super(key: key);

  @override
  _AddScreenState createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  final _formKey = GlobalKey<FormState>();
  String title = "";
  String description = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add todo'),
      ),
      body: Center(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  hintText: 'title',
                ),
                onChanged: (value) {
                  setState(() {
                    title = value;
                  });
                },
              ),
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  hintText: 'Description',
                ),
                onChanged: (value) {
                  setState(() {
                    description = value;
                  });
                },
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await DatabaseHandler()
                        .addToDB(Model(title: title, description: description, id: 0))
                        .whenComplete(() => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const DataTablePage()),
                            ));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Processing Data')),
                    );
                  }
                },
                child: const Text(
                  'Add',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
