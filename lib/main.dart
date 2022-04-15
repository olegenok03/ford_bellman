import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static const String _title = 'Flutter Code Sample';

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: _title,
      home: MyStatefulWidget(),
    );
  }
}

class Edge {
  int a = 0;
  int b = 0;
  int cost = 0;

  Edge(int i, int j, int weight) {
    a = i;
    b = j;
    cost = weight;
  }
}

Widget createTable(int size, List<List> _controllers) {
  if (size == 0) {
    return Container();
  }
  List<Widget> head = [Container()];
  List<Widget> row = [];
  List<TableRow> rows = [];
  for (int i = 0; i < size; i++) {
    head.add(Text((i + 1).toString()));
  }
  rows.add(TableRow(children: head));
  for (int i = 0; i < size; i++) {
    row.add(Text((i + 1).toString()));
    for (int j = 0; j < size; j++) {
      row.add(TextField(
        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly
        ],
        controller: _controllers[i][j],
      ));
    }
    rows.add(TableRow(children: row));
    row = [];
  }
  return Table(
      border: TableBorder.all(),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: rows);
}

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({Key? key}) : super(key: key);

  @override
  State<MyStatefulWidget> createState() => _MyStatelessWidgetState();
}

class _MyStatelessWidgetState extends State<MyStatefulWidget> {
  final int inf = 2147483647;
  String _size = '0';
  final _controller = TextEditingController(),
      _startController = TextEditingController(),
      _endController = TextEditingController();
  var _edgeControllers = [[]];
  List<int> _path = [];
  String _pathString = '';
  int start = 0, end = 0, pathLength = 0;

  _changeSize() {
    setState(() => _size = _controller.text != '' ? _controller.text : '0');
    if (_controller.text != '') {
      _edgeControllers = List.generate(
          int.parse(_size),
          (_) =>
              List.generate(int.parse(_size), (_) => TextEditingController()));
    }
  }

  @override
  void initState() {
    super.initState();
    _controller.text = _size;
    _controller.addListener(_changeSize);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Edge> e = [];

  List<int> solve(List<Edge> e, int n, int start, int end) {
    int m = e.length;
    List<int> d = List.filled(n, inf);
    d[start] = 0;
    List<int> p = List.filled(n, -1);
    for (;;) {
      bool any = false;
      for (int j = 0; j < m; ++j) {
        if (d[e[j].a] < inf) {
          if (d[e[j].b] > d[e[j].a] + e[j].cost) {
            d[e[j].b] = d[e[j].a] + e[j].cost;
            p[e[j].b] = e[j].a;
            any = true;
          }
        }
      }
      if (!any) break;
    }
    pathLength = d[end];
    List<int>? path = [];
    if (d[end] == inf) {
      return path;
    } else {
      for (int cur = end; cur != -1; cur = p[cur]) {
        path.add(cur + 1);
      }
      path = List.of(path.reversed);
      return path;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('First try')),
      body: Center(
          child: Column(children: [
        const Text('The number of vertexes:'),
        TextField(
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly
          ],
          controller: _controller,
        ),
        const Text('Start from:'),
        TextField(
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly
          ],
          controller: _startController,
        ),
        const Text('To:'),
        TextField(
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly
          ],
          controller: _endController,
        ),
        createTable(int.parse(_size), _edgeControllers),
        RaisedButton(
            child: const Text('Find the shortest path'),
            onPressed: () {
              e.clear();
              for (int i = 0; i < int.parse(_size); i++) {
                for (int j = 0; j < int.parse(_size); j++) {
                  if (_edgeControllers[i][j].text != '') {
                    e.add(Edge(i, j, int.parse(_edgeControllers[i][j].text)));
                  }
                }
              }
              if ((_startController.text != '') &&
                  (int.parse(_startController.text) <= int.parse(_size))) {
                start = int.parse(_startController.text) - 1;
              } else {
                start = 0;
              }
              if ((_endController.text != '') &&
                  (int.parse(_endController.text) <= int.parse(_size))) {
                end = int.parse(_endController.text) - 1;
              } else {
                end = 0;
              }
              _path = solve(e, int.parse(_size), start, end);
              if (_path.isEmpty) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Path hasn`t been found'),
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
              } else {
                _pathString = ''; //add the 'path' class
                for (int i = 0; i < _path.length; i++) {
                  _pathString += _path[i].toString();
                  if (i < _path.length - 1) {
                    _pathString += ' ';
                  }
                }
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Path has been found'),
                      content: Text(
                          'The shortest path is $_pathString, its length is $pathLength'),
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
            }),
      ])),
    );
  }
}
