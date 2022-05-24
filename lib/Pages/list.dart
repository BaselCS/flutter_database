import 'package:flutter/material.dart';
import 'add.dart';
import '../db_helper.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({Key? key}) : super(key: key);

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  late DatabaseHandler handler;
  Future<List<Model>>? _model;

  @override
  void initState() {
    super.initState();
    handler = DatabaseHandler();
    handler.openDB().whenComplete(() async {
      setState(() {
        _model = getList();
      });
    });
  }

  Future<List<Model>> getList() async {
    return await handler.showDB();
  }

  Future<void> _onRefresh() async {
    setState(() {
      _model = getList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sqlite todo'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddScreen()),
          );
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.deepOrange,
      ),
      body: FutureBuilder<List<Model>>(
        future: _model,
        builder: (BuildContext context, AsyncSnapshot<List<Model>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            final items = snapshot.data ?? <Model>[];
            return Scrollbar(
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Dismissible(
                      direction: DismissDirection.startToEnd,
                      background: Container(
                        color: Colors.blue,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: const Icon(Icons.delete_forever),
                      ),
                      key: ValueKey<int>(items[index].id),
                      onDismissed: (DismissDirection direction) async {
                        await handler.deleteModel(items[index].id); //To delete
                        setState(() {
                          items.remove(items[index]);
                        });
                      },
                      child: Card(
                          child: ListTile(
                        contentPadding: const EdgeInsets.all(8.0),
                        title: Text(items[index].title),
                        subtitle: Text(items[index].description.toString()),
                      )),
                    );
                  },
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
