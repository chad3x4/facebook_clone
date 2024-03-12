import 'package:flutter/material.dart';
import '../../constant/global_variables.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  TextEditingController emailController = TextEditingController();
  bool _isInputValid = true;
  final List<String> _errorEmailMessages = [];
  final _focusInputNode = FocusNode();
  bool _isLoading = false;

  bool isEmailValid(String email) {
    const pattern = r'^[\w-]+(\.[\w-]+)*@([a-z0-9]+(-[a-z0-9]+)*\.)+[a-z]{2,}$';
    final regex = RegExp(pattern);
    return regex.hasMatch(email);
  }

  void validateInput(String text) {
    bool isValid = isEmailValid(text);

    // Update the state variable to control the error state
    setState(() {
      _isInputValid = isValid;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                GlobalVariables.startGradientColor,
                GlobalVariables.backgroundColor,
                GlobalVariables.endGradientColor,
              ])),
          child: Column(
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: IconButton(
                      padding: const EdgeInsets.only(
                          left: 10, top: 20, bottom: 20, right: 10),
                      alignment: Alignment.bottomLeft,
                      icon: const Icon(
                        Icons.arrow_back,
                        size: 24,
                        color: GlobalVariables.darkGreyColor,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    )),
                const Text(
                  'Tìm tài khoản',
                  style: TextStyle(
                      fontSize: 24,
                      color: GlobalVariables.darkGreyColor,
                      decoration: TextDecoration.none,
                      fontFamily: 'Tahoma',
                      fontWeight: FontWeight.w600),
                ),
              ]),
              Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 20, top: 15),
                  child: const Text(
                    "Nhập địa chỉ email của bạn.",
                    style: TextStyle(
                        fontSize: 18,
                        decoration: TextDecoration.none,
                        fontFamily: 'Tahoma',
                        fontWeight: FontWeight.w500,
                        color: GlobalVariables.darkGreyColor),
                  )),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: _buildInputEmailField(emailController),
              ),
              Padding(
                  padding: const EdgeInsets.only(
                      top: 20, left: 20, right: 20, bottom: 10),
                  child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                          onTap: () async {
                            _isLoading = true;
                            validateInput(emailController.text);
                            if (_isInputValid) {
                              var body = {
                                'email': emailController.text,
                              };
                              var response = await http.post(
                                  Uri.parse('$root/get_verify_code'),
                                  headers: <String, String>{
                                    'Content-Type': 'application/json',
                                  },
                                  body: jsonEncode(body));
                              var responseBody = jsonDecode(response.body);
                              print(responseBody);
                              _isLoading = false;
                              if (int.parse(responseBody['code']) == 1000) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          VerifyEmailPage(
                                            email: emailController.text,
                                          )),
                                );
                              } else {
                                setState(() {
                                  _errorEmailMessages.clear();
                                  _errorEmailMessages.add("Email không tồn tai");
                                });
                              }
                            } else {
                              _isLoading = false;
                              _errorEmailMessages.clear();
                              _errorEmailMessages.add("Email không hợp lệ");
                            }
                          },
                          child: Container(
                              decoration: BoxDecoration(
                                color: GlobalVariables.secondaryColor,
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              height: screenHeight * 0.06,
                              width: screenWidth,
                              alignment: Alignment.center,
                              child: !_isLoading
                                  ? const Text(
                                      "Tìm tài khoản",
                                      style: TextStyle(
                                          letterSpacing: 0.5,
                                          color: Colors.white,
                                          decoration: TextDecoration.none,
                                          fontFamily: 'Tahoma',
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500),
                                    )
                                  : const CircularProgressIndicator(
                                      color: GlobalVariables.backgroundColor,
                                    ))))),
            ],
          )),
    );
  }

  Widget _buildInputEmailField(TextEditingController controller) {
    return Material(
      color: Colors.transparent,
      child: TextFormField(
        focusNode: _focusInputNode,
        onTap: () {
          setState(() {
            _isInputValid = true;
          });
        },
        onTapOutside: (e) {
          _focusInputNode.unfocus();
        },
        controller: controller,
        decoration: InputDecoration(
            border: OutlineInputBorder(
              borderSide:
                  const BorderSide(color: GlobalVariables.secondaryColor),
              borderRadius: BorderRadius.circular(20.0),
            ),
            labelText: 'Email',
            errorText: _errorEmailMessages.isEmpty
              ? null
              : _errorEmailMessages.join('\n'),
      ))
    );
  }
}

class VerifyEmailPage extends StatefulWidget {
  final String email;
  const VerifyEmailPage({super.key, required this.email});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  TextEditingController codeController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isCodeValid = true;
  final focusNode = FocusNode();
  final _focusPasswordNode = FocusNode();
  bool obscureText = true;
  bool _isEmpty = true;
  bool _isDuplicatePassword = false;
  bool _isPasswordValid = true;
  final List<String> _errorPasswordMessages = [];


  void passwordInput(String text, String email) {
    bool isShort = true;
    if (text.length < 6) {
      isShort = true;
    } else {
      isShort = false;
    }
    int index = email.indexOf("@");
    if (email.contains("@")) {
      String nameEmail = email.substring(0, index);

      if (text.contains(nameEmail)) _isDuplicatePassword = true;
    } else {
      if (text.contains(email)) _isDuplicatePassword = true;
    }
    setState(() {
      _isPasswordValid = !isShort;
    });
  }

