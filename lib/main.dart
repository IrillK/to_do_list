import 'package:flutter/material.dart';
import 'Database.dart';
import 'Business.dart';

void main() {
  runApp(MyAppCheck());
}

class MyAppCheck extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ToDo',
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ToDoList(),
    );
  }
}

typedef void CartChangedCallback(Business business, bool inCart);

class ToDoListItem extends StatelessWidget{
  final Business business;
  final bool inCart;
  final CartChangedCallback onCartChanged;

  ToDoListItem({this.business, this.inCart, this.onCartChanged}) : super(key: ObjectKey(business));

  Color _getColor(BuildContext context){
    return inCart ? Colors.black54 : Theme.of(context).primaryColor;
  }

  TextStyle _getTextStyle(BuildContext context){
    if(!inCart) return null;
    return TextStyle(
      color: Colors.black54,
      decoration: TextDecoration.lineThrough,
    );
  }

  @override
  Widget build(BuildContext context) {
      return ListTile(
        onTap: (){
          onCartChanged(business, inCart);
        },
        leading: CircleAvatar(
          backgroundColor: _getColor(context),
          child: Text(business.text[0]),
        ),
        title: Text(business.text, style: _getTextStyle(context)),
      );
  }

}

class ToDoList extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => ToDoListState();
}

class ToDoListState extends State<ToDoList>{
  final myController = TextEditingController();

  _showDialog() async {
    await showDialog<String>(
      context: context,
      child: new _SystemPadding(child: new AlertDialog(
        contentPadding: const EdgeInsets.all(16.0),
        content: new Row(
          children: <Widget>[
            new Expanded(
              child: new TextField(
                controller: myController,
                autofocus: true,
                decoration: new InputDecoration(
                    labelText: 'new business', hintText: 'to_do'),
              ),
            )
          ],
        ),
        actions: <Widget>[
          new FlatButton(
              child: const Text('CANCEL'),
              onPressed: () {
                myController.clear();
                Navigator.pop(context);
              }),
          new FlatButton(
              child: const Text('OPEN'),
              onPressed: ()  {
                Navigator.pop(context);
              })
        ],
      ),),
    );
  }

  void _handleCartChanged(Business business, bool inCart){
    setState(() {
        DBProvider.db.blockOrUnblock(business);
    });
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text("To Do")),
      body: FutureBuilder<List<Business>>(
        future: DBProvider.db.getAllBusiness(),
        // ignore: missing_return
        builder: (BuildContext context, AsyncSnapshot<List<Business>> snapshot){
          if(snapshot.hasData){
            return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index){
                  Business item = snapshot.data[index];
                  return Dismissible(
                    key: UniqueKey(),
                    background: Container(color: Colors.deepOrange),
                    onDismissed: (direction){
                      DBProvider.db.deleteBusiness(item.id);
                    },
                    child: ToDoListItem(
                      business: item,
                      inCart: item.blocked,
                      onCartChanged: _handleCartChanged,
                    ),
                  );
                },
            );
          }else{
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          await _showDialog();
          if(myController.text.length != 0){
            Business bsn = new Business(text: myController.text, blocked: false);
            await DBProvider.db.newBusiness(bsn);
            myController.clear();
            setState(() {});
          }
        },

      ),
    );
  }
}

class _SystemPadding extends StatelessWidget {
  final Widget child;

  _SystemPadding({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    return new AnimatedContainer(
        padding: mediaQuery.padding,
        duration: const Duration(milliseconds: 300),
        child: child);
  }
}


