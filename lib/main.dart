import 'package:flutter/material.dart';
import 'package:recovery_pal/meditation_page.dart';
import 'graph.dart';
import 'journey_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(const RecoveryPal());
}

class RecoveryPal extends StatelessWidget {
  const RecoveryPal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "RecoveryPal",
      theme: ThemeData(
          brightness: Brightness.dark,
          useMaterial3: true,
          colorScheme: const ColorScheme.dark(
              primary: Color.fromARGB(255, 0, 107, 207))),
      home: const Page(
        alreadyLogin: false,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Page extends StatefulWidget {
  final bool alreadyLogin;

  const Page({super.key, required this.alreadyLogin});

  @override
  State<Page> createState() => _PageState();
}

class _PageState extends State<Page> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      Homepage(
        alreadyLogin: widget.alreadyLogin,
      ),
      const JournalPage(),
      const MeditationPage(),
    ];

    return Scaffold(
        body: pages[_currentIndex],
        bottomNavigationBar: NavigationBar(
          onDestinationSelected: (int index) {
            setState(() {
              _currentIndex = index;
            });
          },
          selectedIndex: _currentIndex,
          indicatorColor: Theme.of(context).colorScheme.primary,
          destinations: const <Widget>[
            NavigationDestination(
              selectedIcon: Icon(Icons.home),
              icon: Icon(Icons.home_outlined),
              label: 'Home',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.book),
              icon: Icon(Icons.book_outlined),
              label: 'Journal',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.self_improvement),
              icon: Icon(Icons.self_improvement_outlined),
              label: 'Meditation',
            ),
          ],
        ));
  }
}

List<FlSpot> getSpots(List<String> moods) {
  return moods.asMap().entries.map((entry) {
    return FlSpot(entry.key.toDouble(), int.parse(entry.value).toDouble());
  }).toList();
}

class Homepage extends StatefulWidget {
  final bool alreadyLogin;

