import 'package:flutter/material.dart';
import 'package:ozar_grocerylist/auth.dart';
import 'package:ozar_grocerylist/loginpage.dart';
import 'package:ozar_grocerylist/widget_tree.dart';
import 'package:firebase_core/firebase_core.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyCxipweQZzbxK9CV1MQNap3uKQJCzWCXg8",
      appId: "1:447426764590:android:10bdab251b3309fcc524bf",
      messagingSenderId: "447426764590",
      projectId: "ozar-e2e80",
    ),
  );
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
 
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grocery List App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Montserrat',
      ),
      home: const WidgetTree(),
    );
  }
}
 
class ListsScreen extends StatefulWidget {
  const ListsScreen({Key? key}) : super(key: key);
 
  @override
  _ListsScreenState createState() => _ListsScreenState();
}
 
class _ListsScreenState extends State<ListsScreen> {
  Map<String, List<String>> _lists = {};
 
  void _addList(String listName) {
    setState(() {
      _lists[listName] = [];
    });
  }
 
  void _addItemToList(String listName, String item) {
    setState(() {
      _lists[listName]?.add(item);
    });
  }
 
  void _removeItemFromList(String listName, String item) {
    setState(() {
      _lists[listName]?.remove(item);
    });
  }
 
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ozar Grocery Lists',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      body: ListView.builder(
        itemCount: _lists.length,
        itemBuilder: (context, index) {
          final listName = _lists.keys.elementAt(index);
          return ListTile(
            title: Text(
              listName,
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GroceryListScreen(
                    listName: listName,
                    items: _lists[listName]!,
                    addItemToList: _addItemToList,
                    removeItemFromList: _removeItemFromList,
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.purple[100], // Set the color to light lavender
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Add List',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Account',
          ),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ListsScreen()),
            );
          } else if (index == 1) {
            showDialog<String>(
              context: context,
              builder: (context) => _AddListDialog(),
            ).then((newListName) {
              if (newListName != null && newListName.isNotEmpty) {
                _addList(newListName);
              }
            });
          } else if (index == 2) {
            //Edit:
             Auth().signOut().then((_) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }).catchError((error) {
    print('Signout error: $error');
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Error signing out. Please try again.'),
    ));
  });

          }
        },
      ),
    );
  }
}
 
class _AddListDialog extends StatefulWidget {
  const _AddListDialog({Key? key}) : super(key: key);
 
  @override
  _AddListDialogState createState() => _AddListDialogState();
}
 
class _AddListDialogState extends State<_AddListDialog> {
  final TextEditingController _controller = TextEditingController();
 
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create New List'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(hintText: 'Enter list name'),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final newListName = _controller.text.trim();
            if (newListName.isNotEmpty) {
              Navigator.of(context).pop(newListName);
            }
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
 
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
 
class GroceryListScreen extends StatefulWidget {
  final String listName;
  final List<String> items;
  final void Function(String listName, String item) addItemToList;
  final void Function(String listName, String item) removeItemFromList;
 
  const GroceryListScreen({
    Key? key,
    required this.listName,
    required this.items,
    required this.addItemToList,
    required this.removeItemFromList,
  }) : super(key: key);
 
  @override
  _GroceryListScreenState createState() => _GroceryListScreenState();
}
 
class _GroceryListScreenState extends State<GroceryListScreen> {
  late List<String> _groceryList;
  TextEditingController _textController = TextEditingController();
  String? _itemAddedMessage;
  int? _editIndex;
 
  @override
  void initState() {
    super.initState();
    _groceryList = List.from(widget.items);
  }
 
  void _addItemToList() {
    setState(() {
      String newItem = _textController.text.trim();
      if (_editIndex != null) {
        if (newItem.isNotEmpty) {
          widget.removeItemFromList(widget.listName, _groceryList[_editIndex!]);
          _groceryList[_editIndex!] = newItem;
          widget.addItemToList(widget.listName, newItem);
          _editIndex = null;
          _itemAddedMessage = '$newItem has been edited';
        } else {
          _itemAddedMessage = 'Item cannot be empty';
        }
      } else {
        if (newItem.isNotEmpty) {
          widget.addItemToList(widget.listName, newItem);
          _groceryList.add(newItem);
          _itemAddedMessage = '$newItem has been added to the list';
        } else {
          _itemAddedMessage = 'Item cannot be empty';
        }
      }
      _textController.clear();
    });
  }
 
  void _removeItemFromList(String item) {
    setState(() {
      widget.removeItemFromList(widget.listName, item);
      _groceryList.remove(item);
    });
  }
 
  void _editItem(int index) {
    setState(() {
      _editIndex = index;
      _textController.text = _groceryList[index];
    });
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.listName,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: 'Enter item',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addItemToList,
                  child: Text(_editIndex != null ? 'Save' : 'Add'),
                ),
              ],
            ),
          ),
          if (_itemAddedMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                _itemAddedMessage!,
                style: TextStyle(
                  color: Color.fromARGB(255, 128, 186, 57),
                ), // Changed color to light purple
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: _groceryList.length,
              itemBuilder: (context, index) {
                final item = _groceryList[index];
                return Dismissible(
                  key: Key(item),
                  onDismissed: (_) => _removeItemFromList(item),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  child: ListTile(
                    title: Row(
                      children: [
                        Icon(Icons.edit), // Edit icon
                        SizedBox(width: 8.0),
                        Text(item),
                      ],
                    ),
                    onTap: () => _editItem(index), // Activate edit mode on tap
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}