import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import './login.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'user_manager.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  List<Map<String, dynamic>> _medicines = [];
  bool _isLoading = false;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (_selectedIndex == 0) {
      _fetchMedicines();
    }
  }

  Future<void> _fetchMedicines() async {
    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse("https://drag-opal.vercel.app/api/Drag");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _medicines = data
              .map((item) => {
                    'id': item['id'],
                    'name': item['name'],
                    'type': item['type'],
                    'company': item['company'],
                  })
              .toList();
        });
      } else {
        // Handle server error
        print('Failed to fetch medicines. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Handle network error
      print('Error fetching medicines: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchMedicines();
  }

  @override
  Widget build(BuildContext context) {
    String? username = UserManager().username;
    print(_selectedIndex == 1 && username == 'admin');
    Widget body;
    if (_selectedIndex == 0) {
      body = Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.teal,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            padding: const EdgeInsets.all(16),
            child: const Column(
              children: [
                Text(
                  'منصة التداخلات الدوائية',
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'هو دليل الأدوية يحتوي على معلومات مفصلة و  واسعة عن الأدوية المتوفرة في المجال الطبي تشمل وصف عام عن الدواء, إستعماله, أسماء تجارية ووصلات لأسئلة شائعه حوله, أخبار و مقالات ذات صلة به',
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Expanded(
                  child: ListView.builder(
                    itemCount: _medicines.length,
                    itemBuilder: (context, index) {
                      final medicine = _medicines[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'اسم الدواء: ${medicine['name']}',
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                'الفئة: ${medicine['type']}',
                                style: const TextStyle(fontSize: 14.0),
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                'الشركة: ${medicine['company']}',
                                style: const TextStyle(fontSize: 14.0),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ],
      );
    } else if (_selectedIndex == 1 && username == 'admin') {
      body = AddMedicineForm();
    } else if (_selectedIndex == 2 && username == 'admin') {
      body = MedicinePreviewForm(medicines: _medicines);
    } else {
      body = MedicinePreviewSearch(medicines: _medicines);
    }
    if (username == 'admin') {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
        ),
        body: body,
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home, color: Colors.black),
              label: 'الرئيسية',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_box, color: Colors.black),
              label: 'اضافة دواء',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.post_add, color: Colors.black),
              label: 'معاينة اضافة',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search, color: Colors.black),
              label: 'معاينة',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
        ),
        body: body,
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home, color: Colors.black),
              label: 'الرئيسية',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search, color: Colors.black),
              label: 'معاينة',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      );
    }
  }
}

class AddMedicineForm extends StatefulWidget {
  const AddMedicineForm({super.key});

  @override
  _AddMedicineFormState createState() => _AddMedicineFormState();
}

class _AddMedicineFormState extends State<AddMedicineForm> {
  final TextEditingController _medicineNameController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  String? _selectedCategory;
  String _displayInfo = '';

