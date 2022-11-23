import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() => runApp(const MyCoolApp());

class MyCoolApp extends StatelessWidget {
  const MyCoolApp({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (context) => ToDosProvider(),
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Go Guys Tasks',
      theme: ThemeData(
        primarySwatch: Colors.yellow,
        scaffoldBackgroundColor: const Color(0xFFf6f5ee),
      ),
      home: const MyCoolHomePage(),
    ),
  );
}

class MyCoolHomePage extends StatefulWidget {
  const MyCoolHomePage({Key? key}) : super(key: key);


  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<MyCoolHomePage> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final tabs = [
      const AllListWidget(),
      const CompletedListWidget(),
      const ToDoListWidget(),
    ];

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: IconButton(
          icon: const Icon(Icons.favorite),
          onPressed: () {
            // color change
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.black.withOpacity(0.7),
        selectedItemColor: Colors.black,
        currentIndex: selectedIndex,
        onTap: (index) => setState(() {
          selectedIndex = index;
        }),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.all_inclusive),
            label: 'All',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.ads_click),
            label: 'Done',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'Doing',
          ),
        ],
      ),
      body: tabs[selectedIndex],
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)
        ),
        backgroundColor: Colors.black,
        onPressed: () => showDialog(
          context: context,
          builder: (context) => const AddTodoDialogWidget(),
        ),
        tooltip: 'Adicionar nova tarefa',
        child: const Icon(
            Icons.add,
            color: Colors.white
        ),
      ),
    );
  }
}

class AddTodoDialogWidget extends StatefulWidget {
  const AddTodoDialogWidget({Key? key}) : super(key: key);


  @override
  AddTodoDialogWidgetState createState() => AddTodoDialogWidgetState();
}

class AddTodoDialogWidgetState extends State<AddTodoDialogWidget> {
  final _formKey = GlobalKey<FormState>();
  String title = '';

  @override
  Widget build(BuildContext context) => AlertDialog(
    content: Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nova tarefa:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              backgroundColor: Colors.yellow,
            ),
          ),
          const SizedBox(height: 8),
          ToDoFormWidget(
            onChangedTitle: (title) =>
                setState(
                        () => this.title = title
                ),
            onSavedToDo: addToDo,
          ),
        ],
      ),
    ),
  );
  void addToDo() {
    final isValid = _formKey.currentState?.validate();

    if (isValid == null || isValid == '') {
      return;
    } else {

      final todo = ToDo(
        id: DateTime.now().toString(),
        title: title,
        createdTime: DateTime.now(),
      );

      final provider = Provider.of<ToDosProvider>(context, listen: false);
      provider.addToDo(todo);

      Navigator.of(context).pop();
    }
  }
}

class ToDoFormWidget extends StatelessWidget {
  final String title;
  final ValueChanged<String> onChangedTitle;
  final VoidCallback onSavedToDo;

  const ToDoFormWidget({
    Key? key,
    this.title = '',
    required this.onChangedTitle,
    required this.onSavedToDo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        buildTitle(),
        const SizedBox(height: 10),
        buildButton(),
      ],
    ),
  );
  Widget buildTitle() => TextFormField(

    maxLines: 6,
    initialValue: title,
    onChanged: onChangedTitle,
    validator: (title) {
      if (title == '' || title == null) { // espero que isso funcione (isEmpty)
        // return 'Uma tarefa não pode ficar vazia';
      }
      return null;
    },
    decoration: const InputDecoration(
      border: UnderlineInputBorder(),
      labelText: 'O que precisamos fazer?',
      labelStyle: TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  Widget buildButton() => SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.black),
      ),
      onPressed: onSavedToDo,
      child: const Text(
        'Adicionar tarefa',
        style: TextStyle(
            color: Colors.yellow
        ),
      ),
    ),
  );
}

class ToDosProvider extends ChangeNotifier {
  final List<ToDo> _todos = [
    ToDo(
      createdTime: DateTime.now(),
      title: 'estudar Dart 📚',
      id: '',
    ),
    ToDo(
      createdTime: DateTime.now(),
      title: 'lavar roupa ⛈',
      id: '',
    ),
  ];

  List<ToDo> get allToDos => _todos.toList();

  List<ToDo> get todos => _todos.where((todo) => todo.isDone == false).toList();

  List<ToDo> get todosCompleted => _todos.where((todo) => todo.isDone == true).toList();

  void addToDo(ToDo todo) {
    _todos.add(todo);

    notifyListeners();
  }

  void removeToDo(ToDo todo) {
    _todos.remove(todo);

    notifyListeners();
  }

  bool toggleToDoStatus(ToDo todo) {
    todo.isDone = !todo.isDone;
    notifyListeners();

    return todo.isDone;
  }

  void updateToDo(ToDo todo, String title) {
    todo.title = title;

    notifyListeners();
  }
}

class ToDoField {
  static const createdTime = 'createdTime';
}

