import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class MeditationPage extends StatefulWidget {
  const MeditationPage({super.key});

  @override
  State<MeditationPage> createState() => _MeditationPageState();
}

class _MeditationPageState extends State<MeditationPage> {
  final TextEditingController _controller = TextEditingController();
  String inputValue = '';
  int sliderValue = 5;

  late SharedPreferences prefs;

  Future<void> initPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  @override
  void initState() {
    super.initState();
    initPrefs();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Meditation',
              style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        body: FutureBuilder(
          future: initPrefs(), // Replace this with your Future function
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator(); // Show a loading spinner while waiting
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return Padding(
                padding: const EdgeInsets.fromLTRB(22.0, 10, 22, 30),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Meditation length: $sliderValue minutes',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    Slider(
                      value: sliderValue.toDouble(),
                      min: 5.0,
                      max: 25.0,
                      divisions: 4,
                      label: '$sliderValue',
                      onChanged: (double newValue) {
                        setState(() {
                          sliderValue = newValue.round();
                        });
                      },
                    ),
                    const Align(
                      alignment: Alignment.center,
                      child: Text(
                        'What meditation?',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 25,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: ElevatedButton(
                        child: const Padding(
                          padding: EdgeInsets.fromLTRB(12, 8, 12, 8),
                          child: Text('Mindfulness and Relaxation',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w500)),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MeditationTruePage(
                                      name: prefs.getString('name') ?? 'Human',
                                      age: prefs.getString('age') ?? '0',
                                      gender: prefs.getString('gender') ??
                                          'Unknown',
                                      addiction: prefs.getString('addiction') ??
                                          'General',
                                      emotion: prefs.getString('emotion') ??
                                          'Neutral',
                                      duration: sliderValue.toString(),
                                      theme: 'Mindfulness and Relaxation',
                                      journal:
                                          prefs.getString('journal') ?? 'None',
                                    )),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: ElevatedButton(
                        child: const Padding(
                          padding: EdgeInsets.fromLTRB(12, 8, 12, 8),
                          child: Text('Self-Compassion and Healing',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w500)),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MeditationTruePage(
                                      name: prefs.getString('name') ?? 'Human',
                                      age: prefs.getString('age') ?? '0',
                                      gender: prefs.getString('gender') ??
                                          'Unknown',
                                      addiction: prefs.getString('addiction') ??
                                          'General',
                                      emotion: prefs.getString('emotion') ??
                                          'Neutral',
                                      duration: sliderValue.toString(),
                                      theme: 'Self-Compassiona and Healing',
                                      journal:
                                          prefs.getString('journal') ?? 'None',
                                    )),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: ElevatedButton(
                        child: const Padding(
                          padding: EdgeInsets.fromLTRB(12, 8, 12, 8),
                          child: Text('Building Resilience',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w500)),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MeditationTruePage(
                                      name: prefs.getString('name') ?? 'Human',
                                      age: prefs.getString('age') ?? '0',
                                      gender: prefs.getString('gender') ??
                                          'Unknown',
                                      addiction: prefs.getString('addiction') ??
                                          'General',
                                      emotion: prefs.getString('emotion') ??
                                          'Neutral',
                                      duration: sliderValue.toString(),
                                      theme: 'Building Resilience',
                                      journal:
                                          prefs.getString('journal') ?? 'None',
                                    )),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: ElevatedButton(
                        child: const Padding(
                          padding: EdgeInsets.fromLTRB(12, 8, 12, 8),
                          child: Text('Gratitude and Positivity',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w500)),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MeditationTruePage(
                                      name: prefs.getString('name') ?? 'Human',
                                      age: prefs.getString('age') ?? '0',
                                      gender: prefs.getString('gender') ??
                                          'Unknown',
                                      addiction: prefs.getString('addiction') ??
                                          'General',
                                      emotion: prefs.getString('emotion') ??
                                          'Neutral',
                                      duration: sliderValue.toString(),
                                      theme: 'Gratitude and Posiviity',
                                      journal:
                                          prefs.getString('journal') ?? 'None',
                                    )),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: ElevatedButton(
                        child: const Padding(
                          padding: EdgeInsets.fromLTRB(12, 8, 12, 8),
                          child: Text('Empowerment and Personal Growth',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w500)),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MeditationTruePage(
                                      name: prefs.getString('name') ?? 'Human',
                                      age: prefs.getString('age') ?? '0',
                                      gender: prefs.getString('gender') ??
                                          'Unknown',
                                      addiction: prefs.getString('addiction') ??
                                          'General',
                                      emotion: prefs.getString('emotion') ??
                                          'Neutral',
                                      duration: sliderValue.toString(),
                                      theme: 'Empowerment and Personal Growth',
                                      journal:
                                          prefs.getString('journal') ?? 'None',
                                    )),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ));
  }
}

class MeditationTruePage extends StatefulWidget {
  final String name;
  final String age;
  final String gender;
  final String addiction;
  final String emotion;
  final String duration;
  final String theme;
  final String journal;

