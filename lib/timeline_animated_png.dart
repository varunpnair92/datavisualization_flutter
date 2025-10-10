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
  double scrollSpeed = 50;

  @override
  void initState() {
    super.initState();
    fetchData();
    _scrollController.addListener(() {
      setState(() {}); // update zoom on scroll
    });
  }

  Future<void> fetchData() async {
    await entityController.fetchEntities();
    await detailController.fetchDetails();
    setState(() => isLoaded = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) startAutoScroll();
    });
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
        timer.cancel();
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
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final screenCenter = constraints.maxWidth / 2;
                    final cardWidth = constraints.maxWidth / 3 + 12;

                    // Add 2 dummy items: one at start and one at end
                    final totalItems = datasetEntities.length + 2;

                    return ListView.builder(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      itemCount: totalItems,
                      itemBuilder: (context, index) {
                        // Empty spacer cards (first and last)
                        if (index == 0 || index == totalItems - 1) {
                          return SizedBox(width: cardWidth);
                        }

                        // Adjust index to skip spacer
                        final entity = datasetEntities[index - 1];
                        final entityDetails = detailController.details
                            .where((d) => d.entity == entity.id)
                            .toList();

                        final cardCenter =
                            index * cardWidth - _scrollController.offset + cardWidth / 2;
                        final distanceToCenter = (screenCenter - cardCenter).abs();

                        double scale = 1.0 - (distanceToCenter / screenCenter) * 0.3;
                        scale = scale.clamp(0.8, 1.0);

                        return Transform.scale(
                          scale: scale,
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            opacity: scale == 1.0 ? 1.0 : 0.9,
                            child: GestureDetector(
                              onTap: entity.imageUrl != null
                                  ? () => showImage(entity.imageUrl!)
                                  : null,
                              child: Container(
                                width: constraints.maxWidth / 3,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 6),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4.0),
                                      child: Text(
                                        entity.name,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                    if (entity.imageUrl != null)
                                      AspectRatio(
                                        aspectRatio: 1,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: Image.network(
                                            entity.imageUrl!,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                    Padding(
                                      padding: const EdgeInsets.all(6.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          if (entity.volume != null)
                                            Text(
                                              "Volume: ${entity.volume}",
                                              style: const TextStyle(
                                                  color: Colors.green),
                                            ),
                                          ...entityDetails.map(
                                            (d) => Text(
                                              d.details,
                                              style: const TextStyle(
                                                  color: Colors.greenAccent),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
