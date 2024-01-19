import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:http_parser/http_parser.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'package:flutter/rendering.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<String> uploadImage(File image) async {
  var request = http.MultipartRequest(
    'POST',
    Uri.parse('https://recovery-pal-api-n6wffmw6za-uc.a.run.app/describe-art/'),
  );
  request.headers.addAll({
    'accept': 'application/json',
  });

  Uint8List bytes = await image.readAsBytes();
  File tempFile = File("${(await getTemporaryDirectory()).path}/temp.jpg");
  await tempFile.writeAsBytes(bytes);

  request.files.add(await http.MultipartFile.fromPath(
    'file',
    tempFile.path,
    contentType: MediaType('image', 'jpg'),
  ));

  var response = await request.send();
  if (response.statusCode == 200) {
    debugPrint('Uploaded!');
  } else {
    debugPrint('Failed to upload.');
  }

  var resStr = await response.stream.bytesToString();
  var resJson = jsonDecode(resStr);

  return resJson['meaning'];
}

Future<Map<String, dynamic>> postFeelings(
    String question, String answer) async {
  String conversation = 'Question: $question\n Answer: $answer';
  final response = await http.post(
    Uri.parse(
        'https://recovery-pal-api-n6wffmw6za-uc.a.run.app/process-feelings?conversation=$conversation'),
  );

  return jsonDecode(response.body);
}

Future<Map<String, dynamic>> createPrompts(
    int mood, String conversation) async {
  final response = await http.post(
    Uri.parse(
        'https://recovery-pal-api-n6wffmw6za-uc.a.run.app/generate-prompts?mood=$mood&conversation=$conversation'),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      'mood': mood,
      'conversation': conversation,
    }),
  );

  if (response.statusCode == 200) {
    var responseBody = jsonDecode(response.body);
    return responseBody;
  } else {
    var responseBody = jsonDecode(response.body);
    return responseBody;
  }
}

Future<File> saveCanvas(globalKey) async {
  RenderRepaintBoundary boundary = globalKey.currentContext.findRenderObject();
  ui.Image image = await boundary.toImage();
  ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  if (byteData != null) {
    Uint8List pngBytes = byteData.buffer.asUint8List();

    final directory = (await getApplicationDocumentsDirectory()).path;
    debugPrint(directory);
    File imgFile = File('$directory/screenshots.png');
    await imgFile.writeAsBytes(pngBytes);

    return imgFile;
  } else {
    throw Exception('Failed to convert image to byte data');
  }
}

class JournalPage extends StatefulWidget {
  const JournalPage({super.key});

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class Drawing extends StatefulWidget {
  const Drawing({super.key});

  @override
  State<Drawing> createState() => _DrawingState();
}

class _DrawingState extends State<Drawing> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class IsScreenshottingState extends ChangeNotifier {
  bool isScreenshotting = false;

  void changeScreenshotting(bool value) {
    isScreenshotting = value;
    notifyListeners();
  }
}

class _JournalPageState extends State<JournalPage> {
  final IsScreenshottingState _isScreenshottingState = IsScreenshottingState();

  final TextEditingController _controller = TextEditingController();
  final GlobalKey _globalKey = GlobalKey();
  String inputValue = '';
  late SharedPreferences prefs;
  @override
  void initState() {
    super.initState();
    initializeSharedPreferences();
  }

  void initializeSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
  }

  Color _selectedColor = Colors.white;

  Map<String, dynamic> response = {};
  bool isLoading = false;

  String followUpQuestion = 'How do you feel right now?';
  bool finalQuestion = false;

  int moodScale = 0;

  bool isLoadingDraw = false;

  bool questionDone = false;
  bool drawingDone = false;

  String meaning = '';

  var conversation = [];

