import 'package:injectable/injectable.dart';

import '../../../../../app/routes_names.dart';
import '../../../../../core/base/base_cubit.dart';
import '../../../../../core/base/cubit_message.dart';
import '../../../../../core/base/ui_events.dart';
import '../../../../../core/base_response/base_response.dart';
import '../../../../../core/contants/app_language.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/local/locale_preferences.dart';
import '../../../../../core/local/local_service.dart';
import '../../../../../core/resource/resource.dart';
import '../../../domain/entities/profile_entity.dart';
import '../../../domain/use_cases/get_profile_use_case.dart';
import '../../../domain/use_cases/pick_photo_use_case.dart';
import '../../../domain/use_cases/upload_photo_use_case.dart';
import '../view/models/profile_menu_action.dart';
import '../view/models/profile_menu_item.dart';
import 'profile_intent.dart';
import 'profile_state.dart';
import 'profile_ui_event.dart';

@lazySingleton
class ProfileCubit extends BaseCubit<ProfileState, BaseUiEvent> {
  final GetProfileUseCase _getProfileUseCase;
  final UploadPhotoUseCase _uploadPhotoUseCase;
  final PickPhotoUseCase _pickPhotoUseCase;
  final LocalePreferences _localePreferences;
  final LocaleService _localeService;

  Future<void>? _pendingFetch;
  int _fetchId = 0;

  ProfileCubit(
    this._getProfileUseCase,
    this._uploadPhotoUseCase,
    this._pickPhotoUseCase,
    this._localePreferences,
    this._localeService,
  ) : super(ProfileState(language: _localePreferences.readLanguage()));

  ProfileEntity? get profile => state.profile;

  void doIntent(ProfileIntent intent) {
    switch (intent) {
      case PickPhotoIntent():
        pickAndUploadPhoto();
      case MenuTapIntent(:final item):
        _onMenuTap(item);
    }
  }

  void _onMenuTap(ProfileMenuItem item) {
    switch (item.action) {
      case ProfileMenuAction.editProfile:
        emitEvent(const NavigateEvent(AppRoutes.editProfile));
      case ProfileMenuAction.selectLanguage:
        toggleLanguage();
      case ProfileMenuAction.security:
      case ProfileMenuAction.privacyPolicy:
      case ProfileMenuAction.help:
        emitEvent(NavigateEvent(AppRoutes.webView, arguments: item.page));
      case ProfileMenuAction.changePassword:
      case ProfileMenuAction.logout:
        break;
    }
  }

  Future<void> applySavedLanguage() async {
    final language = _localePreferences.readLanguage();
    _localeService.setLanguageCode(language.code);
    _emit(state.withLanguage(language));
  }

  Future<void> toggleLanguage() => changeLanguage(
    state.language == AppLanguage.english
        ? AppLanguage.arabic
        : AppLanguage.english,
  );

  Future<void> changeLanguage(AppLanguage language) async {
    await _localePreferences.saveLanguage(language);
    _localeService.setLanguageCode(language.code);
    _emit(state.withLanguage(language));
    emitEvent(ProfileUiEvent(language));
  }

  Future<void> ensureLoaded() async {
    if (state.hasProfile) return;
    await fetch();
  }

  Future<void> refresh() => fetch();

  Future<void> fetch() async {
    final pending = _pendingFetch;
    if (pending != null) return pending;
    final running = _load();
    _pendingFetch = running;
    try {
      await running;
    } finally {
      _pendingFetch = null;
    }
  }

  Future<void> _load() async {
    final fetchId = ++_fetchId;
    _emit(
      state.copyWith(
        profileResource: Resource<ProfileEntity>.loading(data: state.profile),
      ),
    );
    final response = await _getProfileUseCase();
    if (fetchId != _fetchId) return;
    switch (response) {
      case SuccessResponse<ProfileEntity>(:final data):
        _emit(state.copyWith(profileResource: Resource.success(data)));
      case ErrorResponse<ProfileEntity>(:final failure):
        _onProfileFailure(failure);
    }
  }

  void applyProfile(ProfileEntity profile) {
    _emit(state.copyWith(profileResource: Resource.success(profile)));
  }

  void clearCache() {
    _fetchId++;
    _pendingFetch = null;
    _emit(const ProfileState());
  }

  Future<void> pickAndUploadPhoto() async {
    if (state.isUploadingPhoto) return;
    final picked = await _pickPhotoUseCase();
    switch (picked) {
      case SuccessResponse<String?>(:final data):
        if (data == null) return;
        await uploadPhoto(data);
      case ErrorResponse<String?>(:final failure):
        emitFailure(failure);
    }
  }

  Future<void> uploadPhoto(String photoPath) async {
    if (state.isUploadingPhoto) return;
    _emit(state.withUpload(photoPath));
    final response = await _uploadPhotoUseCase(photoPath);
    switch (response) {
      case SuccessResponse<ProfileEntity>(:final data):
        applyProfile(data);
        _emit(state.withUpload(null));
        emitSuccess(CubitMessageType.profileUpdated);
      case ErrorResponse<ProfileEntity>(:final failure):
        _emit(state.withUpload(null));
        emitFailure(failure);
    }
  }

  void _onProfileFailure(Failure failure) {
    if (failure is UnauthorizedFailure) {
      clearCache();
      emitFailure(failure);
      return;
    }
    _emit(
      state.copyWith(
        profileResource: Resource.error(failure, data: state.profile),
      ),
    );
    emitFailure(failure);
  }

  void _emit(ProfileState newState) {
    if (isClosed) return;
    emit(newState);
  }
}
