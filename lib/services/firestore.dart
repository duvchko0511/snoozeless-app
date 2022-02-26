import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'package:snoozeless/services/auth.dart';
import 'package:snoozeless/services/models.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<Iterable<Device>> streamDevicesList() {
    return AuthService().userStream.switchMap((user) {
      if (user != null) {
        var ref = _db.collection('users').doc(user.uid).collection('devices');
        return ref.snapshots().map(
            (event) => event.docs.map((doc) => Device.fromJson(doc.data())));
      } else {
        return Stream.fromIterable([]);
      }
    });
  }

  Stream<Device> streamDevice(String deviceId) {
    return AuthService().userStream.switchMap((user) {
      if (user != null) {
        var ref = _db
            .collection('users')
            .doc(user.uid)
            .collection('devices')
            .doc(deviceId);
        return ref.snapshots().map((doc) => Device.fromJson(doc.data()!));
      } else {
        return Stream.fromIterable([Device()]);
      }
    });
  }

  Future<Device> getDevice(String deviceId) async {
    var user = AuthService().user;
    var uid = user != null ? user.uid : '';
    var ref =
        _db.collection('users').doc(uid).collection('devices').doc(deviceId);
    var snapshot = await ref.get();
    var device = Device.fromJson(snapshot.data()!);
    return device;
  }

  Future<void> updateDevice(Device serverDevice, Device localDevice) {
    var user = AuthService().user!;
    var ref = _db
        .collection('users')
        .doc(user.uid)
        .collection('devices')
        .doc(serverDevice.deviceId);

    var data = {
      'deviceName': localDevice.deviceName,
      'timeZoneAdjustment': localDevice.timeZoneAdjustment,
    };

    return ref.update(data /*, SetOptions(merge: true)*/);
  }

  Stream<Iterable<Alarm>> streamAlarmsList(String deviceId) {
    return AuthService().userStream.switchMap((user) {
      if (user != null) {
        var ref = _db
            .collection('users')
            .doc(user.uid)
            .collection('devices')
            .doc(deviceId)
            .collection('alarms');
        return ref.snapshots().map(
            (event) => event.docs.map((doc) => Alarm.fromJson(doc.data())));
      } else {
        return Stream.fromIterable([]);
      }
    });
  }
}
