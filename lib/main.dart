import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import './database.dart';
import 'dart:async';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import './services.dart';
import 'servicesLocator.dart';

void main() {
  setupLocator();
  runApp(HomePage());
}

class AnimatedButtons extends StatelessWidget {
  AnimatedButtons({this.animation});
  final AnimationController animation;

  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: new CurvedAnimation(parent: animation, curve: Curves.easeOut),
      axisAlignment: 0.0,
      child: Center(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  new CircleAvatar(
                    radius: 30,
                    child: new IconButton(
                      icon: Icon(Icons.add, color: Colors.white),
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute<void>(
                            builder: (BuildContext context) => Adicionar()));
                      },
                    ), //
                  ),
                  new CircleAvatar(
                      radius: 30,
                      child: new IconButton(
                        icon: Icon(Icons.list, color: Colors.white),
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute<void>(
                              builder: (BuildContext context) => ContactList()));
                        },
                      )),
                ],
              ),
              new Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  new Container(
                    margin: const EdgeInsets.all(16),
                    child: new Text('Add'),
                  ),
                  new Container(
                    margin: const EdgeInsets.all(16),
                    child: new Text("List"),
                  )
                ],
              ),
            ],
          )),
    );
  }
}

class HomePage extends StatefulWidget {
  State createState() => Home();
}

class Home extends State<HomePage> with TickerProviderStateMixin {
  final ThemeData iOSTheme = new ThemeData(
      primarySwatch: Colors.green,
      primaryColor: Colors.green,
      primaryColorBrightness: Brightness.light);

  final ThemeData androidTheme = new ThemeData(
      primarySwatch: Colors.green, accentColor: Colors.black);

  Widget renderButtons() {
    AnimatedButtons buttons = new AnimatedButtons(
      animation: new AnimationController(
          vsync: this, duration: new Duration(milliseconds: 3000)),
    );
    buttons.animation.forward();
    return buttons;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Home',
      debugShowCheckedModeBanner: false,
      theme:
      defaultTargetPlatform == TargetPlatform.iOS ? iOSTheme : androidTheme,
      home: new Builder(
        builder: (context) => new Scaffold(
            appBar: AppBar(
              title: new Text("Minha Agenda"),
              centerTitle: true,
            ),
            body: Padding(
                padding: const EdgeInsets.all(12.0), child: renderButtons())),
      ),
    );
  }
}

class Validate extends StatelessWidget {
  String validarCelular(String value) {
    String patttern = r'(^[0-9]*$)';
    RegExp regExp = new RegExp(patttern);
    if (value.length == 0) {
      return "Informe o celular";
    } else if (value.length > 14 || value.length < 8) {
      return "O celular deve ter no mínimo 8 e no máximo 14 dígitos";
    } else if (!regExp.hasMatch(value)) {
      return "Número de celular deve conter apenas dígitos!";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return null;
  }
}

class AddForm extends StatefulWidget {
  _AddFormState createState() => _AddFormState();
}

class _AddFormState extends State<AddForm> {
  final dbHelper = DatabaseHelper.instance;
  TextEditingController _nome = TextEditingController();
  TextEditingController _numero = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String imagePath;

  _inserir() async {
    if (_formKey.currentState.validate()) {
      Map<String, dynamic> row = {
        DatabaseHelper.columnNome: _nome.text,
        DatabaseHelper.columnTelefone: _numero.text,
        DatabaseHelper.columnPic: imagePath
      };
      final id = await dbHelper.insert(row);
      print('Linha inserida $id');
      AlertMessages().inserirConfirm(context);
      clearInputs();
    }
  }

  clearInputs() {
    _nome.clear();
    _numero.clear();
  }

  Future<File> imageFile;
  pickImageFromGallery(ImageSource source) async {
    dynamic image = ImagePicker.pickImage(source: source);
    setState(() {
      imageFile = image;
    });
  }

  Widget setImage() {
    return FutureBuilder<File>(
        future: imageFile,
        builder: (BuildContext context, AsyncSnapshot<File> snapashot) {
          if(snapashot.connectionState == ConnectionState.done && snapashot.data != null) {
            imagePath = snapashot.data.path;
            return Image.file(snapashot.data);
          } else if(snapashot.error == null) {
            return Icon(Icons.person, size: 100, color: Colors.blueGrey);
          } else {
            return Image.asset(imagePath);
          }
        }
    );
  }


