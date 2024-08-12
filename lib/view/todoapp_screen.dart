import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:projectsqlflite/view/sql_helper.dart';

class TodoappScreen extends StatefulWidget {
  const TodoappScreen({super.key});

  @override
  State<TodoappScreen> createState() => _TodoappScreenState();
}

class _TodoappScreenState extends State<TodoappScreen> {

  List<Map<String, dynamic>> _journals = [];

  bool _isLoading = true;

  void _refreshJournals()async {
    final data = await SQLHelper.getItems();
    setState(() {
      _journals = data;
      _isLoading = false;
    });
  }

  @override
  void iniState(){
    super.initState();
    _refreshJournals();
  }

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  void _showForm(int? id) async {
    if (id != null) {
      final existingJournal = _journals.firstWhere((_element) => _element['id'] == id);
      _titleController.text = existingJournal['title'];
      _descriptionController.text = existingJournal['description'];
    }

    showModalBottomSheet(
        context: context,
        elevation:5,
        isScrollControlled: true,
        builder: (_) => Container(
          padding: EdgeInsets.only(
            top: 15,
            left: 15,
            right: 15,
            bottom: MediaQuery.of(context).viewInsets.bottom + 120,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'Title'
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  hintText: 'Description'
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: () async{
                if (id == null) {
                  await _addItem();
                }
                if (id != null) {
                  await _updateItem(id);
                }

                _titleController.text = '';
                _descriptionController.text = '';

                if (!mounted) return;
                Navigator.of(context).pop();
              },
                  child: Text(id == null ? 'Create New' : 'Update'),
              )
            ],
          ),
        ));
  }


  Future<void> _addItem() async {
    await SQLHelper.createItem(
      _titleController.text, _descriptionController.text
    );
    _refreshJournals();
  }

  Future<void> _updateItem(int id) async {
    await SQLHelper.updateItem(
        id, _titleController.text, _descriptionController.text);
    _refreshJournals();
  }

  void _deleteItem(int id) async{
    await SQLHelper.deleteItem(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Successfully delete a journal!'),
    ));
    _refreshJournals();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TODO App'),
      ),
      body: _isLoading
      ? const Center(
        child: CircularProgressIndicator(),
      )
          : ListView.builder(
          itemCount: _journals.length,
          itemBuilder: (context, index) => Card(
            color: Colors.orange[200],
            margin: const EdgeInsets.all(15),
            child: ListTile(
              title: Text(_journals[index] ['title']),
              subtitle: Text(_journals[index]['description']),
              trailing: SizedBox(
                width: 100.w,
                child: Row(
                  children: [
                    IconButton(icon: const Icon(Icons.edit),
                    onPressed: () =>
                      _showForm(_journals[index]['id']),
                    ),
                    IconButton(icon: const Icon(Icons.delete),
                    onPressed: () => _deleteItem(_journals[index]['id']),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ),
      floatingActionButton: FloatingActionButton(child: const Icon(Icons.add),
      onPressed: () => _showForm(null),
      ),
    );
  }
}
