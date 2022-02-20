import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

class LoggingInterceptor extends InterceptorsWrapper {
  int maxCharactersPerLine = 200;
  void printWrapped(String text) {
    final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
    pattern.allMatches(text).forEach((match) => print(match.group(0)));
  }
  @override
  Future onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    print("--> ${options.method} ${options.path}");
    // print("Headers: ${options.headers.toString()}");

    // options.headers.forEach((k, v) => print("Key : $k, Value : $v"));
    printWrapped("Headers: ${options.headers.toString()}");
    print("<-- END HTTP");

    // options.headers.forEach((k, v) {
    //   var  maintr = v.toString();
    //   for (var i=0;i<maintr.length;i++){
    //     int starts =i;
    //     var end=starts+limit;
    //     if (end > maintr.length-1){
    //       end = maintr.length-1;
    //     }
    //     print("Key : $k, Value : ${maintr.substring(starts,end)}");
    //     if (end == maintr.length-1){
    //       break;
    //     }
    //   }}

    return super.onRequest(options, handler);
  }

  @override
  Future onResponse(Response response, ResponseInterceptorHandler handler) async {
    print(
        "<-- ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.path}");

    String responseAsString = response.data.toString();

    if (responseAsString.length > maxCharactersPerLine) {
      int iterations = (responseAsString.length / maxCharactersPerLine).floor();
      for (int i = 0; i <= iterations; i++) {
        int endingIndex = i * maxCharactersPerLine + maxCharactersPerLine;
        if (endingIndex > responseAsString.length) {
          endingIndex = responseAsString.length;
        }
        print(
            responseAsString.substring(i * maxCharactersPerLine, endingIndex));
      }
    } else {
      print(response.data);
    }

    print("<-- END HTTP");

    return super.onResponse(response, handler);
  }

  @override
  Future onError(DioError err, ErrorInterceptorHandler handler) async {
    print("ERROR[${err?.response?.statusCode}] => PATH: ${err?.requestOptions?.path}");
    return super.onError(err, handler);
  }
}
