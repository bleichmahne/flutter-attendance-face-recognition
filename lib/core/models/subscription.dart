import 'package:equatable/equatable.dart';
import 'child.dart';
import 'class_model.dart';

///Swagger models.Subscription (links child to class)
class Subscription extends Equatable {
  final int? id;
  final String? activationDt;
  final int? childId;
  final int? classId;
  final String? created;
  final String? expiresDt;
  final int? ffId;
  final int? hSubscriptionStatusId;
  final bool? isImported;
  final bool? isShared;
  final String? kbUuid;
  final int? number;
  final String? updated;
  final String? vaucherActivationDt;
  final String? vaucherExpiresDt;
  final Child? child;
  final ClassModel? classModel;

  const Subscription({
    this.id,
    this.activationDt,
    this.childId,
    this.classId,
    this.created,
    this.expiresDt,
    this.ffId,
    this.hSubscriptionStatusId,
    this.isImported,
    this.isShared,
    this.kbUuid,
    this.number,
    this.updated,
    this.vaucherActivationDt,
    this.vaucherExpiresDt,
    this.child,
    this.classModel,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'] as int?,
      activationDt: json['activation_dt'] as String?,
      childId: json['child_id'] as int?,
      classId: json['class_id'] as int?,
      created: json['created'] as String?,
      expiresDt: json['expires_dt'] as String?,
      ffId: json['ff_id'] as int?,
      hSubscriptionStatusId: json['h_subscription_status_id'] as int?,
      isImported: json['is_imported'] as bool?,
      isShared: json['is_shared'] as bool?,
      kbUuid: json['kb_uuid'] as String?,
      number: json['number'] as int?,
      updated: json['updated'] as String?,
      vaucherActivationDt: json['vaucher_activation_dt'] as String?,
      vaucherExpiresDt: json['vaucher_expires_dt'] as String?,
      child: json['child'] != null
          ? Child.fromJson(json['child'] as Map<String, dynamic>)
          : null,
      classModel: json['class'] != null
          ? ClassModel.fromJson(json['class'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (activationDt != null) 'activation_dt': activationDt,
      if (childId != null) 'child_id': childId,
      if (classId != null) 'class_id': classId,
      if (created != null) 'created': created,
      if (expiresDt != null) 'expires_dt': expiresDt,
      if (ffId != null) 'ff_id': ffId,
      if (hSubscriptionStatusId != null) 'h_subscription_status_id': hSubscriptionStatusId,
      if (isImported != null) 'is_imported': isImported,
      if (isShared != null) 'is_shared': isShared,
      if (kbUuid != null) 'kb_uuid': kbUuid,
      if (number != null) 'number': number,
      if (updated != null) 'updated': updated,
      if (vaucherActivationDt != null) 'vaucher_activation_dt': vaucherActivationDt,
      if (vaucherExpiresDt != null) 'vaucher_expires_dt': vaucherExpiresDt,
      if (child != null) 'child': child?.toJson(),
      if (classModel != null) 'class': classModel?.toJson(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        activationDt,
        childId,
        classId,
        created,
        expiresDt,
        ffId,
        hSubscriptionStatusId,
        isImported,
        isShared,
        kbUuid,
        number,
        updated,
        vaucherActivationDt,
        vaucherExpiresDt,
        child,
        classModel,
      ];
}
