import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:datavisual/entity_controller.dart';
import 'package:datavisual/details_controller.dart';


class TimelineCarouselPage2 extends StatefulWidget {
  final int datasetId;
  const TimelineCarouselPage2({super.key, required this.datasetId});

  @override
  State<TimelineCarouselPage2> createState() => _TimelineCarouselPageState();
}

class _TimelineCarouselPageState extends State<TimelineCarouselPage2> {
  final entityController = Get.put(EntityController());
  final detailController = Get.put(DetailController());

  PageController pageController = PageController(viewportFraction: 0.7);
  Timer? timer;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    await entityController.fetchEntities();
    await detailController.fetchDetails();
    startAutoPlay();
    setState(() {});
  }

  void startAutoPlay() {
    final datasetEntities = entityController.entities
        .where((e) => e.dataset == widget.datasetId)
        .toList();

    if (datasetEntities.isEmpty) return;

    timer?.cancel();
    int index = 0;
    timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (pageController.hasClients) {
        pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 2500),
          curve: Curves.easeInOut,
        );
        index = (index + 1) % datasetEntities.length;
      }
    });
  }

  void showImage(String url) {
    showDialog(
        context: context,
        builder: (_) => Dialog(
              child: InteractiveViewer(child: Image.network(url)),
            ));
  }

  @override
  void dispose() {
    timer?.cancel();
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final datasetEntities = entityController.entities
        .where((e) => e.dataset == widget.datasetId)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Timeline Carousel")),
      body: datasetEntities.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: SizedBox(
                height: 800,
                child: PageView.builder(
                  controller: pageController,
                  itemCount: datasetEntities.length,
                  itemBuilder: (context, index) {
                    final entity = datasetEntities[index];
                    final entityDetails = detailController.details
                        .where((d) => d.entity == entity.id)
                        .toList();

                    return Transform.scale(
                      scale: index == pageController.page?.round() ? 1.0 : 0.85,
                      child: GestureDetector(
                        onTap: entity.imageUrl != null
                            ? () => showImage(entity.imageUrl!)
                            : null,
                        child: Card(
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          child: Column(
                            children: [
                              if (entity.imageUrl != null)
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(16)),
                                  child: Image.network(
                                    entity.imageUrl!,
                                    width: double.infinity,
                                    height: 600,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Text(entity.name,
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold)),
                                    if (entity.volume != null)
                                      Text("Volume: ${entity.volume}"),
                                    ...entityDetails
                                        .map((d) => Text(d.details))
                                        .toList(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
    );
  }
}
