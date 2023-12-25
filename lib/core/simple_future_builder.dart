import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'simple_dialogs.dart';

class SimpleFutureBuilder<T> extends StatelessWidget {
  final Future<T> future;
  final Widget Function(BuildContext context, T? data) builder;
  final Widget? placeholder;
  final Widget Function(String error)? errorBuilder;

  const SimpleFutureBuilder({
    required this.future,
    required this.builder,
    this.placeholder,
    this.errorBuilder,
    super.key,
  });

  @override
  build(context) {
    return FutureBuilder<T?>(
      future: future,
      builder: (context, snapshot) {
        return (snapshot.connectionState == ConnectionState.waiting)
            ? placeholder ?? Center(child: CircularProgressIndicator())
            : snapshot.hasError
                ? () {
                    dev.log('', error: snapshot.error, stackTrace: snapshot.stackTrace);
                    return (errorBuilder != null)
                        ? errorBuilder!(snapshot.error.toString())
                        : ErrorScreen(
                            userMsg: 'ERROR',
                            error: snapshot.error!,
                            stack: snapshot.stackTrace,
                            isExpanded: true,
                          );
                  }()
                : builder(context, (snapshot.hasData) ? snapshot.requireData : null);
      },
    );
  }
}