  const Homepage({super.key, required this.alreadyLogin});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    initPrefs();
  }

  Future<void> addToList(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> myList = prefs.getStringList('mood_list') ?? [];
    myList.add(value);
    await prefs.setStringList('mood_list', myList);
  }

  Future<void> initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    final lastLogin = prefs.getInt('lastLogin') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    const twentyFourHours = 24 * 60 * 60 * 1000;

    if (prefs.getStringList('moods_list') == null) {
      prefs.setStringList('moods_list', ["5"]);
    }

    if (lastLogin - now > twentyFourHours || lastLogin == 0) {
      debugPrint("Last login was over 24 hours ago");
      prefs.setInt('lastLogin', now);
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
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
              {
                return Scaffold(
                  appBar: AppBar(
                    title: const Text("Home",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    centerTitle: true,
                    actions: [
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SettingsPage()),
                          );
                        },
                        icon: const Icon(Icons.settings),
                      ),
                    ],
                  ),
                  body: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text("Welcome, ${prefs.getString('name')}",
                                style: TextStyle(
                                    fontSize: 34.0,
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface)),
                          ),
                          Card(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                ListTile(
                                  leading: const Icon(
                                      Icons.sentiment_satisfied_alt_outlined),
                                  subtitle: const Text(
                                    'Your happiness over the past month.',
                                    style: TextStyle(fontSize: 15),
                                  ),
                                  title: SizedBox(
                                    height:
                                        140, // Adjust this value to give the chart a specific height
                                    child: LineChartSample2(
                                      spots: getSpots(
                                          prefs.getStringList('moods_list') ??
                                              ["5"]),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Divider(
                              thickness: 1.0,
                              color: Theme.of(context).colorScheme.primary),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text("Daily Affirmations",
                                  style: TextStyle(
                                      fontSize: 34.0,
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface)),
                            ),
                          ),
                          Card(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ListTile(
                                    leading:
                                        const Icon(Icons.thumb_up_alt_outlined),
                                    title: Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 4.0),
                                      child: Text(
                                          'Keep going ${prefs.getString('name')}!',
                                          style: const TextStyle(
                                              fontSize: 20.0,
                                              fontWeight: FontWeight.w500)),
                                    ),
                                    subtitle: Text(
                                      prefs.getString('affirmation') ??
                                          'Please fill in the emotion question!',
                                      style: const TextStyle(fontSize: 17),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
            }
          } else {
            return const CircularProgressIndicator();
          }
        });
  }
}

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    initializeSharedPreferences();
  }

  void initializeSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
  }

  final TextEditingController _controller = TextEditingController();
  String inputValue = '';
  bool isLoading = false;

  String followUpQuestion = 'How do you feel right now?';
  bool finalQuestion = false;

  String artPrompt = '';
  String journalPrompt = '';
  String affirmation = '';
  String meditation = '';

  var conversation = [];

  int moodScale = 0;

  Map<String, dynamic> response = {};

  Future<void> initPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().millisecondsSinceEpoch;
    await prefs.setInt('lastLogin', now);
  }

  Future<void> addToList(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> myList = prefs.getStringList('mood_list') ?? [];
    myList.add(value);
    await prefs.setStringList('mood_list', myList);
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
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
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
                                    color:
                                        Theme.of(context).colorScheme.primary),
                                suffixIcon: InkWell(
                                  onTap: () {
                                    _controller.clear();
                                    inputValue = '';
                                  },
                                  child: Icon(Icons.clear,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
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
                                        setState(() {
                                          moodScale = response['mood_scale'];
                                          addToList(moodScale.toString());
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

                                          debugPrint("Saving to prefs");

                                          prefs.setInt('moodScale', moodScale);
                                          prefs.setString(
                                              'journalPrompt', journalPrompt);
                                          prefs.setString(
                                              'artPrompt', artPrompt);
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

                                      setState(() {
                                        isLoading = false;
                                      });

                                      // ignore: use_build_context_synchronously
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => const Page(
                                                  alreadyLogin: true)));
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
                      ],
                    ),
                  ),
                ),
              );
            }
          } else {
            return const CircularProgressIndicator();
          }
        });
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late SharedPreferences prefs;

  final addictionController = TextEditingController();
  final ageController = TextEditingController();
  final genderController = TextEditingController();
  final nameController = TextEditingController();

  String name = 'Human';
  String age = '16';
  String gender = 'Male';
  String addiction = 'General';

  Future<void> initPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  @override
  void initState() {
    super.initState();
    initPrefs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Settings",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: FutureBuilder<SharedPreferences>(
          future: SharedPreferences.getInstance(),
          builder: (BuildContext context,
              AsyncSnapshot<SharedPreferences> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator(); // Show a loading spinner while waiting
            } else {
              final prefs = snapshot.data;
              return SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                  child: Column(
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          hintText: prefs?.getString('name') ?? 'Name',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0, bottom: 20),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: ElevatedButton(
                            onPressed: () {
                              prefs?.setString('name', nameController.text);
                            },
                            style: ElevatedButton.styleFrom(
                              alignment: Alignment.centerLeft,
                            ),
                            child: const Icon(Icons.arrow_forward),
                          ),
                        ),
                      ),
                      TextField(
                        controller: ageController,
                        decoration: InputDecoration(
                          labelText: 'Age',
                          hintText: prefs?.getString('age') ?? 'Age',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0, bottom: 20),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: ElevatedButton(
                            onPressed: () {
                              prefs?.setString('age', ageController.text);
                            },
                            style: ElevatedButton.styleFrom(
                              alignment: Alignment.centerLeft,
                            ),
                            child: const Icon(Icons.arrow_forward),
                          ),
                        ),
                      ),
                      TextField(
                        controller: genderController,
                        decoration: InputDecoration(
                          labelText: 'Gender',
                          hintText: prefs?.getString('Gender') ?? 'Gender',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0, bottom: 20),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: ElevatedButton(
                            onPressed: () {
                              prefs?.setString('gender', genderController.text);
                            },
                            style: ElevatedButton.styleFrom(
                              alignment: Alignment.centerLeft,
                            ),
                            child: const Icon(Icons.arrow_forward),
                          ),
                        ),
                      ),
                      TextField(
                        controller: addictionController,
                        decoration: InputDecoration(
                          labelText: 'What are you struggling with?',
                          hintText:
                              prefs?.getString('addiction') ?? 'Addiction',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0, bottom: 20),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: ElevatedButton(
                            onPressed: () {
                              prefs?.setString(
                                  'addiction', addictionController.text);
                            },
                            style: ElevatedButton.styleFrom(
                              alignment: Alignment.centerLeft,
                            ),
                            child: const Icon(Icons.arrow_forward),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0, bottom: 20),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: ElevatedButton(
                            onPressed: () {
                              if (prefs != null) {
                                setState(() {
                                  prefs.clear();
                                });
                              }
                            },
                            child: const Icon(Icons.cancel),
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