  String artPrompt = '';
  String journalPrompt = '';
  String affirmation = '';
  String meditation = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder:
          (BuildContext context, AsyncSnapshot<SharedPreferences> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            prefs = snapshot.data!;
            return Scaffold(
                body: Scaffold(
              appBar: AppBar(
                title: const Text('Journal',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                centerTitle: true,
              ),
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      if (!finalQuestion)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding:
                                const EdgeInsets.only(bottom: 10.0, top: 8),
                            child: Text(followUpQuestion,
                                style: TextStyle(
                                    fontSize: 24.0,
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface)),
                          ),
                        ),
                      if (!finalQuestion)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: TextField(
                            maxLines: 3,
                            controller: _controller,
                            onChanged: (value) {
                              inputValue = value;
                              debugPrint(inputValue);
                            },
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                  Icons.sentiment_satisfied_alt_outlined,
                                  color: Theme.of(context).colorScheme.primary),
                              suffixIcon: InkWell(
                                onTap: () {
                                  _controller.clear();
                                  inputValue = '';
                                },
                                child: Icon(Icons.clear,
                                    color:
                                        Theme.of(context).colorScheme.primary),
                              ),
                              labelText: 'Your Feeling',
                              hintText: 'I\'m feeling...',
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ),
                      if (!finalQuestion)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () async {
                                    setState(() {
                                      isLoading = true;
                                    });

                                    String currentQuestion = followUpQuestion;

                                    response = await postFeelings(
                                        followUpQuestion, _controller.text);

                                    if (response['follow_up_question'] !=
                                        null) {
                                      setState(() {
                                        followUpQuestion =
                                            response['follow_up_question'];
                                        _controller.clear();
                                      });
                                    } else {
                                      Map<String, dynamic> prompts =
                                          await createPrompts(moodScale,
                                              conversation.join(' + '));
                                      setState(() async {
                                        moodScale = response['mood_scale'];
                                        journalPrompt =
                                            prompts['journal'] is List
                                                ? prompts['journal'].join(' ')
                                                : prompts['journal'];
                                        artPrompt = prompts['art'] is List
                                            ? prompts['art'].join(' ')
                                            : prompts['art'];
                                        meditation = prompts['meditation']
                                                is List
                                            ? prompts['meditation'].join(' ')
                                            : prompts['meditation'];
                                        affirmation = prompts['affirmation']
                                                is List
                                            ? prompts['affirmation'].join(' ')
                                            : prompts['affirmation'];

                                        prefs.setInt('moodScale', moodScale);
                                        prefs.setString(
                                            'journalPrompt', journalPrompt);
                                        prefs.setString('artPrompt', artPrompt);
                                        prefs.setString(
                                            'meditation', meditation);
                                        prefs.setString(
                                            'affirmation', affirmation);
                                        prefs.setBool(
                                            'finalQuestion', finalQuestion);

                                        finalQuestion = true;
                                      });
                                    }

                                    conversation.add(
                                        'Question: $currentQuestion Answer: $inputValue');

                                    setState(() {
                                      isLoading = false;
                                    });
                                  },
                            child: isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(),
                                  )
                                : const Icon(Icons.arrow_forward),
                          ),
                        ),
                      if (finalQuestion)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                finalQuestion = false;
                                followUpQuestion = 'How do you feel right now?';
                              });
                            },
                            child: const Icon(Icons.arrow_back),
                          ),
                        ),
                      Divider(
                          height: 20,
                          thickness: 2,
                          color: Theme.of(context).colorScheme.primary),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10.0, top: 8),
                          child: Text('Draw your emotions',
                              style: TextStyle(
                                  fontSize: 24.0,
                                  fontWeight: FontWeight.w500,
                                  color:
                                      Theme.of(context).colorScheme.onSurface)),
                        ),
                      ),
                      if (!drawingDone && (prefs.get('artPrompt') != null))
                        Card(
                          elevation: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                const Icon(Icons.create),
                                const SizedBox(width: 8.0),
                                Expanded(
                                  // Wrap the Text widget with an Expanded widget
                                  child: Text(
                                    prefs.get('artPrompt') as String,
                                    style: const TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (drawingDone)
                        Card(
                          elevation: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                const Icon(
                                    Icons.sentiment_satisfied_alt_outlined),
                                const SizedBox(width: 8.0),
                                Expanded(
                                  // Wrap the Text widget with an Expanded widget
                                  child: Text(
                                    meaning,
                                    style: const TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (!drawingDone)
                        GestureDetector(
                          onVerticalDragUpdate: (_) {},
                          onVerticalDragStart: (_) {},
                          child: IgnorePointer(
                            ignoring: false,
                            child: RepaintBoundary(
                              key: _globalKey,
                              child: SizedBox(
                                height: 300,
                                child: DrawingBoard(
                                  selectedColor: _selectedColor,
                                  dIsScreenshottingState:
                                      _isScreenshottingState,
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (!drawingDone)
                        Divider(
                            height: 20,
                            thickness: 2,
                            color: Theme.of(context).colorScheme.onSurface),
                      if (!drawingDone)
                        ColorPicker(
                          onColorSelected: (color) {
                            setState(() {
                              _selectedColor = color;
                            });
                          },
                        ),
                      if (!drawingDone)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: ElevatedButton(
                            onPressed: () {
                              _isScreenshottingState.changeScreenshotting(true);
                              late File image;
                              Future.delayed(const Duration(seconds: 1),
                                  () async {
                                image = await saveCanvas(_globalKey);
                                _isScreenshottingState
                                    .changeScreenshotting(false);
                                setState(() {
                                  isLoadingDraw = true;
                                });

                                uploadImage(image).then((value) {
                                  setState(() {
                                    isLoadingDraw = false;
                                    meaning = value;
                                    drawingDone = true;
                                    debugPrint("Success");
                                  });
                                }).catchError((error) {
                                  debugPrint('Error occurred: $error');
                                  setState(() {
                                    isLoadingDraw = false;
                                  });
                                });
                              });
                            },
                            child: isLoadingDraw
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(),
                                  )
                                : const Icon(Icons.arrow_forward),
                          ),
                        ),
                      if (drawingDone)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                drawingDone = false;
                              });
                            },
                            child: const Icon(Icons.arrow_back),
                          ),
                        ),
                      Divider(
                          height: 20,
                          thickness: 2,
                          color: Theme.of(context).colorScheme.primary),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10.0, top: 8),
                          child: Text('Journal your day',
                              style: TextStyle(
                                  fontSize: 24.0,
                                  fontWeight: FontWeight.w500,
                                  color:
                                      Theme.of(context).colorScheme.onSurface)),
                        ),
                      ),
                      if (prefs.get('journalPrompt') != null)
                        Card(
                          elevation: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                const Icon(Icons.create),
                                const SizedBox(width: 8.0),
                                Expanded(
                                  // Wrap the Text widget with an Expanded widget
                                  child: Text(
                                    prefs.get('journalPrompt') as String,
                                    style: const TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
                        child: TextField(
                          maxLines: 5,
                          controller: _controller,
                          onChanged: (value) {
                            inputValue = value;
                            debugPrint(inputValue);
                          },
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.book_outlined,
                                color: Theme.of(context).colorScheme.primary),
                            suffixIcon: InkWell(
                              onTap: () {
                                _controller.clear();
                                inputValue = '';
                              },
                              child: Icon(Icons.clear,
                                  color: Theme.of(context).colorScheme.primary),
                            ),
                            labelText: 'Journal',
                            hintText: 'My day was...',
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: ElevatedButton(
                          onPressed: () {},
                          child: const Icon(Icons.arrow_forward),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      )
                    ],
                  ),
                ),
              ),
            ));
          }
        } else {
          return const CircularProgressIndicator(); // Show a loading spinner while waiting.
        }
      },
    );
  }
}

