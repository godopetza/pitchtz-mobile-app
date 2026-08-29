import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/config/locale_controller.dart';
import '../core/network/api_client.dart';
import '../core/network/token_store.dart';
import '../core/utils/toast_controller.dart';
import '../data/repositories/ai_repository_impl.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../data/repositories/booking_repository_impl.dart';
import '../data/repositories/city_repository_impl.dart';
import '../data/repositories/favorites_repository_impl.dart';
import '../data/repositories/payment_repository_impl.dart';
import '../data/repositories/pitch_repository_impl.dart';
import '../data/repositories/teams_repository_impl.dart';
import '../domain/repositories/ai_repository.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/booking_repository.dart';
import '../domain/repositories/city_repository.dart';
import '../domain/repositories/favorites_repository.dart';
import '../domain/repositories/payment_repository.dart';
import '../domain/repositories/pitch_repository.dart';
import '../domain/repositories/teams_repository.dart';
import '../domain/usecases/booking_calculator.dart';
import '../domain/usecases/search_pitches_with_ai.dart';
import '../domain/usecases/toggle_favorite.dart';
import '../features/auth/viewmodel/login_viewmodel.dart';
import '../features/booking/viewmodel/booking_flow_viewmodel.dart';
import '../features/bookings/viewmodel/bookings_viewmodel.dart';
import '../features/explore/viewmodel/explore_viewmodel.dart';
import '../features/explore/viewmodel/results_viewmodel.dart';
import '../features/onboarding/viewmodel/onboarding_viewmodel.dart';
import '../features/pitch_detail/viewmodel/detail_viewmodel.dart';
import '../features/profile/viewmodel/profile_viewmodel.dart';
import '../features/shell/viewmodel/shell_viewmodel.dart';
import '../features/teams/viewmodel/teams_viewmodel.dart';

/// Global service locator. Repositories/clients are singletons; ViewModels are
/// factories so each screen gets a fresh instance.
final GetIt getIt = GetIt.instance;

/// Async because the session + locale live in SharedPreferences.
Future<void> configureDependencies() async {
  final prefs = await SharedPreferences.getInstance();

  // ---- App services ----
  getIt.registerSingleton<SharedPreferences>(prefs);
  getIt.registerLazySingleton<ToastController>(() => ToastController());
  getIt.registerLazySingleton<LocaleController>(() => LocaleController(prefs));
  getIt.registerLazySingleton<TokenStore>(() => TokenStore(prefs));
  getIt.registerLazySingleton<ApiClient>(() => ApiClient(tokens: getIt()));

  // ---- Repositories (data layer, singletons) ----
  // Live (API-backed):
  getIt.registerLazySingleton<PitchRepository>(
      () => PitchRepositoryImpl(getIt()));
  getIt.registerLazySingleton<CityRepository>(
      () => CityRepositoryImpl(getIt()));
  getIt.registerLazySingleton<BookingRepository>(
      () => BookingRepositoryImpl(getIt()));
  // Kept for coming-soon flows:
  getIt.registerLazySingleton<FavoritesRepository>(
      () => FavoritesRepositoryImpl());
  getIt.registerLazySingleton<TeamsRepository>(() => TeamsRepositoryImpl(getIt()));
  getIt.registerLazySingleton<PaymentRepository>(
      () => PaymentRepositoryImpl());
  // Live player auth: email code + Google/Apple OAuth, 30-day bearer JWT.
  getIt.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(prefs, getIt(), getIt()));
  getIt.registerLazySingleton<AiRepository>(() => const AiRepositoryImpl());

  // ---- Use cases (domain layer) ----
  getIt.registerLazySingleton(() => const BookingCalculator());
  getIt.registerLazySingleton(() => ToggleFavorite(getIt()));
  getIt.registerLazySingleton(() => SearchPitchesWithAi(getIt()));

  // ---- ViewModels (presentation layer) ----
  getIt.registerFactory(() => OnboardingViewModel());
  getIt.registerFactory(() => LoginViewModel(getIt()));
  getIt.registerFactory(() => ProfileViewModel(getIt()));
  getIt.registerLazySingleton(() => ShellViewModel());
  getIt.registerFactory(() => ExploreViewModel(getIt(), getIt(), getIt()));
  getIt.registerFactory(() => ResultsViewModel(getIt()));
  getIt.registerFactory(() => DetailViewModel(getIt(), getIt()));
  getIt.registerLazySingleton(
      () => BookingFlowViewModel(getIt(), getIt(), getIt()));
  getIt.registerFactory(() => BookingsViewModel(getIt()));
  getIt.registerFactory(() => TeamsViewModel(getIt(), getIt(), getIt()));
}
