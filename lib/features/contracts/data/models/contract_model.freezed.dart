// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'contract_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ContractModel {

 int get id;@JsonKey(name: 'contract_number') String get contractNumber;@JsonKey(name: 'contract_type') ContractType get contractType; ContractStatus get status;@JsonKey(name: 'reservation') int? get reservationId;@JsonKey(name: 'reservation_details') ReservationDetails? get reservationDetails;@JsonKey(name: 'sale') int? get saleId;@JsonKey(name: 'sale_details') SaleDetails? get saleDetails;@JsonKey(name: 'contract_date') DateTime get contractDate;@JsonKey(name: 'contract_file') String? get contractFile;@JsonKey(name: 'signed_date') DateTime? get signedDate;@JsonKey(name: 'cancelled_date') DateTime? get cancelledDate;@JsonKey(name: 'cancellation_reason') String? get cancellationReason; String? get notes;@JsonKey(name: 'created_by') int? get createdBy;@JsonKey(name: 'created_by_name') String? get createdByName;@JsonKey(name: 'created_at') DateTime get createdAt;@JsonKey(name: 'updated_at') DateTime get updatedAt;
/// Create a copy of ContractModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContractModelCopyWith<ContractModel> get copyWith => _$ContractModelCopyWithImpl<ContractModel>(this as ContractModel, _$identity);

  /// Serializes this ContractModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContractModel&&(identical(other.id, id) || other.id == id)&&(identical(other.contractNumber, contractNumber) || other.contractNumber == contractNumber)&&(identical(other.contractType, contractType) || other.contractType == contractType)&&(identical(other.status, status) || other.status == status)&&(identical(other.reservationId, reservationId) || other.reservationId == reservationId)&&(identical(other.reservationDetails, reservationDetails) || other.reservationDetails == reservationDetails)&&(identical(other.saleId, saleId) || other.saleId == saleId)&&(identical(other.saleDetails, saleDetails) || other.saleDetails == saleDetails)&&(identical(other.contractDate, contractDate) || other.contractDate == contractDate)&&(identical(other.contractFile, contractFile) || other.contractFile == contractFile)&&(identical(other.signedDate, signedDate) || other.signedDate == signedDate)&&(identical(other.cancelledDate, cancelledDate) || other.cancelledDate == cancelledDate)&&(identical(other.cancellationReason, cancellationReason) || other.cancellationReason == cancellationReason)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.createdByName, createdByName) || other.createdByName == createdByName)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,contractNumber,contractType,status,reservationId,reservationDetails,saleId,saleDetails,contractDate,contractFile,signedDate,cancelledDate,cancellationReason,notes,createdBy,createdByName,createdAt,updatedAt);

@override
String toString() {
  return 'ContractModel(id: $id, contractNumber: $contractNumber, contractType: $contractType, status: $status, reservationId: $reservationId, reservationDetails: $reservationDetails, saleId: $saleId, saleDetails: $saleDetails, contractDate: $contractDate, contractFile: $contractFile, signedDate: $signedDate, cancelledDate: $cancelledDate, cancellationReason: $cancellationReason, notes: $notes, createdBy: $createdBy, createdByName: $createdByName, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ContractModelCopyWith<$Res>  {
  factory $ContractModelCopyWith(ContractModel value, $Res Function(ContractModel) _then) = _$ContractModelCopyWithImpl;
@useResult
$Res call({
 int id,@JsonKey(name: 'contract_number') String contractNumber,@JsonKey(name: 'contract_type') ContractType contractType, ContractStatus status,@JsonKey(name: 'reservation') int? reservationId,@JsonKey(name: 'reservation_details') ReservationDetails? reservationDetails,@JsonKey(name: 'sale') int? saleId,@JsonKey(name: 'sale_details') SaleDetails? saleDetails,@JsonKey(name: 'contract_date') DateTime contractDate,@JsonKey(name: 'contract_file') String? contractFile,@JsonKey(name: 'signed_date') DateTime? signedDate,@JsonKey(name: 'cancelled_date') DateTime? cancelledDate,@JsonKey(name: 'cancellation_reason') String? cancellationReason, String? notes,@JsonKey(name: 'created_by') int? createdBy,@JsonKey(name: 'created_by_name') String? createdByName,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt
});


$ReservationDetailsCopyWith<$Res>? get reservationDetails;$SaleDetailsCopyWith<$Res>? get saleDetails;

}
/// @nodoc
class _$ContractModelCopyWithImpl<$Res>
    implements $ContractModelCopyWith<$Res> {
  _$ContractModelCopyWithImpl(this._self, this._then);

  final ContractModel _self;
  final $Res Function(ContractModel) _then;

/// Create a copy of ContractModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? contractNumber = null,Object? contractType = null,Object? status = null,Object? reservationId = freezed,Object? reservationDetails = freezed,Object? saleId = freezed,Object? saleDetails = freezed,Object? contractDate = null,Object? contractFile = freezed,Object? signedDate = freezed,Object? cancelledDate = freezed,Object? cancellationReason = freezed,Object? notes = freezed,Object? createdBy = freezed,Object? createdByName = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,contractNumber: null == contractNumber ? _self.contractNumber : contractNumber // ignore: cast_nullable_to_non_nullable
as String,contractType: null == contractType ? _self.contractType : contractType // ignore: cast_nullable_to_non_nullable
as ContractType,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ContractStatus,reservationId: freezed == reservationId ? _self.reservationId : reservationId // ignore: cast_nullable_to_non_nullable
as int?,reservationDetails: freezed == reservationDetails ? _self.reservationDetails : reservationDetails // ignore: cast_nullable_to_non_nullable
as ReservationDetails?,saleId: freezed == saleId ? _self.saleId : saleId // ignore: cast_nullable_to_non_nullable
as int?,saleDetails: freezed == saleDetails ? _self.saleDetails : saleDetails // ignore: cast_nullable_to_non_nullable
as SaleDetails?,contractDate: null == contractDate ? _self.contractDate : contractDate // ignore: cast_nullable_to_non_nullable
as DateTime,contractFile: freezed == contractFile ? _self.contractFile : contractFile // ignore: cast_nullable_to_non_nullable
as String?,signedDate: freezed == signedDate ? _self.signedDate : signedDate // ignore: cast_nullable_to_non_nullable
as DateTime?,cancelledDate: freezed == cancelledDate ? _self.cancelledDate : cancelledDate // ignore: cast_nullable_to_non_nullable
as DateTime?,cancellationReason: freezed == cancellationReason ? _self.cancellationReason : cancellationReason // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as int?,createdByName: freezed == createdByName ? _self.createdByName : createdByName // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of ContractModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReservationDetailsCopyWith<$Res>? get reservationDetails {
    if (_self.reservationDetails == null) {
    return null;
  }

  return $ReservationDetailsCopyWith<$Res>(_self.reservationDetails!, (value) {
    return _then(_self.copyWith(reservationDetails: value));
  });
}/// Create a copy of ContractModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SaleDetailsCopyWith<$Res>? get saleDetails {
    if (_self.saleDetails == null) {
    return null;
  }

  return $SaleDetailsCopyWith<$Res>(_self.saleDetails!, (value) {
    return _then(_self.copyWith(saleDetails: value));
  });
}
}


