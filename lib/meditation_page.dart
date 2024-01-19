import 'package:flutter/material.dart';

class MeditationPage extends StatefulWidget {
  const MeditationPage({super.key});

  @override
  State<MeditationPage> createState() => _MeditationPageState();
}

class _MeditationPageState extends State<MeditationPage> {
  final TextEditingController _controller = TextEditingController();
  String inputValue = '';
  int sliderValue = 5;

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
        body: Padding(
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
                  onPressed: () {},
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
        ));
  }
}
