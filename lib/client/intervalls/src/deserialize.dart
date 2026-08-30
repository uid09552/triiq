import 'package:triiq/client/intervalls/src/model/activity.dart';
import 'package:triiq/client/intervalls/src/model/activity_analysis_issue.dart';
import 'package:triiq/client/intervalls/src/model/activity_charts.dart';
import 'package:triiq/client/intervalls/src/model/activity_filter.dart';
import 'package:triiq/client/intervalls/src/model/activity_hr_curve.dart';
import 'package:triiq/client/intervalls/src/model/activity_hr_curve_payload.dart';
import 'package:triiq/client/intervalls/src/model/activity_id.dart';
import 'package:triiq/client/intervalls/src/model/activity_power_curve.dart';
import 'package:triiq/client/intervalls/src/model/activity_power_curve_payload.dart';
import 'package:triiq/client/intervalls/src/model/activity_search_result.dart';
import 'package:triiq/client/intervalls/src/model/activity_stream.dart';
import 'package:triiq/client/intervalls/src/model/activity_weather.dart';
import 'package:triiq/client/intervalls/src/model/activity_weather_summary.dart';
import 'package:triiq/client/intervalls/src/model/activity_with_intervals.dart';
import 'package:triiq/client/intervalls/src/model/anomaly.dart';
import 'package:triiq/client/intervalls/src/model/apply_plan_dto.dart';
import 'package:triiq/client/intervalls/src/model/athlete.dart';
import 'package:triiq/client/intervalls/src/model/athlete_connections.dart';
import 'package:triiq/client/intervalls/src/model/athlete_for_profile.dart';
import 'package:triiq/client/intervalls/src/model/athlete_profile.dart';
import 'package:triiq/client/intervalls/src/model/athlete_route.dart';
import 'package:triiq/client/intervalls/src/model/athlete_search_result.dart';
import 'package:triiq/client/intervalls/src/model/athlete_training_availability.dart';
import 'package:triiq/client/intervalls/src/model/athlete_training_plan.dart';
import 'package:triiq/client/intervalls/src/model/athlete_training_plan_update.dart';
import 'package:triiq/client/intervalls/src/model/athlete_update_dto.dart';
import 'package:triiq/client/intervalls/src/model/athlete_with_tags.dart';
import 'package:triiq/client/intervalls/src/model/attachment.dart';
import 'package:triiq/client/intervalls/src/model/best_efforts.dart';
import 'package:triiq/client/intervalls/src/model/bucket.dart';
import 'package:triiq/client/intervalls/src/model/category_summary.dart';
import 'package:triiq/client/intervalls/src/model/chat.dart';
import 'package:triiq/client/intervalls/src/model/chat_member.dart';
import 'package:triiq/client/intervalls/src/model/closest.dart';
import 'package:triiq/client/intervalls/src/model/coach_tick.dart';
import 'package:triiq/client/intervalls/src/model/course.dart';
import 'package:triiq/client/intervalls/src/model/create_folder_dto.dart';
import 'package:triiq/client/intervalls/src/model/curve.dart';
import 'package:triiq/client/intervalls/src/model/custom_item.dart';
import 'package:triiq/client/intervalls/src/model/data_curve.dart';
import 'package:triiq/client/intervalls/src/model/data_curve_pt.dart';
import 'package:triiq/client/intervalls/src/model/data_curve_set_hr_curve.dart';
import 'package:triiq/client/intervalls/src/model/data_curve_set_pace_curve.dart';
import 'package:triiq/client/intervalls/src/model/data_curve_set_power_curve.dart';
import 'package:triiq/client/intervalls/src/model/delete_events_response.dart';
import 'package:triiq/client/intervalls/src/model/display.dart';
import 'package:triiq/client/intervalls/src/model/doomed_event.dart';
import 'package:triiq/client/intervalls/src/model/duplicate_events_dto.dart';
import 'package:triiq/client/intervalls/src/model/duplicate_workouts_dto.dart';
import 'package:triiq/client/intervalls/src/model/effort.dart';
import 'package:triiq/client/intervalls/src/model/event.dart';
import 'package:triiq/client/intervalls/src/model/event_ex.dart';
import 'package:triiq/client/intervalls/src/model/folder.dart';
import 'package:triiq/client/intervalls/src/model/forecast.dart';
import 'package:triiq/client/intervalls/src/model/gear.dart';
import 'package:triiq/client/intervalls/src/model/gear_reminder.dart';
import 'package:triiq/client/intervalls/src/model/gear_stats.dart';
import 'package:triiq/client/intervalls/src/model/get_activity_default_response.dart';
import 'package:triiq/client/intervalls/src/model/hr_curve.dart';
import 'package:triiq/client/intervalls/src/model/hr_load_model.dart';
import 'package:triiq/client/intervalls/src/model/hr_recovery.dart';
import 'package:triiq/client/intervalls/src/model/hidden.dart';
import 'package:triiq/client/intervalls/src/model/icu_achievement.dart';
import 'package:triiq/client/intervalls/src/model/icu_segment.dart';
import 'package:triiq/client/intervalls/src/model/ignore.dart';
import 'package:triiq/client/intervalls/src/model/interval.dart';
import 'package:triiq/client/intervalls/src/model/interval_group.dart';
import 'package:triiq/client/intervalls/src/model/intervals_dto.dart';
import 'package:triiq/client/intervalls/src/model/map_data.dart';
import 'package:triiq/client/intervalls/src/model/marker.dart';
import 'package:triiq/client/intervalls/src/model/message.dart';
import 'package:triiq/client/intervalls/src/model/new_activity_msg.dart';
import 'package:triiq/client/intervalls/src/model/new_custom_item.dart';
import 'package:triiq/client/intervalls/src/model/new_message.dart';
import 'package:triiq/client/intervalls/src/model/new_msg.dart';
import 'package:triiq/client/intervalls/src/model/pace_curve.dart';
import 'package:triiq/client/intervalls/src/model/pace_distances_dto.dart';
import 'package:triiq/client/intervalls/src/model/pace_model.dart';
import 'package:triiq/client/intervalls/src/model/plot.dart';
import 'package:triiq/client/intervalls/src/model/pos.dart';
import 'package:triiq/client/intervalls/src/model/power_curve.dart';
import 'package:triiq/client/intervalls/src/model/power_hr_curve.dart';
import 'package:triiq/client/intervalls/src/model/power_model.dart';
import 'package:triiq/client/intervalls/src/model/power_vs_hr_plot.dart';
import 'package:triiq/client/intervalls/src/model/push_error.dart';
import 'package:triiq/client/intervalls/src/model/rank.dart';
import 'package:triiq/client/intervalls/src/model/route_similarity.dart';
import 'package:triiq/client/intervalls/src/model/send_response.dart';
import 'package:triiq/client/intervalls/src/model/settings.dart';
import 'package:triiq/client/intervalls/src/model/shared_with.dart';
import 'package:triiq/client/intervalls/src/model/sport_info.dart';
import 'package:triiq/client/intervalls/src/model/sport_settings.dart';
import 'package:triiq/client/intervalls/src/model/strava_gear.dart';
import 'package:triiq/client/intervalls/src/model/summary_with_cats.dart';
import 'package:triiq/client/intervalls/src/model/time.dart';
import 'package:triiq/client/intervalls/src/model/update_streams_result.dart';
import 'package:triiq/client/intervalls/src/model/upload_activity_request.dart';
import 'package:triiq/client/intervalls/src/model/upload_activity_streams_csv_request.dart';
import 'package:triiq/client/intervalls/src/model/upload_response.dart';
import 'package:triiq/client/intervalls/src/model/upload_wellness_request.dart';
import 'package:triiq/client/intervalls/src/model/weather_config.dart';
import 'package:triiq/client/intervalls/src/model/weather_dto.dart';
import 'package:triiq/client/intervalls/src/model/weather_point.dart';
import 'package:triiq/client/intervalls/src/model/wellness.dart';
import 'package:triiq/client/intervalls/src/model/wind_rose.dart';
import 'package:triiq/client/intervalls/src/model/with_count.dart';
import 'package:triiq/client/intervalls/src/model/with_courses.dart';
import 'package:triiq/client/intervalls/src/model/with_sport_settings.dart';
import 'package:triiq/client/intervalls/src/model/workout.dart';
import 'package:triiq/client/intervalls/src/model/workout_ex.dart';
import 'package:triiq/client/intervalls/src/model/zone_info.dart';
import 'package:triiq/client/intervalls/src/model/zone_set.dart';
import 'package:triiq/client/intervalls/src/model/zone_time.dart';

