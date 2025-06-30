import 'dart:async';

T get<T extends Object>()  => throw UnimplementedError();
initLocator() => throw UnimplementedError();
registerLazySingleton<T extends Object>(T Function() function)=> throw UnimplementedError();

FutureOr unregister<T extends Object>() => throw UnimplementedError();

Future<dynamic> createNativeConnection(String dbName) => throw UnimplementedError();
