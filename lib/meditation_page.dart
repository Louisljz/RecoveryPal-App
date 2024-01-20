import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

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
                        onPressed: () {},
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
                        onPressed: () {},
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
                        onPressed: () {},
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
                        onPressed: () {},
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

  const MeditationTruePage(
      {super.key,
      required this.name,
      required this.age,
      required this.gender,
      required this.addiction,
      required this.emotion,
      required this.duration,
      required this.theme});

  @override
  State<MeditationTruePage> createState() => _MeditationTruePageState();
}

class _MeditationTruePageState extends State<MeditationTruePage> {
  Future<String>? meditationFuture;

  Future<String> chooseMeditation(String name, String age, String gender,
      String struggle, String emotion, String duration, String theme) async {
    debugPrint("Hi I'm chooseMeditation() and I was called");

    const String baseUrl =
        'https://recovery-pal-api-n6wffmw6za-uc.a.run.app/choose-meditation/';
    final String parameters =
        '?name=$name&age=$age&gender=$gender&struggle=$struggle&emotion=$emotion&duration=$duration&theme=$theme';
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

  Future<String> meditation() async {
    var meditation = await chooseMeditation(
        widget.name,
        widget.age,
        widget.gender,
        widget.addiction,
        widget.emotion,
        widget.duration,
        widget.theme);
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
                  child: Card(
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                snapshot.data ?? 'No meditation found',
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }
          },
        ));
  }
}
