import 'package:giptv_flutter/app/screens/main/cubit/state_main.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:giptv_flutter/domain/entities/entity_user.dart';
import 'package:giptv_flutter/domain/providers/provider_api_interactions.dart';

class CubitMain extends Cubit<StateMain> {
  CubitMain() : super(const StateMain());

  void clearChannels() {
    emit(
      state.copyWith(
        channels: [],
      ),
    );
  }

  Future getCategories(ProviderApiInteractions provider) async {
    emit(
      state.copyWith(
        categories: await provider.getCategories(state.user.code ?? ""),
      ),
    );
  }

  Future getWebsite(ProviderApiInteractions provider) async {
    emit(
      state.copyWith(
        websiteUrl: await provider.getWebsite(),
      ),
    );
  }

  Future getChannels(
    ProviderApiInteractions provider,
    String categoryId,
  ) async {
    emit(
      state.copyWith(
        channels: await provider.getChannelsByCategory(
          categoryId,
          state.user.code ?? "",
        ),
      ),
    );
  }

  Future getRadioStations(ProviderApiInteractions provider, String code) async {
    emit(
      state.copyWith(
        radioStations: await provider.getRadioStations(code),
      ),
    );
  }

  Future getFavorites(ProviderApiInteractions provider, String idSerial) async {
    emit(
      state.copyWith(
        favorites: await provider.getFavorites(idSerial),
      ),
    );
  }

  void setUrl(String url) {
    emit(state.copyWith(videoUrl: url));
  }

  void setUser(EntityUser user) {
    emit(state.copyWith(user: user));
  }

  void selectChannel(int index) {
    emit(state.copyWith(selectedChannel: index));
  }

  Future goToLiveTvStage(ProviderApiInteractions provider) async {
    await getCategories(provider);
    emit(state.copyWith(stage: StagesScreenMain.liveTv));
  }

  void goToRadioStage() {
    emit(state.copyWith(stage: StagesScreenMain.radio));
  }

  void goToSettingsStage() {
    emit(state.copyWith(stage: StagesScreenMain.settings));
  }

  Future goToFavoritesStage(
    ProviderApiInteractions provider,
    String idSerial,
  ) async {
    await getFavorites(provider, idSerial);
    emit(state.copyWith(stage: StagesScreenMain.favorites));
  }

  void goToActivationStage() {
    emit(state.copyWith(stage: StagesScreenMain.activation));
  }
}
