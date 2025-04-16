import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class TaskForm extends StatefulWidget {
  final Function(String imageUrl, String description) onImageGenerated;
  final Function(bool isProcessing) onFormSubmitted;

  const TaskForm(
      {super.key,
      required this.onImageGenerated,
      required this.onFormSubmitted});

  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  bool isProcessing = false;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  late bool timeSelected;
  late bool dateSelected;
  String? selectedAspect;

  late TextEditingController descriptionController;

  @override
  void initState() {
    super.initState();
    descriptionController = TextEditingController();
    timeSelected = false;
    dateSelected = false;
    selectedAspect = 'LANDSCAPE';
  }

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _generateImage(
      String text, Function(String url) onSuccess) async {
    setState(() {
      isProcessing = true;
    });
    widget.onFormSubmitted(true);

    try {
      final response = await http.get(
        Uri.parse(
            'https://mydiumtify.globeapp.dev/imagebytes?q=${Uri.encodeComponent(text)}&rebackimg=false&aspect=${selectedAspect?.toUpperCase()}'),
      );
      if (response.statusCode == 200) {
        String base64String = response.body;

        var request = http.MultipartRequest(
          'POST',
          Uri.parse('https://api.cloudinary.com/v1_1/ddgzciyug/auto/upload'),
        );
        request.files.add(http.MultipartFile.fromBytes(
          'file',
          base64Decode(base64String),
          filename: 'image.jpg',
          contentType: MediaType('image', 'jpeg'),
        ));
        request.fields.addAll({
          'upload_preset': 'supplyuuu',
          'tags': 'generated_image',
        });

        final uploadResponse = await request.send();
        final responseBody = await uploadResponse.stream.bytesToString();
        final jsonResponse = json.decode(responseBody);
        final secureUrl = jsonResponse['secure_url'];

        widget.onImageGenerated(secureUrl, descriptionController.text);
      }
    } catch (e) {
      print('Error during image generation or upload: $e');
      widget.onImageGenerated('', descriptionController.text);
    } finally {
      setState(() {
        isProcessing = false;
      });
      widget.onFormSubmitted(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFFF1E8), // 背景颜色
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                maxLength: 250,
                controller: descriptionController,
                style: const TextStyle(
                  color: Color(0xFF72471C), // 输入文字颜色
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFFFF1E8), // 背景色
                  labelText: '输入提示',
                  labelStyle: const TextStyle(color: Color(0xFF72471C)), // 标签颜色
                  hintText: '说说你想要描述的画面',
                  hintStyle: const TextStyle(
                    color: Color(0xAA72471C), // HintText 更淡一点
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF72471C)),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Color(0xFF72471C), width: 2),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Wrap(
                spacing: 8.0,
                children: [
                  InputChip(
                    avatar: const Icon(Icons.image),
                    label: const Text('(9:16)'),
                    selectedColor: const Color(0xFFFFDBC1), // Chip 选中颜色
                    onPressed: () {
                      setState(() {
                        selectedAspect = 'PORTRAIT';
                      });
                    },
                    selected: selectedAspect == 'PORTRAIT',
                  ),
                  InputChip(
                    avatar: const Icon(Icons.crop_square),
                    label: const Text('(1:1)'),
                    selectedColor: const Color(0xFFFFDBC1),
                    onPressed: () {
                      setState(() {
                        selectedAspect = 'SQUARE';
                      });
                    },
                    selected: selectedAspect == 'SQUARE',
                  ),
                  InputChip(
                    avatar: const Icon(Icons.landscape),
                    label: const Text('(16:9)'),
                    selectedColor: const Color(0xFFFFDBC1),
                    onPressed: () {
                      setState(() {
                        selectedAspect = 'LANDSCAPE';
                      });
                    },
                    selected: selectedAspect == 'LANDSCAPE',
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: double.infinity,
                height: 55.0,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: const Color(0xFF72471C), // 按钮字体颜色
                    backgroundColor: Colors.white, // 按钮背景色（你可以按需更改）
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: isProcessing
                      ? null
                      : () {
                          if (descriptionController.text.isNotEmpty) {
                            _generateImage(
                                descriptionController.text, (url) {});
                          }
                        },
                  child: isProcessing
                      ? const CircularProgressIndicator(
                          color: Color(0xFFFFDBC1),
                        )
                      : const Text(
                          '生成图片',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
