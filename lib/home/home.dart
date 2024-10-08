import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Future<void> saveTodo(String title) async {
    final todo = ParseObject('Todo')
      ..set('title', title)
      ..set('done', false);
    await todo.save();
  }

  Future<List<ParseObject>> fetchDataFromTodo() async {
    return await fetchDataFromClass('Todo');
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Back 4 App'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder<List<ParseObject>>(
        future: fetchDataFromTodo(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No Todos found'));
          }

          List<ParseObject> todos = snapshot.data!;
          return ListView.builder(
            itemCount: todos.length,
            itemBuilder: (context, index) {
              final todo = todos[index];
              return Card(
                elevation: 3,
                color: Colors.white70,
                child: ListTile(
                  title: Text(todo.get<String>('title') ?? 'No Title'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          await _updateTodoTitle(context, todo, onUpdate: () {
                            setState(() {});
                          });
                        },
                        child: const Icon(
                          Icons.edit,
                        ),
                      ),
                      const SizedBox(width: 7),
                      GestureDetector(
                        onTap: () async {
                          deleteTodo(todo.objectId.toString()).then((e) {
                            setState(() {});
                          });

                        },
                        child: const Icon(
                          Icons.delete,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {

          saveTodo('A Dummy task to do').then((_) {
            setState(() {});
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // General method to fetch data from any Parse class
  Future<List<ParseObject>> fetchDataFromClass(String className) async {
    QueryBuilder<ParseObject> query =
        QueryBuilder<ParseObject>(ParseObject(className));
    final ParseResponse apiResponse = await query.query();

    if (apiResponse.success && apiResponse.results != null) {
      return apiResponse.results as List<ParseObject>;
    } else {
      return [];
    }
  }
}

Future<void> _updateTodoTitle(BuildContext context, ParseObject todo,
    {required VoidCallback onUpdate}) async {
  String? newTitle = await showDialog<String>(
    context: context,
    builder: (context) {
      TextEditingController controller =
          TextEditingController(text: todo.get<String>('title'));

      return AlertDialog(
        title: const Text('Update Todo Title'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter new title'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context)
                  .pop(controller.text); // Return the new title
            },
            child: const Text('Update'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Just close the dialog
            },
            child: const Text('Cancel'),
          ),
        ],
      );
    },
  );

  if (newTitle != null && newTitle.isNotEmpty) {
    todo.set('title', newTitle);
    await todo.save();
    onUpdate(); // Call the onUpdate callback to refresh the state
  }
}

Future<void> deleteTodo(String id) async {
  var todo = ParseObject('Todo')..objectId = id;
  await todo.delete();
}

