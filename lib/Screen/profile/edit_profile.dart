import 'package:chaton/Services/auth_services.dart';
import 'package:chaton/Services/user_services.dart';
import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _displayNameController = TextEditingController();
  final _userNameController = TextEditingController();
  final _aboutController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  final _auth = AuthServices();
  final _db = DatabaseServices();

  String _originalUsername = "";
  List<String> _allUsernames = [];
  bool _isLoading = false;
  String? _usernameError;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fetchAllUsernames();
    _userNameController.addListener(_checkUsernameAvailability);
  }

  @override
  void dispose() {
    _userNameController.removeListener(_checkUsernameAvailability);
    _displayNameController.dispose();
    _userNameController.dispose();
    _aboutController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final uid = _auth.currentUser!.uid;
    final user = await _db.getUser(uid);
    if (user == null) return;
    setState(() {
      _displayNameController.text = user.displayName;
      _userNameController.text = user.userName;
      _originalUsername = user.userName;
      _aboutController.text = user.statusMessage ?? '';
      _emailController.text = user.email;
      _phoneController.text = user.phoneNumber ?? '';
    });
  }

  Future<void> _fetchAllUsernames() async {
    final users = await _db.getAllUsers();
    setState(() {
      _allUsernames = users.map((u) => u.userName).toList();
    });
  }

  void _checkUsernameAvailability() {
    final name = _userNameController.text.trim();
    if (name.isEmpty || name == _originalUsername) {
      setState(() => _usernameError = null);
    } else if (_allUsernames.contains(name)) {
      setState(() => _usernameError = 'Username already taken');
    } else {
      setState(() => _usernameError = null);
    }
  }

  String? _validateDisplayName(String? v) {
    if (v == null || v.trim().isEmpty) return 'Display name required';
    return null;
  }

  String? _validatePhone(String? v) {
    final val = v?.trim() ?? '';
    if (val.isEmpty) return 'Phone number is required';
    if (val.length < 11) return 'Phone must be at least 11 digits';
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _usernameError != null) return;
    setState(() => _isLoading = true);

    final uid = _auth.currentUser!.uid;
    try {
      await _db.updateUser(uid, {
        'displayName': _displayNameController.text.trim(),
        'userName': _userNameController.text.trim(),
        'statusMessage': _aboutController.text.trim(),
        'email': _emailController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
      });
      await _auth.currentUser?.updateDisplayName(
        _displayNameController.text.trim(),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Update failed: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: _buildForm(),
    );
  }

  Widget _buildForm() {
    return AbsorbPointer(
      absorbing: _isLoading,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Avatar Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.teal[100],
                        child: Text(
                          _displayNameController.text.isNotEmpty
                              ? _displayNameController.text[0].toUpperCase()
                              : 'U',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal[700],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.teal,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Change Profile Photo',
                    style: TextStyle(
                      color: Colors.teal,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Form Fields
            Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Personal Information'),
                    SizedBox(height: 15),
                    _buildTextField(
                      controller: _displayNameController,
                      label: 'Display Name',
                      icon: Icons.person_outline,
                      validator: _validateDisplayName,
                      hint: 'How your name will appear to others',
                    ),
                    SizedBox(height: 20),
                    _buildTextField(
                      controller: _userNameController,
                      label: 'Username',
                      icon: Icons.alternate_email,
                      errorText: _usernameError,
                      hint: 'Your unique username',
                      suffixIcon:
                          _usernameError == null &&
                              _userNameController.text.isNotEmpty &&
                              _userNameController.text != _originalUsername
                          ? Icon(Icons.check_circle, color: Colors.green)
                          : null,
                    ),
                    SizedBox(height: 30),
                    _buildSectionTitle('Contact Information'),
                    SizedBox(height: 15),
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email',
                      icon: Icons.email_outlined,
                      readOnly: true,
                      fillColor: Colors.grey[100],
                    ),
                    SizedBox(height: 20),
                    _buildTextField(
                      controller: _phoneController,
                      label: 'Phone Number',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: _validatePhone,
                      hint: 'Enter your phone number',
                    ),
                    SizedBox(height: 30),
                    _buildSectionTitle('About'),
                    SizedBox(height: 15),
                    _buildTextField(
                      controller: _aboutController,
                      label: 'Bio',
                      icon: Icons.info_outline,
                      maxLines: 3,
                      hint: 'Tell us about yourself',
                    ),
                    SizedBox(height: 40),
                    CustomButton(
                      label: 'Save Changes',
                      onPressed: _isLoading ? null : _submit,
                      isLoading: _isLoading,
                    ),
                    SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    String? errorText,
    String? Function(String?)? validator,
    bool readOnly = false,
    TextInputType? keyboardType,
    int maxLines = 1,
    Color? fillColor,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        cursorColor: Colors.teal,
        cursorErrorColor: fillColor ?? Colors.white,
        enableInteractiveSelection: false,

        controller: controller,
        validator: validator,
        readOnly: readOnly,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: TextStyle(fontSize: 16),
        decoration: InputDecoration(
          labelText: label,

          hintText: hint,
          errorText: errorText,
          prefixIcon: Icon(icon, color: Colors.grey[600]),
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: fillColor ?? Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.teal, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.red[300]!, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.red, width: 2),
          ),

          labelStyle: TextStyle(color: Colors.grey[600]),
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        ),
      ),
    );
  }
}

/// A custom styled button with loading state
class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const CustomButton({
    Key? key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          colors: onPressed == null
              ? [Colors.grey[400]!, Colors.grey[400]!]
              : [Colors.teal[600]!, Colors.teal[700]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: onPressed == null
            ? []
            : [
                BoxShadow(
                  color: Colors.teal.withOpacity(0.3),
                  blurRadius: 15,
                  offset: Offset(0, 8),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(15),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    label,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
