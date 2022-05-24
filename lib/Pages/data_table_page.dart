import 'package:flutter/material.dart';
import 'add.dart';
import '../db_helper.dart';

class DataTablePage extends StatefulWidget {
  const DataTablePage({Key? key}) : super(key: key);

  @override
  State<DataTablePage> createState() => _DataTablePageState();
}

class _DataTablePageState extends State<DataTablePage> {
  late DatabaseHandler _handler;
  Future<List<Model>>? _model;
  late TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    _handler = DatabaseHandler();
    _handler.openDB().whenComplete(() async {
      setState(() {
        _model = getList();
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<List<Model>> getList() async {
    return await _handler.showDB();
  }

  Future<void> _onRefresh() async {
    setState(() {
      _model = getList();
    });
  }

  List<DataColumn> getColumns(List<String> columns) {
    return columns.map((String column) {
      return DataColumn(
        label: Text(column),
      );
    }).toList();
  }

  List<DataRow> getRows(List<Model> models) => models.map((Model model) {
        //TODO:add the Rows
        final cells = [model.id, model.title, model.description];

        return DataRow(
          cells: Model.modelBuilder(cells, (index, cell) {
            return DataCell(
              Text('$cell'),
              showEditIcon: index == 0 ? false : true,
              onTap: () {
                showDialog<void>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: index == 0 ? const Text('To Delete write the id') : const Text('Change information'),
                        content: TextField(controller: _controller, autofocus: true),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              setState(() {
                                //TODO:change the value of cell's;
                                if (index == 0 && int.parse(_controller.text) == model.id) {
                                  _handler.deleteModel(model.id);
                                } else if (index == 1 && _controller.text.isNotEmpty) {
                                  model.title = _controller.text;
                                } else if (index == 2 && _controller.text.isNotEmpty) {
                                  model.description = _controller.text;
                                }
                                _handler.update(model);
                                _model = getList();
                              });
                              _controller.clear();
                              Navigator.pop(context);
                            },
                            child: const Text('submit'),
                          ),
                        ],
                      );
                    });
              },
            );
          }),
        );
      }).toList();

  @override
  Widget build(BuildContext context) {
    //TODO:add column's name
    final columns = [columnIdName, columnTitleName, columnDescriptionName];
    return interFace(context, columns);
  }

  Scaffold interFace(BuildContext context, List<String> columns) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Sqlite TODO'),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const AddScreen()));
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
                        onRefresh: _onRefresh, child: DataTable(columns: getColumns(columns), rows: getRows(items))));
              }
            }));
  }
}
