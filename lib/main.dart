import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ImageLabelingApp(),
    );
  }
}

class ImageLabelingApp extends StatefulWidget {
  @override
  _ImageLabelingAppState createState() => _ImageLabelingAppState();
}

class _ImageLabelingAppState extends State<ImageLabelingApp> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  List<String> _labels = [];

  // Function to pick an image from the gallery or camera
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _labels = [];
      });
      _processImage(File(pickedFile.path));
    }
  }

  // Function to process the image with ML Kit
  Future<void> _processImage(File image) async {
  final inputImage = InputImage.fromFile(image);
  final imageLabeler = ImageLabeler(options: ImageLabelerOptions());

  final List<ImageLabel> labels = await imageLabeler.processImage(inputImage);
  setState(() {
    _labels = labels
        .map((label) =>
            "${label.label} (Confidence: ${(label.confidence * 100).toStringAsFixed(2)}%)")
        .toList();
  });
  imageLabeler.close();
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Labeling App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Image Display Area
            if (_selectedImage != null)
              Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Image.file(
                  _selectedImage!,
                  fit: BoxFit.cover,
                ),
              ),
            if (_selectedImage == null)
              Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(child: Text("No Image Selected")),
              ),
            const SizedBox(height: 16),
            // Detected Labels Display
            if (_labels.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _labels.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: const Icon(Icons.label),
                      title: Text(_labels[index]),
                    );
                  },
                ),
              ),
            // Buttons for Camera and Gallery
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.camera),
                  label: const Text("Camera"),
                  onPressed: () => _pickImage(ImageSource.camera),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.photo),
                  label: const Text("Gallery"),
                  onPressed: () => _pickImage(ImageSource.gallery),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