  @override
  Widget build(BuildContext context) {
    return new Container(
        child: new Form(
          key: _formKey,
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              CircleAvatar(
                  backgroundColor: Colors.transparent,
                  radius: 80,
                  child: ClipOval(child: setImage())
              ),
              new Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new IconButton(icon: Icon(Icons.camera), onPressed: ()  { pickImageFromGallery(ImageSource.gallery); }),
                  new IconButton(icon: Icon(Icons.camera_alt), onPressed: ()  { pickImageFromGallery(ImageSource.camera); }),
                ],
              ),              new TextFormField(
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Digite o nome';
                  }
                  return null;
                },
                decoration: InputDecoration(
                    labelText: "Nome", labelStyle: TextStyle(fontSize: 20.0)),
                controller: _nome,
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 15.0),
              ),
              new TextFormField(
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                    labelText: "Número", labelStyle: TextStyle(fontSize: 20.0)),
                controller: _numero,
                validator: Validate().validarCelular,
                style: TextStyle(fontSize: 15.0),
                textAlign: TextAlign.left,
              ),
              new Container(
                padding: const EdgeInsets.fromLTRB(40.0, 25.0, 70.0, 0),
                height: 60.0,
                child: new Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    new RaisedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(20.0),
                        ),
                        child: new Text("Cancelar",
                            style: TextStyle(color: Colors.white, fontSize: 20.0)),
                        color: Colors.red),
                    new RaisedButton(
                      onPressed: () {
                        _inserir();
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(20.0),
                      ),
                      child: new Text("Salvar",
                          style: TextStyle(color: Colors.white, fontSize: 20.0)),
                      color: Colors.green,
                    )
                  ],
                ),
              )
            ],
          ),
        ));
  }
}

class Adicionar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Container(),
        title: new Text("Adicionar Contato"),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.home),
              onPressed: () {
                Navigator.popUntil(
                    context, ModalRoute.withName(Navigator.defaultRouteName));
              }),
          IconButton(
              icon: Icon(Icons.list),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => ContactList())); //
              }),
        ],
      ),
      body: SingleChildScrollView(
          padding: EdgeInsets.all(16.0), child: AddForm()),
    );
  }
}

class ContactList extends StatefulWidget {
  _ContactListState createState() => _ContactListState();
}

class _ContactListState extends State<ContactList> {
  final dbHelper = DatabaseHelper.instance;
  List<dynamic> _saved = List<dynamic>();
  List<dynamic> mapProfileId = List<dynamic>();
  _ContactEditState delete = _ContactEditState();

  AlertMessages alerts = AlertMessages();

  _consultar() async {
    final lista = await dbHelper.queryAllRows();
    setState(() {
      _saved.clear();
      for (final each in lista) {
        _saved.add(each);
      }
    });
  }

  Future<File> _getProfile(String path) async {
    var dir = (await getApplicationDocumentsDirectory()).path;
    File file = new File(path);
    return file;
  }

  Widget loadImage(contact) {
    print("Perfil path: ${contact['perfil']}");
    return FutureBuilder<File>(
        future: _getProfile(contact['perfil']),
        builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
        return snapshot.data != null ? Image.file(snapshot.data):
        new Text(contact['nome'][0], style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold, color: Colors.black));
      }
    );
  }

  Widget cardView(actualContact) {
    return Row(
        children: [
          Padding(padding: const EdgeInsets.all(4.0)),
          CircleAvatar(
            backgroundColor: Colors.white,
            radius: 30,
            child: ClipOval(
                child: loadImage(actualContact)),
          ),
          Flexible(
            fit: FlexFit.loose,
            flex: 1,
            child:
            ListTile(
              title: new Text(
                actualContact['nome'],
                style: new TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold),
              ),
              subtitle: new Text(actualContact['telefone'].toString(),
                  style: TextStyle(fontSize: 14.0)),
            ),
          ),
          IconButton(
              onPressed: () {
                alerts.makeCall(context, actualContact);
              },
              icon: Icon(Icons.call)),
          IconButton(
              onPressed: () {
                delete.delete(actualContact['_id'], context);
              },
              icon: Icon(Icons.delete)),
          IconButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ContactEdit(actualContact)));
              },
              icon: Icon(Icons.edit))
        ]);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> divided = List<Widget>();
    _consultar();

    Iterable<Widget> tiles = _saved.map((dynamic actualContact) {
      return new Container(
          margin: const EdgeInsets.all(4.0),
          child:  Card(
              child: InkWell(
                  splashColor: Colors.blue.withAlpha(30),
                  child: cardView(actualContact))
          )
      );
    }
    );

    divided = ListTile.divideTiles(
      context: context,
      tiles: tiles,
    ).toList();

    return Scaffold(
      appBar: AppBar(
        leading: Container(),
        title: new Text("Lista de Contatos"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              Navigator.popUntil(
                  context, ModalRoute.withName(Navigator.defaultRouteName));
            },
          )
        ],

      ),

      body: new ListView(children: divided),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Adicionar contato',
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Adicionar()));
        },
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class ContactEdit extends StatefulWidget {
  ContactEdit(this.contact);
  final dynamic contact;
  State createState() => _ContactEditState();
}

