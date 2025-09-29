import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../const/google_api.dart';

class SearchWidget extends StatefulWidget {
  final String hintText;
  final Function(String placeId, String description) onPlaceSelected;
  final TextEditingController? controller;

  const SearchWidget({
    super.key,
    this.hintText = 'Search places',
    required this.onPlaceSelected,
    this.controller,
  });

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  late TextEditingController _controller;
  List<dynamic> _placePredictions = [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  Future<void> _searchPlace(String input) async {
    if (input.isEmpty) {
      setState(() {
        _placePredictions = [];
      });
      return;
    }

    final url =
        "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$googleApiKey";
    
    try {
      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);

      if (data['status'] == 'OK') {
        setState(() {
          _placePredictions = data['predictions'];
        });
      } else {
        setState(() {
          _placePredictions = [];
        });
      }
    } catch (e) {
      debugPrint('Search error: $e');
      setState(() {
        _placePredictions = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search TextField
        TextField(
          controller: _controller,
          onChanged: (value) {
            if (_debounce?.isActive ?? false) _debounce!.cancel();
            _debounce = Timer(
              const Duration(milliseconds: 500),
              () {
                _searchPlace(value);
              },
            );
          },
          decoration: InputDecoration(
            hintText: widget.hintText,
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),

        // Autocomplete Suggestions List
        if (_placePredictions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _placePredictions.length,
              itemBuilder: (context, index) {
                final prediction = _placePredictions[index];
                return ListTile(
                  leading: const Icon(Icons.location_on),
                  title: Text(
                    prediction['description'],
                    style: const TextStyle(fontSize: 14),
                  ),
                  onTap: () {
                    widget.onPlaceSelected(
                      prediction['place_id'],
                      prediction['description'],
                    );
                    _controller.text = prediction['description'];
                    setState(() {
                      _placePredictions = [];
                    });
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}

/// Positioned search widget for overlaying on maps
class PositionedSearchWidget extends StatelessWidget {
  final double top;
  final double left;
  final double right;
  final String hintText;
  final Function(String placeId, String description) onPlaceSelected;
  final TextEditingController? controller;

  const PositionedSearchWidget({
    super.key,
    required this.top,
    required this.left,
    required this.right,
    this.hintText = 'Search places',
    required this.onPlaceSelected,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      child: SearchWidget(
        hintText: hintText,
        onPlaceSelected: onPlaceSelected,
        controller: controller,
      ),
    );
  }
}
