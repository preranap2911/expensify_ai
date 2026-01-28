import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../models/receipt.dart';
import '../../services/ai_service.dart';
import '../../state/receipt_controller.dart';
import 'review_receipt_screen.dart';


class AddReceiptScreen extends ConsumerStatefulWidget {
  const AddReceiptScreen({super.key});

  @override
  ConsumerState<AddReceiptScreen> createState() => _AddReceiptScreenState();
}

class _AddReceiptScreenState extends ConsumerState<AddReceiptScreen> {
  final picker = ImagePicker();
  XFile? image;
  bool loading = false;

  final ai = AiService();

  Future<void> pick(ImageSource source) async {
    final img = await picker.pickImage(source: source, imageQuality: 80);
    if (img == null) return;
    setState(() => image = img);
  }

  Future<void> extractAndSave() async {
    if (image == null) return;
    setState(() => loading = true);

    final result = await ai.extractFromReceiptImage(image!.path);

    if (!mounted) return;
    setState(() => loading = false);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReviewReceiptScreen(
          imagePath: image!.path,
          extracted: result,
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text('Scan')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                height: 230,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.white.withOpacity(0.10)),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primary.withOpacity(0.18),
                      Theme.of(context).colorScheme.secondary.withOpacity(0.08),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    if (image != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: Image.file(File(image!.path),
                            width: double.infinity, fit: BoxFit.cover),
                      )
                    else
                      const Center(child: Text('Upload a receipt to start')),

                    // scan overlay
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: double.infinity,
                        height: 90,
                        margin: const EdgeInsets.symmetric(horizontal: 18),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.white.withOpacity(0.25)),
                          color: Colors.black.withOpacity(0.12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => pick(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Camera'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => pick(ImageSource.gallery),
                      icon: const Icon(Icons.photo),
                      label: const Text('Gallery'),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              SizedBox(
                height: 52,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (image == null || loading) ? null : extractAndSave,
                  child: loading
                      ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('AI extracting'),
                      const SizedBox(width: 10),
                      const Text('•').animate(onPlay: (c) => c.repeat()).fadeIn(duration: 450.ms).then().fadeOut(duration: 450.ms),
                      const SizedBox(width: 6),
                      const Text('•').animate(onPlay: (c) => c.repeat()).fadeIn(delay: 150.ms, duration: 450.ms).then().fadeOut(duration: 450.ms),
                      const SizedBox(width: 6),
                      const Text('•').animate(onPlay: (c) => c.repeat()).fadeIn(delay: 300.ms, duration: 450.ms).then().fadeOut(duration: 450.ms),
                    ],
                  )
                      : const Text('Extract & Save'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
