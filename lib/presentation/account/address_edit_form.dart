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
      print('🔄 Using fallback country list...');
      
      // Use fallback country list
      setState(() {
        _countries = _getFallbackCountries();
        _isLoadingCountries = false;
      });
      
      // Check if the current address country exists in fallback countries
      final countryExists = _countries.any((country) => country.id == _selectedCountryId);
      if (!countryExists && _countries.isNotEmpty) {
        print('⚠️ Current address country ID $_selectedCountryId not found in fallback countries, using first available country');
        _selectedCountryId = _countries.first.id;
      }
      
      print('✅ Loaded ${_countries.length} countries from fallback list');
      print('🔍 Current selected country ID: $_selectedCountryId');
    }
  }

  List<Country> _getFallbackCountries() {
    // Conservative list with common countries and lower IDs that are more likely to be supported by server
    return [
      Country(id: 1, name: 'United States', code: 'US'),
      Country(id: 2, name: 'Canada', code: 'CA'),
      Country(id: 3, name: 'United Kingdom', code: 'GB'),
      Country(id: 4, name: 'Australia', code: 'AU'),
      Country(id: 5, name: 'Germany', code: 'DE'),
      Country(id: 6, name: 'Italy', code: 'IT'),
      Country(id: 7, name: 'France', code: 'FR'),
      Country(id: 8, name: 'Spain', code: 'ES'),
      Country(id: 9, name: 'Netherlands', code: 'NL'),
      Country(id: 10, name: 'Belgium', code: 'BE'),
      Country(id: 11, name: 'Switzerland', code: 'CH'),
      Country(id: 12, name: 'Austria', code: 'AT'),
      Country(id: 13, name: 'Sweden', code: 'SE'),
      Country(id: 14, name: 'Norway', code: 'NO'),
      Country(id: 15, name: 'Denmark', code: 'DK'),
      Country(id: 16, name: 'Finland', code: 'FI'),
      Country(id: 17, name: 'Poland', code: 'PL'),
      Country(id: 18, name: 'Czech Republic', code: 'CZ'),
      Country(id: 19, name: 'Hungary', code: 'HU'),
      Country(id: 20, name: 'Portugal', code: 'PT'),
      Country(id: 21, name: 'Greece', code: 'GR'),
      Country(id: 22, name: 'Turkey', code: 'TR'),
      Country(id: 23, name: 'Russia', code: 'RU'),
      Country(id: 24, name: 'Japan', code: 'JP'),
      Country(id: 25, name: 'China', code: 'CN'),
      Country(id: 26, name: 'South Korea', code: 'KR'),
      Country(id: 27, name: 'India', code: 'IN'),
      Country(id: 28, name: 'Brazil', code: 'BR'),
      Country(id: 29, name: 'Mexico', code: 'MX'),
      Country(id: 30, name: 'Argentina', code: 'AR'),
      Country(id: 31, name: 'Chile', code: 'CL'),
      Country(id: 32, name: 'Colombia', code: 'CO'),
      Country(id: 33, name: 'Peru', code: 'PE'),
      Country(id: 34, name: 'Venezuela', code: 'VE'),
      Country(id: 35, name: 'South Africa', code: 'ZA'),
      Country(id: 36, name: 'Egypt', code: 'EG'),
      Country(id: 37, name: 'Nigeria', code: 'NG'),
      Country(id: 38, name: 'Kenya', code: 'KE'),
      Country(id: 39, name: 'Morocco', code: 'MA'),
      Country(id: 40, name: 'Tunisia', code: 'TN'),
      Country(id: 41, name: 'Algeria', code: 'DZ'),
      Country(id: 42, name: 'Libya', code: 'LY'),
      Country(id: 43, name: 'Sudan', code: 'SD'),
      Country(id: 44, name: 'Ethiopia', code: 'ET'),
      Country(id: 45, name: 'Ghana', code: 'GH'),
      Country(id: 46, name: 'Uganda', code: 'UG'),
      Country(id: 47, name: 'Tanzania', code: 'TZ'),
      Country(id: 48, name: 'Zimbabwe', code: 'ZW'),
      Country(id: 49, name: 'Botswana', code: 'BW'),
      Country(id: 50, name: 'Namibia', code: 'NA'),
      Country(id: 51, name: 'Zambia', code: 'ZM'),
      Country(id: 52, name: 'Malawi', code: 'MW'),
      Country(id: 53, name: 'Mozambique', code: 'MZ'),
      Country(id: 54, name: 'Madagascar', code: 'MG'),
      Country(id: 55, name: 'Mauritius', code: 'MU'),
      Country(id: 56, name: 'Seychelles', code: 'SC'),
      Country(id: 57, name: 'Rwanda', code: 'RW'),
      Country(id: 58, name: 'Burundi', code: 'BI'),
      Country(id: 59, name: 'Somalia', code: 'SO'),
      Country(id: 60, name: 'Djibouti', code: 'DJ'),
      Country(id: 61, name: 'Eritrea', code: 'ER'),
      Country(id: 62, name: 'Chad', code: 'TD'),
      Country(id: 63, name: 'Niger', code: 'NE'),
      Country(id: 64, name: 'Mali', code: 'ML'),
      Country(id: 65, name: 'Burkina Faso', code: 'BF'),
      Country(id: 66, name: 'Senegal', code: 'SN'),
      Country(id: 67, name: 'Guinea', code: 'GN'),
      Country(id: 68, name: 'Sierra Leone', code: 'SL'),
      Country(id: 69, name: 'Liberia', code: 'LR'),
      Country(id: 70, name: 'Ivory Coast', code: 'CI'),
      Country(id: 71, name: 'Togo', code: 'TG'),
      Country(id: 72, name: 'Benin', code: 'BJ'),
      Country(id: 73, name: 'Cameroon', code: 'CM'),
      Country(id: 74, name: 'Central African Republic', code: 'CF'),
      Country(id: 75, name: 'Equatorial Guinea', code: 'GQ'),
      Country(id: 76, name: 'Gabon', code: 'GA'),
      Country(id: 77, name: 'Congo', code: 'CG'),
      Country(id: 78, name: 'Democratic Republic of the Congo', code: 'CD'),
      Country(id: 79, name: 'Angola', code: 'AO'),
      Country(id: 80, name: 'Comoros', code: 'KM'),
      Country(id: 81, name: 'Cape Verde', code: 'CV'),
      Country(id: 82, name: 'São Tomé and Príncipe', code: 'ST'),
      Country(id: 83, name: 'Guinea-Bissau', code: 'GW'),
      Country(id: 84, name: 'Gambia', code: 'GM'),
      Country(id: 85, name: 'United Arab Emirates', code: 'AE'),
      Country(id: 86, name: 'Saudi Arabia', code: 'SA'),
      Country(id: 87, name: 'Israel', code: 'IL'),
      Country(id: 88, name: 'Jordan', code: 'JO'),
      Country(id: 89, name: 'Lebanon', code: 'LB'),
      Country(id: 90, name: 'Syria', code: 'SY'),
      Country(id: 91, name: 'Iraq', code: 'IQ'),
      Country(id: 92, name: 'Iran', code: 'IR'),
      Country(id: 93, name: 'Afghanistan', code: 'AF'),
      Country(id: 94, name: 'Pakistan', code: 'PK'),
      Country(id: 95, name: 'Bangladesh', code: 'BD'),
      Country(id: 96, name: 'Sri Lanka', code: 'LK'),
      Country(id: 97, name: 'Nepal', code: 'NP'),
      Country(id: 98, name: 'Bhutan', code: 'BT'),
      Country(id: 99, name: 'Myanmar', code: 'MM'),
      Country(id: 100, name: 'Thailand', code: 'TH'),
    ];
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
                  initialValue: _isLoadingCountries ? null : _selectedCountryId,
                  decoration: InputDecoration(
                    hintText: _isLoadingCountries ? 'Loading countries...' : 'Select Country',
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
                  onChanged: _isLoadingCountries ? null : (value) {
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
                      return 'Country is required';
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
