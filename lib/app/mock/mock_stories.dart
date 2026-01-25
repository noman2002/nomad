import '../models/story.dart';
import 'mock_data.dart';

class MockStories {
  static const sampleVideoUrl =
      'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4';

  static final stories = <Story>[
    Story(
      id: 's1',
      author: MockData.nearbyNomads[0],
      videoUrl: sampleVideoUrl,
      caption: 'Quick van tour + where I\'m headed next.',
      category: StoryCategory.nearby,
    ),
    Story(
      id: 's2',
      author: MockData.nearbyNomads[2],
      videoUrl: sampleVideoUrl,
      caption: 'Sunrise yoga spot you have to see.',
      category: StoryCategory.forYou,
    ),
    Story(
      id: 's3',
      author: MockData.nearbyNomads[1],
      videoUrl: sampleVideoUrl,
      caption: 'Camp setup + coffee ping for anyone nearby.',
      category: StoryCategory.onYourRoute,
    ),
  ];
}