/// Adds pattern-matching-related methods to [ContractModel].
extension ContractModelPatterns on ContractModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ContractModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ContractModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ContractModel value)  $default,){
final _that = this;
switch (_that) {
case _ContractModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ContractModel value)?  $default,){
final _that = this;
switch (_that) {
case _ContractModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id, @JsonKey(name: 'contract_number')  String contractNumber, @JsonKey(name: 'contract_type')  ContractType contractType,  ContractStatus status, @JsonKey(name: 'reservation')  int? reservationId, @JsonKey(name: 'reservation_details')  ReservationDetails? reservationDetails, @JsonKey(name: 'sale')  int? saleId, @JsonKey(name: 'sale_details')  SaleDetails? saleDetails, @JsonKey(name: 'contract_date')  DateTime contractDate, @JsonKey(name: 'contract_file')  String? contractFile, @JsonKey(name: 'signed_date')  DateTime? signedDate, @JsonKey(name: 'cancelled_date')  DateTime? cancelledDate, @JsonKey(name: 'cancellation_reason')  String? cancellationReason,  String? notes, @JsonKey(name: 'created_by')  int? createdBy, @JsonKey(name: 'created_by_name')  String? createdByName, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ContractModel() when $default != null:
return $default(_that.id,_that.contractNumber,_that.contractType,_that.status,_that.reservationId,_that.reservationDetails,_that.saleId,_that.saleDetails,_that.contractDate,_that.contractFile,_that.signedDate,_that.cancelledDate,_that.cancellationReason,_that.notes,_that.createdBy,_that.createdByName,_that.createdAt,_that.updatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id, @JsonKey(name: 'contract_number')  String contractNumber, @JsonKey(name: 'contract_type')  ContractType contractType,  ContractStatus status, @JsonKey(name: 'reservation')  int? reservationId, @JsonKey(name: 'reservation_details')  ReservationDetails? reservationDetails, @JsonKey(name: 'sale')  int? saleId, @JsonKey(name: 'sale_details')  SaleDetails? saleDetails, @JsonKey(name: 'contract_date')  DateTime contractDate, @JsonKey(name: 'contract_file')  String? contractFile, @JsonKey(name: 'signed_date')  DateTime? signedDate, @JsonKey(name: 'cancelled_date')  DateTime? cancelledDate, @JsonKey(name: 'cancellation_reason')  String? cancellationReason,  String? notes, @JsonKey(name: 'created_by')  int? createdBy, @JsonKey(name: 'created_by_name')  String? createdByName, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _ContractModel():
return $default(_that.id,_that.contractNumber,_that.contractType,_that.status,_that.reservationId,_that.reservationDetails,_that.saleId,_that.saleDetails,_that.contractDate,_that.contractFile,_that.signedDate,_that.cancelledDate,_that.cancellationReason,_that.notes,_that.createdBy,_that.createdByName,_that.createdAt,_that.updatedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id, @JsonKey(name: 'contract_number')  String contractNumber, @JsonKey(name: 'contract_type')  ContractType contractType,  ContractStatus status, @JsonKey(name: 'reservation')  int? reservationId, @JsonKey(name: 'reservation_details')  ReservationDetails? reservationDetails, @JsonKey(name: 'sale')  int? saleId, @JsonKey(name: 'sale_details')  SaleDetails? saleDetails, @JsonKey(name: 'contract_date')  DateTime contractDate, @JsonKey(name: 'contract_file')  String? contractFile, @JsonKey(name: 'signed_date')  DateTime? signedDate, @JsonKey(name: 'cancelled_date')  DateTime? cancelledDate, @JsonKey(name: 'cancellation_reason')  String? cancellationReason,  String? notes, @JsonKey(name: 'created_by')  int? createdBy, @JsonKey(name: 'created_by_name')  String? createdByName, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'updated_at')  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _ContractModel() when $default != null:
return $default(_that.id,_that.contractNumber,_that.contractType,_that.status,_that.reservationId,_that.reservationDetails,_that.saleId,_that.saleDetails,_that.contractDate,_that.contractFile,_that.signedDate,_that.cancelledDate,_that.cancellationReason,_that.notes,_that.createdBy,_that.createdByName,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ContractModel implements ContractModel {
  const _ContractModel({required this.id, @JsonKey(name: 'contract_number') required this.contractNumber, @JsonKey(name: 'contract_type') required this.contractType, required this.status, @JsonKey(name: 'reservation') this.reservationId, @JsonKey(name: 'reservation_details') this.reservationDetails, @JsonKey(name: 'sale') this.saleId, @JsonKey(name: 'sale_details') this.saleDetails, @JsonKey(name: 'contract_date') required this.contractDate, @JsonKey(name: 'contract_file') this.contractFile, @JsonKey(name: 'signed_date') this.signedDate, @JsonKey(name: 'cancelled_date') this.cancelledDate, @JsonKey(name: 'cancellation_reason') this.cancellationReason, this.notes, @JsonKey(name: 'created_by') this.createdBy, @JsonKey(name: 'created_by_name') this.createdByName, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'updated_at') required this.updatedAt});
  factory _ContractModel.fromJson(Map<String, dynamic> json) => _$ContractModelFromJson(json);

@override final  int id;
@override@JsonKey(name: 'contract_number') final  String contractNumber;
@override@JsonKey(name: 'contract_type') final  ContractType contractType;
@override final  ContractStatus status;
@override@JsonKey(name: 'reservation') final  int? reservationId;
@override@JsonKey(name: 'reservation_details') final  ReservationDetails? reservationDetails;
@override@JsonKey(name: 'sale') final  int? saleId;
@override@JsonKey(name: 'sale_details') final  SaleDetails? saleDetails;
@override@JsonKey(name: 'contract_date') final  DateTime contractDate;
@override@JsonKey(name: 'contract_file') final  String? contractFile;
@override@JsonKey(name: 'signed_date') final  DateTime? signedDate;
@override@JsonKey(name: 'cancelled_date') final  DateTime? cancelledDate;
@override@JsonKey(name: 'cancellation_reason') final  String? cancellationReason;
@override final  String? notes;
@override@JsonKey(name: 'created_by') final  int? createdBy;
@override@JsonKey(name: 'created_by_name') final  String? createdByName;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@JsonKey(name: 'updated_at') final  DateTime updatedAt;

/// Create a copy of ContractModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContractModelCopyWith<_ContractModel> get copyWith => __$ContractModelCopyWithImpl<_ContractModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ContractModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContractModel&&(identical(other.id, id) || other.id == id)&&(identical(other.contractNumber, contractNumber) || other.contractNumber == contractNumber)&&(identical(other.contractType, contractType) || other.contractType == contractType)&&(identical(other.status, status) || other.status == status)&&(identical(other.reservationId, reservationId) || other.reservationId == reservationId)&&(identical(other.reservationDetails, reservationDetails) || other.reservationDetails == reservationDetails)&&(identical(other.saleId, saleId) || other.saleId == saleId)&&(identical(other.saleDetails, saleDetails) || other.saleDetails == saleDetails)&&(identical(other.contractDate, contractDate) || other.contractDate == contractDate)&&(identical(other.contractFile, contractFile) || other.contractFile == contractFile)&&(identical(other.signedDate, signedDate) || other.signedDate == signedDate)&&(identical(other.cancelledDate, cancelledDate) || other.cancelledDate == cancelledDate)&&(identical(other.cancellationReason, cancellationReason) || other.cancellationReason == cancellationReason)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.createdByName, createdByName) || other.createdByName == createdByName)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,contractNumber,contractType,status,reservationId,reservationDetails,saleId,saleDetails,contractDate,contractFile,signedDate,cancelledDate,cancellationReason,notes,createdBy,createdByName,createdAt,updatedAt);

@override
String toString() {
  return 'ContractModel(id: $id, contractNumber: $contractNumber, contractType: $contractType, status: $status, reservationId: $reservationId, reservationDetails: $reservationDetails, saleId: $saleId, saleDetails: $saleDetails, contractDate: $contractDate, contractFile: $contractFile, signedDate: $signedDate, cancelledDate: $cancelledDate, cancellationReason: $cancellationReason, notes: $notes, createdBy: $createdBy, createdByName: $createdByName, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ContractModelCopyWith<$Res> implements $ContractModelCopyWith<$Res> {
  factory _$ContractModelCopyWith(_ContractModel value, $Res Function(_ContractModel) _then) = __$ContractModelCopyWithImpl;
@override @useResult
$Res call({
 int id,@JsonKey(name: 'contract_number') String contractNumber,@JsonKey(name: 'contract_type') ContractType contractType, ContractStatus status,@JsonKey(name: 'reservation') int? reservationId,@JsonKey(name: 'reservation_details') ReservationDetails? reservationDetails,@JsonKey(name: 'sale') int? saleId,@JsonKey(name: 'sale_details') SaleDetails? saleDetails,@JsonKey(name: 'contract_date') DateTime contractDate,@JsonKey(name: 'contract_file') String? contractFile,@JsonKey(name: 'signed_date') DateTime? signedDate,@JsonKey(name: 'cancelled_date') DateTime? cancelledDate,@JsonKey(name: 'cancellation_reason') String? cancellationReason, String? notes,@JsonKey(name: 'created_by') int? createdBy,@JsonKey(name: 'created_by_name') String? createdByName,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'updated_at') DateTime updatedAt
});


@override $ReservationDetailsCopyWith<$Res>? get reservationDetails;@override $SaleDetailsCopyWith<$Res>? get saleDetails;

}
/// @nodoc
class __$ContractModelCopyWithImpl<$Res>
    implements _$ContractModelCopyWith<$Res> {
  __$ContractModelCopyWithImpl(this._self, this._then);

  final _ContractModel _self;
  final $Res Function(_ContractModel) _then;

/// Create a copy of ContractModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? contractNumber = null,Object? contractType = null,Object? status = null,Object? reservationId = freezed,Object? reservationDetails = freezed,Object? saleId = freezed,Object? saleDetails = freezed,Object? contractDate = null,Object? contractFile = freezed,Object? signedDate = freezed,Object? cancelledDate = freezed,Object? cancellationReason = freezed,Object? notes = freezed,Object? createdBy = freezed,Object? createdByName = freezed,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_ContractModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,contractNumber: null == contractNumber ? _self.contractNumber : contractNumber // ignore: cast_nullable_to_non_nullable
as String,contractType: null == contractType ? _self.contractType : contractType // ignore: cast_nullable_to_non_nullable
as ContractType,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ContractStatus,reservationId: freezed == reservationId ? _self.reservationId : reservationId // ignore: cast_nullable_to_non_nullable
as int?,reservationDetails: freezed == reservationDetails ? _self.reservationDetails : reservationDetails // ignore: cast_nullable_to_non_nullable
as ReservationDetails?,saleId: freezed == saleId ? _self.saleId : saleId // ignore: cast_nullable_to_non_nullable
as int?,saleDetails: freezed == saleDetails ? _self.saleDetails : saleDetails // ignore: cast_nullable_to_non_nullable
as SaleDetails?,contractDate: null == contractDate ? _self.contractDate : contractDate // ignore: cast_nullable_to_non_nullable
as DateTime,contractFile: freezed == contractFile ? _self.contractFile : contractFile // ignore: cast_nullable_to_non_nullable
as String?,signedDate: freezed == signedDate ? _self.signedDate : signedDate // ignore: cast_nullable_to_non_nullable
as DateTime?,cancelledDate: freezed == cancelledDate ? _self.cancelledDate : cancelledDate // ignore: cast_nullable_to_non_nullable
as DateTime?,cancellationReason: freezed == cancellationReason ? _self.cancellationReason : cancellationReason // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as int?,createdByName: freezed == createdByName ? _self.createdByName : createdByName // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of ContractModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReservationDetailsCopyWith<$Res>? get reservationDetails {
    if (_self.reservationDetails == null) {
    return null;
  }

  return $ReservationDetailsCopyWith<$Res>(_self.reservationDetails!, (value) {
    return _then(_self.copyWith(reservationDetails: value));
  });
}/// Create a copy of ContractModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SaleDetailsCopyWith<$Res>? get saleDetails {
    if (_self.saleDetails == null) {
    return null;
  }

  return $SaleDetailsCopyWith<$Res>(_self.saleDetails!, (value) {
    return _then(_self.copyWith(saleDetails: value));
  });
}
}


/// @nodoc
mixin _$ReservationDetails {

 int get id;@JsonKey(name: 'reservation_number') String get reservationNumber;@JsonKey(name: 'customer') CustomerSummary get customer;@JsonKey(name: 'property') PropertySummary get property;@JsonKey(name: 'reservation_date') DateTime get reservationDate;@JsonKey(name: 'reservation_amount') String get reservationAmount;
/// Create a copy of ReservationDetails
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReservationDetailsCopyWith<ReservationDetails> get copyWith => _$ReservationDetailsCopyWithImpl<ReservationDetails>(this as ReservationDetails, _$identity);

  /// Serializes this ReservationDetails to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReservationDetails&&(identical(other.id, id) || other.id == id)&&(identical(other.reservationNumber, reservationNumber) || other.reservationNumber == reservationNumber)&&(identical(other.customer, customer) || other.customer == customer)&&(identical(other.property, property) || other.property == property)&&(identical(other.reservationDate, reservationDate) || other.reservationDate == reservationDate)&&(identical(other.reservationAmount, reservationAmount) || other.reservationAmount == reservationAmount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,reservationNumber,customer,property,reservationDate,reservationAmount);

@override
String toString() {
  return 'ReservationDetails(id: $id, reservationNumber: $reservationNumber, customer: $customer, property: $property, reservationDate: $reservationDate, reservationAmount: $reservationAmount)';
}


}

/// @nodoc
abstract mixin class $ReservationDetailsCopyWith<$Res>  {
  factory $ReservationDetailsCopyWith(ReservationDetails value, $Res Function(ReservationDetails) _then) = _$ReservationDetailsCopyWithImpl;
@useResult
$Res call({
 int id,@JsonKey(name: 'reservation_number') String reservationNumber,@JsonKey(name: 'customer') CustomerSummary customer,@JsonKey(name: 'property') PropertySummary property,@JsonKey(name: 'reservation_date') DateTime reservationDate,@JsonKey(name: 'reservation_amount') String reservationAmount
});


$CustomerSummaryCopyWith<$Res> get customer;$PropertySummaryCopyWith<$Res> get property;

}
/// @nodoc
class _$ReservationDetailsCopyWithImpl<$Res>
    implements $ReservationDetailsCopyWith<$Res> {
  _$ReservationDetailsCopyWithImpl(this._self, this._then);

  final ReservationDetails _self;
  final $Res Function(ReservationDetails) _then;

/// Create a copy of ReservationDetails
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? reservationNumber = null,Object? customer = null,Object? property = null,Object? reservationDate = null,Object? reservationAmount = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,reservationNumber: null == reservationNumber ? _self.reservationNumber : reservationNumber // ignore: cast_nullable_to_non_nullable
as String,customer: null == customer ? _self.customer : customer // ignore: cast_nullable_to_non_nullable
as CustomerSummary,property: null == property ? _self.property : property // ignore: cast_nullable_to_non_nullable
as PropertySummary,reservationDate: null == reservationDate ? _self.reservationDate : reservationDate // ignore: cast_nullable_to_non_nullable
as DateTime,reservationAmount: null == reservationAmount ? _self.reservationAmount : reservationAmount // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of ReservationDetails
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CustomerSummaryCopyWith<$Res> get customer {
  
  return $CustomerSummaryCopyWith<$Res>(_self.customer, (value) {
    return _then(_self.copyWith(customer: value));
  });
}/// Create a copy of ReservationDetails
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PropertySummaryCopyWith<$Res> get property {
  
  return $PropertySummaryCopyWith<$Res>(_self.property, (value) {
    return _then(_self.copyWith(property: value));
  });
}
}


/// Adds pattern-matching-related methods to [ReservationDetails].
extension ReservationDetailsPatterns on ReservationDetails {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReservationDetails value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReservationDetails() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReservationDetails value)  $default,){
final _that = this;
switch (_that) {
case _ReservationDetails():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReservationDetails value)?  $default,){
final _that = this;
switch (_that) {
case _ReservationDetails() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id, @JsonKey(name: 'reservation_number')  String reservationNumber, @JsonKey(name: 'customer')  CustomerSummary customer, @JsonKey(name: 'property')  PropertySummary property, @JsonKey(name: 'reservation_date')  DateTime reservationDate, @JsonKey(name: 'reservation_amount')  String reservationAmount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReservationDetails() when $default != null:
return $default(_that.id,_that.reservationNumber,_that.customer,_that.property,_that.reservationDate,_that.reservationAmount);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id, @JsonKey(name: 'reservation_number')  String reservationNumber, @JsonKey(name: 'customer')  CustomerSummary customer, @JsonKey(name: 'property')  PropertySummary property, @JsonKey(name: 'reservation_date')  DateTime reservationDate, @JsonKey(name: 'reservation_amount')  String reservationAmount)  $default,) {final _that = this;
switch (_that) {
case _ReservationDetails():
return $default(_that.id,_that.reservationNumber,_that.customer,_that.property,_that.reservationDate,_that.reservationAmount);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id, @JsonKey(name: 'reservation_number')  String reservationNumber, @JsonKey(name: 'customer')  CustomerSummary customer, @JsonKey(name: 'property')  PropertySummary property, @JsonKey(name: 'reservation_date')  DateTime reservationDate, @JsonKey(name: 'reservation_amount')  String reservationAmount)?  $default,) {final _that = this;
switch (_that) {
case _ReservationDetails() when $default != null:
return $default(_that.id,_that.reservationNumber,_that.customer,_that.property,_that.reservationDate,_that.reservationAmount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReservationDetails implements ReservationDetails {
  const _ReservationDetails({required this.id, @JsonKey(name: 'reservation_number') required this.reservationNumber, @JsonKey(name: 'customer') required this.customer, @JsonKey(name: 'property') required this.property, @JsonKey(name: 'reservation_date') required this.reservationDate, @JsonKey(name: 'reservation_amount') required this.reservationAmount});
  factory _ReservationDetails.fromJson(Map<String, dynamic> json) => _$ReservationDetailsFromJson(json);

@override final  int id;
@override@JsonKey(name: 'reservation_number') final  String reservationNumber;
@override@JsonKey(name: 'customer') final  CustomerSummary customer;
@override@JsonKey(name: 'property') final  PropertySummary property;
@override@JsonKey(name: 'reservation_date') final  DateTime reservationDate;
@override@JsonKey(name: 'reservation_amount') final  String reservationAmount;

/// Create a copy of ReservationDetails
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReservationDetailsCopyWith<_ReservationDetails> get copyWith => __$ReservationDetailsCopyWithImpl<_ReservationDetails>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReservationDetailsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReservationDetails&&(identical(other.id, id) || other.id == id)&&(identical(other.reservationNumber, reservationNumber) || other.reservationNumber == reservationNumber)&&(identical(other.customer, customer) || other.customer == customer)&&(identical(other.property, property) || other.property == property)&&(identical(other.reservationDate, reservationDate) || other.reservationDate == reservationDate)&&(identical(other.reservationAmount, reservationAmount) || other.reservationAmount == reservationAmount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,reservationNumber,customer,property,reservationDate,reservationAmount);

@override
String toString() {
  return 'ReservationDetails(id: $id, reservationNumber: $reservationNumber, customer: $customer, property: $property, reservationDate: $reservationDate, reservationAmount: $reservationAmount)';
}


}

/// @nodoc
abstract mixin class _$ReservationDetailsCopyWith<$Res> implements $ReservationDetailsCopyWith<$Res> {
  factory _$ReservationDetailsCopyWith(_ReservationDetails value, $Res Function(_ReservationDetails) _then) = __$ReservationDetailsCopyWithImpl;
@override @useResult
$Res call({
 int id,@JsonKey(name: 'reservation_number') String reservationNumber,@JsonKey(name: 'customer') CustomerSummary customer,@JsonKey(name: 'property') PropertySummary property,@JsonKey(name: 'reservation_date') DateTime reservationDate,@JsonKey(name: 'reservation_amount') String reservationAmount
});


@override $CustomerSummaryCopyWith<$Res> get customer;@override $PropertySummaryCopyWith<$Res> get property;

}
/// @nodoc
class __$ReservationDetailsCopyWithImpl<$Res>
    implements _$ReservationDetailsCopyWith<$Res> {
  __$ReservationDetailsCopyWithImpl(this._self, this._then);

  final _ReservationDetails _self;
  final $Res Function(_ReservationDetails) _then;

/// Create a copy of ReservationDetails
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? reservationNumber = null,Object? customer = null,Object? property = null,Object? reservationDate = null,Object? reservationAmount = null,}) {
  return _then(_ReservationDetails(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,reservationNumber: null == reservationNumber ? _self.reservationNumber : reservationNumber // ignore: cast_nullable_to_non_nullable
as String,customer: null == customer ? _self.customer : customer // ignore: cast_nullable_to_non_nullable
as CustomerSummary,property: null == property ? _self.property : property // ignore: cast_nullable_to_non_nullable
as PropertySummary,reservationDate: null == reservationDate ? _self.reservationDate : reservationDate // ignore: cast_nullable_to_non_nullable
as DateTime,reservationAmount: null == reservationAmount ? _self.reservationAmount : reservationAmount // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of ReservationDetails
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CustomerSummaryCopyWith<$Res> get customer {
  
  return $CustomerSummaryCopyWith<$Res>(_self.customer, (value) {
    return _then(_self.copyWith(customer: value));
  });
}/// Create a copy of ReservationDetails
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PropertySummaryCopyWith<$Res> get property {
  
  return $PropertySummaryCopyWith<$Res>(_self.property, (value) {
    return _then(_self.copyWith(property: value));
  });
}
}


/// @nodoc
mixin _$SaleDetails {

 int get id;@JsonKey(name: 'sale_number') String get saleNumber;@JsonKey(name: 'customer') CustomerSummary get customer;@JsonKey(name: 'property') PropertySummary get property;@JsonKey(name: 'sale_date') DateTime get saleDate;@JsonKey(name: 'sale_price') String get salePrice;@JsonKey(name: 'payment_plan') String get paymentPlan;
/// Create a copy of SaleDetails
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SaleDetailsCopyWith<SaleDetails> get copyWith => _$SaleDetailsCopyWithImpl<SaleDetails>(this as SaleDetails, _$identity);

  /// Serializes this SaleDetails to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SaleDetails&&(identical(other.id, id) || other.id == id)&&(identical(other.saleNumber, saleNumber) || other.saleNumber == saleNumber)&&(identical(other.customer, customer) || other.customer == customer)&&(identical(other.property, property) || other.property == property)&&(identical(other.saleDate, saleDate) || other.saleDate == saleDate)&&(identical(other.salePrice, salePrice) || other.salePrice == salePrice)&&(identical(other.paymentPlan, paymentPlan) || other.paymentPlan == paymentPlan));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,saleNumber,customer,property,saleDate,salePrice,paymentPlan);

@override
String toString() {
  return 'SaleDetails(id: $id, saleNumber: $saleNumber, customer: $customer, property: $property, saleDate: $saleDate, salePrice: $salePrice, paymentPlan: $paymentPlan)';
}


}

/// @nodoc
abstract mixin class $SaleDetailsCopyWith<$Res>  {
  factory $SaleDetailsCopyWith(SaleDetails value, $Res Function(SaleDetails) _then) = _$SaleDetailsCopyWithImpl;
@useResult
$Res call({
 int id,@JsonKey(name: 'sale_number') String saleNumber,@JsonKey(name: 'customer') CustomerSummary customer,@JsonKey(name: 'property') PropertySummary property,@JsonKey(name: 'sale_date') DateTime saleDate,@JsonKey(name: 'sale_price') String salePrice,@JsonKey(name: 'payment_plan') String paymentPlan
});


$CustomerSummaryCopyWith<$Res> get customer;$PropertySummaryCopyWith<$Res> get property;

}
/// @nodoc
class _$SaleDetailsCopyWithImpl<$Res>
    implements $SaleDetailsCopyWith<$Res> {
  _$SaleDetailsCopyWithImpl(this._self, this._then);

  final SaleDetails _self;
  final $Res Function(SaleDetails) _then;

/// Create a copy of SaleDetails
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? saleNumber = null,Object? customer = null,Object? property = null,Object? saleDate = null,Object? salePrice = null,Object? paymentPlan = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,saleNumber: null == saleNumber ? _self.saleNumber : saleNumber // ignore: cast_nullable_to_non_nullable
as String,customer: null == customer ? _self.customer : customer // ignore: cast_nullable_to_non_nullable
as CustomerSummary,property: null == property ? _self.property : property // ignore: cast_nullable_to_non_nullable
as PropertySummary,saleDate: null == saleDate ? _self.saleDate : saleDate // ignore: cast_nullable_to_non_nullable
as DateTime,salePrice: null == salePrice ? _self.salePrice : salePrice // ignore: cast_nullable_to_non_nullable
as String,paymentPlan: null == paymentPlan ? _self.paymentPlan : paymentPlan // ignore: cast_nullable_to_non_nullable
as String,
  ));
}
/// Create a copy of SaleDetails
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CustomerSummaryCopyWith<$Res> get customer {
  
  return $CustomerSummaryCopyWith<$Res>(_self.customer, (value) {
    return _then(_self.copyWith(customer: value));
  });
}/// Create a copy of SaleDetails
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PropertySummaryCopyWith<$Res> get property {
  
  return $PropertySummaryCopyWith<$Res>(_self.property, (value) {
    return _then(_self.copyWith(property: value));
  });
}
}


/// Adds pattern-matching-related methods to [SaleDetails].
extension SaleDetailsPatterns on SaleDetails {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SaleDetails value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SaleDetails() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SaleDetails value)  $default,){
final _that = this;
switch (_that) {
case _SaleDetails():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SaleDetails value)?  $default,){
final _that = this;
switch (_that) {
case _SaleDetails() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id, @JsonKey(name: 'sale_number')  String saleNumber, @JsonKey(name: 'customer')  CustomerSummary customer, @JsonKey(name: 'property')  PropertySummary property, @JsonKey(name: 'sale_date')  DateTime saleDate, @JsonKey(name: 'sale_price')  String salePrice, @JsonKey(name: 'payment_plan')  String paymentPlan)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SaleDetails() when $default != null:
return $default(_that.id,_that.saleNumber,_that.customer,_that.property,_that.saleDate,_that.salePrice,_that.paymentPlan);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id, @JsonKey(name: 'sale_number')  String saleNumber, @JsonKey(name: 'customer')  CustomerSummary customer, @JsonKey(name: 'property')  PropertySummary property, @JsonKey(name: 'sale_date')  DateTime saleDate, @JsonKey(name: 'sale_price')  String salePrice, @JsonKey(name: 'payment_plan')  String paymentPlan)  $default,) {final _that = this;
switch (_that) {
case _SaleDetails():
return $default(_that.id,_that.saleNumber,_that.customer,_that.property,_that.saleDate,_that.salePrice,_that.paymentPlan);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id, @JsonKey(name: 'sale_number')  String saleNumber, @JsonKey(name: 'customer')  CustomerSummary customer, @JsonKey(name: 'property')  PropertySummary property, @JsonKey(name: 'sale_date')  DateTime saleDate, @JsonKey(name: 'sale_price')  String salePrice, @JsonKey(name: 'payment_plan')  String paymentPlan)?  $default,) {final _that = this;
switch (_that) {
case _SaleDetails() when $default != null:
return $default(_that.id,_that.saleNumber,_that.customer,_that.property,_that.saleDate,_that.salePrice,_that.paymentPlan);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SaleDetails implements SaleDetails {
  const _SaleDetails({required this.id, @JsonKey(name: 'sale_number') required this.saleNumber, @JsonKey(name: 'customer') required this.customer, @JsonKey(name: 'property') required this.property, @JsonKey(name: 'sale_date') required this.saleDate, @JsonKey(name: 'sale_price') required this.salePrice, @JsonKey(name: 'payment_plan') required this.paymentPlan});
  factory _SaleDetails.fromJson(Map<String, dynamic> json) => _$SaleDetailsFromJson(json);

@override final  int id;
@override@JsonKey(name: 'sale_number') final  String saleNumber;
@override@JsonKey(name: 'customer') final  CustomerSummary customer;
@override@JsonKey(name: 'property') final  PropertySummary property;
@override@JsonKey(name: 'sale_date') final  DateTime saleDate;
@override@JsonKey(name: 'sale_price') final  String salePrice;
@override@JsonKey(name: 'payment_plan') final  String paymentPlan;

/// Create a copy of SaleDetails
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SaleDetailsCopyWith<_SaleDetails> get copyWith => __$SaleDetailsCopyWithImpl<_SaleDetails>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SaleDetailsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SaleDetails&&(identical(other.id, id) || other.id == id)&&(identical(other.saleNumber, saleNumber) || other.saleNumber == saleNumber)&&(identical(other.customer, customer) || other.customer == customer)&&(identical(other.property, property) || other.property == property)&&(identical(other.saleDate, saleDate) || other.saleDate == saleDate)&&(identical(other.salePrice, salePrice) || other.salePrice == salePrice)&&(identical(other.paymentPlan, paymentPlan) || other.paymentPlan == paymentPlan));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,saleNumber,customer,property,saleDate,salePrice,paymentPlan);

@override
String toString() {
  return 'SaleDetails(id: $id, saleNumber: $saleNumber, customer: $customer, property: $property, saleDate: $saleDate, salePrice: $salePrice, paymentPlan: $paymentPlan)';
}


}