  @override
  Widget build(BuildContext context) {
    String email = widget.email;
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                GlobalVariables.startGradientColor,
                GlobalVariables.backgroundColor,
                GlobalVariables.endGradientColor,
              ])),
          child: Column(
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: IconButton(
                      padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
                      alignment: Alignment.bottomLeft,
                      icon: const Icon(
                        Icons.arrow_back,
                        size: 24,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    )),
                const Text(
                  'Đặt lại mật khẩu mới',
                  style: TextStyle(
                      fontSize: 24,
                      color: GlobalVariables.darkGreyColor,
                      decoration: TextDecoration.none,
                      fontFamily: 'Tahoma',
                      fontWeight: FontWeight.w600),
                ),
              ]),
              const Padding(
                padding: EdgeInsets.only(top: 40),
                child: Text('Mã xác nhận đã được gửi tới email của bạn',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        decoration: TextDecoration.none,
                        fontSize: 16,
                        fontFamily: "Tahoma",
                        fontWeight: FontWeight.w500,
                        color: GlobalVariables.darkGreyColor)),
              ),
              Padding(
                  padding: EdgeInsets.only(
                      top: screenHeight * 0.03, left: 20, right: 20),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: _buildInputCodeField(codeController)),
                      ])),
              Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: _buildInputPasswordField(passwordController)),
                      ])),
              Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                          onTap: () async {
                            passwordInput(passwordController.text,
                                email);
                            if (!_isPasswordValid) {
                              _errorPasswordMessages.clear();
                              _errorPasswordMessages
                                  .add('Mật khẩu quá ngắn');
                            }
                            if (_isDuplicatePassword) {
                              _errorPasswordMessages.clear();
                              _errorPasswordMessages
                                  .add('Mật khẩu trùng với email');
                            }
                            if (_isPasswordValid &&
                                !_isDuplicatePassword) {
                              setState(() {
                                _isLoading = true;
                              });
                              var body = {
                                'email': email,
                                "code": codeController.text,
                                "password": passwordController.text
                              };
                              var response = await http.post(
                                  Uri.parse('$root/reset_password'),
                                  headers: <String, String>{
                                    'Content-Type': 'application/json',
                                  },
                                  body: jsonEncode(body));
                              var responseBody = jsonDecode(response.body);
                              if (int.parse(responseBody['code']) == 1000) {
                                print(responseBody['data']);
                                _isLoading = false;
                                Navigator.pop(context);
                              } else {
                                setState(() {
                                  _isCodeValid = false;
                                  _isLoading = false;
                                });
                              }
                            }
                          },
                          child: Container(
                              decoration: BoxDecoration(
                                color: GlobalVariables.secondaryColor,
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              margin: const EdgeInsets.only(top: 20),
                              height: screenHeight * 0.06,
                              width: screenWidth,
                              alignment: Alignment.center,
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                      color: GlobalVariables.backgroundColor,
                                    )
                                  : const Text(
                                      "Đặt mật khẩu mới",
                                      style: TextStyle(
                                          decoration: TextDecoration.none,
                                          letterSpacing: 0.5,
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontFamily: "Tahoma",
                                          fontWeight: FontWeight.w600),
                                    )))))
            ],
          )),
    );
  }

  Widget _buildInputCodeField(TextEditingController controller) {
    return Material(
        color: Colors.transparent,
        child: TextFormField(
          focusNode: focusNode,
          onTap: () {
            setState(() {
              _isCodeValid = true;
            });
          },
          onTapOutside: (e) {
            focusNode.unfocus();
          },
          controller: controller,
          decoration: InputDecoration(
              hintText: 'Code',
              border: OutlineInputBorder(
                borderSide:
                    const BorderSide(color: GlobalVariables.secondaryColor),
                borderRadius: BorderRadius.circular(20.0),
              ),
              labelText: 'Code',
              errorText: _isCodeValid ? null : 'Mã xác nhận không chính xác'),
        ));
  }

  Widget _buildInputPasswordField(TextEditingController controller) {
    return Material(
        color: Colors.transparent,
        child: TextFormField(
          focusNode: _focusPasswordNode,
          controller: controller,
          obscureText: obscureText,
          onTap: () {
            _errorPasswordMessages.clear();
            _isDuplicatePassword = false;
          },
          onChanged: (text) {
            setState(() {
              _isEmpty = text.characters.isEmpty ? true : false;
            });
          },
          onTapOutside: (e) {
            if (_focusPasswordNode.hasFocus) {
              _focusPasswordNode.unfocus();
            }
          },
          decoration: InputDecoration(
              border: OutlineInputBorder(
                borderSide:
                    const BorderSide(color: GlobalVariables.secondaryColor),
                borderRadius: BorderRadius.circular(20.0),
              ),
              labelText: 'Mật khẩu mới',
              hintText: 'Mật khẩu mới',
              suffixIcon: _isEmpty
                  ? null
                  : IconButton(
                      icon: obscureText
                          ? const Icon(Icons.visibility_off)
                          : const Icon(Icons.visibility),
                      onPressed: () {
                        setState(() {
                          obscureText = !obscureText;
                        });
                      },
                    ),
              errorText: _errorPasswordMessages.isEmpty
                  ? null
                  : _errorPasswordMessages.join('\n'),
          ),
        ));
  }
}
