import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  final String username;
  const ProfilePage({super.key, required this.username});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? userData;
  bool _editingEmail = false;
  bool _editingPassword = false;

  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  File? _newImage;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString("users") ?? "{}";
    final Map<String, dynamic> users = jsonDecode(raw);

    if (users.containsKey(widget.username)) {
      setState(() {
        userData = Map<String, dynamic>.from(users[widget.username]);
        _emailCtrl.text = userData?["email"] ?? "";
        _passwordCtrl.text = userData?["password"] ?? "";
      });
    }
  }

  Future<void> _saveUser() async {
    if (userData == null) return;

    userData?["email"] = _emailCtrl.text;
    userData?["password"] = _passwordCtrl.text;

    if (_newImage != null) {
      userData?["photo"] = base64Encode(await _newImage!.readAsBytes());
    }

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString("users") ?? "{}";
    final Map<String, dynamic> users = jsonDecode(raw);

    users[widget.username] = userData;
    await prefs.setString("users", jsonEncode(users));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("อัพเดตข้อมูลแล้ว")),
      );
    }
  }

  Future<void> _pickNewImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _newImage = File(picked.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (userData == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("ประวัติผู้เรียน"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickNewImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _newImage != null
                    ? FileImage(_newImage!)
                    : (userData?["photo"] != null
                        ? MemoryImage(base64Decode(userData?["photo"]))
                        : null) as ImageProvider?,
                child: (userData?["photo"] == null && _newImage == null)
                    ? const Icon(Icons.person, size: 40)
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            Text("${widget.username}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            // Birthday
            ListTile(
              title: const Text("วันเกิด"),
              subtitle: Text(userData?["birthday"] ?? "-"),
            ),
            ListTile(
              title: const Text("ระดับการศึกษา"),
              subtitle: Text(userData?["education"] ?? "-"),
            ),
            ListTile(
              title: const Text("Email"),
              subtitle: _editingEmail
                  ? TextField(controller: _emailCtrl, autofocus: true)
                  : Text(userData?["email"] ?? "-"),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => setState(() => _editingEmail = !_editingEmail),
              ),
            ),
            ListTile(
              title: const Text("User"),
              subtitle: Text(widget.username),
            ),
            ListTile(
              title: const Text("Password"),
              subtitle: _editingPassword
                  ? TextField(controller: _passwordCtrl, obscureText: true, autofocus: true)
                  : Text("*" * (_passwordCtrl.text.length)),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => setState(() => _editingPassword = !_editingPassword),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _saveUser, child: const Text("บันทึกการแก้ไข")),
          ],
        ),
      ),
    );
  }
}