class _ContactEditState extends State<ContactEdit> {
  static TextEditingController _nameEdit = TextEditingController();
  TextEditingController _numberEdit = TextEditingController();
  final _Key = GlobalKey<FormState>();
  final dbHelper = DatabaseHelper.instance;
  TextFormField inputNome;
  TextFormField inputNumero;


  String imagePath;
  Future<File> imageFile;
  pickImageFromGallery(ImageSource source) {
    dynamic image = ImagePicker.pickImage(source: source);

    setState(() {
      imageFile = image;
    });
  }


    Future<File> _getLocalFile(String path) async {
    String dir = (await getApplicationDocumentsDirectory()).path;
    File fileImage = new File(path);
    return fileImage;
  }

  Widget setImage() {
    return FutureBuilder<File>(
        future: imageFile,
        builder: (BuildContext context, AsyncSnapshot<File> snapashot) {
          if(snapashot.connectionState == ConnectionState.done && snapashot.data != null) {
            imagePath = snapashot.data.path;
            return Image.file(snapashot.data);
          } else {
            return Icon(Icons.person, size: 100, color: Colors.blueGrey);
          }
        }
    );
  }

  Widget loadImage(path) {
    return FutureBuilder<File>(
        future: _getLocalFile(path),
        builder: (BuildContext context, AsyncSnapshot<File> snapashot) {
          if(snapashot.connectionState == ConnectionState.done && snapashot.data != null) {
            return Image.file(snapashot.data);
          } else {
            return Text("Failed", style: TextStyle(color: Colors.white));
          }
        }
    );
  }

  @override
  void initState() {
    _nameEdit.text = widget.contact['nome'];
    _numberEdit.text = widget.contact['telefone'].toString();


//    print(widget.contact['perfil']);
    print("before***************** $imagePath");
    imagePath = widget.contact['perfil'];
    print("After***************** $imagePath");

    super.initState();

    inputNome = TextFormField(
      controller: _nameEdit,
      validator: (value) {
        if (value.isEmpty) {
          return 'Digite o Nome';
        }
        return null;
      },
      decoration: new InputDecoration(
          labelText: "Nome", labelStyle: new TextStyle(fontSize: 20.0)),
      style: TextStyle(fontSize: 15.0),
      textAlign: TextAlign.left,
    );
    inputNumero = TextFormField(
      keyboardType: TextInputType.number,
      controller: _numberEdit,
      validator: Validate().validarCelular,
      decoration: new InputDecoration(
          labelText: "Número", labelStyle: new TextStyle(fontSize: 20.0)),
      style: TextStyle(fontSize: 15.0),
      textAlign: TextAlign.left,
    );
  }

  _atualizar(dynamic contact) async {
    if (_Key.currentState.validate()) {
      Map<String, dynamic> row = {
        DatabaseHelper.columnId: contact['_id'],
        DatabaseHelper.columnNome: _nameEdit.text,
        DatabaseHelper.columnTelefone: _numberEdit.text,
        DatabaseHelper.columnPic: imagePath
      };
      final linhasAfetadas = await dbHelper.update(row);
      print('Linhas afetadas: $linhasAfetadas linha(s)');
      print(row);
      AlertMessages().atualizarConfirm(context);
    }
  }

  delete(id, context) {
    print(id);
    AlertMessages().excluirConfirm(context, id);
  }

