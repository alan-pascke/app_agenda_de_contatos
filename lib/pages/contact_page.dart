import 'dart:io';

import 'package:app_agenda_de_contatos/helpers/contact_helper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../widgets/button_image_select.dart';

class ContactPage extends StatefulWidget {
  final Contact? contact;
  const ContactPage({Key? key, this.contact}) : super(key: key);

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  //
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _foneController = TextEditingController();
  bool userEdited = false;
  Contact? _editedContact;

  //
  @override
  void initState() {
    super.initState();
    if (widget.contact == null) {
      _editedContact = Contact();
    } else {
      _editedContact = Contact.fromMap(widget.contact!.toMap());
      _nomeController.text = _editedContact!.nome!;
      _emailController.text = _editedContact!.email!;
      _foneController.text = _editedContact!.telefone!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _onWillPop(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.orange[800],
          title: Text(_editedContact!.nome ?? 'Novo Contato'),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              if (_nomeController.text.isNotEmpty &&
                  _foneController.text.isNotEmpty) {
                Navigator.pop(context, _editedContact!);
              } else if (_formKey.currentState!.validate()) {}
            });
          },
          child: const Icon(Icons.save),
          backgroundColor: Colors.orange[800],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                GestureDetector(
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image: _editedContact!.img != null
                              ? FileImage(File(_editedContact!.img!))
                              : const AssetImage('images/person.png')
                                  as ImageProvider,
                          fit: BoxFit.cover),
                    ),
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Selecione uma opção'),
                          actionsAlignment: MainAxisAlignment.spaceBetween,
                          actions: [
                            buttonSelectImage(
                              text: 'Camera',
                              icon: Icons.photo_camera,
                              onClicked: () {
                                ImagePicker()
                                    .pickImage(source: ImageSource.camera)
                                    .then((file) {
                                  if (file == null) {
                                    return;
                                  } else {
                                    setState(() {
                                      _editedContact!.img = file.path;
                                      Navigator.pop(context);
                                    });
                                  }
                                });
                              },
                            ),
                            const SizedBox(height: 10),
                            buttonSelectImage(
                              text: 'Galeria',
                              icon: Icons.photo_library,
                              onClicked: () {
                                ImagePicker()
                                    .pickImage(source: ImageSource.gallery)
                                    .then((file) {
                                  if (file == null) {
                                    return;
                                  } else {
                                    setState(() {
                                      _editedContact!.img = file.path;
                                      Navigator.pop(context);
                                    });
                                  }
                                });
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 15),
                TextFormField(
                  validator: (value) =>
                      validaCampo(value!, text: 'Digite um nome'),
                  controller: _nomeController,
                  decoration: InputDecoration(
                    label: const Text('Nome'),
                    hintText: _editedContact!.nome ?? ' ',
                  ),
                  onChanged: (text) {
                    userEdited = true;
                    setState(() {
                      _editedContact!.nome = text;
                    });
                  },
                ),
                TextFormField(
                  validator: (value) =>
                      validaCampo(value!, text: 'Digite um numero'),
                  controller: _foneController,
                  decoration: InputDecoration(
                    label: const Text('Telefone'),
                    hintText: _editedContact!.telefone ?? ' ',
                  ),
                  onChanged: (text) {
                    userEdited = true;
                    _editedContact!.telefone = text;
                  },
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    label: const Text('Email'),
                    hintText: _editedContact!.email ?? ' ',
                  ),
                  onChanged: (text) {
                    userEdited = true;
                    _editedContact!.email = text;
                  },
                  keyboardType: TextInputType.emailAddress,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String validaCampo(String value, {String? text}) {
    if (value.isEmpty) {
      return '$text';
    } else {
      return '';
    }
  }

  Future<bool> _onWillPop() {
    if (userEdited) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(
              'Descartar alterações?',
            ),
            content: const Text(
              'Sair sem salvar fará com que perca as alterações',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('SIM'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('CANCELAR'),
              ),
            ],
          );
        },
      );
      return Future.value(false);
    } else {
      Navigator.pop(context);
      return Future.value(true);
    }
  }
}
