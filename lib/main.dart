// blog_editor.dart
import 'package:flutter/material.dart';

import 'database/db_helper.dart';
import 'model/blog_model.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlogEditor(),
    );
  }
}

class BlogEditor extends StatefulWidget {
  @override
  _BlogEditorState createState() => _BlogEditorState();
}

class _BlogEditorState extends State<BlogEditor> {
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();
  List<Blog> blogs = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    List<Blog> fetchedBlogs = await DBHelper.instance.getAllBlogs();
    setState(() {
      blogs = fetchedBlogs;
    });
  }

  Future<void> _showDeleteDialog(int id) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Confirmation'),
          content: Text('Are you sure you want to delete this blog post?'),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                await DBHelper.instance.deleteBlog(id);
                fetchData();
                _showSuccessMessage('Blog post deleted successfully.');
                Navigator.of(context).pop();
              },
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('No'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditDialog(Blog blog) async {
    titleController.text = blog.title;
    contentController.text = blog.content;

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Blog Post'),
          content: Column(
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: contentController,
                decoration: InputDecoration(labelText: 'Content'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                blog.title = titleController.text;
                blog.content = contentController.text;
                await DBHelper.instance.updateBlog(blog);
                fetchData();
                _showSuccessMessage('Blog post updated successfully.');
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAddDialog() async {
    titleController.text = '';
    contentController.text = '';

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Blog Post'),
          content: Column(
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: contentController,
                decoration: InputDecoration(labelText: 'Content'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                Blog blog = Blog(
                  title: titleController.text,
                  content: contentController.text,
                );
                await DBHelper.instance.insertBlog(blog);
                fetchData();
                _showSuccessMessage('Blog post created successfully.');
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Blog Editor'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddDialog();
        },
        child: Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: blogs.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(blogs[index].title),
                    subtitle: Text(blogs[index].content),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            _showEditDialog(blogs[index]);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            _showDeleteDialog(blogs[index].id!);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
