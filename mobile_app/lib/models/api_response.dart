class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final List<dynamic>? errors;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic)? fromJsonT) {
    return ApiResponse(
      success: json['Success'] ?? false,
      message: json['Message'] ?? '',
      data: json['Data'] != null && fromJsonT != null ? fromJsonT(json['Data']) : json['Data'],
      errors: json['Errors'],
    );
  }
}
