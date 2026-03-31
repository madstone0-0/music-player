import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({
    super.key,
    required this.resultsBuilder,
    this.hint = 'Search…',
    this.hintTitle = 'Start searching',
    this.hintSubtitle,
    this.hintIcon = Icons.search_rounded,
  });

  final Widget Function(BuildContext context, String query) resultsBuilder;

  final String hint;

  final String hintTitle;

  final String? hintSubtitle;

  final IconData hintIcon;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() => _query = _controller.text.trim());
    });
    // Auto-focus so the keyboard appears immediately on push.
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        leadingWidth: 40,
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: Get.back),
        title: SearchTextField(controller: _controller, focusNode: _focusNode, hint: widget.hint),
        actions: [
          if (_query.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_rounded),
              onPressed: () {
                _controller.clear();
                _focusNode.requestFocus();
              },
            ),
        ],
      ),
      body: _query.isEmpty
          ? SearchEmptyHint(icon: widget.hintIcon, title: widget.hintTitle, subtitle: widget.hintSubtitle)
          : widget.resultsBuilder(context, _query),
    );
  }
}

class SearchTextField extends StatelessWidget {
  const SearchTextField({
    super.key,
    required this.controller,
    required this.focusNode,
    this.hint = 'Search…',
    this.fontSize = 16,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return TextField(
      controller: controller,
      focusNode: focusNode,
      textInputAction: TextInputAction.search,
      style: TextStyle(color: scheme.onSurface, fontSize: fontSize),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: scheme.onSurface.withValues(alpha: 0.35), fontSize: fontSize),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        isDense: true,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}

class SearchEmptyHint extends StatelessWidget {
  const SearchEmptyHint({super.key, required this.title, this.subtitle, this.icon = Icons.search_rounded});

  final IconData icon;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 56, color: scheme.onSurface.withValues(alpha: 0.15)),
          const SizedBox(height: 16),
          Text(title, style: textTheme.titleMedium?.copyWith(color: scheme.onSurface)),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(subtitle!, style: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
          ],
        ],
      ),
    );
  }
}
