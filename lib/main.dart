import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
//import 'package:torch_compat/torch_compat.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:tflite/tflite.dart';
import 'package:fluttertoast/fluttertoast.dart';

int total = 0;
final FlutterTts flutterTts = FlutterTts();


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final camerass = await availableCameras();
  final firstCamera = camerass.first;

  runApp(
    MaterialApp(
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: TakePictureScreen(
        camera: firstCamera,
        //TakePictureScreen
      ),
    ),
  );
}

class TakePictureScreen extends StatefulWidget {
  final CameraDescription camera;

  const TakePictureScreen({
    Key key,
    @required this.camera,
  }) : super(key: key);


  @override
  _TakePictureScreenState createState() => _TakePictureScreenState();
}

class _TakePictureScreenState extends State<TakePictureScreen> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.high,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
    speak("Kamera Kullanıma hazır");
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    //TorchCompat.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Center(child: Text('Noteify'))),
      // Wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner
      // until the controller has finished initializing.
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return CameraPreview(_controller);
          } else {
            // Otherwise, display a loading indicator.
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Center(
            child: Container(
              height: 180.0,
              width: 180.0,
              child: FittedBox(
                child: FloatingActionButton(
                  child: Icon(Icons.camera_alt),
                  // Provide an onPressed callback.
                  onPressed: () async {
                    // Take the Picture in a try / catch block. If anything goes wrong,
                    // catch the error.
                    try {
                      //TorchCompat.turnOn();
                      // Ensure that the camera is initialized.
                      await _initializeControllerFuture;

                      // Construct the path where the image should be saved using the
                      // pattern package.
                      final path = join(
                        // Store the picture in the temp directory.
                        // Find the temp directory using the `path_provider` plugin.
                        (await getTemporaryDirectory()).path,
                        '${DateTime.now()}.png',

                      );
                      print(path);

                      // Attempt to take a picture and log where it's been saved.
                      await _controller.takePicture(path);
                      //TorchCompat.turnOff();

                      // If the picture was taken, display it on a new screen.
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DisplayPictureScreen(path),
                        ),
                      );
                    } catch (e) {
                      // If an error occurs, log the error to the console.
                      print(e);
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  speak(String textToSpeech) async {
    await flutterTts.setLanguage("tr-TR");
    await flutterTts.setPitch(0.8);
    await flutterTts.awaitSpeakCompletion(true);
    await flutterTts.speak(textToSpeech);

  }
}

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatefulWidget {
  final String imagePath;


  DisplayPictureScreen(this.imagePath);

  @override
  _DisplayPictureScreenState createState() => _DisplayPictureScreenState();
}

class _DisplayPictureScreenState extends State<DisplayPictureScreen> {
  List op;
  Image img;

  @override
  void initState() {
    super.initState();
    loadModel().then((value) {
      setState(() {});
    });

    img = Image.file(File(widget.imagePath));
    classifyImage(widget.imagePath);
  }

  @override
  Widget build(BuildContext context) {
   // Image img = Image.file(File(widget.imagePath));
   // classifyImage(widget.imagePath);

    return Scaffold(
      appBar: AppBar(title: Text('Display the Picture')),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(child: Center(child: img)),
            SizedBox(
              height: 20,
            )
          ],
        ),
      ),
    );
  }

  loadModel() async {
    await Tflite.loadModel(
        model: "assets/my_model.tflite", labels: "assets/labels.txt");
  }

  speak(String textToSpeech) async {
    await flutterTts.setLanguage("tr-TR");
    await flutterTts.setPitch(0.8);
    await flutterTts.awaitSpeakCompletion(true);
    await flutterTts.speak(textToSpeech);

  }

  Future<void> runTextToSpeech(String outputMoney, int totalMoney) async {
    //FlutterTts flutterTts;
    //flutterTts = new FlutterTts();

    if (outputMoney == "5") {
      String tot = totalMoney.toString();
      print(tot);
      String speakString = "5 TL, Toplam Paranız, $tot";
      speak(speakString);
    }
    else if (outputMoney == "10") {
      String tot = totalMoney.toString();
      print(tot);
      String speakString = "10 TL, Toplam Paranız, $tot";
      speak(speakString);
    }
    else if (outputMoney == "20") {
      String tot = totalMoney.toString();
      print(tot);
      String speakString = "20 TL, Toplam Paranız, $tot";
      speak(speakString);
    }

    else if (outputMoney == "50") {
      String tot = totalMoney.toString();
      print(tot);
      String speakString = "50 TL, Toplam Paranız, $tot";
      speak(speakString);
    }

    else if (outputMoney == "100") {
      String tot = totalMoney.toString();
      print(tot);
      String speakString = "100 TL, Toplam Paranız, $tot";
      speak(speakString);
    }
    else if (outputMoney == "200") {
      String tot = totalMoney.toString();
      print(tot);
      String speakString = "200 TL, Toplam Paranız, $tot";
      speak(speakString);
    }
  }

  classifyImage(String image) async {
    var output = await Tflite.runModelOnImage(
      path: image,
      numResults: 6,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );

    if (output == null) {
      runTextToSpeech("Para tanımlanırken bir sorun yaşandı", total);
      print('para tanımlamada sorun var output yok aw');
    } else {
      op = output;
    }
    if (op != null) {
      print(op[0]);
      if (op[0]["label"] == "5") {
        total += 5;
        runTextToSpeech("5 TL", total);
        print('hebede 1223');
        Fluttertoast.showToast(
            msg: "5",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        );

      }
      else if (op[0]["label"] == "10") {
        total += 10;
        runTextToSpeech("10 TL", total);
        print('hebede 10');
        Fluttertoast.showToast(
            msg: "10",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        );

      }
      else if (op[0]["label"] == "20") {
        total += 20;
        runTextToSpeech("20 TL", total);
        print('hebede 20');
        Fluttertoast.showToast(
            msg: "20",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        );

      }
      else if (op[0]["label"] == "50") {
        total += 50;
        runTextToSpeech("50 TL", total);
        print('hebede50');
        Fluttertoast.showToast(
            msg: "50",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        );

      }
      else if (op[0]["label"] == "100") {
        total += 100;
        runTextToSpeech("100 TL", total);
        print('hebede 100');
        Fluttertoast.showToast(
            msg: "100",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        );

      }

      else if (op[0]["label"] == "200") {
        total += 200;
        runTextToSpeech("200 TL", total);
        print('hebede 200');
        Fluttertoast.showToast(
            msg: "200",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        );

      }
    }
      else{
        runTextToSpeech("Para Tanımlanamadı", total);
        print('hebede para yok aw');
      }
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }
}
