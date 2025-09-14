import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:datavisual/entity_controller.dart';
import 'package:datavisual/details_controller.dart';
import 'package:datavisual/models.dart';

class TimelineAnimationPage extends StatefulWidget {
  final int datasetId;
  const TimelineAnimationPage({super.key, required this.datasetId});

  @override
  State<TimelineAnimationPage> createState() => _TimelineAnimationPageState();
}

class _TimelineAnimationPageState extends State<TimelineAnimationPage> {
  final entityController = Get.put(EntityController());
  final detailController = Get.put(DetailController());

  final ScrollController scrollController = ScrollController();
  final List<Entity> animatedEntities = [];
  Timer? timer;
  int currentIndex = 0;
  bool isAnimating = false;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    await entityController.fetchEntities();
    await detailController.fetchDetails();
  }

  void startAnimation() {
    if (isAnimating) return;

    setState(() {
      animatedEntities.clear();
      currentIndex = 0;
      isAnimating = true;
    });

    final datasetEntities = entityController.entities
        .where((e) => e.dataset == widget.datasetId)
        .toList();

    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (currentIndex < datasetEntities.length) {
        setState(() {
          animatedEntities.add(datasetEntities[currentIndex]);
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (scrollController.hasClients) {
            scrollController.animateTo(
              scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });

        currentIndex++;
      } else {
        t.cancel();
        setState(() => isAnimating = false);
      }
    });
  }

  void showImagePreview(String imageUrl) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: InteractiveViewer(
          child: Image.network(imageUrl),
        ),
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Timeline Animation")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: startAnimation,
              child: const Text("Play Timeline"),
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: animatedEntities.length,
              itemBuilder: (context, index) {
                final entity = animatedEntities[index];
                final entityDetails = detailController.details
                    .where((d) => d.entity == entity.id)
                    .toList();

                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                  child: ListTile(
                    leading: entity.imageUrl != null
                        ? GestureDetector(
                            onTap: () => showImagePreview(entity.imageUrl!),
                            child: Image.network(
                              entity.imageUrl!,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.broken_image),
                            ),
                          )
                        : const Icon(Icons.image_not_supported, size: 60),
                    title: Text(entity.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (entity.volume != null) Text(entity.volume!),
                        ...entityDetails.map((d) => Text(d.details)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
