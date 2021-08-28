import 'dart:async';

import 'package:collaction_app/domain/user/i_user_repository.dart';
import 'package:collaction_app/domain/user/user.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: IUserRepository)
class UserRepository implements IUserRepository, Disposable {
  late final firebase_auth.FirebaseAuth _firebaseAuth;

  UserRepository({firebase_auth.FirebaseAuth? firebaseAuth}) {
    _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance;
    _userStreamController.sink.add(User.anonymous);
    _firebaseAuth
        .authStateChanges()
        .map(_firebaseUserToUser)
        .listen(_userStreamController.sink.add);
  }

  static User _firebaseUserToUser(firebase_auth.User? firebaseUser) {
    if (firebaseUser == null || firebaseUser.isAnonymous) {
      return User.anonymous;
    } else {
      return User(
        id: firebaseUser.uid,
        displayName: firebaseUser.displayName,
        phoneNumber: firebaseUser.phoneNumber,
        isPhoneNumberVerified: firebaseUser.phoneNumber != null,
        email: firebaseUser.email,
        isEmailVerified: firebaseUser.emailVerified,
        photoURL: firebaseUser.photoURL,
        getIdToken: firebaseUser.getIdToken,
      );
    }
  }

  final _userStreamController = StreamController<User>();

  @override
  Stream<User> observeUser() => _userStreamController.stream;

  @override
  Stream<Credential> registerPhoneNumber(String phoneNumber) {
    final result = StreamController<Credential>();
    _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (credential) {
          result.add(Credential(credential.verificationId, credential.smsCode));
          result.close();
        },
        verificationFailed: (e) {
          result.addError(e); // TODO map error to non-firebase exception (?)
          result.close();
        },
        codeSent: (verificationId, resendToken) {
          result.add(Credential(verificationId, null));
        },
        codeAutoRetrievalTimeout: (_) => result.close());
    return result.stream;
  }

  @override
  Future<SignInResult> signIn(Credential credential) async {
    assert(credential.verificationId != null);
    assert(credential.smsCode != null);
    final firebaseCredential = firebase_auth.PhoneAuthProvider.credential(
        verificationId: credential.verificationId!,
        smsCode: credential.smsCode!);
    final userCredential = await _firebaseAuth.signInWithCredential(
        firebaseCredential); // TODO map error to non-firebase exception (?)
    final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
    return SignInResult(isNewUser: isNewUser);
  }

  @override
  FutureOr onDispose() {
    _userStreamController.close();
  }
}