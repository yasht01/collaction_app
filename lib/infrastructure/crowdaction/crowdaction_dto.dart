import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/crowdaction/crowdaction.dart';

part 'crowdaction_dto.freezed.dart';
part 'crowdaction_dto.g.dart';

@freezed
abstract class CrowdActionDto implements _$CrowdActionDto {
  const CrowdActionDto._();

  factory CrowdActionDto({
    required String name,
    required String description,
    required DateTime start,
    required DateTime end,
    // TODO: Review GraphQL
    // required String title,
    // required String subtitle,
    // required String description,
    // required int numParticipants,
    // required int participantsGoal,
    // List<String>? tags,
  }) = _CrowdActionDto;

  CrowdAction toDomain() {
    return CrowdAction(
      name: name,
      description: description,
      start: start,
      end: end,
      // TODO: Review GraphQL
      // title: title,
      // subtitle: subtitle,
      // description: description,
      // numParticipants: numParticipants,
      // participantsGoal: participantsGoal,
      // tags: tags!.toList(),
    );
  }

  factory CrowdActionDto.fromJson(Map<String, dynamic> json) =>
      _$CrowdActionDtoFromJson(json);
}

@freezed
abstract class CrowdActionList implements _$CrowdActionList {
  const CrowdActionList._();

  factory CrowdActionList({
    required List<CrowdActionDto> crowdactions,
  }) = _CrowdActionList;

  factory CrowdActionList.fromJson(Map<String, dynamic> json) =>
      _$CrowdActionListFromJson(json);
}
