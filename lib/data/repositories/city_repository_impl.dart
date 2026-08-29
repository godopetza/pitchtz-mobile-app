import '../../core/network/api_client.dart';
import '../../domain/entities/city.dart';
import '../../domain/repositories/city_repository.dart';
import '../models/city_dto.dart';

class CityRepositoryImpl implements CityRepository {
  CityRepositoryImpl(this._api);

  final ApiClient _api;

  @override
  Future<List<City>> getCities() async {
    final list = await _api.getList('/cities');
    return list
        .whereType<Map>()
        .map((m) => CityDto.toEntity(m.cast<String, dynamic>()))
        .toList();
  }

  @override
  Future<void> joinWaitlist({
    required String cityId,
    String? email,
    String? phone,
  }) async {
    await _api.post('/waitlist', body: {
      'city_id': cityId,
      if (email != null && email.isNotEmpty) 'email': email,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
    });
  }
}