  const MeditationTruePage(
      {super.key,
      required this.name,
      required this.age,
      required this.gender,
      required this.addiction,
      required this.emotion,
      required this.duration,
      required this.theme,
      required this.journal});

  @override
  State<MeditationTruePage> createState() => _MeditationTruePageState();
}

Future<String> textToSpeech(String text) async {
  final response = await http.post(
    Uri.parse(
        'https://recovery-pal-api-n6wffmw6za-uc.a.run.app/text-to-speech/?text=$text'),
    headers: <String, String>{
      'accept': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    // If the server returns a 200 OK response, then save the MP3 file.
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/output.mp3');
    await file.writeAsBytes(response.bodyBytes);
    return file.uri.toString(); // return the URI of the file
  } else {
    // If the server did not return a 200 OK response, then throw an exception.
    throw Exception('Failed to convert text to speech');
  }
}

class _MeditationTruePageState extends State<MeditationTruePage> {
  Future<String>? meditationFuture;

  Future<String> chooseMeditation(
      String name,
      String age,
      String gender,
      String struggle,
      String emotion,
      String duration,
      String theme,
      String journal) async {
    debugPrint("Hi I'm chooseMeditation() and I was called");

    const String baseUrl =
        'https://recovery-pal-api-n6wffmw6za-uc.a.run.app/choose-meditation/';
    final String parameters =
        '?name=$name&age=$age&gender=$gender&struggle=$struggle&mood=$emotion&duration=$duration&theme=$theme&journal=$journal';
    final String url = baseUrl + parameters;

    final response = await http.post(Uri.parse(url));

    Map<String, dynamic> jsonResponse = jsonDecode(response.body);
    return jsonResponse['meditation_script'];
  }

  @override
  void initState() {
    super.initState();
    meditationFuture = meditation();
  }

  Future<Image> processImage(String meditation) async {
    final response = await http.post(
      Uri.parse(
          'https://recovery-pal-api-n6wffmw6za-uc.a.run.app/create-image?script=$meditation'),
      headers: <String, String>{
        'accept': 'application/json',
      },
    );

    var image = Image.memory(response.bodyBytes);
    debugPrint("Image processed");
    try {
      return image;
    } catch (e) {
      debugPrint(e.toString());
      return image;
    }
  }

  Future<String> meditation() async {
    var meditation = await chooseMeditation(
        widget.name,
        widget.age,
        widget.gender,
        widget.addiction,
        widget.emotion,
        widget.duration,
        widget.theme,
        widget.journal);
    debugPrint("Meditation done!");
    return meditation;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text('Meditation',
                style: TextStyle(fontWeight: FontWeight.bold)),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            )),
        body: FutureBuilder<String>(
          future: meditationFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Column(
                    children: [
                      FutureBuilder(
                        future: processImage(snapshot.data!),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return Center(
                              child: Text('Error: ${snapshot.error}'),
                            );
                          } else {
                            return SizedBox(
                              height: 300,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: snapshot.data as Widget,
                              ),
                            );
                          }
                        },
                      ),
                      Card(
                        elevation: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Stack(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        '\n ${snapshot.data}',
                                        style: const TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: TextToSpeechWidget(data: snapshot.data!),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          },
        ));
  }
}

class TextToSpeechWidget extends StatefulWidget {
  final String data;

  const TextToSpeechWidget({super.key, required this.data});

  @override
  State<TextToSpeechWidget> createState() => _TextToSpeechWidgetState();
}

class _TextToSpeechWidgetState extends State<TextToSpeechWidget> {
  Future<String>? _future;
  bool isPlaying = false;
  late AudioPlayer player;
  late PlayerState playerState = PlayerState.stopped;

  @override
  void initState() {
    super.initState();

    player = AudioPlayer();
    debugPrint('AudioPlayer initialized');

    player.onPlayerStateChanged.listen((PlayerState s) {
      setState(() {
        playerState = s;
      });
      {
        switch (s) {
          case PlayerState.paused:
            debugPrint('Player stopped!');
            break;
          case PlayerState.playing:
            debugPrint('Player complete!');
            break;
          default:
            break;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _future == null
          ? IconButton(
              icon: const Icon(Icons.record_voice_over_outlined),
              onPressed: () {
                setState(() {
                  _future = textToSpeech(widget.data); // use data here
                });
              },
            )
          : // Add a new state variable
          FutureBuilder<String>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return const Icon(Icons.error);
                } else {
                  return IconButton(
                    icon: playerState == PlayerState.playing
                        ? const Icon(Icons.pause)
                        : const Icon(Icons.play_arrow),
                    onPressed: () {
                      if (playerState == PlayerState.playing) {
                        debugPrint("Pausing");
                        player.pause();
                      } else {
                        debugPrint("Playing");
                        player.play(DeviceFileSource(
                            '/data/user/0/com.example.recovery_pal/app_flutter/output.mp3'));
                      }
                    },
                  );
                }
              },
            ),
    );
  }
}
