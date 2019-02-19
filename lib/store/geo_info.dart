import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong/latlong.dart';

//MODEL
class GeoInfo {
  GeoInfo({this.id, this.title, this.body, this.distance, this.disp, this.position, this.range});
  final String id;
  final String title;
  final String body;
  final GeoPoint position;
  final double range;
  final double distance;
  final bool disp;
}


//STORE
class GeoinfoModel extends Model {
    GeoinfoModel({Stream<List<GeoInfo>> stream}) {
    stream.listen((geoInfoData) {      
      this.infoList = geoInfoData;
      notifyListeners();
      this.initPosition();
    });
    

  }

  static Position _currentPosition;
  List<GeoInfo> infoList;
  List<GeoInfo> _displist;


  static var _geolocator = Geolocator();
  static var locationOptions = LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 10);

/*   StreamSubscription<Position> positionStream = _geolocator.getPositionStream(locationOptions).listen((Position data){
    
      _currentPosition = data;      

  }); */

  

    //getter
    List<GeoInfo> get getInfoList =>  this.infoList;
    List<GeoInfo> get getDisplist => this._displist;
    Position get currentPosition => _currentPosition;


  //actions
  void initPosition() async
  {
    _currentPosition = await _geolocator.getLastKnownPosition(desiredAccuracy: LocationAccuracy.high);
    this.upsateItemsDistance(_currentPosition);
    notifyListeners();
    
  }



    //MUTATION
    //=============================


    //set item distances
    void upsateItemsDistance(Position _position)
    {

        _displist = [];

        List<GeoInfo> cekList = infoList; 
  

        if(_position != null)
        {
          List<GeoInfo> newList = cekList.map<GeoInfo>((info) {
            
              double distance = calculateDistance(
                    LatLng(info.position.latitude, info.position.longitude),
                    LatLng(_position.latitude, _position.longitude)
                  );

              return GeoInfo(
                  id: info.id,
                  title: info.title,
                  body: info.body,
                  position: info.position,
                  distance: distance,
                  range: info.range,
                  disp: checkVisibility(distance, info.range),
              );
          }).toList();  

         
          this._displist = newList.where((item)=> item.disp).toList();          
          notifyListeners();
                    
        }
    }

    bool checkVisibility(double distance, double range)
    {        
        return range.compareTo(distance) > -1;
    }

    //calculate distance 
    double calculateDistance(LatLng start, LatLng end)
    {
      final kilo = new Distance().as(LengthUnit.Kilometer, start, end);
      //print(kilo);
      return kilo;
    }


    //set displist by filtering
}

//DATABASE
abstract class GeoInfoData {
  Future<void> create();
  Future<void> update(GeoInfo geoInfo);
  Future<void> delete(GeoInfo geoInfo);
  Stream<List<GeoInfo>> dataStream();
}




//DATABASE IMPLEMENTATION
class GeoInfoFirestore implements GeoInfoData
{   

    Future<void> create()
    {

    }


    Future<void> update(GeoInfo geoInfo)
    {

    }

    Future<void> delete(GeoInfo info)
    {

    }

    Stream<List<GeoInfo>> dataStream()
    {
      return _FirestoreStream<List<GeoInfo>>(
        apiPath: rootPath,
        parser: FirestoreGeoInfoParser(),
      ).stream;
    }

    DocumentReference _documentReference(GeoInfo geoInfo) {
      return Firestore.instance.collection(rootPath).document('${geoInfo.id}');      
    }  

    static final String rootPath = 'geo_info';
}



abstract class FirestoreNodeParser<T> {

  T parse(QuerySnapshot querySnapshot);
}

class FirestoreGeoInfoParser extends FirestoreNodeParser<List<GeoInfo>> {

  List<GeoInfo> parse(QuerySnapshot querySnapshot) {
    var geoinfos = querySnapshot.documents.map((documentSnapshot) {


      return GeoInfo(
        id: documentSnapshot.documentID,
        title: documentSnapshot['title'],
        body: documentSnapshot['body'],
        position: documentSnapshot['kordinat'],
        range: documentSnapshot['range'].toDouble(),
        disp: false
        //distance: 0
      );
    }).toList();
    
    //geoinfos.sort((lhs, rhs) => rhs.id.compareTo(lhs.distance));

    return geoinfos;
  }


}


class _FirestoreStream<T> {
  _FirestoreStream({String apiPath, FirestoreNodeParser<T> parser}) {
    CollectionReference collectionReference = Firestore.instance.collection(apiPath);
    Stream<QuerySnapshot> snapshots = collectionReference.snapshots();
    stream = snapshots.map((snapshot) => parser.parse(snapshot));
  }

  Stream<T> stream;
}