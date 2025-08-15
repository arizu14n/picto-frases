
import 'package:app_flutter/models/pictogram.dart';
import 'package:app_flutter/services/phrase_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'package:speech_to_text/speech_to_text.dart';

class PhraseBuilderScreen extends StatefulWidget {
  const PhraseBuilderScreen({super.key});

  @override
  State<PhraseBuilderScreen> createState() => _PhraseBuilderScreenState();
}

class _PhraseBuilderScreenState extends State<PhraseBuilderScreen> {
  final FlutterTts flutterTts = FlutterTts();
  final TextEditingController _textController = TextEditingController();
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;

  @override
  void initState() {
    super.initState();
    _initTts();
    _initSpeech();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _initTts() async {
    await flutterTts.setLanguage("es-ES"); // Set language to Spanish
    await flutterTts.setSpeechRate(0.5); // Adjust speech rate
    await flutterTts.setVolume(1.0); // Set volume
    await flutterTts.setPitch(1.0); // Set pitch
  }

  Future<void> _speak(String text) async {
    if (text.isNotEmpty) {
      await flutterTts.speak(text);
    }
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    await _speechToText.listen(onResult: (result) {
      setState(() {
        _textController.text = result.recognizedWords;
      });
    });
    setState(() {});
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Construir Frase'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              Provider.of<PhraseProvider>(context, listen: false).clearPhrase();
            },
          ),
          IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: () {
              final phraseProvider = Provider.of<PhraseProvider>(context, listen: false);
              final phraseText = phraseProvider.currentPhrase.map((p) => p.name).join(' ');
              _speak(phraseText);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<PhraseProvider>(
              builder: (context, phraseProvider, child) {
                if (phraseProvider.currentPhrase.isEmpty) {
                  return const Center(
                    child: Text('Toca pictogramas para construir tu frase.'),
                  );
                }
                return ReorderableGridView.builder(
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                  ),
                  itemCount: phraseProvider.currentPhrase.length,
                  onReorder: (oldIndex, newIndex) {
                    phraseProvider.onReorder(oldIndex, newIndex);
                  },
                  itemBuilder: (context, index) {
                    final pictogram = phraseProvider.currentPhrase[index];
                    return Card(
                      key: ValueKey(pictogram.uuid), // Unique key for reordering
                      child: InkWell(
                        onTap: () {
                          // Optionally remove pictogram on tap
                          phraseProvider.removePictogram(pictogram);
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (pictogram.imageUrl.isNotEmpty)
                              Expanded(
                                child: Image.network(
                                  pictogram.imageUrl,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(Icons.image_not_supported, size: 48);
                                  },
                                ),
                              )
                            else
                              const SizedBox.shrink(), // No image for text-only
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                pictogram.name,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: pictogram.imageUrl.isEmpty ? 20.0 : null), // Larger font for text-only
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: 'Escribe una palabra o conector...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (text) {
                      Provider.of<PhraseProvider>(context, listen: false).addText(text);
                      _textController.clear();
                    },
                  ),
                ),
                const SizedBox(width: 8.0),
                IconButton(
                  icon: Icon(_speechToText.isListening ? Icons.mic_off : Icons.mic),
                  onPressed: _speechEnabled
                      ? () {
                          _speechToText.isListening ? _stopListening() : _startListening();
                        }
                      : null,
                ),
                ElevatedButton(
                  onPressed: () {
                    Provider.of<PhraseProvider>(context, listen: false).addText(_textController.text);
                    _textController.clear();
                  },
                  child: const Text('Añadir'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
