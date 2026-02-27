import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class MapSearchBarWidget extends StatefulWidget {
  final Function(String) onSearch;

  const MapSearchBarWidget({Key? key, required this.onSearch})
    : super(key: key);

  @override
  State<MapSearchBarWidget> createState() => _MapSearchBarWidgetState();
}

class _MapSearchBarWidgetState extends State<MapSearchBarWidget> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _controller,
        onSubmitted: widget.onSearch,
        decoration: InputDecoration(
          hintText: 'Search places...',
          hintStyle: GoogleFonts.inter(fontSize: 14.sp, color: Colors.grey),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF4EC2FE)),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    _controller.clear();
                    widget.onSearch('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 12.h,
          ),
        ),
        style: GoogleFonts.inter(fontSize: 14.sp),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
