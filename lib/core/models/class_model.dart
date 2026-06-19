import 'package:equatable/equatable.dart';
import 'course.dart';

///Swagger models.Class (class_model to avoid Dart keyword)
class ClassModel extends Equatable {
  final int? id;
  final int? capacity;
  final int? childAgeFrom;
  final int? childAgeTo;
  final String? commentKz;
  final String? commentRu;
  final int? courseId;
  final String? created;
  final int? hClassTypeId;
  final String? kbUuid;
  final int? lessons;
  final String? updated;
  final Course? course;

  const ClassModel({
    this.id,
    this.capacity,
    this.childAgeFrom,
    this.childAgeTo,
    this.commentKz,
    this.commentRu,
    this.courseId,
    this.created,
    this.hClassTypeId,
    this.kbUuid,
    this.lessons,
    this.updated,
    this.course,
  });

  String get displayName => commentRu ?? commentKz ?? 'Class ${id ?? ""}';

  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(
      id: json['id'] as int?,
      capacity: json['capacity'] as int?,
      childAgeFrom: json['child_age_from'] as int?,
      childAgeTo: json['child_age_to'] as int?,
      commentKz: json['comment_kz'] as String?,
      commentRu: json['comment_ru'] as String?,
      courseId: json['course_id'] as int?,
      created: json['created'] as String?,
      hClassTypeId: json['h_class_type_id'] as int?,
      kbUuid: json['kb_uuid'] as String?,
      lessons: json['lessons'] as int?,
      updated: json['updated'] as String?,
      course: json['course'] != null
          ? Course.fromJson(json['course'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (capacity != null) 'capacity': capacity,
      if (childAgeFrom != null) 'child_age_from': childAgeFrom,
      if (childAgeTo != null) 'child_age_to': childAgeTo,
      if (commentKz != null) 'comment_kz': commentKz,
      if (commentRu != null) 'comment_ru': commentRu,
      if (courseId != null) 'course_id': courseId,
      if (created != null) 'created': created,
      if (hClassTypeId != null) 'h_class_type_id': hClassTypeId,
      if (kbUuid != null) 'kb_uuid': kbUuid,
      if (lessons != null) 'lessons': lessons,
      if (updated != null) 'updated': updated,
      if (course != null) 'course': course?.toJson(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        capacity,
        childAgeFrom,
        childAgeTo,
        commentKz,
        commentRu,
        courseId,
        created,
        hClassTypeId,
        kbUuid,
        lessons,
        updated,
        course,
      ];
}
