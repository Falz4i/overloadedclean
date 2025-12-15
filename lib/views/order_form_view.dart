import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/app_controller.dart';

class OrderFormView extends StatefulWidget {
  final Map<String, dynamic>? existingOrder; // If null, it's Add mode

  const OrderFormView({Key? key, this.existingOrder}) : super(key: key);

  @override
  State<OrderFormView> createState() => _OrderFormViewState();
}

class _OrderFormViewState extends State<OrderFormView> {
  final AppController controller = Get.find<AppController>();
  
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _customerNameController;
  late TextEditingController _customBrandController;
  late TextEditingController _notesController;
  
  String? _selectedService;
  String _selectedStatus = 'Pending';
  String _selectedBrand = 'Nike'; // Default
  double _estimatedPrice = 0.0;
  
  final List<String> _brandOptions = ['Nike', 'Adidas', 'New Balance', 'Puma', 'Vans', 'Converse', 'Other'];

  @override
  void initState() {
    super.initState();
    _customerNameController = TextEditingController(text: widget.existingOrder?['customer_name'] ?? '');
    _notesController = TextEditingController(text: widget.existingOrder?['notes'] ?? '');
    
    // Brand Logic
    String existingBrand = widget.existingOrder?['shoe_brand'] ?? 'Nike';
    if (_brandOptions.contains(existingBrand)) {
      _selectedBrand = existingBrand;
      _customBrandController = TextEditingController();
    } else {
      _selectedBrand = 'Other';
      _customBrandController = TextEditingController(text: existingBrand);
    }
    
    if (widget.existingOrder != null) {
      _selectedService = widget.existingOrder!['service_name'];
      _selectedStatus = widget.existingOrder!['status'] ?? 'Pending';
      _updatePrice(_selectedService);
    } else {
        // Default to first service if available
        if (controller.laundryServices.isNotEmpty) {
           _selectedService = controller.laundryServices[0]['name'];
           _estimatedPrice = (controller.laundryServices[0]['price'] as int).toDouble();
        }
    }
  }

  void _updatePrice(String? serviceName) {
     if (serviceName == null) return;
     final service = controller.laundryServices.firstWhere(
       (s) => s['name'] == serviceName, 
       orElse: () => {'price': 0}
     );
     setState(() {
       _estimatedPrice = (service['price'] as int).toDouble();
     });
  }

  @override
  Widget build(BuildContext context) {
    bool isEdit = widget.existingOrder != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Order' : 'Add Order')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Customer Info Section
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Customer Info',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _customerNameController,
                        decoration: const InputDecoration(
                          labelText: 'Nama Pemesan',
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) => value!.isEmpty ? 'Please enter name' : null,
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Order Details Section
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order Details',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Service Type
                      DropdownButtonFormField<String>(
                        value: _selectedService,
                        decoration: const InputDecoration(
                          labelText: 'Service Type',
                          prefixIcon: Icon(Icons.local_laundry_service),
                        ),
                        items: controller.laundryServices.map<DropdownMenuItem<String>>((Map<String, dynamic> service) {
                          return DropdownMenuItem<String>(
                            value: service['name'].toString(),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(service['name'].toString()),
                                Text("Rp ${service['price']}", 
                                  style: TextStyle(
                                    color: Theme.of(context).textTheme.bodySmall?.color,
                                    fontSize: 12
                                  )
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedService = newValue!;
                            _updatePrice(newValue);
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Status Dropdown - Only Visible in Edit Mode
                      if (isEdit) ...[
                        DropdownButtonFormField<String>(
                          value: _selectedStatus,
                          decoration: const InputDecoration(
                            labelText: 'Status',
                            prefixIcon: Icon(Icons.info),
                          ),
                          items: ['Pending', 'Sedang Dicuci', 'Selesai'].map((String status) {
                            return DropdownMenuItem<String>(
                              value: status,
                              child: Text(status),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              _selectedStatus = newValue!;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Brand Dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedBrand,
                        decoration: const InputDecoration(
                          labelText: 'Shoe Brand',
                          prefixIcon: Icon(Icons.branding_watermark),
                        ),
                        items: _brandOptions.map((String brand) {
                          return DropdownMenuItem<String>(
                            value: brand,
                            child: Text(brand),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedBrand = newValue!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Custom Brand Field (Visible if 'Other')
                      if (_selectedBrand == 'Other') ...[
                         TextFormField(
                          controller: _customBrandController,
                          decoration: const InputDecoration(
                            labelText: 'Specify Brand',
                            prefixIcon: Icon(Icons.edit),
                          ),
                          validator: (value) => value!.isEmpty ? 'Please specify brand' : null,
                        ),
                        const SizedBox(height: 16),
                      ],

                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: 'Notes',
                          prefixIcon: Icon(Icons.note),
                        ),
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ),

              // 3. Price & Submit
              Card(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                margin: const EdgeInsets.only(bottom: 24),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Estimated Price",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Rp ${_estimatedPrice.toStringAsFixed(0)}", 
                        style: TextStyle(
                          fontSize: 20, 
                          fontWeight: FontWeight.bold, 
                          color: Theme.of(context).primaryColor
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              Obx(() => controller.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            
                            String finalBrand = _selectedBrand == 'Other' 
                                ? _customBrandController.text 
                                : _selectedBrand;

                            if (isEdit) {
                              controller.updateOrder(
                                widget.existingOrder!['id'],
                                _customerNameController.text,
                                finalBrand,
                                _notesController.text,
                                _selectedService!,
                                _selectedStatus,
                              );
                            } else {
                              controller.addOrder(
                                _customerNameController.text,
                                _selectedService!,
                                finalBrand,
                                _notesController.text,
                                _estimatedPrice, 
                              );
                            }
                          }
                        },
                        child: Text(isEdit ? 'Update Order' : 'Submit Order'),
                      ),
                    )),
            ],
          ),
        ),
      ),
    );
  }
}
