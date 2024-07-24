import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OptionsDialog extends StatefulWidget {
  @override
  _OptionsDialogState createState() => _OptionsDialogState();
}

class _OptionsDialogState extends State<OptionsDialog> {
  final _goalController = TextEditingController();
  final _emailController = TextEditingController();
  double _currentGoal = 2.0;
  double _currentProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _loadCurrentGoalAndProgress();
  }

  Future<void> _loadCurrentGoalAndProgress() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _emailController.text = user.email ?? '';
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          setState(() {
            _currentGoal = data['dailyGoal'] ?? 3.0;
            _currentProgress = data['progress'] ?? 0.0;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _goalController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveDailyGoal() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final newGoal = double.tryParse(_goalController.text) ?? _currentGoal;
      final newProgress = _currentProgress * (_currentGoal / newGoal);

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'dailyGoal': newGoal,
        'progress': newProgress,
      }, SetOptions(merge: true));

      Navigator.of(context).pop(); // Close the dialog after saving
    }
  }

  Future<void> _showChangePasswordDialog() async {
    final _currentPasswordController = TextEditingController();
    final _newPasswordController = TextEditingController();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Mudar senha'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _currentPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Senha atual',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _newPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Nova senha',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar', style: TextStyle(color: Colors.red),),
            ),
            TextButton(
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  try {
                    if (_newPasswordController.text.length < 6) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('A nova senha deve ter pelo menos 6 caracteres')),
                      );
                      return;
                    }
                    final credential = EmailAuthProvider.credential(
                      email: user.email ?? '',
                      password: _currentPasswordController.text,
                    );

                    await user.reauthenticateWithCredential(credential);
                    await user.updatePassword(_newPasswordController.text);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Senha atualizada com sucesso')),
                    );
                    Navigator.of(context).pop();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erro ao atualizar senha: $e')),
                    );
                  }
                }
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAccountDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Conta',style: TextStyle(color:Colors.white)),

          backgroundColor: Color(0xFF5B8ADB),
          surfaceTintColor: Colors.transparent,
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                    fillColor: Colors.white,
                    filled: true,
                    hintText: "Email",
                    hintStyle: const TextStyle(color:Colors.white),
                  ),
                  enabled: false, // Disable editing email

                ),
                SizedBox(height: 10),
                TextField(
                  controller: TextEditingController(text: '******'),
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                    fillColor: Colors.white,
                    filled: true,
                    hintText: "Senha",
                    hintStyle: const TextStyle(color: Colors.white),
                  ),
                  enabled: false, // Disable editing password
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _showChangePasswordDialog,
                  child: Text('Mudar senha'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Fechar',style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDailyGoalDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF5B8ADB),
          title: const Text('Definir o objetivo diário', style: TextStyle(color: Colors.white),),
          content: TextField(
            controller: _goalController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide.none,
              ),
              fillColor: Colors.white,
              filled: true,
              hintText: "Objetivo diário em (L)",
              hintStyle: const TextStyle(color: Color(0xFF5B8ADB)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar', style: TextStyle(color: Colors.white),),
            ),
            TextButton(
              onPressed: () async {
                await _saveDailyGoal();
              },
              child: const Text('Guardar', style: TextStyle(color: Colors.white),),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _showAccountDialog,
              child: Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color:  Color(0xFF5B8ADB),
                  border: Border.all(color: Colors.transparent),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Conta',
                      style: const TextStyle(
                        fontSize: 25,
                        color: Colors.white,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            GestureDetector(
              onTap: _showDailyGoalDialog,
              child: Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Color(0xFF5B8ADB),
                  border: Border.all(color: Colors.transparent),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Objetivo diário',
                      style: const TextStyle(
                        fontSize: 25,
                        color: Colors.white,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
