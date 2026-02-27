import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';


class RegionFilterWidget extends StatelessWidget {
  final String selectedCountry;
  final List<String> availableCountries;
  final bool isLoading;
  final Function(String?) onCountryChanged;

  const RegionFilterWidget({
    super.key,
    required this.selectedCountry,
    required this.availableCountries,
    required this.isLoading,
    required this.onCountryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(26),
            blurRadius: 4.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.public, color: Theme.of(context).primaryColor, size: 5.w),
          SizedBox(width: 2.w),
          Text(
            'Region:',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: isLoading
                ? const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : DropdownButton<String>(
                    value: selectedCountry,
                    isExpanded: true,
                    underline: Container(),
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: Theme.of(context).primaryColor,
                    ),
                    items: availableCountries.map((String country) {
                      return DropdownMenuItem<String>(
                        value: country,
                        child: Text(
                          country,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: onCountryChanged,
                  ),
          ),
        ],
      ),
    );
  }
}
