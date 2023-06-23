import 'package:dio/dio.dart' hide Headers;
import 'package:mealup_driver/util/constants.dart';

class ServerError implements Exception {
  int? _errorCode;
  String _errorMessage = "";

  ServerError.withError({error}) {
    _handleError(error);
  }

  getErrorCode() {
    return _errorCode;
  }

  getErrorMessage() {
    return _errorMessage;
  }

  _handleError(DioError error) {
    switch (error.type) {
      case DioErrorType.connectTimeout:
        _errorMessage = "Connection timeout";
        Constants.toastMessage('Connection timeout');
        break;
      case DioErrorType.sendTimeout:
        _errorMessage = "Receive timeout in send request";
        Constants.toastMessage('Receive timeout in send request');
        break;
      case DioErrorType.receiveTimeout:
        _errorMessage = "Receive timeout in connection";
        Constants.toastMessage('Receive timeout in connection');
        break;
      case DioErrorType.response:
        _errorMessage = "Received invalid status code: ${error.response!.data}";
        try {
          if (error.response!.data['errors']['name'] != null) {
            Constants.toastMessage(error.response!.data['errors']['name'][0]);
            return;
          } else if (error.response!.data['errors']['phone'] != null) {
            Constants.toastMessage(error.response!.data['errors']['phone'][0]);
            return;
          } else if (error.response!.data['errors']['email_id'] != null) {
            Constants.toastMessage(error.response!.data['errors']['email_id'][0]);
            return;
          } else if (error.response!.data['errors']['password'] != null) {
            Constants.toastMessage(error.response!.data['errors']['password'][0]);
            return;
          } else if (error.response!.data['errors']['vendor_own_driver'] != null) {
            Constants.toastMessage(error.response!.data['errors']['vendor_own_driver'][0]);
            return;
          } else if (error.response!.data['errors']['phone_code'] != null) {
            Constants.toastMessage(error.response!.data['errors']['phone_code'][0]);
            return;
          } else {
            Constants.toastMessage(error.response!.data['message'].toString());
            return;
          }
        } catch (error1, stacktrace) {
          try {
            Constants.toastMessage(error.response!.data['message'].toString());
          } catch (error11) {
            Constants.toastMessage(error.response!.data.toString());
          }
          print(
              "Exception occurred: $error stackTrace: $stacktrace apiError: ${error.response!.data}");
        }
        break;
      case DioErrorType.cancel:
        _errorMessage = "Request was cancelled";
        Constants.toastMessage('Request was cancelled');
        break;
      case DioErrorType.other:
        _errorMessage =
        "Connection failed due to internet connection";
        Constants.toastMessage('Connection failed due to internet connection');
        break;
    }
    return _errorMessage;
  }
}