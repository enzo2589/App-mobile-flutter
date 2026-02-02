import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://eykbjkunballfjvcfzsw.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV5a2Jqa3VuYmFsbGZqdmNmenN3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA5MTEzODIsImV4cCI6MjA3NjQ4NzM4Mn0.M6aZsL0RcOtl7PclIgzcfiv-Nk5blJJcDTpEevLy4go',
  );
  
  runApp(const MyApp());
}

class Note {
  final int id;
  final String text;
  final String date;
  
  Note({required this.id, required this.text, required this.date});
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My ToDoList App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const AuthChecker(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const MyHomePage(),
      },
    );
  }
}

class AuthChecker extends StatefulWidget {
  const AuthChecker({super.key});

  @override
  State<AuthChecker> createState() => _AuthCheckerState();
}

class _AuthCheckerState extends State<AuthChecker> {
  late final StreamSubscription<AuthState> _authStateSubscription;

  @override
  void initState() {
    super.initState();
    _authStateSubscription =
        Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _authStateSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Supabase.instance.client.auth.currentSession == null
        ? const LoginPage()
        : const MyHomePage();
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Note> notes = [];
  
  final client = Supabase.instance.client;
  String? errorMsg;

  @override
  void initState() {
    super.initState();
    fetchNotes();
  }


  Future<void> fetchNotes() async {
    try {
      final data = await client.from('note').select().order('id', ascending: true);
      
      setState(() {
        notes = [
          for (final item in data)
            Note(id: item['id'], text: item['text'], date: item['date'])
        ];
        errorMsg = null;
      });
    } catch (e) {
      setState(() {
        errorMsg = 'Erreur chargement: $e';
      });
      debugPrint(errorMsg);
    }
  }

  Future<void> addNote(String text) async {
    try {
      await client.from('note').insert({
        'text': text, 
        'date': DateTime.now().toString().split(' ')[0]
      });
      await fetchNotes();
    } catch (e) {
      setState(() { errorMsg = 'Erreur ajout: $e'; });
    }
  }

  Future<void> updateNote(int id, String newText) async {
    try {
      await client.from('note').update({'text': newText}).eq('id', id);
      await fetchNotes();
    } catch (e) {
      setState(() { errorMsg = 'Erreur modif: $e'; });
    }
  }

  Future<void> deleteNote(int id) async {
    try {
      await client.from('note').delete().eq('id', id);
      await fetchNotes();
    } catch (e) {
      setState(() { errorMsg = 'Erreur suppression: $e'; });
    }
  }


  void _addNote() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController textController = TextEditingController();
        return AlertDialog(
          title: const Text('Ajouter une tache'),
          content: TextField(
            controller: textController,
            decoration: const InputDecoration(hintText: 'Entrez votre tache '),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                if (textController.text.isNotEmpty) {
                  await addNote(textController.text);
                  if (mounted) Navigator.of(context).pop();
                }
              },
              child: const Text('Ajouter'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout() async {
    try {
      await Supabase.instance.client.auth.signOut();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur déconnexion: $e')),
        );
      }
    }
  }

  void _editNote(int index) {
    final noteToEdit = notes[index];
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController textController = TextEditingController(text: noteToEdit.text);
        return AlertDialog(
          title: const Text('Modifier la tache'),
          content: TextField(
            controller: textController,
            decoration: const InputDecoration(hintText: 'Modifiez votre tache'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                if (textController.text.isNotEmpty) {
                  await updateNote(noteToEdit.id, textController.text);
                  if (mounted) Navigator.of(context).pop();
                }
              },
              child: const Text('Modifier'),
            ),
          ],
        );
      },
    );
  }

  void _deleteNote(int index) async {
    final noteId = notes[index].id;
    await deleteNote(noteId);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: Row(
          children: [
            const Icon(Icons.menu_book, color: Color.fromARGB(255, 7, 226, 255)),
            const SizedBox(width: 8),
            const Text("My ToDoList App",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const Spacer(),
            IconButton(
              onPressed: () {
                _addNote();
              },
              icon: const Icon(Icons.add, color: Color.fromARGB(255, 7, 226, 255)),
            ),
            IconButton(
              onPressed: _logout,
              icon: const Icon(Icons.logout, color: Color.fromARGB(255, 7, 226, 255)),
              tooltip: 'Se déconnecter',
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          if (errorMsg != null)
            Container(
              color: Colors.redAccent,
              padding: const EdgeInsets.all(8),
              width: double.infinity,
              child: Text(errorMsg!, style: const TextStyle(color: Colors.white)),
            ),
          Expanded(
            child: notes.isEmpty
                ? const Center(child: Text("Aucune tâche"))
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      final task = notes[index];

                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(task.text,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(task.date,
                                      style: const TextStyle(
                                          color: Colors.blueAccent, fontWeight: FontWeight.w600)),
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () => _editNote(index),
                                        icon: const Icon(Icons.edit, color: Colors.green),
                                      ),
                                      IconButton(
                                        onPressed: () => _deleteNote(index),
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
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