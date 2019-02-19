import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geocomment/store/geo_info.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:geolocator/geolocator.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Geo-Info',
      theme: ThemeData(primaryColor: Colors.pink),
      home: MyHomePage(
        title: 'Geo-Info Prototype',
      ),
    );
  }
}


class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() =>
      _MyHomePageState(database: GeoInfoFirestore());
}

class _MyHomePageState extends State<MyHomePage> {
  _MyHomePageState({this.database});
  final GeoInfoData database;

  Future<GeolocationStatus> geolocationStatus =
      Geolocator().checkGeolocationPermissionStatus();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: _buildBody());
  }

  Widget _buildBody() {
    var stream = database.dataStream();
    return ScopedModel<GeoinfoModel>(
      model: GeoinfoModel(stream: stream),
      child: ScopedModelDescendant<GeoinfoModel>(
        builder: (context, child, model) {
              ///model.initPosition();
              return _contentBuilder(model);
            
        },
      ),
    );
  }

  Widget _contentBuilder(GeoinfoModel model)
  {
    if(model.getDisplist != null)
    {      
      return ListView.builder(
              itemCount: model.getDisplist.length,
              itemBuilder: (context, index) {
                return _infoItem(model.getDisplist[index]);
              }
        );
    } else {
      return Container(
        child: Center(
          child: Text("No Data In Range"),
        ),
      );
    }
  }

  Widget _infoItem(GeoInfo data) {


    return Card(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFFC466B),
              const Color(0xFF3F5EFB)
            ], // whitish to gray
            tileMode: TileMode.repeated, // repeats the gradient over the canvas
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(5.0),
          child: Container(
            height: 240.0,
            color: Colors.white24,
            child: Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(5.0),
                  color: Color(0x30FFFFFF),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.location_on,
                        color: Colors.white,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 6.0),
                        child: Text(
                          data.title,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Spacer(),
                      Icon(
                        Icons.public,
                        size: 15.0,
                      ),
                      Text(" ${(data.distance != null) ? data.distance.toString() + ' Km' : ' N/A'}"),
                      //Text("${data.distance - data.range}")
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    data.body,
                    style: TextStyle(color: Colors.white, fontSize: 24.0),
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Container(
                        height: 40.0,
                        color: Colors.black12,
                        child: Row(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.all(6.0),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0)),
                              child: FlatButton(
                                color: Colors.white24,
                                onPressed: () {},
                                child: Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.explore,
                                      color: Colors.white70,
                                      size: 16.0,
                                    ),
                                    Text(
                                      "  detail",
                                      style: TextStyle(color: Colors.white),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Spacer(),
                            IconButton(
                              onPressed: () {},
                              icon: Icon(
                                Icons.thumb_up,
                                color: Colors.white70,
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
