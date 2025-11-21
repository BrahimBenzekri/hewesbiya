class TourStop {
  final String id;
  final String name;
  final String description;
  final String audioUrl; // Placeholder for real audio

  const TourStop({
    required this.id,
    required this.name,
    required this.description,
    this.audioUrl = '',
  });
}

class MockTourService {
  static const List<TourStop> stops = [
    TourStop(
      id: '1',
      name: 'The Minaret',
      description: 'The tallest minaret in the world (265m). A lighthouse guiding ships and souls alike.',
    ),
    TourStop(
      id: '2',
      name: 'The Prayer Hall',
      description: 'A masterpiece holding 120,000 worshippers. Look up at the 9.5-ton crystal chandelier.',
    ),
    TourStop(
      id: '3',
      name: 'The Courtyard',
      description: 'A serene open space with fountains echoing the Alhambra. A transition from the city to the divine.',
    ),
    TourStop(
      id: '4',
      name: 'Islamic Garden',
      description: 'The "Gardens of Paradise". Every tree planted here is mentioned in the Quran.',
    ),
    TourStop(
      id: '5',
      name: 'Cultural Center',
      description: 'A hub of knowledge with 1 million books and a lab for restoring ancient manuscripts.',
    ),
  ];

  Future<List<TourStop>> getStops() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return stops;
  }
}