// ignore: must_be_immutable
class ColorPicker extends StatefulWidget {
  final ValueChanged<Color> onColorSelected;

  const ColorPicker({Key? key, required this.onColorSelected})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ColorPickerState createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  late List<Color> colors;
  Color selectedColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    colors = [
      Colors.white,
      Colors.pink,
      Colors.red,
      Colors.yellow,
      Colors.orange,
      Colors.purple,
      Colors.green,
    ];

    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          colors.length,
          (index) => _buildColorChose(colors[index], context),
        ),
      ),
    );
  }

  Widget _buildColorChose(Color color, BuildContext context) {
    bool isSelected = selectedColor == color;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedColor = color;
        });
        widget.onColorSelected(color);
      },
      child: Container(
        height: isSelected ? 47 : 40,
        width: isSelected ? 47 : 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected
              ? Border.all(
                  color: Theme.of(context).colorScheme.primary, width: 3)
              : null,
        ),
      ),
    );
  }
}

class DrawingBoard extends StatefulWidget {
  final Color selectedColor;
  final IsScreenshottingState dIsScreenshottingState;

  const DrawingBoard(
      {Key? key,
      required this.selectedColor,
      required this.dIsScreenshottingState})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _DrawingBoardState createState() => _DrawingBoardState();
}

