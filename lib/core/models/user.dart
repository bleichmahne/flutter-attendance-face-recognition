import 'package:equatable/equatable.dart';
import 'organization.dart';

//swagger: /users, /auth/users
//note: swagger doesn't document 'name' field but server returns it
class User extends Equatable {
  final int? id;
  final String kbUuid;
  final String name;
  final String username;
  final int organizationId;
  final Organization? organization;
  final String? created;
  final String? updated;

  const User({
    this.id,
    required this.kbUuid,
    required this.name,
    required this.username,
    required this.organizationId,
    this.organization,
    this.created,
    this.updated,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    //handle organization_id as either int or string UUID
    int organizationId = 0;
    final orgIdValue = json['organization_id'];
    if (orgIdValue is int) {
      organizationId = orgIdValue;
    } else if (orgIdValue is String) {
      if (json['organization'] != null) {
        final org = json['organization'] as Map<String, dynamic>;
        if (org['id'] != null) {
          organizationId = org['id'] is int
              ? org['id'] as int
              : (int.tryParse(org['id'].toString()) ?? 0);
        }
      }
    }

    return User(
      id: json['id'] as int?,
      kbUuid: (json['kb_uuid'] ?? json['uuid'] ?? '') as String,
      name: (json['name'] ?? json['username'] ?? '') as String,
      username: (json['username'] ?? '') as String,
      organizationId: organizationId,
      organization: json['organization'] != null
          ? Organization.fromJson(json['organization'] as Map<String, dynamic>)
          : null,
      created: json['created'] as String?,
      updated: json['updated'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'kb_uuid': kbUuid,
      'name': name,
      'username': username,
      'organization_id': organizationId,
      if (organization != null) 'organization': organization!.toJson(),
      if (created != null) 'created': created,
      if (updated != null) 'updated': updated,
    };
  }

  @override
  List<Object?> get props => [id, kbUuid, name, username, organizationId, organization, created, updated];
}
