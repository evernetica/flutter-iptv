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
        showSearchField: false,
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
    String categoryName,
  ) async {
    print("GET :: $categoryId :: $categoryName");

    List<EntityChannel> channels = await provider.getChannelsByCategory(
      categoryId,
      categoryName,
      state.user.code ?? "",
    );

    if (!state.showBackButton) return;

    emit(
      state.copyWith(
        channels: channels,
        showSearchField: false,
      ),
    );
  }

  Future getRadioStations(ProviderApiInteractions provider, String code) async {
    emit(
      state.copyWith(
        radioStations: await provider.getRadioStations(code),
        showSearchField: false,
      ),
    );
  }

  Future getFavorites(ProviderApiInteractions provider, String idSerial) async {
    emit(
      state.copyWith(
        favorites: await provider.getFavorites(idSerial),
        showSearchField: false,
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
        showSearchField: false,
      ),
    );
    await getCategories(provider);
  }

  void goToRadioStage() {
    emit(
      state.copyWith(
        stage: StagesScreenMain.radio,
        showBackButton: false,
        showSearchField: false,
      ),
    );
  }

  void goToSettingsStage() {
    emit(
      state.copyWith(
        stage: StagesScreenMain.settings,
        showBackButton: false,
        showSearchField: false,
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
        showSearchField: false,
      ),
    );
  }

  void goToActivationStage() {
    emit(
      state.copyWith(
        stage: StagesScreenMain.activation,
        showBackButton: false,
        showSearchField: false,
      ),
    );
  }

  void setBackButtonVisibility(bool newState) {
    emit(state.copyWith(showBackButton: newState));
  }

  void setSearchFieldVisibility(bool newState) {
    emit(state.copyWith(showSearchField: newState));
  }
}
