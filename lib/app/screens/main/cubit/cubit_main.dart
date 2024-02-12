import 'package:giptv_flutter/app/screens/main/cubit/state_main.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:giptv_flutter/domain/entities/entity_channel.dart';
import 'package:giptv_flutter/domain/entities/entity_user.dart';
import 'package:giptv_flutter/domain/providers/provider_api_interactions.dart';

class CubitMain extends Cubit<StateMain> {
  CubitMain() : super(const StateMain());

  void clearChannels() {
    emit(
      state.copyWith(
        channels: [],
        showBackButton: false,
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
    List<EntityChannel> channels = await provider.getChannelsByCategory(
      categoryId,
      state.user.code ?? "",
    );

    if (!state.showBackButton) return;

    emit(state.copyWith(channels: channels));
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

  void setUser(EntityUser user) {
    emit(state.copyWith(user: user));
  }

  Future goToLiveTvStage(ProviderApiInteractions provider) async {
    emit(
      state.copyWith(
        stage: StagesScreenMain.liveTv,
        channels: [],
        categories: [],
        showBackButton: false,
      ),
    );
    await getCategories(provider);
  }

  void goToRadioStage() {
    emit(
      state.copyWith(
        stage: StagesScreenMain.radio,
        showBackButton: false,
      ),
    );
  }

  void goToSettingsStage() {
    emit(
      state.copyWith(
        stage: StagesScreenMain.settings,
        showBackButton: false,
      ),
    );
  }

  Future goToFavoritesStage(
    ProviderApiInteractions provider,
    String idSerial,
  ) async {
    await getFavorites(provider, idSerial);
    emit(
      state.copyWith(
        stage: StagesScreenMain.favorites,
        showBackButton: false,
      ),
    );
  }

  void goToActivationStage() {
    emit(
      state.copyWith(
        stage: StagesScreenMain.activation,
        showBackButton: false,
      ),
    );
  }

  void setBackButtonVisibility(bool newState) {
    emit(state.copyWith(showBackButton: newState));
  }
}
