import 'package:injectable/injectable.dart';

import '../../../../../app/routes_names.dart';
import '../../../../../core/base/base_cubit.dart';
import '../../../../../core/base/cubit_message.dart';
import '../../../../../core/base/ui_events.dart';
import '../../../../../core/base_response/base_response.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/resource/resource.dart';
import '../../../domain/entities/profile_entity.dart';
import '../../../domain/use_cases/get_profile_use_case.dart';
import '../../../domain/use_cases/pick_photo_use_case.dart';
import '../../../domain/use_cases/upload_photo_use_case.dart';
import '../view/models/profile_menu_action.dart';
import '../view/models/profile_menu_item.dart';
import 'profile_intent.dart';
import 'profile_state.dart';
import 'toggle_locale_event.dart';

@lazySingleton
class ProfileCubit extends BaseCubit<ProfileState, BaseUiEvent> {
  final GetProfileUseCase _getProfileUseCase;
  final UploadPhotoUseCase _uploadPhotoUseCase;
  final PickPhotoUseCase _pickPhotoUseCase;

  Future<void>? _pendingFetch;
  int _fetchId = 0;

  ProfileCubit(
    this._getProfileUseCase,
    this._uploadPhotoUseCase,
    this._pickPhotoUseCase,
  ) : super(const ProfileState());

  void doIntent(ProfileIntent intent) {
    switch (intent) {
      case LoadProfileIntent():
        _ensureLoaded();
      case SyncProfileIntent(:final profile):
        _sync(profile);
      case PickPhotoIntent():
        _pickAndUpload();
      case MenuTapIntent(:final item):
        _onMenuTap(item);
    }
  }

  void _onMenuTap(ProfileMenuItem item) {
    switch (item.action) {
      case ProfileMenuAction.editProfile:
        emitEvent(const NavigateEvent(AppRoutes.editProfile));
      case ProfileMenuAction.selectLanguage:
        emitEvent(const ToggleLocaleEvent());
      case ProfileMenuAction.security:
      case ProfileMenuAction.privacyPolicy:
      case ProfileMenuAction.help:
        emitEvent(NavigateEvent(AppRoutes.webView, arguments: item.page));
      case ProfileMenuAction.changePassword:
      case ProfileMenuAction.logout:
        break;
    }
  }

  Future<void> _ensureLoaded() async {
    if (state.hasProfile) return;
    await _fetch();
  }

  Future<void> _fetch() async {
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

  void _sync(ProfileEntity profile) {
    _emit(state.copyWith(profileResource: Resource.success(profile)));
  }

  void _clearCache() {
    _fetchId++;
    _pendingFetch = null;
    _emit(const ProfileState());
  }

  Future<void> _pickAndUpload() async {
    if (state.isUploadingPhoto) return;
    final picked = await _pickPhotoUseCase();
    switch (picked) {
      case SuccessResponse<String?>(:final data):
        if (data == null) return;
        await _upload(data);
      case ErrorResponse<String?>(:final failure):
        emitFailure(failure);
    }
  }

  Future<void> _upload(String photoPath) async {
    if (state.isUploadingPhoto) return;
    _emit(state.withUpload(photoPath));
    final response = await _uploadPhotoUseCase(photoPath);
    switch (response) {
      case SuccessResponse<ProfileEntity>(:final data):
        _sync(data);
        _emit(state.withUpload(null));
        emitSuccess(CubitMessageType.profileUpdated);
      case ErrorResponse<ProfileEntity>(:final failure):
        _emit(state.withUpload(null));
        emitFailure(failure);
    }
  }

  void _onProfileFailure(Failure failure) {
    if (failure is UnauthorizedFailure) {
      _clearCache();
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
