import 'package:flipbook/models/groupPoints.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  List<GroupPoints> points = [];
  List<GroupPoints> tempPoints = [];
  Map<int, List<GroupPoints>> frames = {};

  int currentFrame = 0;

  double scrollPos = 0;
  ScrollController controller = ScrollController();

  bool isPlaying = false;
  bool isLooped = false;
  Timer _timer;
  int _start = 33;
  void startTimer(){
    const oneSec = const Duration(milliseconds: 1);
    _timer = new Timer.periodic(
        oneSec,
            (Timer timer) => setState(
                (){
              if (isPlaying){
                if (_start == 0){
                  if(currentFrame <= frames.length - 1){
                    currentFrame += 1;
                  }else{
                    if(isLooped){
                      _start = 33;
                      currentFrame = 0;
                    }else{
                      isPlaying = false;
                      timer.cancel();
                      _start = 33;
                      currentFrame = 0;
                    }

                  }
                  _start = 33;
                }
                else{
                  _start -= 1;
                }
              }
              else {
                timer.cancel();
              }
            }
        )
    );
  }

  Widget controls(BuildContext context){
    double _width = MediaQuery.of(context).size.width;
    double _height = MediaQuery.of(context).size.height;
    return Positioned(
      bottom: 0,
      left: 0,
      child: Container(
        width: _width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black]
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: SizedBox(width: 0,),
            ),

            InkWell(
              child: Icon(Icons.repeat, size: 20, color: (isLooped)?Colors.cyanAccent:Colors.white, ),
              onTap: (){
                setState(() {
                  isLooped = (isLooped)? false : true;
                });
              },
            ),
            SizedBox(width: 3,),
            InkWell(
              child: Icon((isPlaying)?Icons.pause:Icons.play_arrow, color: Colors.white, size: 60,),
              onTap: (){
                setState(() {
                  isPlaying = (isPlaying)?false:true;
                });
                startTimer();
              },
            ),
            SizedBox(width: 3,),
            InkWell(
              child: Icon(Icons.add, size: 27, color: Colors.white,),
              onTap: (){

                setState(() {
                  scrollPos += _width / 4;
                  frames[currentFrame] = points;
                  tempPoints = points;
                  points = [];
                  currentFrame += 1;
                });
                controller.animateTo(scrollPos, duration: Duration(milliseconds: 750), curve: Curves.ease);
              },
            ),
            Expanded(
              child: SizedBox(width: 0,),
            ),

            InkWell(
              child: Icon(Icons.clear, size: 25, color: Colors.white,),
              onTap: (){
                setState(() {
                  points = [];
                });
              },
            ),
            SizedBox(width: 15,),
          ],
        ),
      ),
    );
  }

  Widget timeline(BuildContext context){
    double _width = MediaQuery.of(context).size.width;
    double _height = MediaQuery.of(context).size.height;
    return Container(
      width: _width,
      height: _height / 5,
      color: Colors.black87,
      padding: MediaQuery.of(context).padding,
      child: SingleChildScrollView(
        controller: controller,
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[

            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: frames.entries.map((entry){
                return GestureDetector(
                  onTap: (){
                    setState(() {
                      currentFrame = entry.key;
                    });
                  },

                  child: Dismissible(
                    direction: DismissDirection.vertical,
                    key: UniqueKey(),
                    onDismissed: (DismissDirection dir){
                      if (frames.containsValue(entry.value))
                        setState(() {
                          frames.remove(entry);
                        });
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 5, vertical: 12),
                      width: _width/ 4 - 16,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.cyan, width: (entry.key == currentFrame)?5:0),
                        color: Colors.white,
                      ),
                      child: Stack(
                        children: <Widget>[
                          Transform.translate(
                            offset: Offset(-1 * 24.0, -36),
                            child: Transform.scale(
                              scale: 0.15,
                              child: CustomPaint(painter: new StartPaint(points: entry.value, currentColor: Colors.black), size: Size.infinite,),
                            ),
                          ),
                          Positioned(
                            bottom: 4,
                            right: 8,
                            child: InkWell(
                              onTap: (){
                                setState(() {
                                  points = List.from(points)..addAll(entry.value);
                                });
                              },
                              child: Icon(Icons.control_point_duplicate, color: Colors.red, size: 25,),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            GestureDetector(
              onTap: (){
                setState(() {
                  currentFrame = frames.length;
                });
              },
              child: Stack(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 5, vertical: 12),
                    width: _width/ 4 - 16,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.cyan, width: (frames.length == currentFrame)?5:0),
                      color: Colors.white,
                    ),
                    child: Transform.translate(
                      offset: Offset(-1 * 24.0, -36),
                      child: Transform.scale(
                        scale: 0.15,
                        child: CustomPaint(painter: new StartPaint(points: points, currentColor: Colors.black), size: Size.infinite,),
                      ),
                    ),
                  ),
                  if (points.length != 0)
                    Positioned(
                      bottom: 20,
                      right: 20,
                      child: InkWell(
                        onTap: (){
                          setState(() {
                            scrollPos += _width / 4;
                            frames[currentFrame] = points;

                            currentFrame += 1;
                            points = frames[currentFrame - 1];
                          });
                          controller.animateTo(scrollPos, duration: Duration(milliseconds: 750), curve: Curves.ease);

                        },
                        child: Icon(Icons.control_point_duplicate, color: Colors.red, size: 25,),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    double _height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      //floatingActionButton: controls(context),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[

          timeline(context),
          Stack(
            children: <Widget>[
              Container(
                //margin: EdgeInsets.all(5),
                color: Colors.white24,
                height: 4 * _height / 5 ,
                child: (frames.length <= currentFrame)?
                  GestureDetector(
                    onPanUpdate: (DragUpdateDetails details){
                        setState(() {
  //                    RenderBox object = context.findRenderObject();
  //                    Offset _localPosition = object.globalToLocal(details.globalPosition);
  //                    _points = List.from(_points)..add(_localPosition);
                          points = List.from(points)..add(
                              new GroupPoints(offset: details.localPosition, color: Colors.black)
                          );
                        });
                    },
                    onPanEnd: (DragEndDetails details){
                      points.add(
                          GroupPoints(offset: null, color: Colors.black)
                      );
                    },
                    child: Stack(
                      children: <Widget>[
                        CustomPaint(painter: new TempPaint(points: tempPoints, ), size: Size.infinite,),
                        CustomPaint(painter: new StartPaint(points: points, currentColor: Colors.black), size: Size.infinite,),

                      ],
                    ),
                  )
                :
                  Container(
                    height: 4 * _height / 5,
                    child: Stack(
                      children: <Widget>[
                        CustomPaint(painter: new StartPaint(points: frames[currentFrame], currentColor: Colors.black), size: Size.infinite,),

                      ],
                    ),

                  ),
              ),
              controls(context),
            ],
          ),

        ],
      ),
    );
  }
}

class TempPaint extends CustomPainter{
  List<GroupPoints> points;
  TempPaint({this.points});
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = new Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0
      ..color = Colors.grey;

    for (int i = 0; i<points.length - 1; i++){
      if(points[i].offset != null && points[i+1].offset != null){
        canvas.drawLine(
            points[i].offset,
            points[i+1].offset,
            paint
        );
      }
    }
  }

  @override
  bool shouldRepaint(TempPaint oldDelegate) => oldDelegate.points != points;


}

class StartPaint extends CustomPainter{
  //List<Offset> points;
  List<GroupPoints> points;
  Color currentColor;
  StartPaint({this.points, this.currentColor});

  @override
  void paint(Canvas canvas, Size size){
    Paint paint = new Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;

    for (int i = 0; i<points.length - 1; i++){
      paint.color = points[i].color;
      if(points[i].offset != null && points[i+1].offset != null){
        canvas.drawLine(
            points[i].offset,
            points[i+1].offset,
            paint
        );
      }
//      else if(points[i] != null && points[i + 1] == null){
//        canvas.drawPoints(PointMode.points, [points[i+1]], paint);
//      }
    }
  }

  @override
  bool shouldRepaint(StartPaint oldDelegate) => oldDelegate.points != points;

}
