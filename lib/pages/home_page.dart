// ignore_for_file: avoid_print

import 'dart:io';

import 'package:app_agenda_de_contatos/helpers/contact_helper.dart';
import 'package:app_agenda_de_contatos/pages/contact_page.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //
  ContactHelper helper = ContactHelper();
  //
  List<Contact> contacts = [];
  //
  @override
  void initState() {
    super.initState();
    _getAllContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange[800],
        title: const Text('Contados'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                contacts.sort(
                  ((a, b) {
                    return a.nome!
                        .toLowerCase()
                        .compareTo(b.nome!.toLowerCase());
                    //toLowerCase serve para as letras maiusculas não interferirem na ordenação
                  }),
                );
              });
            },
            icon: const Icon(
              Icons.sort_by_alpha,
              size: 30,
            ),
          ),
          IconButton(
            onPressed: () => showContactPage(),
            icon: const Icon(
              Icons.add,
              size: 30,
            ),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          return _contactCard(context, index);
        },
      ),
    );
  }

  Widget _contactCard(BuildContext context, int index) {
    return GestureDetector(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      image: contacts[index].img != null
                          ? FileImage(File(contacts[index].img!))
                          : const AssetImage('images/person.png')
                              as ImageProvider,
                      fit: BoxFit.cover),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contacts[index].nome ?? ' ',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      contacts[index].email ?? ' ',
                    ),
                    Text(
                      contacts[index].telefone ?? ' ',
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      onTap: () => _showOptions(context, index),
    );
  }

  void _showOptions(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return BottomSheet(
          onClosing: () {},
          builder: (context) {
            return Container(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {
                      launch('tel:${contacts[index].telefone}');
                      Navigator.pop(context);
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.call,
                          color: Colors.red,
                          size: 35,
                        ),
                        Text('Ligar')
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => showContactPage(contact: contacts[index]),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.edit,
                          color: Colors.blue,
                          size: 35,
                        ),
                        Text('Editar')
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      helper.deleteContact(contacts[index].id!);
                      setState(() {
                        contacts.removeAt(index);
                        Navigator.pop(context);
                      });
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.delete,
                          color: Colors.black,
                          size: 35,
                        ),
                        Text('Deletar')
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void showContactPage({Contact? contact}) async {
    final recContact = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContactPage(contact: contact),
      ),
    );
    if (recContact != null) {
      if (contact != null) {
        await helper.updateContact(recContact);
      } else {
        await helper.saveContact(recContact);
      }
      _getAllContacts();
    }
  }

  void _getAllContacts() {
    setState(
      () {
        helper.getAllContact().then((list) => contacts = list as List<Contact>);
      },
    );
  }
}
