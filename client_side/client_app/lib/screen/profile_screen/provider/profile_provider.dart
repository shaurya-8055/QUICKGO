import '../../../core/data/data_provider.dart';
import '../../../utility/constants.dart';
import '../../../utility/snack_bar_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_storage/get_storage.dart';
import '../../../models/address.dart';

class ProfileProvider extends ChangeNotifier {
  final DataProvider _dataProvider;
  final box = GetStorage();

  final GlobalKey<FormState> addressFormKey = GlobalKey<FormState>();
  TextEditingController phoneController = TextEditingController();
  TextEditingController streetController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController postalCodeController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  TextEditingController couponController = TextEditingController();

  List<Address> addresses = [];
  int? selectedAddressIndex;

  static const String ADDRESSES_KEY = 'user_addresses';
  static const String SELECTED_ADDRESS_KEY = 'selected_address_index';

  ProfileProvider(this._dataProvider) {
    retrieveSavedAddresses();
  }

  void addOrUpdateAddress({int? index}) {
    final address = Address(
      phone: phoneController.text,
      street: streetController.text,
      city: cityController.text,
      state: stateController.text,
      postalCode: postalCodeController.text,
      country: countryController.text,
    );
    if (index != null && index >= 0 && index < addresses.length) {
      addresses[index] = address;
    } else {
      addresses.add(address);
      selectedAddressIndex = addresses.length - 1;
    }
    saveAddresses();
    SnackBarHelper.showSuccessSnackBar('Address Saved Successfully');
    notifyListeners();
  }

  void removeAddress(int index) {
    if (index >= 0 && index < addresses.length) {
      addresses.removeAt(index);
      if (selectedAddressIndex != null &&
          selectedAddressIndex! >= addresses.length) {
        selectedAddressIndex = addresses.isNotEmpty ? 0 : null;
      }
      saveAddresses();
      notifyListeners();
    }
  }

  void selectAddress(int index) {
    if (index >= 0 && index < addresses.length) {
      selectedAddressIndex = index;
      box.write(SELECTED_ADDRESS_KEY, index);
      notifyListeners();
    }
  }

  void saveAddresses() {
    final addressList = addresses.map((a) => a.toJson()).toList();
    box.write(ADDRESSES_KEY, addressList);
    if (selectedAddressIndex != null) {
      box.write(SELECTED_ADDRESS_KEY, selectedAddressIndex);
    }
  }

  void retrieveSavedAddresses() {
    final addressList = box.read(ADDRESSES_KEY) as List?;
    addresses = addressList != null
        ? addressList
            .map((a) => Address.fromJson(Map<String, dynamic>.from(a)))
            .toList()
        : [];
    selectedAddressIndex = box.read(SELECTED_ADDRESS_KEY) as int?;
    notifyListeners();
  }

  void fillControllersFromAddress(Address address) {
    phoneController.text = address.phone;
    streetController.text = address.street;
    cityController.text = address.city;
    stateController.text = address.state;
    postalCodeController.text = address.postalCode;
    countryController.text = address.country;
  }

  void clearAddressControllers() {
    phoneController.clear();
    streetController.clear();
    cityController.clear();
    stateController.clear();
    postalCodeController.clear();
    countryController.clear();
  }
}
