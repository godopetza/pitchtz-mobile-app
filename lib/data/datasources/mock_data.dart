import '../../domain/entities/booking.dart';
import '../../domain/entities/payment_method.dart';
import '../../domain/entities/team.dart';

/// Remaining local/mock content for the areas that are **not** backed by the
/// live API yet (booking flow extras, teams, static filter options). Discovery
/// (venues, cities, availability, reviews, extras) now comes from the real
/// backend — see the API-backed repository implementations.
class MockData {
  MockData._();

  /// Date carousel for the (gated) booking flow: [dow, day, long-label].
  static const List<List<String>> dates = [
    ['MON', '24', 'Monday, 24 August'],
    ['TUE', '25', 'Tuesday, 25 August'],
    ['WED', '26', 'Wednesday, 26 August'],
    ['THU', '27', 'Thursday, 27 August'],
    ['FRI', '28', 'Friday, 28 August'],
  ];

  static const List<String> exploreChips = [
    'Tonight',
    'Tomorrow',
    'Weekend',
    'Near me',
    '5-a-side',
    '7-a-side',
    '11-a-side',
  ];

  // Static filter-sheet options.
  static const List<String> filterAreas = [
    'Masaki',
    'Mikocheni',
    'Sinza',
    'Kinondoni',
    'Oyster Bay',
    'Upanga',
    'Mbezi',
    'Kigamboni',
  ];

  static const List<String> filterAmenities = [
    'Parking',
    'Changing rooms',
    'Showers',
    'Floodlights',
    'Drinks',
    'Bibs',
    'Football available',
  ];

  // --- Booking flow (gated / coming soon) ---
  static const List<ExtraDef> extras = [
    ExtraDef(key: 'bibs', name: 'Team bibs (rent)', price: 10000, description: 'Set of 14'),
    ExtraDef(key: 'cones', name: 'Training cones (rent)', price: 5000, description: 'Set of 20'),
    ExtraDef(key: 'water', name: 'Drinking water', price: 12000, description: 'Per carton · 12 bottles'),
    ExtraDef(key: 'jersey', name: 'Pitch TZ jersey', price: 25000, description: 'Merch · yours to keep'),
    ExtraDef(key: 'ps5', name: 'PS5 station (1 hr)', price: 10000, description: 'FC 26 · 4 pads · after your game'),
  ];

  static const List<String> repeatOptions = [
    'Just once',
    'Weekly ×4',
    'Monthly',
    '3 months',
  ];

  static const List<String> splitGroups = [
    'Mikocheni Warriors',
    'Thursday Crew',
    'Custom group',
  ];

  static const List<PaymentMethod> paymentMethods = [
    PaymentMethod(id: 'mpesa', name: 'M-Pesa', subtitle: '+255 754 XXX XXX', mark: 'M', brandColor: 0xFF3FA34D),
    PaymentMethod(id: 'airtel', name: 'Airtel Money', subtitle: '+255 786 XXX XXX', mark: 'A', brandColor: 0xFFD9403A),
    PaymentMethod(id: 'mixx', name: 'Mixx by Yas', subtitle: '+255 713 XXX XXX', mark: 'X', brandColor: 0xFFE8A93B),
    PaymentMethod(id: 'halo', name: 'HaloPesa', subtitle: '+255 622 XXX XXX', mark: 'H', brandColor: 0xFFC96A2E),
    PaymentMethod(id: 'card', name: 'Card', subtitle: 'Visa · Mastercard', mark: 'C', brandColor: 0xFF4A5A96),
  ];

  static const Booking defaultUpcoming = Booking(
    venue: 'Sinza Soccer Park',
    date: 'Sat, 29 August',
    time: '5:00 PM – 6:00 PM',
    code: 'PITCH-6119',
  );

  static const List<Booking> pastBookings = [
    Booking(venue: 'Mikocheni Arena', date: 'Tue, 18 Aug', time: '8:00 PM – 9:00 PM', code: '', priceLabel: 'TSh 75,000', status: BookingStatus.completed),
    Booking(venue: 'GameHub Kinondoni', date: 'Sat, 8 Aug', time: '6:00 PM – 7:00 PM', code: '', priceLabel: 'TSh 70,000', status: BookingStatus.completed),
  ];

  // --- Teams (gated / coming soon) ---
  static const MyTeam myTeam = MyTeam(
    name: 'Mikocheni Warriors',
    league: 'Kinondoni Sunday League',
    rank: '2nd of 10',
    stats: [
      TeamStat('Played', '8'),
      TeamStat('W', '5'),
      TeamStat('D', '1'),
      TeamStat('L', '2'),
      TeamStat('Pts', '16'),
    ],
  );

  static const List<StandingRow> standings = [
    StandingRow(position: '1', team: 'Sinza United', points: '18'),
    StandingRow(position: '2', team: 'Mikocheni Warriors', points: '16', highlighted: true),
    StandingRow(position: '3', team: 'Masaki FC', points: '14'),
  ];

  static const List<Challenge> challenges = [
    Challenge(id: 1, team: 'Upanga Tigers', meta: '5-a-side · Intermediate', when: 'Sat 6:00 PM · Mikocheni Arena'),
    Challenge(id: 2, team: 'Kigamboni Ballers', meta: '7-a-side · Casual', when: 'Sun 4:00 PM · Kigamboni Football Hub'),
    Challenge(id: 3, team: 'Oyster Bay Old Boys', meta: '5-a-side · Competitive', when: 'Tue 8:00 PM · Oyster Bay Five'),
  ];

  static const List<JoinableTeam> joinable = [
    JoinableTeam(id: 'j1', tag: 'SU', team: 'Sinza United', needs: 'Needs 2 players', meta: '7-a-side · Trains Tue & Thu · Sinza'),
    JoinableTeam(id: 'j2', tag: 'MF', team: 'Masaki FC', needs: 'Needs a keeper', meta: '5-a-side · Plays Sat mornings · Masaki'),
    JoinableTeam(id: 'j3', tag: 'KB', team: 'Kigamboni Ballers', needs: 'Open tryouts', meta: '11-a-side · Sun 4 PM · Kigamboni'),
  ];

  static const List<String> profileRows = [
    'Account',
    'Payment methods',
    'Notifications',
    'Favorite areas',
    'Help',
    'Terms',
  ];
}