/// @nodoc
abstract mixin class _$SaleDetailsCopyWith<$Res> implements $SaleDetailsCopyWith<$Res> {
  factory _$SaleDetailsCopyWith(_SaleDetails value, $Res Function(_SaleDetails) _then) = __$SaleDetailsCopyWithImpl;
@override @useResult
$Res call({
 int id,@JsonKey(name: 'sale_number') String saleNumber,@JsonKey(name: 'customer') CustomerSummary customer,@JsonKey(name: 'property') PropertySummary property,@JsonKey(name: 'sale_date') DateTime saleDate,@JsonKey(name: 'sale_price') String salePrice,@JsonKey(name: 'payment_plan') String paymentPlan
});


@override $CustomerSummaryCopyWith<$Res> get customer;@override $PropertySummaryCopyWith<$Res> get property;

}
/// @nodoc
class __$SaleDetailsCopyWithImpl<$Res>
    implements _$SaleDetailsCopyWith<$Res> {
  __$SaleDetailsCopyWithImpl(this._self, this._then);

  final _SaleDetails _self;
  final $Res Function(_SaleDetails) _then;

/// Create a copy of SaleDetails
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? saleNumber = null,Object? customer = null,Object? property = null,Object? saleDate = null,Object? salePrice = null,Object? paymentPlan = null,}) {
  return _then(_SaleDetails(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,saleNumber: null == saleNumber ? _self.saleNumber : saleNumber // ignore: cast_nullable_to_non_nullable
as String,customer: null == customer ? _self.customer : customer // ignore: cast_nullable_to_non_nullable
as CustomerSummary,property: null == property ? _self.property : property // ignore: cast_nullable_to_non_nullable
as PropertySummary,saleDate: null == saleDate ? _self.saleDate : saleDate // ignore: cast_nullable_to_non_nullable
as DateTime,salePrice: null == salePrice ? _self.salePrice : salePrice // ignore: cast_nullable_to_non_nullable
as String,paymentPlan: null == paymentPlan ? _self.paymentPlan : paymentPlan // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

/// Create a copy of SaleDetails
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CustomerSummaryCopyWith<$Res> get customer {
  
  return $CustomerSummaryCopyWith<$Res>(_self.customer, (value) {
    return _then(_self.copyWith(customer: value));
  });
}/// Create a copy of SaleDetails
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PropertySummaryCopyWith<$Res> get property {
  
  return $PropertySummaryCopyWith<$Res>(_self.property, (value) {
    return _then(_self.copyWith(property: value));
  });
}
}


/// @nodoc
mixin _$CustomerSummary {

 int get id;@JsonKey(name: 'full_name') String get fullName; String? get phone; String? get email;
/// Create a copy of CustomerSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CustomerSummaryCopyWith<CustomerSummary> get copyWith => _$CustomerSummaryCopyWithImpl<CustomerSummary>(this as CustomerSummary, _$identity);

  /// Serializes this CustomerSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CustomerSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fullName,phone,email);

@override
String toString() {
  return 'CustomerSummary(id: $id, fullName: $fullName, phone: $phone, email: $email)';
}


}

/// @nodoc
abstract mixin class $CustomerSummaryCopyWith<$Res>  {
  factory $CustomerSummaryCopyWith(CustomerSummary value, $Res Function(CustomerSummary) _then) = _$CustomerSummaryCopyWithImpl;
@useResult
$Res call({
 int id,@JsonKey(name: 'full_name') String fullName, String? phone, String? email
});




}
/// @nodoc
class _$CustomerSummaryCopyWithImpl<$Res>
    implements $CustomerSummaryCopyWith<$Res> {
  _$CustomerSummaryCopyWithImpl(this._self, this._then);

  final CustomerSummary _self;
  final $Res Function(CustomerSummary) _then;

/// Create a copy of CustomerSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? fullName = null,Object? phone = freezed,Object? email = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CustomerSummary].
extension CustomerSummaryPatterns on CustomerSummary {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CustomerSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CustomerSummary() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CustomerSummary value)  $default,){
final _that = this;
switch (_that) {
case _CustomerSummary():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CustomerSummary value)?  $default,){
final _that = this;
switch (_that) {
case _CustomerSummary() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id, @JsonKey(name: 'full_name')  String fullName,  String? phone,  String? email)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CustomerSummary() when $default != null:
return $default(_that.id,_that.fullName,_that.phone,_that.email);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id, @JsonKey(name: 'full_name')  String fullName,  String? phone,  String? email)  $default,) {final _that = this;
switch (_that) {
case _CustomerSummary():
return $default(_that.id,_that.fullName,_that.phone,_that.email);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id, @JsonKey(name: 'full_name')  String fullName,  String? phone,  String? email)?  $default,) {final _that = this;
switch (_that) {
case _CustomerSummary() when $default != null:
return $default(_that.id,_that.fullName,_that.phone,_that.email);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CustomerSummary implements CustomerSummary {
  const _CustomerSummary({required this.id, @JsonKey(name: 'full_name') required this.fullName, this.phone, this.email});
  factory _CustomerSummary.fromJson(Map<String, dynamic> json) => _$CustomerSummaryFromJson(json);

@override final  int id;
@override@JsonKey(name: 'full_name') final  String fullName;
@override final  String? phone;
@override final  String? email;

/// Create a copy of CustomerSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CustomerSummaryCopyWith<_CustomerSummary> get copyWith => __$CustomerSummaryCopyWithImpl<_CustomerSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CustomerSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CustomerSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.email, email) || other.email == email));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,fullName,phone,email);

@override
String toString() {
  return 'CustomerSummary(id: $id, fullName: $fullName, phone: $phone, email: $email)';
}


}

/// @nodoc
abstract mixin class _$CustomerSummaryCopyWith<$Res> implements $CustomerSummaryCopyWith<$Res> {
  factory _$CustomerSummaryCopyWith(_CustomerSummary value, $Res Function(_CustomerSummary) _then) = __$CustomerSummaryCopyWithImpl;
@override @useResult
$Res call({
 int id,@JsonKey(name: 'full_name') String fullName, String? phone, String? email
});




}
/// @nodoc
class __$CustomerSummaryCopyWithImpl<$Res>
    implements _$CustomerSummaryCopyWith<$Res> {
  __$CustomerSummaryCopyWithImpl(this._self, this._then);

  final _CustomerSummary _self;
  final $Res Function(_CustomerSummary) _then;

/// Create a copy of CustomerSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fullName = null,Object? phone = freezed,Object? email = freezed,}) {
  return _then(_CustomerSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$PropertySummary {

 int get id; String get title;@JsonKey(name: 'property_type') String get propertyType;@JsonKey(name: 'block_number') String? get blockNumber;@JsonKey(name: 'floor_number') int? get floorNumber;@JsonKey(name: 'apartment_number') String? get apartmentNumber;
/// Create a copy of PropertySummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PropertySummaryCopyWith<PropertySummary> get copyWith => _$PropertySummaryCopyWithImpl<PropertySummary>(this as PropertySummary, _$identity);

  /// Serializes this PropertySummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PropertySummary&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.propertyType, propertyType) || other.propertyType == propertyType)&&(identical(other.blockNumber, blockNumber) || other.blockNumber == blockNumber)&&(identical(other.floorNumber, floorNumber) || other.floorNumber == floorNumber)&&(identical(other.apartmentNumber, apartmentNumber) || other.apartmentNumber == apartmentNumber));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,propertyType,blockNumber,floorNumber,apartmentNumber);

@override
String toString() {
  return 'PropertySummary(id: $id, title: $title, propertyType: $propertyType, blockNumber: $blockNumber, floorNumber: $floorNumber, apartmentNumber: $apartmentNumber)';
}


}

/// @nodoc
abstract mixin class $PropertySummaryCopyWith<$Res>  {
  factory $PropertySummaryCopyWith(PropertySummary value, $Res Function(PropertySummary) _then) = _$PropertySummaryCopyWithImpl;
@useResult
$Res call({
 int id, String title,@JsonKey(name: 'property_type') String propertyType,@JsonKey(name: 'block_number') String? blockNumber,@JsonKey(name: 'floor_number') int? floorNumber,@JsonKey(name: 'apartment_number') String? apartmentNumber
});




}
/// @nodoc
class _$PropertySummaryCopyWithImpl<$Res>
    implements $PropertySummaryCopyWith<$Res> {
  _$PropertySummaryCopyWithImpl(this._self, this._then);

  final PropertySummary _self;
  final $Res Function(PropertySummary) _then;

/// Create a copy of PropertySummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? propertyType = null,Object? blockNumber = freezed,Object? floorNumber = freezed,Object? apartmentNumber = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,propertyType: null == propertyType ? _self.propertyType : propertyType // ignore: cast_nullable_to_non_nullable
as String,blockNumber: freezed == blockNumber ? _self.blockNumber : blockNumber // ignore: cast_nullable_to_non_nullable
as String?,floorNumber: freezed == floorNumber ? _self.floorNumber : floorNumber // ignore: cast_nullable_to_non_nullable
as int?,apartmentNumber: freezed == apartmentNumber ? _self.apartmentNumber : apartmentNumber // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PropertySummary].
extension PropertySummaryPatterns on PropertySummary {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PropertySummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PropertySummary() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PropertySummary value)  $default,){
final _that = this;
switch (_that) {
case _PropertySummary():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PropertySummary value)?  $default,){
final _that = this;
switch (_that) {
case _PropertySummary() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String title, @JsonKey(name: 'property_type')  String propertyType, @JsonKey(name: 'block_number')  String? blockNumber, @JsonKey(name: 'floor_number')  int? floorNumber, @JsonKey(name: 'apartment_number')  String? apartmentNumber)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PropertySummary() when $default != null:
return $default(_that.id,_that.title,_that.propertyType,_that.blockNumber,_that.floorNumber,_that.apartmentNumber);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String title, @JsonKey(name: 'property_type')  String propertyType, @JsonKey(name: 'block_number')  String? blockNumber, @JsonKey(name: 'floor_number')  int? floorNumber, @JsonKey(name: 'apartment_number')  String? apartmentNumber)  $default,) {final _that = this;
switch (_that) {
case _PropertySummary():
return $default(_that.id,_that.title,_that.propertyType,_that.blockNumber,_that.floorNumber,_that.apartmentNumber);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String title, @JsonKey(name: 'property_type')  String propertyType, @JsonKey(name: 'block_number')  String? blockNumber, @JsonKey(name: 'floor_number')  int? floorNumber, @JsonKey(name: 'apartment_number')  String? apartmentNumber)?  $default,) {final _that = this;
switch (_that) {
case _PropertySummary() when $default != null:
return $default(_that.id,_that.title,_that.propertyType,_that.blockNumber,_that.floorNumber,_that.apartmentNumber);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PropertySummary implements PropertySummary {
  const _PropertySummary({required this.id, required this.title, @JsonKey(name: 'property_type') required this.propertyType, @JsonKey(name: 'block_number') this.blockNumber, @JsonKey(name: 'floor_number') this.floorNumber, @JsonKey(name: 'apartment_number') this.apartmentNumber});
  factory _PropertySummary.fromJson(Map<String, dynamic> json) => _$PropertySummaryFromJson(json);

@override final  int id;
@override final  String title;
@override@JsonKey(name: 'property_type') final  String propertyType;
@override@JsonKey(name: 'block_number') final  String? blockNumber;
@override@JsonKey(name: 'floor_number') final  int? floorNumber;
@override@JsonKey(name: 'apartment_number') final  String? apartmentNumber;

/// Create a copy of PropertySummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PropertySummaryCopyWith<_PropertySummary> get copyWith => __$PropertySummaryCopyWithImpl<_PropertySummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PropertySummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PropertySummary&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.propertyType, propertyType) || other.propertyType == propertyType)&&(identical(other.blockNumber, blockNumber) || other.blockNumber == blockNumber)&&(identical(other.floorNumber, floorNumber) || other.floorNumber == floorNumber)&&(identical(other.apartmentNumber, apartmentNumber) || other.apartmentNumber == apartmentNumber));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,propertyType,blockNumber,floorNumber,apartmentNumber);

@override
String toString() {
  return 'PropertySummary(id: $id, title: $title, propertyType: $propertyType, blockNumber: $blockNumber, floorNumber: $floorNumber, apartmentNumber: $apartmentNumber)';
}


}

/// @nodoc
abstract mixin class _$PropertySummaryCopyWith<$Res> implements $PropertySummaryCopyWith<$Res> {
  factory _$PropertySummaryCopyWith(_PropertySummary value, $Res Function(_PropertySummary) _then) = __$PropertySummaryCopyWithImpl;
@override @useResult
$Res call({
 int id, String title,@JsonKey(name: 'property_type') String propertyType,@JsonKey(name: 'block_number') String? blockNumber,@JsonKey(name: 'floor_number') int? floorNumber,@JsonKey(name: 'apartment_number') String? apartmentNumber
});




}
/// @nodoc
class __$PropertySummaryCopyWithImpl<$Res>
    implements _$PropertySummaryCopyWith<$Res> {
  __$PropertySummaryCopyWithImpl(this._self, this._then);

  final _PropertySummary _self;
  final $Res Function(_PropertySummary) _then;

/// Create a copy of PropertySummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? propertyType = null,Object? blockNumber = freezed,Object? floorNumber = freezed,Object? apartmentNumber = freezed,}) {
  return _then(_PropertySummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,propertyType: null == propertyType ? _self.propertyType : propertyType // ignore: cast_nullable_to_non_nullable
as String,blockNumber: freezed == blockNumber ? _self.blockNumber : blockNumber // ignore: cast_nullable_to_non_nullable
as String?,floorNumber: freezed == floorNumber ? _self.floorNumber : floorNumber // ignore: cast_nullable_to_non_nullable
as int?,apartmentNumber: freezed == apartmentNumber ? _self.apartmentNumber : apartmentNumber // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
