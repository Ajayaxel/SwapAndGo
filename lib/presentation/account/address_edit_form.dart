import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swap_app/bloc/address/address_bloc.dart';
import 'package:swap_app/bloc/address/address_event.dart';
import 'package:swap_app/bloc/address/address_state.dart';
import 'package:swap_app/model/address_models.dart';
import 'package:swap_app/const/go_button.dart';
import 'package:swap_app/repo/address_repository.dart';

class AddressEditForm extends StatefulWidget {
  final Address address;

  const AddressEditForm({super.key, required this.address});

  @override
  State<AddressEditForm> createState() => _AddressEditFormState();
}

class _AddressEditFormState extends State<AddressEditForm> {
  final _formKey = GlobalKey<FormState>();
  final _addressLine1Controller = TextEditingController();
  final _addressLine2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _postalCodeController = TextEditingController();
  
  String _selectedType = 'home';
  bool _isDefault = false;
  int _selectedCountryId = 1;
  List<Country> _countries = [];
  bool _isLoadingCountries = true;
  final AddressRepository _addressRepository = AddressRepository();

  @override
  void initState() {
    super.initState();
    _initializeForm();
    _loadCountries();
  }

  void _initializeForm() {
    _addressLine1Controller.text = widget.address.addressLine1;
    _addressLine2Controller.text = widget.address.addressLine2 ?? '';
    _cityController.text = widget.address.city;
    _stateController.text = widget.address.state;
    _postalCodeController.text = widget.address.postalCode;
    _selectedType = widget.address.type;
    _isDefault = widget.address.isDefault;
    
    // Set initial country ID from the address
    _selectedCountryId = widget.address.country.id;
    
    // Debug logging
    print('🔍 Initializing form with address country: ${widget.address.country.name} (ID: ${widget.address.country.id})');
    print('🔍 Selected country ID: $_selectedCountryId');
  }