final _regList = RegExp(r'^List<(.*)>$');
final _regSet = RegExp(r'^Set<(.*)>$');
final _regMap = RegExp(r'^Map<String,(.*)>$');

  ReturnType deserialize<ReturnType, BaseType>(dynamic value, String targetType, {bool growable= true}) {
      switch (targetType) {
        case 'String':
          return '$value' as ReturnType;
        case 'int':
          return (value is int ? value : int.parse('$value')) as ReturnType;
        case 'bool':
          if (value is bool) {
            return value as ReturnType;
          }
          final valueString = '$value'.toLowerCase();
          return (valueString == 'true' || valueString == '1') as ReturnType;
        case 'double':
          return (value is double ? value : double.parse('$value')) as ReturnType;
        case 'Activity':
          return Activity.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ActivityAnalysisIssue':
          return ActivityAnalysisIssue.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ActivityCharts':
          return ActivityCharts.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ActivityFilter':
          return ActivityFilter.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ActivityHRCurve':
          return ActivityHRCurve.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ActivityHRCurvePayload':
          return ActivityHRCurvePayload.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ActivityId':
          return ActivityId.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ActivityPowerCurve':
          return ActivityPowerCurve.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ActivityPowerCurvePayload':
          return ActivityPowerCurvePayload.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ActivitySearchResult':
          return ActivitySearchResult.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ActivityStream':
          return ActivityStream.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ActivityWeather':
          return ActivityWeather.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ActivityWeatherSummary':
          return ActivityWeatherSummary.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ActivityWithIntervals':
          return ActivityWithIntervals.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Anomaly':
          return Anomaly.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ApplyPlanDTO':
          return ApplyPlanDTO.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Athlete':
          return Athlete.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AthleteConnections':
          return AthleteConnections.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AthleteForProfile':
          return AthleteForProfile.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AthleteProfile':
          return AthleteProfile.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AthleteRoute':
          return AthleteRoute.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AthleteSearchResult':
          return AthleteSearchResult.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AthleteTrainingAvailability':
          return AthleteTrainingAvailability.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AthleteTrainingPlan':
          return AthleteTrainingPlan.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AthleteTrainingPlanUpdate':
          return AthleteTrainingPlanUpdate.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AthleteUpdateDTO':
          return AthleteUpdateDTO.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'AthleteWithTags':
          return AthleteWithTags.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Attachment':
          return Attachment.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'BestEfforts':
          return BestEfforts.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Bucket':
          return Bucket.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CategorySummary':
          return CategorySummary.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Chat':
          return Chat.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ChatMember':
          return ChatMember.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Closest':
          return Closest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CoachTick':
          return CoachTick.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Course':
          return Course.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CreateFolderDTO':
          return CreateFolderDTO.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Curve':
          return Curve.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'CustomItem':
          return CustomItem.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DataCurve':
          return DataCurve.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DataCurvePt':
          return DataCurvePt.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DataCurveSetHRCurve':
          return DataCurveSetHRCurve.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DataCurveSetPaceCurve':
          return DataCurveSetPaceCurve.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DataCurveSetPowerCurve':
          return DataCurveSetPowerCurve.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DeleteEventsResponse':
          return DeleteEventsResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Display':
          return Display.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DoomedEvent':
          return DoomedEvent.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DuplicateEventsDTO':
          return DuplicateEventsDTO.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'DuplicateWorkoutsDTO':
          return DuplicateWorkoutsDTO.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Effort':
          return Effort.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Event':
          return Event.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'EventEx':
          return EventEx.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Folder':
          return Folder.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Forecast':
          return Forecast.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Gear':
          return Gear.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'GearReminder':
          return GearReminder.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'GearStats':
          return GearStats.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'GetActivityDefaultResponse':
          return GetActivityDefaultResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'HRCurve':
          return HRCurve.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'HRLoadModel':
          return HRLoadModel.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'HRRecovery':
          return HRRecovery.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Hidden':
          return Hidden.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'IcuAchievement':
          return IcuAchievement.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'IcuSegment':
          return IcuSegment.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Ignore':
          return Ignore.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Interval':
          return Interval.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'IntervalGroup':
          return IntervalGroup.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'IntervalsDTO':
          return IntervalsDTO.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'MapData':
          return MapData.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Marker':
          return Marker.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Message':
          return Message.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'NewActivityMsg':
          return NewActivityMsg.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'NewCustomItem':
          return NewCustomItem.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'NewMessage':
          return NewMessage.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'NewMsg':
          return NewMsg.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PaceCurve':
          return PaceCurve.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PaceDistancesDTO':
          return PaceDistancesDTO.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PaceModel':
          return PaceModel.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Plot':
          return Plot.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Pos':
          return Pos.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PowerCurve':
          return PowerCurve.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PowerHRCurve':
          return PowerHRCurve.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PowerModel':
          return PowerModel.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PowerVsHRPlot':
          return PowerVsHRPlot.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'PushError':
          return PushError.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Rank':
          return Rank.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'RouteSimilarity':
          return RouteSimilarity.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SendResponse':
          return SendResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Settings':
          return Settings.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SharedWith':
          return SharedWith.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SportInfo':
          return SportInfo.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SportSettings':
          return SportSettings.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'StravaGear':
          return StravaGear.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'SummaryWithCats':
          return SummaryWithCats.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Time':
          return Time.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'UpdateStreamsResult':
          return UpdateStreamsResult.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'UploadActivityRequest':
          return UploadActivityRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'UploadActivityStreamsCSVRequest':
          return UploadActivityStreamsCSVRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'UploadResponse':
          return UploadResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'UploadWellnessRequest':
          return UploadWellnessRequest.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'WeatherConfig':
          return WeatherConfig.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'WeatherDTO':
          return WeatherDTO.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'WeatherPoint':
          return WeatherPoint.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Wellness':
          return Wellness.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'WindRose':
          return WindRose.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'WithCount':
          return WithCount.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'WithCourses':
          return WithCourses.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'WithSportSettings':
          return WithSportSettings.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'Workout':
          return Workout.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'WorkoutEx':
          return WorkoutEx.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ZoneInfo':
          return ZoneInfo.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ZoneSet':
          return ZoneSet.fromJson(value as Map<String, dynamic>) as ReturnType;
        case 'ZoneTime':
          return ZoneTime.fromJson(value as Map<String, dynamic>) as ReturnType;
        default:
          RegExpMatch? match;

          if (value is List && (match = _regList.firstMatch(targetType)) != null) {
            targetType = match![1]!; // ignore: parameter_assignments
            return value
              .map<BaseType>((dynamic v) => deserialize<BaseType, BaseType>(v, targetType, growable: growable))
              .toList(growable: growable) as ReturnType;
          }
          if (value is Set && (match = _regSet.firstMatch(targetType)) != null) {
            targetType = match![1]!; // ignore: parameter_assignments
            return value
              .map<BaseType>((dynamic v) => deserialize<BaseType, BaseType>(v, targetType, growable: growable))
              .toSet() as ReturnType;
          }
          if (value is Map && (match = _regMap.firstMatch(targetType)) != null) {
            targetType = match![1]!.trim(); // ignore: parameter_assignments
            return Map<String, BaseType>.fromIterables(
              value.keys as Iterable<String>,
              value.values.map((dynamic v) => deserialize<BaseType, BaseType>(v, targetType, growable: growable)),
            ) as ReturnType;
          }
          break;
    }
    throw Exception('Cannot deserialize');
  }