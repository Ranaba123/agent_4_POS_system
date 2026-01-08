import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../services/database_helper.dart';
import '../services/localization_service.dart';
import '../services/app_theme.dart';
import '../models/customer.dart';
import '../services/responsive.dart';

class AddCustomerScreen extends StatefulWidget {
  final AppStrings strings;
  final bool isDarkMode;
  
  const AddCustomerScreen({super.key, required this.strings, this.isDarkMode = false});

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _phoneFocusNode = FocusNode();
  File? _image;
  final _imagePicker = ImagePicker();
  bool _isSaving = false;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() => _image = File(pickedFile.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e'), backgroundColor: AppTheme.accentRed),
        );
      }
    }
  }

  Future<void> _saveCustomer() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);
      
      try {
        final phone = '+94${_phoneController.text.trim()}';
        
        // Check for duplicates
        final existing = await DatabaseHelper().getCustomerByPhone(phone);
        if (existing != null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(widget.strings.customerExists, style: GoogleFonts.poppins()),
                backgroundColor: AppTheme.accentOrange,
              ),
            );
            _phoneFocusNode.requestFocus();
          }
          return;
        }

        final customer = Customer(
          name: _nameController.text.trim(),
          phone: phone,
          photoPath: _image?.path,
        );
        await DatabaseHelper().insertCustomer(customer);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Text('${customer.name} added successfully!', style: GoogleFonts.poppins()),
                ],
              ),
              backgroundColor: AppTheme.accentGreen,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.accentRed),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isSaving = false);
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final primaryColor = isDark ? AppTheme.primaryDark : AppTheme.primaryLight;
    final bgColor = isDark ? AppTheme.darkBackground : AppTheme.lightBackground;
    final cardColor = isDark ? AppTheme.darkCard : Colors.white;
    
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(widget.strings.addCustomer, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with photo
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, primaryColor.withOpacity(0.7)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: _showImagePicker,
                    child: Stack(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: cardColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                            image: _image != null
                                ? DecorationImage(
                                    image: FileImage(_image!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: _image == null
                              ? Icon(Icons.person, size: 60, color: primaryColor.withOpacity(0.4))
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: primaryColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _image != null ? 'Tap to change photo' : 'Tap to add photo',
                    style: GoogleFonts.istokWeb(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
            // Form
            Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 600),
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                child: Column(
                  children: [
                    // Name field
                    Container(
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: isDark ? null : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _nameController,
                        style: GoogleFonts.istokWeb(
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        decoration: InputDecoration(
                          labelText: widget.strings.name,
                          labelStyle: GoogleFonts.poppins(color: isDark ? Colors.white60 : null),
                          hintText: 'Enter customer name',
                          hintStyle: GoogleFonts.istokWeb(color: isDark ? Colors.white30 : null),
                          prefixIcon: Icon(Icons.person_outline, color: primaryColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                          filled: true,
                          fillColor: cardColor,
                        ),
                        textCapitalization: TextCapitalization.words,
                        validator: (value) => value == null || value.trim().isEmpty 
                            ? 'Please enter a name' 
                            : null,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Phone field
                    Container(
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: isDark ? null : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _phoneController,
                        focusNode: _phoneFocusNode,
                        style: GoogleFonts.istokWeb(
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        decoration: InputDecoration(
                          labelText: widget.strings.phone,
                          labelStyle: GoogleFonts.poppins(color: isDark ? Colors.white60 : null),
                          hintText: '7xxxxxxxx',
                          hintStyle: GoogleFonts.istokWeb(color: isDark ? Colors.white30 : null),
                          prefixIcon: Icon(Icons.phone_outlined, color: primaryColor),
                          prefixText: '+94 ',
                          prefixStyle: GoogleFonts.istokWeb(
                            color: isDark ? Colors.white : Colors.black87,
                            fontSize: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                          filled: true,
                          fillColor: cardColor,
                          counterText: "",
                        ),
                        maxLength: 9,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a phone number';
                          }
                          // Check for exactly 9 digits
                          if (!RegExp(r'^[0-9]{9}$').hasMatch(value.trim())) {
                            return widget.strings.invalidPhoneError; // "Phone number must be 9 digits"
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Save button
                    SizedBox(
                      width: double.infinity,
                      height: 64,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveCustomer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                          shadowColor: primaryColor.withOpacity(0.4),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.check_circle_outline),
                                  const SizedBox(width: 12),
                                  Text(
                                    widget.strings.save,
                                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImagePicker() {
    final isDark = widget.isDarkMode;
    final cardColor = isDark ? AppTheme.darkCard : Colors.white;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Add Photo',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildImageOption(
                      icon: Icons.camera_alt,
                      label: widget.strings.takePhoto,
                      color: Colors.blue,
                      isDark: isDark,
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.camera);
                      },
                    ),
                    _buildImageOption(
                      icon: Icons.photo_library,
                      label: widget.strings.selectGallery,
                      color: Colors.purple,
                      isDark: isDark,
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.gallery);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageOption({
    required IconData icon,
    required String label,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: color.withOpacity(isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, size: 32, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white70 : Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