  deletar(id) async {
    final linhaDeletada = await dbHelper.delete(id);
    print('Deletada(s) $linhaDeletada linha(s): linha $id');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            leading: new Container(),
            title: new Text("Editar"),
            centerTitle: true,
            actions: <Widget>[
              IconButton(
                  icon: Icon(Icons.home),
                  onPressed: () {
                    Navigator.popUntil(context,
                        ModalRoute.withName(Navigator.defaultRouteName));
                  }),
            ]),
        body: new SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: new Form(
              key: _Key,
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  CircleAvatar(
                      backgroundColor: Colors.transparent,
                      radius: 80,
                      child: ClipOval(child: imagePath != null ? loadImage(imagePath) : setImage())
                  ),
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new IconButton(icon: Icon(Icons.camera), onPressed: ()  { pickImageFromGallery(ImageSource.gallery); }),
                      new IconButton(icon: Icon(Icons.camera_alt), onPressed: ()  { pickImageFromGallery(ImageSource.camera); }),
                      new IconButton(icon: Icon(Icons.delete), onPressed: ()  {
                        setState(() {
                        imagePath = null;
                      }); }),
                    ],
                  ),
                  inputNome,
                  inputNumero,
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: new Container(
                        padding: const EdgeInsets.fromLTRB(50.0, 20.0, 60.0, 0),
                        height: 60.0,
                        child: new Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            new RaisedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                shape: RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(20.0),
                                ),
                                child: new Text("Cancelar",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 20.0)),
                                color: Colors.red),
                            new RaisedButton(
                              onPressed: () {
                                _atualizar(widget.contact);
                              },
                              shape: RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(20.0),
                              ),
                              child: new Text("Salvar",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20.0)),
                              color: Colors.green,
                            )
                          ],
                        ),
                      ))
                ],
              ),
            )));
  }
}

class Chamada extends StatefulWidget {
  Chamada(this.contato);
  final contato;
  State createState() => _ChamadaState();
}

class _ChamadaState extends State<Chamada> {
  Timer _timer;
  int _start = 0;
  final CallsAndMessagesService _service = locator<CallsAndMessagesService>();

  void durationCall() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
        oneSec,
            (Timer timer) => setState(() {
          if (_start > 59) {
            _start = 0;
          } else {
            _start += 1;
          }
        }));
  }

  @override
  void initState() {
    _service.call(widget.contato['telefone'].toString());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Home tema = Home();
    durationCall();
    return new MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: tema.androidTheme,
        home: Scaffold(
            appBar: AppBar(
              title: new Text('Em chamada...'),
              centerTitle: true,
            ),
            body: new Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  new Text("00:00:$_start", style: TextStyle(fontSize: 25)),
                  new Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.transparent,
                          radius: 100,
                          child: ClipOval(
                              child: _ContactListState().loadImage(widget.contato)),
                          //new Text(actualContact['nome'][0])
                        )
                      ]),
                  new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        new CircleAvatar(
                          radius: 40,
                          child: new IconButton(
                              icon: Icon(Icons.call_end),
                              iconSize: 40,
                              onPressed: () {
                                dispose();
                                Navigator.pop(context);
                              }),
                          backgroundColor: Colors.red,
                        ),
                      ])
                ])));
  }
}

class AlertMessages extends StatelessWidget {
  Widget inserirConfirm(context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text('Salvo'),
              content: Text('Contato Salvo com sucesso!'),
              actions: <Widget>[
                new FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ContactList(),
                          ));
                    },
                    child: Text('OK',
                        style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold)))
              ]);
        });
  }

  hangUp(context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: new Text('Chamada encerrada'),
          );
        });
  }

  afterDelete(context) { // not used
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text('Excluído'),
              content: Text('Contato excluído!'),
              actions: <Widget>[
                new FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ContactList()));

                    },
                    child: Text('OK', style: TextStyle(color: Colors.green))),
              ]);
        });
  }

  excluirConfirm(context, id) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text('Excluir ?'),
              content: Text('Deseja realmente excluir este contato?'),
              actions: <Widget>[
                new FlatButton(
                  child: Text('Não', style: TextStyle(color: Colors.green)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                new FlatButton(
                  child: Text('Sim',
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    _ContactEditState().deletar(id);
                    Navigator.of(context).pop();
                  },
                )
              ]);
        });
  }

  Widget atualizarConfirm(context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text('Salvo'),
              content: Text('As alterações foram salvas com sucesso!'),
              actions: <Widget>[
                new FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ContactList(),
                          ));
                    },
                    child: Text('OK',
                        style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold)))
              ]);
        });
  }

  Widget makeCall(context, contact) {
    // test only
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text('Chamar ?'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 30,
                        child: ClipOval(
                            child: _ContactListState().loadImage(contact)),
                        //new Text(actualContact['nome'][0])
                      )),
                  new Text(contact['nome'],
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  new Text(contact['telefone'].toString())
                ],
              ),
              actions: <Widget>[
                new FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Não',
                        style: TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold))),
                new FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Chamada(contact)));
                    },
                    child: Text('Ligar',
                        style: TextStyle(
                            color: Colors.green, fontWeight: FontWeight.bold)))
              ]);
        });
  }

  @override
  Widget build(BuildContext context) {
    return inserirConfirm(context);
  }
}
