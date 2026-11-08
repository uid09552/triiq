//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'package:dio/dio.dart';
import 'package:triiq/client/intervalls/src/auth/api_key_auth.dart';
import 'package:triiq/client/intervalls/src/auth/basic_auth.dart';
import 'package:triiq/client/intervalls/src/auth/bearer_auth.dart';
import 'package:triiq/client/intervalls/src/auth/oauth.dart';
import 'package:triiq/client/intervalls/src/api/aktivitten_api.dart';
import 'package:triiq/client/intervalls/src/api/athleten_api.dart';
import 'package:triiq/client/intervalls/src/api/ausrstung_api.dart';
import 'package:triiq/client/intervalls/src/api/bibliothek_api.dart';
import 'package:triiq/client/intervalls/src/api/chats_api.dart';
import 'package:triiq/client/intervalls/src/api/custom_items_api.dart';
import 'package:triiq/client/intervalls/src/api/o_auth_server_controller_api.dart';
import 'package:triiq/client/intervalls/src/api/routen_api.dart';
import 'package:triiq/client/intervalls/src/api/shared_events_api.dart';
import 'package:triiq/client/intervalls/src/api/sport_api.dart';
import 'package:triiq/client/intervalls/src/api/veranstaltungen_api.dart';
import 'package:triiq/client/intervalls/src/api/wellness_api.dart';
import 'package:triiq/client/intervalls/src/api/wetter_api.dart';

class IntervallsClient {
  static const String basePath = r'https://intervals.icu';

  final Dio dio;
  IntervallsClient({
    Dio? dio,
    String? basePathOverride,
    List<Interceptor>? interceptors,
  }) : this.dio =
           dio ??
           Dio(
             BaseOptions(
               baseUrl: basePathOverride ?? basePath,
               connectTimeout: const Duration(milliseconds: 5000),
               receiveTimeout: const Duration(milliseconds: 3000),
             ),
           ) {
    if (interceptors == null) {
      this.dio.interceptors.addAll([
        OAuthInterceptor(),
        BasicAuthInterceptor(),
        BearerAuthInterceptor(),
        ApiKeyAuthInterceptor(),
      ]);
    } else {
      this.dio.interceptors.addAll(interceptors);
    }
  }

  void setOAuthToken(String name, String token) {
    if (this.dio.interceptors.any((i) => i is OAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((i) => i is OAuthInterceptor)
                  as OAuthInterceptor)
              .tokens[name] =
          token;
    }
  }

  /// Removes the OAuth token associated with the given [name].
  ///
  /// If no [OAuthInterceptor] is registered or no token exists for the given
  /// [name], this method has no effect.
  void removeOAuthToken(String name) {
    if (this.dio.interceptors.any((i) => i is OAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((i) => i is OAuthInterceptor)
              as OAuthInterceptor)
          .tokens
          .remove(name);
    }
  }

  void setBearerAuth(String name, String token) {
    if (this.dio.interceptors.any((i) => i is BearerAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((i) => i is BearerAuthInterceptor)
                  as BearerAuthInterceptor)
              .tokens[name] =
          token;
    }
  }

  /// Removes the bearer authentication token associated with the given [name].
  ///
  /// If no [BearerAuthInterceptor] is registered or no token exists for the
  /// given [name], this method has no effect.
  void removeBearerAuth(String name) {
    if (this.dio.interceptors.any((i) => i is BearerAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((i) => i is BearerAuthInterceptor)
              as BearerAuthInterceptor)
          .tokens
          .remove(name);
    }
  }

  void setBasicAuth(String name, String username, String password) {
    if (this.dio.interceptors.any((i) => i is BasicAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((i) => i is BasicAuthInterceptor)
              as BasicAuthInterceptor)
          .authInfo[name] = BasicAuthInfo(
        username,
        password,
      );
    }
  }

  /// Removes the basic authentication credentials associated with the given [name].
  ///
  /// If no [BasicAuthInterceptor] is registered or no credentials exist for the
  /// given [name], this method has no effect.
  void removeBasicAuth(String name) {
    if (this.dio.interceptors.any((i) => i is BasicAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((i) => i is BasicAuthInterceptor)
              as BasicAuthInterceptor)
          .authInfo
          .remove(name);
    }
  }

  void setApiKey(String name, String apiKey) {
    if (this.dio.interceptors.any((i) => i is ApiKeyAuthInterceptor)) {
      (this.dio.interceptors.firstWhere(
                    (element) => element is ApiKeyAuthInterceptor,
                  )
                  as ApiKeyAuthInterceptor)
              .apiKeys[name] =
          apiKey;
    }
  }

  /// Removes the API key associated with the given [name].
  ///
  /// If no [ApiKeyAuthInterceptor] is registered or no API key exists for the
  /// given [name], this method has no effect.
  void removeApiKey(String name) {
    if (this.dio.interceptors.any((i) => i is ApiKeyAuthInterceptor)) {
      (this.dio.interceptors.firstWhere(
                (element) => element is ApiKeyAuthInterceptor,
              )
              as ApiKeyAuthInterceptor)
          .apiKeys
          .remove(name);
    }
  }

  /// Get AktivittenApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  AktivittenApi getAktivittenApi() {
    return AktivittenApi(dio);
  }

  /// Get AthletenApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  AthletenApi getAthletenApi() {
    return AthletenApi(dio);
  }

  /// Get AusrstungApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  AusrstungApi getAusrstungApi() {
    return AusrstungApi(dio);
  }

  /// Get BibliothekApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  BibliothekApi getBibliothekApi() {
    return BibliothekApi(dio);
  }

  /// Get ChatsApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  ChatsApi getChatsApi() {
    return ChatsApi(dio);
  }

  /// Get CustomItemsApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  CustomItemsApi getCustomItemsApi() {
    return CustomItemsApi(dio);
  }

  /// Get OAuthServerControllerApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  OAuthServerControllerApi getOAuthServerControllerApi() {
    return OAuthServerControllerApi(dio);
  }

  /// Get RoutenApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  RoutenApi getRoutenApi() {
    return RoutenApi(dio);
  }

  /// Get SharedEventsApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  SharedEventsApi getSharedEventsApi() {
    return SharedEventsApi(dio);
  }

  /// Get SportApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  SportApi getSportApi() {
    return SportApi(dio);
  }

  /// Get VeranstaltungenApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  VeranstaltungenApi getVeranstaltungenApi() {
    return VeranstaltungenApi(dio);
  }

  /// Get WellnessApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  WellnessApi getWellnessApi() {
    return WellnessApi(dio);
  }

  /// Get WetterApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  WetterApi getWetterApi() {
    return WetterApi(dio);
  }
}
