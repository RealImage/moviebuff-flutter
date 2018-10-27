import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Moviebuff',
      theme: new ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
        // counter didn't reset back to zero; the application is not restarted.
        primarySwatch: Colors.deepOrange,
      ),
      home: new MainPage(title: 'Moviebuff'),
    );
  }
}

class MainPage extends StatefulWidget {
  MainPage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MainPageState createState() => new _MainPageState();
}

class _MainPageState extends State<MainPage> {
  Map<String, dynamic> results;

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return new Scaffold(
      appBar: new AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: new Text(widget.title),
        bottom: PreferredSize(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                onSubmitted: (val) {
                  print("FETCHING ${val}");
                  setState(() {
                    results = null;
                    http
                        .get(
                            'https://moviebuff-index.herokuapp.com/search/movie?query=${val}')
                        .then((resp) {
                      setState(() {
                        results = json.decode(resp.body);
                      });
                    });
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search',
                  suffixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    borderSide: BorderSide(
                        color: Theme.of(context).primaryColorDark, width: 2.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    borderSide: BorderSide(
                        color: Theme.of(context).primaryColorDark, width: 2.0),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).primaryColorLight,
//                  contentPadding: EdgeInsets.all(8.0),
                  isDense: true,
                ),
              ),
            ),
            preferredSize: Size.fromHeight(48.0)),
      ),
      body: Center(
          child: this.results == null
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : ListView.separated(
                  padding: EdgeInsets.all(16.0),
                  itemCount: results['results'].length,
                  itemBuilder: (context, i) {
                    var list = results['results'];
                    return InkWell(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return new MovieDetails(movie: list[i]);
                        }));
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          IntrinsicHeight(
                            child: Image.network(
                              'https://images.moviebuff.com/${list[i]['poster']}?w=160',
                              fit: BoxFit.contain,
                              width: 80.0,
                            ),
                          ),
                          SizedBox(width: 16.0),
                          Expanded(
                            child: Column(
                              children: <Widget>[
                                Text(
                                  list[i]['name'],
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline
                                      .apply(
                                          color: Theme.of(context)
                                              .primaryColorDark),
                                ),
                                Text(list[i]['info']['synopsis'] ?? '-')
                              ],
                              crossAxisAlignment: CrossAxisAlignment.start,
                            ),
                          )
                        ],
                      ),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return Divider(
                      height: 32.0,
                      color: Theme.of(context).primaryColorLight,
                    );
                  },
                )),
    );
  }
}

class MovieDetails extends StatelessWidget {
  const MovieDetails({
    Key key,
    @required this.movie,
  }) : super(key: key);

  final movie;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(movie['name']),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: <Widget>[
          Text(
            movie['info']['synopsis'] ?? '-',
            style: Theme.of(context)
                .textTheme
                .subhead
                .apply(color: Theme.of(context).primaryColor),
          ),
          SizedBox(
            height: 16.0,
          ),
          SizedBox(
            height: 250.0,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: List<Widget>.from(movie['info']['cast'].map((c) {
                return SizedBox(
                  width: 250.0+16.0,
                  child: Padding(
                    padding: EdgeInsets.only(right: 16.0),
                    child: Stack(
                      children: <Widget>[
                        Positioned.fill(
                            child: Image.network(
                          'https://images.moviebuff.com/${c['poster']}?w=500',
                          fit: BoxFit.cover,
                        )),
                        Positioned(
                          bottom: 8.0,
                          left: 8.0,
                          right: 8.0,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.bottomLeft,
                            child: Container(
                              color: Colors.black.withOpacity(0.7),
                              padding: EdgeInsets.all(4.0),
                              child: Text(
                                c['name'],
                                style: Theme.of(context)
                                    .textTheme
                                    .headline
                                    .apply(
                                        color:
                                            Theme.of(context).primaryColorDark),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              })),
            ),
          ),
        ],
      ),
    );
  }
}

class Logo extends StatelessWidget {
  const Logo({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.network(
        'https://d14t8xmihdgf99.cloudfront.net/assets/favicon-1200-aeb0f1aaaf8b86b3d6475eb855a3234362c442a7b7f0ed7fd2dddd78d4783320.jpg');
  }
}
