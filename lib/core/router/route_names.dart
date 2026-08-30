/// Central list of named routes.
class Routes {
  Routes._();

  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const home = '/home'; // bottom-nav shell

  // Discovery / venue flow
  static const results = '/results';
  static const detail = '/detail';

  // Booking flow
  static const summary = '/summary';
  static const processing = '/processing';
  static const success = '/success';
  static const scanPay = '/scan-pay';
  static const bookingDetail = '/booking-detail'; // GET /bookings/:id

  // Split-pay public share page
  static const sharePayment = '/share-payment'; // /pay/shares/:id

  // Teams feature
  static const teamDetail = '/team-detail'; // teams/:id detail & members

  // Fixtures
  static const fixtures = '/fixtures';

  // Shop
  static const shop = '/shop';

  // Watch Spots
  static const watchSpots = '/watch-spots';

  // AI Assistant
  static const ai = '/ai';
}
