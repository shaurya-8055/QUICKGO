
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
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColor.darkOrange),
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
                    onTap: () => provider.selectAddress(index),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFe6e6fa) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? AppColor.darkOrange : Colors.grey.shade300,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: [
                          if (isSelected)
                            BoxShadow(
                              color: AppColor.darkOrange.withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                        ],
                      ),
                      child: ListTile(
                        title: Text(address.phone, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${address.street}, ${address.city}, ${address.state} ${address.postalCode}, ${address.country}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isSelected)
                              const Icon(Icons.check_circle, color: AppColor.darkOrange),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blueAccent),
                              onPressed: () {
                                setState(() {
                                  showForm = true;
                                  editingIndex = index;
                                });
                                provider.fillControllersFromAddress(address);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () => setState(() {
                                provider.removeAddress(index);
                              }),
                            ),
                          ],
                        ),
                        onTap: () => provider.selectAddress(index),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                surfaceTintColor: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: provider.addressFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextField(
                          labelText: 'Phone',
                          onSave: (value) {},
                          inputType: TextInputType.number,
                          controller: provider.phoneController,
                          validator: (value) => value!.isEmpty ? 'Please enter a phone number' : null,
                        ),
                        CustomTextField(
                          labelText: 'Street',
                          onSave: (val) {},
                          controller: provider.streetController,
                          validator: (value) => value!.isEmpty ? 'Please enter a street' : null,
                        ),
                        CustomTextField(
                          labelText: 'City',
                          onSave: (value) {},
                          controller: provider.cityController,
                          validator: (value) => value!.isEmpty ? 'Please enter a city' : null,
                        ),
                        CustomTextField(
                          labelText: 'State',
                          onSave: (value) {},
                          controller: provider.stateController,
                          validator: (value) => value!.isEmpty ? 'Please enter a state' : null,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                labelText: 'Postal Code',
                                onSave: (value) {},
                                inputType: TextInputType.number,
                                controller: provider.postalCodeController,
                                validator: (value) => value!.isEmpty ? 'Please enter a code' : null,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: CustomTextField(
                                labelText: 'Country',
                                onSave: (value) {},
                                controller: provider.countryController,
                                validator: (value) => value!.isEmpty ? 'Please enter a country' : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  showForm = false;
                                  editingIndex = null;
                                });
                                provider.clearAddressControllers();
                              },
                              child: const Text('Cancel'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColor.darkOrange,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              ),
                              onPressed: () {
                                if (provider.addressFormKey.currentState!.validate()) {
                                  provider.addOrUpdateAddress(index: editingIndex);
                                  setState(() {
                                    showForm = false;
                                    editingIndex = null;
                                  });
                                  provider.clearAddressControllers();
                                }
                              },
                              child: Text(editingIndex != null ? 'Update Address' : 'Add Address', style: const TextStyle(fontSize: 16)),
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
