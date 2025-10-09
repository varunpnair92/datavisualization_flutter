import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:datavisual/entity_controller.dart';
import 'package:datavisual/details_controller.dart';

class ContinuousTimelinePage extends StatefulWidget {
  final int datasetId;
  const ContinuousTimelinePage({super.key, required this.datasetId});

  @override
  State<ContinuousTimelinePage> createState() => _ContinuousTimelinePageState();
}

class _ContinuousTimelinePageState extends State<ContinuousTimelinePage> {
  final entityController = Get.put(EntityController());
  final detailController = Get.put(DetailController());

  final ScrollController _scrollController = ScrollController();
  bool isLoaded = false;
  double scrollSpeed = 50; // pixels per second

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    await entityController.fetchEntities();
    await detailController.fetchDetails();
    setState(() => isLoaded = true);
    startAutoScroll();
  }

  void startAutoScroll() {
    const fps = 60;
    const frameDuration = Duration(milliseconds: 1000 ~/ fps);

    Timer.periodic(frameDuration, (timer) {
      if (!_scrollController.hasClients) return;
      final maxScroll = _scrollController.position.maxScrollExtent;
      final current = _scrollController.offset;
      final next = current + (scrollSpeed / fps);

      if (next >= maxScroll) {
        timer.cancel(); // stop at the end
      } else {
        _scrollController.jumpTo(next);
      }
    });
  }

  void showImage(String url) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: InteractiveViewer(
          child: Image.network(url, fit: BoxFit.cover),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final datasetEntities = entityController.entities
        .where((e) => e.dataset == widget.datasetId)
        .toList();

    return Scaffold(
      backgroundColor: Colors.white10,
      appBar: AppBar(title: const Text("Timeline Viewer")),
      body: !isLoaded
          ? const Center(child: CircularProgressIndicator())
          : datasetEntities.isEmpty
              ? const Center(
                  child: Text("No entities found",
                      style: TextStyle(color: Colors.white)))
              : ListView.builder(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  itemCount: datasetEntities.length,
                  itemBuilder: (context, index) {
                    final entity = datasetEntities[index];
                    final entityDetails = detailController.details
                        .where((d) => d.entity == entity.id)
                        .toList();

                    return GestureDetector(
                      onTap: entity.imageUrl != null
                          ? () => showImage(entity.imageUrl!)
                          : null,
                      child: Container(
                        width: MediaQuery.of(context).size.width/3,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        alignment: Alignment.topCenter,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                         // color: Colors.grey[900],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Image fills container
                            if (entity.imageUrl != null)
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12),
                                  ),
                                  child:Expanded(
                                    child: Image.network(
                                      entity.imageUrl!,
                                      fit: BoxFit.contain,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                  ),
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    entity.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  if (entity.volume != null)
                                    Text(
                                      "Volume: ${entity.volume}",
                                      style: const TextStyle(
                                          color: Colors.white70),
                                    ),
                                  ...entityDetails.map(
                                    (d) => Text(
                                      d.details,
                                      style: const TextStyle(
                                          color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
