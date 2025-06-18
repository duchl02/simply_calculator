import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:simply_calculator/domain/models/currency_model.dart';
import 'package:simply_calculator/i18n/strings.g.dart';

class SearchableCurrencyDropdown extends StatefulWidget {
  final List<CurrencyModel> currencies;
  final CurrencyModel selectedCurrency;
  final Function(CurrencyModel) onChanged;

  const SearchableCurrencyDropdown({
    required this.currencies,
    required this.selectedCurrency,
    required this.onChanged,
    Key? key,
  }) : super(key: key);

  @override
  _SearchableCurrencyDropdownState createState() =>
      _SearchableCurrencyDropdownState();
}

class _SearchableCurrencyDropdownState
    extends State<SearchableCurrencyDropdown> {
  final LayerLink _layerLink = LayerLink();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  bool _isDropdownOpen = false;
  late List<CurrencyModel> _filteredCurrencies;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _filteredCurrencies = List.from(widget.currencies);
    _searchFocusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.removeListener(_onFocusChanged);
    _searchFocusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _onFocusChanged() {
    if (!_searchFocusNode.hasFocus) {
      Future.delayed(Duration(milliseconds: 100), () {
        if (mounted) {
          _closeDropdown();
        }
      });
    }
  }

  void _toggleDropdown() {
    setState(() {
      _isDropdownOpen = !_isDropdownOpen;

      if (_isDropdownOpen) {
        _showOverlay();
        _searchFocusNode.requestFocus();
      } else {
        _removeOverlay();
      }
    });
  }

  void _closeDropdown() {
    if (_isDropdownOpen) {
      setState(() {
        _isDropdownOpen = false;
        _searchController.clear();
        _filteredCurrencies = List.from(widget.currencies);
        _removeOverlay();
      });
    }
  }

  void _showOverlay() {
    _removeOverlay();
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, size.height),
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(8.r),
            color: Theme.of(context).colorScheme.surface,
            child: StatefulBuilder(
              builder: (context, setOverlayState) {
                return Container(
                  height: 300.h,
                  padding: EdgeInsets.all(8.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Search input field
                      TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        decoration: InputDecoration(
                          hintText: t.search_currency,
                          prefixIcon: Icon(Icons.search, size: 20.sp),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 8.h),
                          isDense: true,
                        ),
                        onChanged: (query) {
                          // Update the filtering directly here
                          setOverlayState(() {
                            if (query.isEmpty) {
                              _filteredCurrencies = List.from(widget.currencies);
                            } else {
                              _filteredCurrencies = widget.currencies
                                  .where((currency) {
                                    return currency.name.toLowerCase().contains(query.toLowerCase()) ||
                                        currency.code.toLowerCase().contains(query.toLowerCase());
                                  })
                                  .toList();
                            }
                          });
                        },
                      ),

                      SizedBox(height: 8.h),

                      // Currency list
                      Expanded(
                        child:
                            _filteredCurrencies.isEmpty
                                ? Center(child: Text(t.no_results_found))
                                : ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: _filteredCurrencies.length,
                                  itemBuilder: (context, index) {
                                    final currency = _filteredCurrencies[index];
                                    final isSelected =
                                        currency.code ==
                                        widget.selectedCurrency.code;

                                    return ListTile(
                                      dense: true,
                                      visualDensity: VisualDensity.compact,
                                      leading: Text(
                                        currency.flag,
                                        style: TextStyle(fontSize: 20.sp),
                                      ),
                                      title: Text(
                                        '${currency.code} - ${currency.name}',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      subtitle: Text(currency.symbol),
                                      selected: isSelected,
                                      selectedTileColor: Theme.of(context)
                                          .colorScheme
                                          .primaryContainer
                                          .withOpacity(0.3),
                                      onTap: () => _selectCurrency(currency),
                                    );
                                  },
                                ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _selectCurrency(CurrencyModel currency) {
    widget.onChanged(currency);
    _closeDropdown();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: InkWell(
        onTap: _toggleDropdown,
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            children: [
              Text(
                widget.selectedCurrency.flag,
                style: TextStyle(fontSize: 18.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  '${widget.selectedCurrency.code} - ${widget.selectedCurrency.name}',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 16.sp),
                ),
              ),
              Icon(
                _isDropdownOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
