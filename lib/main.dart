// lib/main.dart
// Single-file Flutter app implementing a Pooja booking flow.
// - Pooja list with AnimatedCrossFade accordion
// - Sankalpa Details bottom sheet with validation
// - Priest selection, mock payment, and booking success
//
// Follow the user's UI and behavior requirements closely.

import 'package:flutter/material.dart';

void main() {
  runApp(const PoojaApp());
}

const Color kDarkRed = Color(0xFF8B0000);

class PoojaApp extends StatelessWidget {
  const PoojaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pooja Booking',
      theme: ThemeData(
        primaryColor: kDarkRed,
        colorScheme: ColorScheme.fromSwatch().copyWith(primary: kDarkRed),
      ),
      home: const PoojaListScreen(),
    );
  }
}

// Model that carries booking info between screens.
class BookingData {
  final String poojaName;
  final String veda;
  final String sutra;
  final String gotra;
  final String name;

  BookingData({
    required this.poojaName,
    required this.veda,
    required this.sutra,
    required this.gotra,
    required this.name,
  });
}

class Priest {
  final String name;
  final String experience;
  final double rating;
  final int price;

  const Priest({
    required this.name,
    required this.experience,
    required this.rating,
    required this.price,
  });
}

class PoojaListScreen extends StatefulWidget {
  const PoojaListScreen({super.key});

  @override
  State<PoojaListScreen> createState() => _PoojaListScreenState();
}

class _PoojaListScreenState extends State<PoojaListScreen> {
  bool _expanded = false;

  static const List<String> poojas = [
    'Ayudha Pooja',
    'Ayyappa Swamy Pooja',
    'Bhagavathi Seva',
    'Bhoomi Pooja',
    'Chandi Parayanam (Saptashati)',
    'Ganapathi Pooja',
    'Krishna Jayanthi Pooja (Janmashtami)',
    'Lakshmi Pooja',
    'Lalitha Sahasranama Pooja',
    'New Business/Office Opening Pooja',
    'New Vehicle Pooja',
    'Punyaha Vachanam',
    'Rudrabhishekam',
    'Samaradhanai Pooja',
    'Saraswathi Pooja',
    'Sathyanarayana Swamy Pooja',
    'Srimad Bhagavatam Parayanam',
    'Sumangali Pooja',
    'Vara Lakshmi Pooja',
    'Vasakal Pooja (Nilai Vasal Pooja)',
    'Veda Parayanam',
  ];

