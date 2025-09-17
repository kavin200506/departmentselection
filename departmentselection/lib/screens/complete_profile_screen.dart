import 'package:flutter/material.dart';
import '../services/profile_service.dart';
import 'home_screen.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});
  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  final ageController = TextEditingController();
  final nicknameController = TextEditingController();
  final quoteController = TextEditingController();

  bool loading = false;
  String errorMessage = '';

  Future<void> saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { loading = true; errorMessage = ''; });
    try {
      await ProfileService.upsertProfile({
        'name': nameController.text.trim(),
        'mobile': mobileController.text.trim(),
        'age': ageController.text.trim(),
        'nickname': nicknameController.text.trim(),
        'quote': quoteController.text.trim(),
      });
      Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => HomeScreen()),
      );
    } catch (e) {
      setState(() { errorMessage = 'Could not save profile!'; });
    }
    setState(() => loading = false);
  }

  void skipProfile() {
    Navigator.pushReplacement(
      context, MaterialPageRoute(builder: (_) => HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          // Light blue → white vertical gradient
          gradient: LinearGradient(
            colors: [Color(0xffc8e6fc), Color(0xffffffff)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  const SizedBox(height: 10),
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 34,
                          backgroundColor: Colors.blueAccent.withOpacity(0.13),
                          child: const Icon(Icons.person_add_alt_1,
                              color: Colors.blue, size: 36),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Let's set up your profile!",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: Color(0xff0a2240),
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Tell us bit about yourself \n(or you can skip this for now)",
                          style: TextStyle(fontSize: 15, color: Colors.grey[700], fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 28),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(19),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.12),
                          blurRadius: 11,
                          offset: const Offset(1, 7),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _textField(
                          controller: nameController,
                          label: "Full Name",
                          icon: Icons.person,
                        ),
                        _textField(
                          controller: mobileController,
                          label: "Mobile",
                          icon: Icons.phone_rounded,
                          inputType: TextInputType.phone,
                        ),
                        _textField(
                          controller: ageController,
                          label: "Age",
                          icon: Icons.cake_rounded,
                          inputType: TextInputType.number,
                        ),
                        _textField(
                          controller: nicknameController,
                          label: "Nickname",
                          icon: Icons.tag_faces_rounded,
                        ),
                        _textField(
                          controller: quoteController,
                          label: "Your Quote",
                          icon: Icons.format_quote_rounded,
                        ),
                        const SizedBox(height: 20),
                        if (errorMessage.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(errorMessage, style: const TextStyle(color: Colors.red, fontSize: 15)),
                          ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: loading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.check_circle),
                            label: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                loading ? "Saving..." : "Save Profile",
                                style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 2,
                              minimumSize: const Size.fromHeight(45),
                            ),
                            onPressed: loading ? null : saveProfile,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          icon: const Icon(Icons.arrow_forward_ios_rounded, size: 17),
                          label: const Text('Skip for Now'),
                          onPressed: skipProfile,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.blueAccent,
                            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _textField({required TextEditingController controller, required String label, required IconData icon, TextInputType? inputType}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        style: const TextStyle(fontSize: 17),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          filled: true,
          fillColor: Colors.blueGrey.withOpacity(0.06),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          floatingLabelStyle: const TextStyle(
              color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        validator: (v) => null,
      ),
    );
  }
}
