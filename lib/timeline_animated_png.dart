import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:datavisual/entity_controller.dart';
import 'package:datavisual/details_controller.dart';

class ContinuousImageSlider extends StatefulWidget {
  final int datasetId;
  const ContinuousImageSlider({super.key, required this.datasetId});

  @override
  State<ContinuousImageSlider> createState() => _ContinuousImageSliderState();
}

class _ContinuousImageSliderState extends State<ContinuousImageSlider>
    with SingleTickerProviderStateMixin {
  final entityController = Get.put(EntityController());
  final detailController = Get.put(DetailController());
  bool isLoaded = false;

  late final ScrollController _scrollController;
  late final AnimationController _animationController;
  double scrollSpeed = 50; // pixels per second

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(days: 1),
    );
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
        _scrollController.jumpTo(0); // loop back like a train
      } else {
        _scrollController.jumpTo(next);
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final datasetEntities = entityController.entities
        .where((e) => e.dataset == widget.datasetId)
        .toList();

    return Scaffold(
      backgroundColor: Colors.black,
      body: isLoaded
          ? datasetEntities.isEmpty
              ? const Center(
                  child: Text("No images found",
                      style: TextStyle(color: Colors.white)))
              : ListView.builder(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  itemCount: datasetEntities.length * 2, // duplicate for looping
                  itemBuilder: (context, index) {
                    final entity =
                        datasetEntities[index % datasetEntities.length];
                    return entity.imageUrl != null
                        ? Image.network(
                            entity.imageUrl!,
                            fit: BoxFit.cover,
                            width: MediaQuery.of(context).size.width/2,
                            height: MediaQuery.of(context).size.height/3,
                          )
                        : const SizedBox.shrink();
                  },
                )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