  void _openSankalpaSheet(String pooja) async {
    final BookingData? result = await showModalBottomSheet<BookingData>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: SankalpaForm(poojaName: pooja),
      ),
    );

    if (result != null) {
      // Navigate to Priest Selection screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PriestSelectionScreen(bookingData: result),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Poojas'),
        backgroundColor: kDarkRed,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Accordion header
            GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Container(
                decoration: BoxDecoration(
                  color: kDarkRed,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Poojas',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ),
                    Icon(
                      _expanded ? Icons.expand_more : Icons.chevron_right,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: _buildPoojaList(),
              crossFadeState: _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPoojaList() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(top: 4),
        child: ListView.separated(
          itemCount: poojas.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final String pooja = poojas[index];
            return InkWell(
              onTap: () => _openSankalpaSheet(pooja),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        pooja,
                        style: const TextStyle(color: kDarkRed, fontSize: 16),
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: kDarkRed),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// Sankalpa Details bottom sheet as a StatefulWidget
class SankalpaForm extends StatefulWidget {
  final String poojaName;

  const SankalpaForm({super.key, required this.poojaName});

  @override
  State<SankalpaForm> createState() => _SankalpaFormState();
}

class _SankalpaFormState extends State<SankalpaForm> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedVeda;
  String? _selectedSutra;
  String? _selectedGotra;
  final TextEditingController _nameController = TextEditingController();

  static const List<String> vedaOptions = ['Rig', 'Yajur', 'Sama', 'Atharvana'];
  static const List<String> sutraOptions = ['Apastamba', 'Bodhayana', 'Katyayana', "Other / Don't Know"];
  static const List<String> gotraOptions = [
    'Bharadwaja',
    'Kashyapa',
    'Vashishta',
    'Vishwamitra',
    'Gautama',
    'Jamadagni',
    'Atri',
    'Agastya',
    'Bhrigu',
    'Kaushika',
    'Sandilya',
    'Garga',
    'Krishnatreya',
  ];

  void _showSnack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _onFindPriests() {
    if (!_formKey.currentState!.validate()) {
      _showSnack('Please fill all required fields');
      return;
    }

    final BookingData booking = BookingData(
      poojaName: widget.poojaName,
      veda: _selectedVeda!,
      sutra: _selectedSutra!,
      gotra: _selectedGotra ?? '',
      name: _nameController.text.trim(),
    );

    Navigator.of(context).pop(booking);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Enter Sankalpa Details',
                style: TextStyle(color: kDarkRed, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                widget.poojaName,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 16),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Veda
                    DropdownButtonFormField<String>(
                      decoration: _inputDecoration('Veda'),
                      items: vedaOptions
                          .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                          .toList(),
                      value: _selectedVeda,
                      onChanged: (v) => setState(() => _selectedVeda = v),
                      validator: (v) => (v == null || v.isEmpty) ? 'Please select Veda' : null,
                    ),
                    const SizedBox(height: 12),

                    // Sutra
                    DropdownButtonFormField<String>(
                      decoration: _inputDecoration('Sutra'),
                      items: sutraOptions
                          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      value: _selectedSutra,
                      onChanged: (v) => setState(() => _selectedSutra = v),
                      validator: (v) => (v == null || v.isEmpty) ? 'Please select Sutra' : null,
                    ),
                    const SizedBox(height: 12),

                    // Gotra - Autocomplete
                    Autocomplete<String>(
                      optionsBuilder: (textEditingValue) {
                        if (textEditingValue.text == '') {
                          return const Iterable<String>.empty();
                        }
                        return gotraOptions.where((option) => option.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                      },
                      onSelected: (selection) => _selectedGotra = selection,
                      fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                        return TextFormField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: _inputDecoration('Gotra'),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter Gotra' : null,
                        );
                      },
                    ),
                    const SizedBox(height: 12),

                    // Sharmaanamam (Your Name)
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: _inputDecoration('Sharmaanamam (Your Name)'),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter your name' : null,
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kDarkRed,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: _onFindPriests,
                        child: const Text('Find Priests'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: kDarkRed)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    );
  }
}

// Priest Selection Screen - Stateless as requested
class PriestSelectionScreen extends StatelessWidget {
  final BookingData bookingData;

  const PriestSelectionScreen({super.key, required this.bookingData});

  static const List<Priest> mockPriests = [
    Priest(name: 'Ramesh Sharma', experience: '10 years experience', rating: 4.8, price: 2100),
    Priest(name: 'Mukesh Nair', experience: '8 years experience', rating: 4.6, price: 1800),
    Priest(name: 'S. Raghavan', experience: '12 years experience', rating: 4.9, price: 2500),
    Priest(name: 'K. Anil', experience: '6 years experience', rating: 4.4, price: 1600),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Priest'),
        backgroundColor: kDarkRed,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Booking summary card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bookingData.poojaName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  Text('Veda: ${bookingData.veda} | Sutra: ${bookingData.sutra}'),
                  const SizedBox(height: 4),
                  Text('Gotra: ${bookingData.gotra} | Name: ${bookingData.name}'),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: ListView.separated(
                itemCount: mockPriests.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final Priest priest = mockPriests[index];
                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.grey[200],
                            child: const Icon(Icons.person, color: Colors.black54),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(priest.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text(priest.experience, style: const TextStyle(color: Colors.grey)),
                                const SizedBox(height: 6),
                                Row(
                                  children: List.generate(
                                    5,
                                    (i) => Icon(Icons.star, size: 16, color: i < priest.rating.round() ? Colors.amber : Colors.grey[300]),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('₹ ${priest.price}', style: const TextStyle(fontWeight: FontWeight.bold, color: kDarkRed)),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: kDarkRed),
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (_) => PaymentScreen(bookingData: bookingData, priest: priest),
                                  ));
                                },
                                child: const Text('Book Now'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Simple mock payment screen using StatefulWidget (stateful for payment flow)
class PaymentScreen extends StatefulWidget {
  final BookingData bookingData;
  final Priest priest;

  const PaymentScreen({super.key, required this.bookingData, required this.priest});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _processing = false;

  Future<void> _mockPay() async {
    setState(() => _processing = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _processing = false);

    // Simulate payment success and navigate to success screen
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const BookingSuccessScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: kDarkRed,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pooja: ${widget.bookingData.poojaName}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Priest: ${widget.priest.name} | Price: ₹ ${widget.priest.price}'),
            const SizedBox(height: 20),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Mock Razorpay Interface', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 6),
                    Text('This is a mock payment interface for demonstration purposes.'),
                  ],
                ),
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _processing ? null : _mockPay,
                style: ElevatedButton.styleFrom(backgroundColor: kDarkRed, padding: const EdgeInsets.symmetric(vertical: 14)),
                child: _processing
                    ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text('Pay ₹ ${widget.priest.price}'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Booking success screen - Stateless
class BookingSuccessScreen extends StatelessWidget {
  const BookingSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(color: Colors.green[50], shape: BoxShape.circle),
                child: const Center(
                  child: Icon(Icons.check, color: Colors.green, size: 64),
                ),
              ),
              const SizedBox(height: 24),
              const Text('Booking Confirmed!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kDarkRed)),
              const SizedBox(height: 8),
              const Text(
                'Your pooja has been booked successfully. The priest will contact you shortly.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black87),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: kDarkRed, padding: const EdgeInsets.symmetric(vertical: 14)),
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const PoojaListScreen()),
                      (route) => false,
                    );
                  },
                  child: const Text('Back to Home'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
