import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/network/api_config.dart';
import '../../../core/theme/app_colors.dart';

/// In-app browser for `GET /auth/{google|apple}/start`.
///
/// After consent the API redirects to the PitchTZ client site with
/// `#oauth_token=<jwt>` (or `?oauth_error=…` on failure). The navigation
/// delegate watches every URL change, captures the token before that page
/// loads, and pops it back to the login screen:
///   * pops `String` (the JWT) on success,
///   * pops `null` when the user closes the sheet or the provider errors.
class OAuthPage extends StatefulWidget {
  const OAuthPage({super.key, required this.provider});

  /// 'google' | 'apple'.
  final String provider;

  @override
  State<OAuthPage> createState() => _OAuthPageState();
}

class _OAuthPageState extends State<OAuthPage> {
  late final WebViewController _controller;
  bool _loading = true;
  bool _done = false;

  // Google refuses OAuth from anything that self-identifies as a WebView
  // (403 disallowed_useragent), so present a plain mobile-browser UA.
  static const _userAgent =
      'Mozilla/5.0 (Linux; Android 14; Pixel 7) AppleWebKit/537.36 '
      '(KHTML, like Gecko) Chrome/124.0.0.0 Mobile Safari/537.36';

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(_userAgent)
      ..setBackgroundColor(AppColors.cream)
      ..setNavigationDelegate(NavigationDelegate(
        onNavigationRequest: (request) =>
            _capture(request.url) ? NavigationDecision.prevent
                                  : NavigationDecision.navigate,
        // Fragment-only redirects don't always raise a navigation request.
        onUrlChange: (change) {
          final url = change.url;
          if (url != null) _capture(url);
        },
        onPageStarted: (url) => _capture(url),
        onPageFinished: (_) {
          if (mounted) setState(() => _loading = false);
        },
      ))
      ..loadRequest(
          Uri.parse('${ApiConfig.baseUrl}/auth/${widget.provider}/start'));
  }

  /// Returns true when [url] is the final redirect and the flow is finished.
  bool _capture(String url) {
    if (_done) return true;
    final uri = Uri.tryParse(url);
    if (uri == null) return false;

    if (uri.fragment.contains('oauth_token=')) {
      final token = Uri.splitQueryString(uri.fragment)['oauth_token'];
      if (token != null && token.isNotEmpty) {
        _done = true;
        Navigator.pop(context, token);
        return true;
      }
    }
    if (uri.queryParameters.containsKey('oauth_error') ||
        uri.fragment.contains('oauth_error=')) {
      _done = true;
      Navigator.pop(context, null);
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.ink),
          onPressed: () => Navigator.pop(context, null),
        ),
        title: Text(
          widget.provider == 'google' ? 'Google' : 'Apple',
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.ink),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading)
            const Center(
                child: CircularProgressIndicator(color: AppColors.primary)),
        ],
      ),
    );
  }
}