  Future<void> _loadCountries() async {
    try {
      print('🔍 Loading countries from server...');
      final countries = await _addressRepository.fetchCountries();
      
      setState(() {
        _countries = countries;
        _isLoadingCountries = false;
      });
      
      // Check if the current address country exists in the server countries
      final countryExists = _countries.any((country) => country.id == _selectedCountryId);
      if (!countryExists && _countries.isNotEmpty) {
        print('⚠️ Current address country ID $_selectedCountryId not found in server countries, using first available country');
        _selectedCountryId = _countries.first.id;
      }
      
      print('✅ Loaded ${_countries.length} countries from server');
      print('🔍 Current selected country ID: $_selectedCountryId');
      print('🔍 Available countries: ${_countries.map((c) => '${c.name} (${c.id})').join(', ')}');
    } catch (e) {
      print('❌ Failed to load countries from server: $e');
      
      setState(() {
        _countries = [];
        _isLoadingCountries = false;
      });
      
      // Show error message to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load countries: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }


  @override
  void dispose() {
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  void _updateAddress() {
    if (_formKey.currentState!.validate()) {
      // Check if countries are loaded
      if (_countries.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please wait for countries to load or try again'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Debug logging for country selection
      final selectedCountry = _countries.firstWhere(
        (country) => country.id == _selectedCountryId,
        orElse: () => Country(id: _selectedCountryId, name: 'Unknown', code: 'XX'),
      );
      print('🔍 About to update address with country: ${selectedCountry.name} (ID: ${selectedCountry.id})');
      print('🔍 Original address country: ${widget.address.country.name} (ID: ${widget.address.country.id})');
      
      final updateRequest = UpdateAddressRequest(
        addressLine1: _addressLine1Controller.text.trim(),
        addressLine2: _addressLine2Controller.text.trim().isEmpty 
            ? null 
            : _addressLine2Controller.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        postalCode: _postalCodeController.text.trim(),
        countryId: _selectedCountryId,
        type: _selectedType,
        isDefault: _isDefault,
      );

      print('🔍 Update request data: ${updateRequest.toJson()}');

      context.read<AddressBloc>().add(UpdateAddressEvent(
        addressId: widget.address.id,
        request: updateRequest,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Address',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<AddressBloc, AddressState>(
            listener: (context, state) {
              if (state is AddressUpdateSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.pop(context, true); // Return true to indicate success
              } else if (state is AddressError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              } else if (state is AddressUnauthenticated) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
                Navigator.pop(context);
              }
            },
          ),
        ],
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Address Line 1
                const Text(
                  'Address Line 1',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _addressLine1Controller,
                  decoration: InputDecoration(
                    hintText: '123 Main Street',
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF007AFF), width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  style: const TextStyle(fontSize: 14),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Address line 1 is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Address Line 2
                const Text(
                  'Address Line 2',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _addressLine2Controller,
                  decoration: InputDecoration(
                    hintText: 'Martha Apt.',
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF007AFF), width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 20),

                // City and State Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'City*',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF333333),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _cityController,
                            decoration: InputDecoration(
                              hintText: 'Bur Dubai',
                              hintStyle: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFF007AFF), width: 2),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                            style: const TextStyle(fontSize: 14),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'City is required';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'State*',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF333333),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _stateController,
                            decoration: InputDecoration(
                              hintText: 'Sharjah',
                              hintStyle: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFF007AFF), width: 2),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                            style: const TextStyle(fontSize: 14),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'State is required';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Postal Code
                const Text(
                  'Postal Code*',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _postalCodeController,
                  decoration: InputDecoration(
                    hintText: '100034',
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF007AFF), width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  style: const TextStyle(fontSize: 14),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Postal code is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Address Type
                const Text(
                  'Address Type*',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _selectedType,
                  decoration: InputDecoration(
                    hintText: 'Home',
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF007AFF), width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                  items: const [
                    DropdownMenuItem(value: 'home', child: Text('Home')),
                    DropdownMenuItem(value: 'work', child: Text('Work')),
                    DropdownMenuItem(value: 'other', child: Text('Other')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value!;
                    });
                  },
                ),
                const SizedBox(height: 20),

                // Country
                const Text(
                  'Country*',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  value: _isLoadingCountries ? null : (_countries.isNotEmpty ? _selectedCountryId : null),
                  decoration: InputDecoration(
                    hintText: _isLoadingCountries 
                        ? 'Loading countries...' 
                        : _countries.isEmpty 
                            ? 'No countries available' 
                            : 'Select Country',
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF007AFF), width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                  items: _countries.map((country) {
                    return DropdownMenuItem<int>(
                      value: country.id,
                      child: Text(country.name),
                    );
                  }).toList(),
                  onChanged: (_isLoadingCountries || _countries.isEmpty) ? null : (value) {
                    if (value != null) {
                      final selectedCountry = _countries.firstWhere((country) => country.id == value);
                      print('🔍 Country selected: ${selectedCountry.name} (ID: ${selectedCountry.id})');
                      setState(() {
                        _selectedCountryId = value;
                      });
                    }
                  },
                  validator: (value) {
                    if (value == null) {
                      return _countries.isEmpty ? 'Countries not available' : 'Country is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Default Address Checkbox
                Row(
                  children: [
                    Checkbox(
                      value: _isDefault,
                      onChanged: (value) {
                        setState(() {
                          _isDefault = value ?? false;
                        });
                      },
                      activeColor: const Color(0xFF007AFF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Set as default address',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF333333),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'This will be used as your primary address',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Update Button
                BlocBuilder<AddressBloc, AddressState>(
                  builder: (context, state) {
                    return GoButton(
                      onPressed: _updateAddress,
                      text: 'Update Address',
                      backgroundColor: const Color(0xFF0A2342),
                      textColor: Colors.white,
                      foregroundColor: Colors.white,
                      isLoading: state is AddressUpdateLoading,
                      loadingText: 'Updating Address...',
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
