import '../entities/city.dart';

/// City selector + launch waitlist.
abstract class CityRepository {
  /// `GET /v1/cities` — all cities (`live` and `waitlist`).
  Future<List<City>> getCities();

  /// `POST /v1/waitlist` — join a not-yet-live city's launch list. Provide at
  /// least one contact (`email` or `phone`).
  Future<void> joinWaitlist({
    required String cityId,
    String? email,
    String? phone,
  });
}
