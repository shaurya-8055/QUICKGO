import '../../utility/extensions.dart';
import 'package:flutter/material.dart';
import '../../utility/app_color.dart';
import '../../widget/custom_text_field.dart';
import '../../models/address.dart';

class MyAddressPage extends StatefulWidget {
  const MyAddressPage({super.key});

  @override
  State<MyAddressPage> createState() => _MyAddressPageState();
}

class _MyAddressPageState extends State<MyAddressPage> {
  bool showForm = false;
  int? editingIndex;

  @override
  Widget build(BuildContext context) {
    final provider = context.profileProvider;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Addresses",
          style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColor.darkOrange),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView.separated(
                itemCount: provider.addresses.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final address = provider.addresses[index];
                  final isSelected = provider.selectedAddressIndex == index;
                  return GestureDetector(
                    onTap: () => setState(() => provider.selectAddress(index)),
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? AppColor.darkOrange
                              : Colors.grey.shade300,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        leading: Icon(
                          isSelected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          color: isSelected ? AppColor.darkOrange : Colors.grey,
                        ),
                        title: Text(address.phone,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                            '${address.street}, ${address.city}, ${address.state} ${address.postalCode}, ${address.country}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit,
                                  color: Colors.blueAccent),
                              onPressed: () {
                                setState(() {
                                  showForm = true;
                                  editingIndex = index;
                                });
                                provider.fillControllersFromAddress(address);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.redAccent),
                              onPressed: () => setState(() {
                                provider.removeAddress(index);
                              }),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (showForm) ...[
              const SizedBox(height: 16),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                margin: EdgeInsets.zero,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
                  child: Form(
                    key: provider.addressFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextField(
                          labelText: 'Phone',
                          onSave: (value) {},
                          inputType: TextInputType.phone,
                          controller: provider.phoneController,
                          validator: (value) => value!.isEmpty
                              ? 'Please enter a phone number'
                              : null,
                          height: 70,
                        ),
                        const SizedBox(height: 8),
                        CustomTextField(
                          labelText: 'Street Address',
                          onSave: (val) {},
                          controller: provider.streetController,
                          validator: (value) =>
                              value!.isEmpty ? 'Please enter a street' : null,
                          height: 70,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                labelText: 'City',
                                onSave: (value) {},
                                controller: provider.cityController,
                                validator: (value) =>
                                    value!.isEmpty ? 'Enter city' : null,
                                height: 70,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: CustomTextField(
                                labelText: 'State',
                                onSave: (value) {},
                                controller: provider.stateController,
                                validator: (value) =>
                                    value!.isEmpty ? 'Enter state' : null,
                                height: 70,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                labelText: 'Postal Code',
                                onSave: (value) {},
                                inputType: TextInputType.number,
                                controller: provider.postalCodeController,
                                validator: (value) =>
                                    value!.isEmpty ? 'Enter code' : null,
                                height: 70,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: CustomTextField(
                                labelText: 'Country',
                                onSave: (value) {},
                                controller: provider.countryController,
                                validator: (value) =>
                                    value!.isEmpty ? 'Enter country' : null,
                                height: 70,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              icon: const Icon(Icons.close,
                                  color: AppColor.darkGrey),
                              label: const Text('Cancel'),
                              onPressed: () {
                                setState(() {
                                  showForm = false;
                                  editingIndex = null;
                                });
                                provider.clearAddressControllers();
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: AppColor.darkGrey,
                                textStyle: const TextStyle(
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton.icon(
                              icon: Icon(
                                  editingIndex != null
                                      ? Icons.save
                                      : Icons.add_location_alt,
                                  color: Colors.white),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColor.darkOrange,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30)),
                                textStyle: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              onPressed: () {
                                if (provider.addressFormKey.currentState!
                                    .validate()) {
                                  provider.addOrUpdateAddress(
                                      index: editingIndex);
                                  setState(() {
                                    showForm = false;
                                    editingIndex = null;
                                  });
                                  provider.clearAddressControllers();
                                }
                              },
                              label: Text(editingIndex != null
                                  ? 'Update Address'
                                  : 'Add Address'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColor.darkOrange,
        child: const Icon(Icons.add),
        onPressed: () {
          setState(() {
            showForm = true;
            editingIndex = null;
          });
          provider.clearAddressControllers();
        },
        tooltip: 'Add Address',
      ),
    );
  }
}
