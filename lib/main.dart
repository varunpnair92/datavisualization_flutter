import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:datavisual/home.dart';
import 'package:datavisual/dataset_form.dart';
import 'package:datavisual/entity_form.dart';
import 'package:datavisual/details_form.dart';
import 'package:datavisual/timeline.dart';
import 'package:datavisual/timeline_home.dart';
import 'package:datavisual/timeline_animated.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Visualization Project',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const HomePage()),
        GetPage(name: '/dataset-form', page: () => DatasetFormPage()),
        GetPage(name: '/entity-form', page: () => EntityFormPage()),
        GetPage(name: '/detail-form', page: () => DetailFormPage()),
        GetPage(name: '/timeline-view', page: () => const TimelineViewPage()),
        GetPage(name: '/timeline-home', page: () => TimelineHomePage()),
        // Timeline animation page expects an argument
        GetPage(
          name: '/timeline-animated',
          page: () {
            final datasetId = Get.arguments as int;
            return TimelineCarouselPage(datasetId: datasetId);
          },
        ),
      ],
    );
  }
}