class ToDo {
  DateTime createdTime;
  String title;
  String id;
  bool isDone;

  ToDo({
    required this.createdTime,
    required this.title,
    required this.id,
    this.isDone = false,
  });
}

class ToDoListWidget extends StatelessWidget {
  const ToDoListWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ToDosProvider>(context);
    final todos = provider.todos;

    return todos.isEmpty
        ? const Center(
      child: Text(
        'Carpe Diem! 💛',
        style: TextStyle(
          fontSize: 20,
          fontStyle: FontStyle.italic,
        ),
      ),
    )
        : ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      separatorBuilder: (context, index) => Container(height: 8),
      itemCount: todos.length,
      itemBuilder: (context, index) {
        final todo = todos[index];

        return ToDoWidget(todo: todo);
      },
    );
  }
}

class ToDoWidget extends StatelessWidget {

  final ToDo todo;

  const ToDoWidget({
    required this.todo,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Colors.white,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(16))
    ),
    padding: const EdgeInsets.all(20),
    child: Row(
      children: [
        Expanded(
          child: Checkbox(
            activeColor: Theme.of(context).primaryColor,
            checkColor: Colors.black,
            value: todo.isDone,
            onChanged: (_) {
              final provider = Provider.of<ToDosProvider>(context, listen: false);
              final isDone = provider.toggleToDoStatus(todo);

              Utils.showSnackBar(
                context,
                isDone ? 'Yay! 💛' : 'Ah, oops 😓',
              );
            },
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          flex: 7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                todo.title,
                style: const TextStyle(
                    fontSize: 20,
                    height: 1.5,
                    fontWeight:
                    FontWeight.bold,
                    color: Colors.black
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: Icon(Icons.edit),
                tooltip: 'Editar',
                onPressed: () => editToDo(context, todo),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.delete_forever),
                tooltip: 'Deletar',
                onPressed: () => (deleteToDo(context, todo)),
              ),
            ],
          ),
        ),
      ],
    ),
  );
  void deleteToDo(BuildContext context, ToDo todo) {
    final provider = Provider.of<ToDosProvider>(context, listen: false);
    provider.removeToDo(todo);

    Utils.showSnackBar(context, 'Tarefa deletada!');
  }

  void editToDo(BuildContext context, ToDo todo) => Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => EditToDoPage(todo: todo, key: UniqueKey(),),
    ),
  );
}

class EditToDoPage extends StatefulWidget {
  final ToDo todo;

  const EditToDoPage({required Key key, required this.todo}) : super(key: key);

  @override
  _EditToDoPageState createState() => _EditToDoPageState();
}

class _EditToDoPageState extends State<EditToDoPage> {
  final _formKey = GlobalKey<FormState>();

  late String title;

  @override
  void initState() {
    super.initState();

    title = widget.todo.title;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      centerTitle: true,
      title: IconButton(
        icon: const Icon(Icons.edit),
        onPressed: () {
          // color change
        },
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.delete_forever),
          onPressed: () {
            final provider =
            Provider.of<ToDosProvider>(context, listen: false);
            provider.removeToDo(widget.todo);

            Navigator.of(context).pop();
          },
        )
      ],
    ),
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: ToDoFormWidget(
          title: title,
          onChangedTitle: (title) => setState(() => this.title = title),
          onSavedToDo: saveToDo,
        ),
      ),
    ),
  );

  void saveToDo() {
    final provider = Provider.of<ToDosProvider>(context, listen: false);

    provider.updateToDo(widget.todo, title);

    Navigator.of(context).pop();
  }
}

class Utils {
  static void showSnackBar(BuildContext context, String text) =>
      ScaffoldMessenger.of(context).removeCurrentSnackBar(
        reason: SnackBarClosedReason.remove,
      );
}

class CompletedListWidget extends StatelessWidget {
  const CompletedListWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ToDosProvider>(context);
    final todos = provider.todosCompleted;

    return todos.isEmpty
        ? const Center(
      child: Text(
        'Carpe Diem! 💛',
        style: TextStyle(
          fontSize: 20,
          fontStyle: FontStyle.italic,
        ),
      ),
    ) : ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      separatorBuilder: (context, index) => Container(height: 8),
      itemCount: todos.length,
      itemBuilder: (context, index) {
        final todo = todos[index];

        return ToDoWidget(todo: todo);
      },
    );
  }
}

class AllListWidget extends StatelessWidget {
  const AllListWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ToDosProvider>(context);
    final todos = provider.allToDos;

    return todos.isEmpty
        ? const Center(
      child: Text(
        'Carpe Diem! 💛',
        style: TextStyle(
          fontSize: 20,
          fontStyle: FontStyle.italic,
        ),
      ),
    ) : ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      separatorBuilder: (context, index) => Container(height: 8),
      itemCount: todos.length,
      itemBuilder: (context, index) {
        final todo = todos[index];

        return ToDoWidget(todo: todo);
      },
    );
  }
}