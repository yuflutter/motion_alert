import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher_string.dart';

void showWaitingOverlay(BuildContext context) {
  Navigator.push(
    context,
    PageRouteBuilder(
      opaque: false,
      fullscreenDialog: true,
      pageBuilder: (_, __, ___) => Container(
        color: Color.fromARGB(150, 60, 60, 60),
        child: Center(child: CircularProgressIndicator()),
      ),
    ),
  );
}

void showErrorSnackBar(BuildContext context, String userMsg, Object error, [StackTrace? stack]) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      duration: Duration(seconds: 60),
      showCloseIcon: true,
      closeIconColor: Colors.white,
      content: _CommonErrorDialog(userMsg: userMsg, error: error, stack: stack, isSnackbar: true),
    ),
  );
}

void showInfoSnackBar(BuildContext context, String userMsg) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Center(
        child: Text(userMsg, textAlign: TextAlign.center),
      ),
    ),
  );
}

class ErrorScreen extends StatelessWidget {
  final String userMsg;
  final Object error;
  final StackTrace? stack;
  final bool isExpanded;

  const ErrorScreen({
    required this.userMsg,
    required this.error,
    this.stack,
    this.isExpanded = false,
    super.key,
  });

  @override
  build(context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox.expand(
          child: Container(
            color: Colors.black87,
            padding: EdgeInsets.all(8),
            child: _CommonErrorDialog(
              userMsg: userMsg,
              error: error,
              stack: stack,
              isExpanded: isExpanded,
            ),
          ),
        ),
      ),
    );
  }
}

class _CommonErrorDialog extends StatefulWidget {
  final String userMsg;
  final Object? error;
  final StackTrace? stack;
  final bool isSnackbar;
  final bool isExpanded;

  const _CommonErrorDialog({
    required this.userMsg,
    this.error,
    this.stack,
    this.isSnackbar = false,
    this.isExpanded = false,
  });

  @override
  createState() => __CommonErrorDialog();
}

class __CommonErrorDialog extends State<_CommonErrorDialog> {
  late bool _expanded;
  late String _text;

  @override
  initState() {
    _expanded = widget.isExpanded;
    _text = '${widget.userMsg}\n${widget.error}\n${widget.stack}';
    super.initState();
  }

  @override
  build(context) {
    return (!_expanded)
        ? SizedBox(
            height: 70,
            child: InkWell(
              onTap: () => setState(() => _expanded = true),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    widget.userMsg,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Details...',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ],
              ),
            ),
          )
        : SizedBox(
            height: (widget.isSnackbar) ? MediaQuery.of(context).size.height / 2 : null,
            child: Column(
              children: [
                Row(
                  children: [
                    SizedBox(width: 30),
                    OutlinedButton(
                      onPressed: _copy,
                      child: Text(
                        'Copy',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Spacer(),
                    OutlinedButton(
                      onPressed: _send,
                      child: Text(
                        'Send',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(width: (!widget.isSnackbar) ? 30 : null),
                  ],
                ),
                SizedBox(height: 5),
                Expanded(
                  child: SingleChildScrollView(
                    child: SelectableText(
                      _text,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              ],
            ),
          );
  }

  void _copy() async {
    await Clipboard.setData(ClipboardData(text: _text));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('Copied to clipboard', textAlign: TextAlign.center)));
  }

  void _send() async {
    await launchUrlString('mailto:yuflutter@yandex.ru?subject=Motion Alert Bug Report&body=$_text');
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }
}