  Future<void> _addMedicine() async {
    final name = _medicineNameController.text;
    final company = _companyController.text;
    final type = _selectedCategory ?? 'غير محددة';

    final url = Uri.parse("https://drag-opal.vercel.app/api/Drag");

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'type': type,
          'company': company,
        }),
      );

      if (response.statusCode == 201) {
        setState(() {
          _displayInfo = 'تمت إضافة الدواء بنجاح:\n'
              'اسم الدواء: $name\n'
              'الفئة: $type\n'
              'الشركة: $company';
        });
      } else {
        setState(() {
          _displayInfo = 'فشل في إضافة الدواء. حاول مرة أخرى.';
        });
      }
    } catch (e) {
      setState(() {
        _displayInfo = 'حدث خطأ أثناء الاتصال بالخادم: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('إضافة دواء جديد'),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _medicineNameController,
              decoration: const InputDecoration(
                labelText: 'اسم الدواء الأول',
                hintText: 'ادخل اسم الدواء الأول',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'الفئة',
              ),
              value: _selectedCategory,
              items: [
                'مسكنات الألم',
                'مضادات الالتهاب',
                'المضادات الحيوية',
                'أدوية القلب',
                'أدوية السكري',
                'أدوية الحساسية',
                'المكملات الغذائية',
                'أدوية الجهاز الهضمي',
                'الأدوية الجلدية',
                'الأدوية النفسية',
              ].map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCategory = newValue;
                });
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _companyController,
              decoration: const InputDecoration(
                labelText: 'الشركة',
                hintText: 'ادخل اسم الشركة',
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: _addMedicine,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      vertical: 18.0, horizontal: 30.0),
                  backgroundColor: Colors.teal,
                ),
                child: Text('إضافة',
                    style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: _displayInfo.isNotEmpty
                  ? Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.teal,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _displayInfo,
                        style:
                            const TextStyle(fontSize: 16, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class MedicinePreviewForm extends StatefulWidget {
  final List<Map<String, dynamic>> medicines;

  const MedicinePreviewForm({super.key, required this.medicines});

  @override
  _MedicinePreviewFormState createState() => _MedicinePreviewFormState();
}

class _MedicinePreviewFormState extends State<MedicinePreviewForm> {
  String? _selectedMedicine1;
  String? _selectedMedicine2;
  String _displayInfo = '';
  bool _hasSideEffects = false;
  final TextEditingController _sideEffectsController = TextEditingController();

  Future<void> _submitForm() async {
    final url = Uri.parse("https://drag-opal.vercel.app/api/DragEffect");

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'drag1Id': _selectedMedicine1,
          'drag2Id': _selectedMedicine2,
          'status': _hasSideEffects,
          'content': _sideEffectsController.text,
        }),
      );

      if (response.statusCode == 201) {
        setState(() {
          _displayInfo = 'تمت إضافة المعاينة بنجاح';
        });
      } else {
        setState(() {
          _displayInfo = 'فشل في إضافة المعاينة. حاول مرة أخرى.';
        });
      }
    } catch (e) {
      print('حدث خطأ أثناء الاتصال بالخادم: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'معاينة الأدوية',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'اسم الدواء الأول',
              border: OutlineInputBorder(),
            ),
            items: widget.medicines.map((medicine) {
              return DropdownMenuItem<String>(
                value: medicine['id'].toString(),
                child: Text(medicine['name']),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedMedicine1 = newValue;
              });
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'اسم الدواء الثاني',
              border: OutlineInputBorder(),
            ),
            items: widget.medicines.map((medicine) {
              return DropdownMenuItem<String>(
                value: medicine['id'].toString(),
                child: Text(medicine['name']),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedMedicine2 = newValue;
              });
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _submitForm,
            style: ElevatedButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(vertical: 18.0, horizontal: 30.0),
              backgroundColor: Colors.teal,
            ),
            child: Text(' اضافة معاينة',
                style: TextStyle(fontSize: 18, color: Colors.white)),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('توجد أعراض', style: TextStyle(fontSize: 16)),
              Switch(
                value: _hasSideEffects,
                onChanged: (bool newValue) {
                  setState(() {
                    _hasSideEffects = newValue;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _sideEffectsController,
            decoration: const InputDecoration(
              labelText: 'وصف الأعراض',
              border: OutlineInputBorder(),
            ),
            maxLines: 4,
          ),
        ],
      ),
    );
  }
}

class MedicinePreviewSearch extends StatefulWidget {
  final List<Map<String, dynamic>> medicines;

  const MedicinePreviewSearch({super.key, required this.medicines});

  @override
  _MedicinePreviewSearchState createState() => _MedicinePreviewSearchState();
}

class _MedicinePreviewSearchState extends State<MedicinePreviewSearch> {
  String? _selectedMedicine1;
  String? _selectedMedicine2;
  String _displayInfo = '';
  bool _hasSideEffects = false;
  final TextEditingController _sideEffectsController = TextEditingController();

  Future<void> _submitForm() async {
    final baseUrl = "https://drag-opal.vercel.app/api/DragEffect";

    try {
      // Construct the full URL with query parameters
      final url = Uri.parse(baseUrl).replace(queryParameters: {
        'drag1Id': _selectedMedicine1 ?? '',
        'drag2Id': _selectedMedicine2 ?? '',
      });
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        setState(() {
          _hasSideEffects = responseData['status'];
          _sideEffectsController.text = responseData['content'] ?? '';
          _displayInfo = _hasSideEffects ? 'يوجد أعراض' : 'لا يوجد أعراض';
        });
      } else {
        setState(() {
          _hasSideEffects = false;
          _sideEffectsController.text = '';
          _displayInfo = _hasSideEffects ? 'يوجد أعراض' : 'لا يوجد أعراض';
        });
      }
    } catch (e) {
      print('حدث خطأ أثناء الاتصال بالخادم: $e');
      setState(() {
        _hasSideEffects = false;
        _sideEffectsController.text = '';
        _displayInfo = _hasSideEffects ? 'يوجد أعراض' : 'لا يوجد أعراض';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'معاينة الأدوية',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'اسم الدواء الأول',
              border: OutlineInputBorder(),
            ),
            items: widget.medicines.map((medicine) {
              return DropdownMenuItem<String>(
                value: medicine['id'].toString(),
                child: Text(medicine['name']),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedMedicine1 = newValue;
              });
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'اسم الدواء الثاني',
              border: OutlineInputBorder(),
            ),
            items: widget.medicines.map((medicine) {
              return DropdownMenuItem<String>(
                value: medicine['id'].toString(),
                child: Text(medicine['name']),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedMedicine2 = newValue;
              });
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _submitForm,
            style: ElevatedButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(vertical: 18.0, horizontal: 30.0),
              backgroundColor: Colors.teal,
            ),
            child: const Text('معاينة',
                style: TextStyle(fontSize: 18, color: Colors.white)),
          ),
          const SizedBox(height: 16),
          if (_displayInfo.isNotEmpty) ...[
            Text(
              _displayInfo,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
          ],
          Text(
            _sideEffectsController.text,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