class DrawingPoint {
  Offset offset;
  Paint paint;
  bool endOfLine;

  DrawingPoint(this.offset, this.paint, {this.endOfLine = false});
}

class _DrawingBoardState extends State<DrawingBoard> {
  Color selectedColor = Colors.white;
  double strokeWidth = 5;
  List<DrawingPoint> drawingPoints = [];
  bool isScreenshotting = false;
  late IsScreenshottingState isScreenshottingStateD;

  @override
  void initState() {
    super.initState();
    isScreenshottingStateD = widget.dIsScreenshottingState;
  }

  void undoDrawing() {
    if (drawingPoints.isNotEmpty) {
      int lastPointIndex = drawingPoints.length - 1;
      while (lastPointIndex >= 0) {
        if (drawingPoints[lastPointIndex].endOfLine) {
          lastPointIndex--;
          continue;
        } else {
          drawingPoints.removeAt(lastPointIndex);
          lastPointIndex--;
        }
        if (lastPointIndex >= 0 && drawingPoints[lastPointIndex].endOfLine) {
          break;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Listener(
            onPointerDown: (details) {
              setState(() {
                drawingPoints.add(
                  DrawingPoint(
                    details.localPosition,
                    Paint()
                      ..color = widget.selectedColor
                      ..isAntiAlias = true
                      ..strokeWidth = strokeWidth
                      ..strokeCap = StrokeCap.round,
                  ),
                );
              });
            },
            onPointerMove: (details) {
              setState(() {
                drawingPoints.add(
                  DrawingPoint(
                    details.localPosition,
                    Paint()
                      ..color = widget.selectedColor
                      ..isAntiAlias = true
                      ..strokeWidth = strokeWidth
                      ..strokeCap = StrokeCap.round,
                  ),
                );
              });
            },
            onPointerUp: (details) {
              setState(() {
                drawingPoints.add(
                  DrawingPoint(
                    drawingPoints
                        .last.offset, // use the last point of the stroke
                    Paint(),
                    endOfLine: true,
                  ),
                );
              });
            },
            child: CustomPaint(
              painter: _DrawingPainter(drawingPoints),
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
              ),
            ),
          ),
          ListenableBuilder(
            listenable: isScreenshottingStateD,
            builder: (BuildContext context, Widget? child) {
              if (!isScreenshottingStateD.isScreenshotting) {
                return Positioned(
                  top: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 0.0,
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 48.0),
                          child: Slider(
                            min: 0,
                            max: 20,
                            value: strokeWidth,
                            onChanged: (val) =>
                                setState(() => strokeWidth = val),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: undoDrawing,
                          child: const Icon(Icons.undo_rounded),
                        ),
                        ElevatedButton(
                          onPressed: () => setState(() => drawingPoints = []),
                          child: const Icon(Icons.clear),
                        )
                      ],
                    ),
                  ),
                );
              } else {
                return const SizedBox();
              }
            },
          ),
        ],
      ),
    );
  }
}

class _DrawingPainter extends CustomPainter {
  final List<DrawingPoint> drawingPoints;

  _DrawingPainter(this.drawingPoints);

  List<Offset> offsetsList = [];

  @override
  void paint(Canvas canvas, Size size) {
    if (drawingPoints.isNotEmpty) {
      // Check if the list is not empty
      for (int i = 0; i < drawingPoints.length - 1; i++) {
        if (!drawingPoints[i].endOfLine) {
          canvas.drawLine(drawingPoints[i].offset, drawingPoints[i + 1].offset,
              drawingPoints[i].paint);
        }
      }
      if (drawingPoints.last.endOfLine) {
        offsetsList.clear();
        offsetsList.add(drawingPoints.last.offset);
        canvas.drawPoints(
            ui.PointMode.points, offsetsList, drawingPoints.last.paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
