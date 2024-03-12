import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_application_2/constant/static_variables.dart';
import 'package:flutter_application_2/constant/global_variables.dart';
import 'package:flutter_application_2/extension.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';

import '../../model/Session.dart';
import '../../model/User.dart';
import '../home/HomePage.dart';

class WelcomeRegisterPage extends StatelessWidget {
  const WelcomeRegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Center(
      child: SafeArea(
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
                    'Tạo tài khoản',
                    style: TextStyle(
                        fontSize: 24,
                        color: GlobalVariables.darkGreyColor,
                        decoration: TextDecoration.none,
                        fontFamily: 'Tahoma',
                        fontWeight: FontWeight.w600),
                  ),
                ]),
                Padding(
                  padding: const EdgeInsets.only(top: 25),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/images/welcome.png',
                      width: 320,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text('Tham gia Facebook',
                    style: TextStyle(
                        fontSize: 25,
                        decoration: TextDecoration.none,
                        fontFamily: 'Tahoma',
                        fontWeight: FontWeight.bold,
                        color: GlobalVariables.darkGreyColor)),
                const Padding(
                    padding: EdgeInsets.only(top: 8, left: 20, right: 20),
                    child: Text(
                        'Chúng tôi sẽ giúp bạn tạo tài khoản sau vài bước dễ dàng!',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            decoration: TextDecoration.none,
                            fontFamily: 'Tahoma',
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: GlobalVariables.darkGreyColor))),
                Padding(
                    padding: const EdgeInsets.only(
                        top: 20, left: 20, right: 20, bottom: 10),
                    child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const NameRegisterPage()),
                              );
                            },
                            child: Container(
                                decoration: BoxDecoration(
                                  color: GlobalVariables.secondaryColor,
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                height: screenHeight * 0.06,
                                width: screenWidth,
                                alignment: Alignment.center,
                                child: const Text(
                                  "Bắt đầu",
                                  style: TextStyle(
                                      letterSpacing: 0.5,
                                      color: Colors.white,
                                      decoration: TextDecoration.none,
                                      fontFamily: 'Tahoma',
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500),
                                ))))),
                Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(20.0),
                                    border: Border.all(
                                        color: GlobalVariables.borderInputColor,
                                        width: 0.5)),
                                height: screenHeight * 0.06,
                                width: screenWidth,
                                alignment: Alignment.center,
                                child: const Text(
                                  "Tôi có tài khoản rồi",
                                  style: TextStyle(
                                      letterSpacing: 0.5,
                                      color: GlobalVariables.darkGreyColor,
                                      decoration: TextDecoration.none,
                                      fontFamily: 'Tahoma',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500),
                                )))))
              ],
            )),
      ),
    );
  }
}

class NameRegisterPage extends StatefulWidget {
  const NameRegisterPage({super.key});

  @override
  State<NameRegisterPage> createState() => _NameRegisterPageState();
}

class _NameRegisterPageState extends State<NameRegisterPage> {
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  bool isEmpty = false;
  bool _isLoading = false;
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
          child: Column(children: [
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
                'Tên',
                style: TextStyle(
                    fontSize: 24,
                    color: GlobalVariables.darkGreyColor,
                    decoration: TextDecoration.none,
                    fontFamily: 'Tahoma',
                    fontWeight: FontWeight.w600),
              ),
            ]),
            const Padding(
              padding: EdgeInsets.only(top: 35, bottom: 20),
              child: Text('Bạn tên gì?',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      decoration: TextDecoration.none,
                      fontSize: 30,
                      fontFamily: 'Tahoma',
                      fontWeight: FontWeight.bold,
                      color: GlobalVariables.darkGreyColor)),
            ),
            Padding(
                padding: EdgeInsets.only(
                    top: screenHeight * 0.03,
                    left: screenWidth * 0.05,
                    right: screenWidth * 0.05),
                child: Row(
                  children: [
                    Expanded(
                        child: _buildInputNameField(firstNameController, 'Họ')),
                    const SizedBox(
                        width: 10), // Add some spacing between the TextFields
                    Expanded(
                      child: _buildInputNameField(lastNameController, 'Tên'),
                    ),
                  ],
                )),
            Padding(
                padding: EdgeInsets.only(
                    left: 0.05 * screenWidth, right: 0.05 * screenWidth),
                child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                        onTap: () {
                          _isLoading = true;
                          String fName = firstNameController.text;
                          String lName = lastNameController.text;
                          setEmptyValue(fName);
                          setEmptyValue(lName);
                          if (firstNameController.text != "" &&
                              lastNameController.text != "") {
                            StaticVariable.name = "$fName $lName";
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const BirthdayRegisterPage()),
                            );
                          } else {
                            _isLoading = false;
                          }
                        },
                        child: Container(
                            decoration: BoxDecoration(
                              color: GlobalVariables.secondaryColor,
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            margin: const EdgeInsets.only(top: 30),
                            height: screenHeight * 0.06,
                            width: screenWidth,
                            alignment: Alignment.center,
                            child: _isLoading
                                ? const CircularProgressIndicator()
                                : const Text(
                                    "Tiếp",
                                    style: TextStyle(
                                        decoration: TextDecoration.none,
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontFamily: 'Tahoma',
                                        fontWeight: FontWeight.w600),
                                  )))))
          ])),
    );
  }

  bool checkEmpty(String text) {
    if (text == "") return true;
    return false;
  }

  void setEmptyValue(String text) {
    setState(() {
      isEmpty = checkEmpty(text);
    });
  }

  Widget _buildInputNameField(TextEditingController controller, String label) {
    return Material(
        color: Colors.transparent,
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: label,
            border: OutlineInputBorder(
                borderSide: const BorderSide(color: Color(0xFF3b5998)),
                borderRadius: BorderRadius.circular(20.0)),
            labelText: label,
            errorText: isEmpty ? 'Không được bỏ trống' : null,
          ),
        ));
  }
}

class BirthdayRegisterPage extends StatefulWidget {
  const BirthdayRegisterPage({super.key});

  @override
  State<BirthdayRegisterPage> createState() => _BirthdayRegisterPageState();
}

class _BirthdayRegisterPageState extends State<BirthdayRegisterPage> {
  DateTime _selectedDate = DateTime.now();
  bool isCorrect = true;
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
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.start, children: [
              MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: IconButton(
                    padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
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
                'Sinh nhật',
                style: TextStyle(
                    fontSize: 24,
                    color: GlobalVariables.darkGreyColor,
                    decoration: TextDecoration.none,
                    fontFamily: 'Tahoma',
                    fontWeight: FontWeight.w600),
              ),
            ]),
            const Padding(
              padding: EdgeInsets.only(top: 40, bottom: 20),
              child: Text('Sinh nhật bạn khi nào?',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      decoration: TextDecoration.none,
                      fontSize: 30,
                      fontFamily: 'Tahoma',
                      fontWeight: FontWeight.bold,
                      color: GlobalVariables.darkGreyColor)),
            ),
            if (isCorrect == false)
              const Padding(
                  padding: EdgeInsets.fromLTRB(15, 10, 15, 0),
                  child: Text(
                    "Hình như bạn đã nhập sai thông tin. Hãy nhớ dùng ngày sinh thật của mình nhé.",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        decoration: TextDecoration.none,
                        color: GlobalVariables.redColor,
                        fontSize: 16,
                        fontFamily: 'Tahoma',
                        fontWeight: FontWeight.w500),
                  )),
            Container(
                padding: const EdgeInsets.only(top: 10),
                width: 0.8 * screenWidth,
                height: 0.3 * screenHeight,
                child: Row(children: [
                  Expanded(
                      child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: _selectedDate,
                    minimumDate: DateTime(DateTime.now().year - 100),
                    maximumDate: DateTime(DateTime.now().year + 1),
                    onDateTimeChanged: (DateTime newDate) {
                      setState(() {
                        _selectedDate = newDate;
                      });
                    },
                  ))
                ])),
            Padding(
                padding: EdgeInsets.only(
                    left: 0.05 * screenWidth, right: 0.05 * screenWidth),
                child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                        onTap: () {
                          checkDateTime();
                          if (isCorrect) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const PolicyPage()),
                            );
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
                            child: const Text(
                              "Tiếp",
                              style: TextStyle(
                                  decoration: TextDecoration.none,
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontFamily: 'Tahoma',
                                  fontWeight: FontWeight.w600),
                            )))))
          ])),
    );
  }

  void checkDateTime() {
    bool tmpCorrect = true;
    if (DateTime.now().year - _selectedDate.year < 16) {
      tmpCorrect = false;
    }
    setState(() {
      isCorrect = tmpCorrect;
    });
  }
}

class PolicyPage extends StatelessWidget {
  const PolicyPage({super.key});

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
                      padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
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
                  'Điều khoản & Quyền riêng tư',
                  style: TextStyle(
                      decoration: TextDecoration.none,
                      fontSize: 20,
                      fontFamily: 'Tahoma',
                      color: GlobalVariables.darkGreyColor,
                      fontWeight: FontWeight.w600),
                ),
              ]),
              Padding(
                  padding: EdgeInsets.only(
                      left: 0.05 * screenWidth, right: 0.05 * screenWidth),
                  child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const AccountRegisterPage()),
                            );
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
                              child: const Text(
                                "Tiếp",
                                style: TextStyle(
                                    decoration: TextDecoration.none,
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontFamily: "Tahoma",
                                    fontWeight: FontWeight.w600),
                              ))))),
            ],
          )),
    );
  }
}

class AccountRegisterPage extends StatefulWidget {
  const AccountRegisterPage({super.key});

  @override
  State<AccountRegisterPage> createState() => _AccountRegisterPageState();
}

class _AccountRegisterPageState extends State<AccountRegisterPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController cfPasswordController = TextEditingController();
  bool _isInputValid = true;
  bool _isPasswordValid = true;
  bool _isDuplicatePassword = false;
  bool _isSame = true;
  final List<String> _errorEmailMessages = [];
  final List<String> _errorPasswordMessages = [];
  bool _isPassEmpty = true;
  bool _isCfPassEmpty = true;
  bool obscureText = true;
  bool obscureCfText = true;
  bool _isLoading = false;
  final focusInput = FocusNode();
  final focusPass = FocusNode();
  final focusCfPass = FocusNode();

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

  void checkSamePassword(String password, String cfPassword) {
    bool same = false;
    if (password != cfPassword) {
      same = false;
    } else {
      same = true;
    }
    setState(() {
      _isSame = same;
    });
  }

  void passwordInput(String text, String email) {
    bool isShort = false;
    if (text.length < 6) {
      isShort = false;
    } else {
      isShort = true;
    }
    int index = email.indexOf("@");
    if (email.contains("@")) {
      String nameEmail = email.substring(0, index);

      if (text.contains(nameEmail)) _isDuplicatePassword = true;
    } else {
      if (text.contains(email)) _isDuplicatePassword = true;
    }
    setState(() {
      _isPasswordValid = isShort;
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: IconButton(
                      padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
                      alignment: Alignment.bottomLeft,
                      icon: const Icon(
                        Icons.arrow_back,
                        size: 24,
                        color: GlobalVariables.darkGreyColor,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ))
              ]),
              const Padding(
                padding: EdgeInsets.only(top: 15, left: 15),
                child: Text('Thông tin tài khoản',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        decoration: TextDecoration.none,
                        fontSize: 24,
                        fontFamily: 'Tahoma',
                        fontWeight: FontWeight.bold,
                        color: GlobalVariables.darkGreyColor)),
              ),
              Padding(
                  padding: EdgeInsets.only(
                      top: screenHeight * 0.03, left: 20, right: 20),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInputEmailField(emailController),
                        const SizedBox(height: 15),
                        _buildInputPasswordField(passwordController,
                            isPassword: true),
                        const SizedBox(height: 15),
                        _buildCfPasswordField(cfPasswordController),
                        MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                                onTap: () async {
                                  validateInput(emailController.text);
                                  passwordInput(passwordController.text,
                                      emailController.text);
                                  checkSamePassword(passwordController.text,
                                      cfPasswordController.text);
                                  if (!_isInputValid) {
                                    _errorEmailMessages.clear();
                                    _errorEmailMessages
                                        .add('Email không hợp lệ');
                                  }
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
                                  if (_isInputValid &&
                                      _isPasswordValid &&
                                      !_isDuplicatePassword &&
                                      _isSame) {
                                    setState(() {
                                      _isLoading = true;
                                    });
                                    var body = {
                                      'email': emailController.text,
                                      'password': passwordController.text,
                                      'uuid': StaticVariable.deviceId.isEmpty
                                          ? '1'
                                          : StaticVariable.deviceId
                                    };
                                    var response = await http.post(
                                        Uri.parse('$root/signup'),
                                        headers: <String, String>{
                                          'Content-Type': 'application/json',
                                        },
                                        body: jsonEncode(body));
                                    print(response.body);
                                    var responseBody =
                                        jsonDecode(response.body);
                                    setState(() {
                                      _isLoading = false;
                                    });
                                    if (int.parse(responseBody['code']) ==
                                        1000) {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                VerifyEmailPage(
                                                    email: emailController.text,
                                                    password: passwordController
                                                        .text)),
                                      );
                                    } else {
                                      setState(() {
                                        _errorEmailMessages.clear();
                                        _errorEmailMessages
                                            .add('Email đã được sử dụng');
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
                                            color:
                                                GlobalVariables.backgroundColor,
                                          )
                                        : const Text(
                                            "Đăng ký",
                                            style: TextStyle(
                                                color: Colors.white,
                                                decoration: TextDecoration.none,
                                                fontSize: 19,
                                                fontFamily: 'Tahoma',
                                                fontWeight: FontWeight.bold),
                                          ))))
                      ]))
            ],
          )),
    );
  }

  Widget _buildInputEmailField(TextEditingController controller) {
    return Material(
        color: Colors.transparent,
        child: TextFormField(
            focusNode: focusInput,
            controller: controller,
            onTap: () {
              setState(() {
                _isInputValid = true;
                _errorEmailMessages.clear();
              });
            },
            onTapOutside: (e) {
              focusInput.unfocus();
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderSide:
                    const BorderSide(color: GlobalVariables.secondaryColor),
                borderRadius: BorderRadius.circular(20.0),
              ),
              hintText: 'Email của bạn',
              suffixIcon: _isInputValid
                  ? const Icon(null)
                  : IconButton(
                      onPressed: () {
                        setState(() {
                          emailController.clear();
                          _isInputValid = true;
                        });
                      },
                      icon: const Icon(Icons.close)),
              errorText: _errorEmailMessages.isEmpty
                  ? null
                  : _errorEmailMessages.join('\n'),
            )));
  }

  Widget _buildInputPasswordField(TextEditingController controller,
      {isPassword = false}) {
    return Material(
        color: Colors.transparent,
        child: TextFormField(
          focusNode: focusPass,
          controller: controller,
          onTap: () {
            setState(() {
              _isPasswordValid = true;
              _isDuplicatePassword = false;
              _errorPasswordMessages.clear();
            });
          },
          onTapOutside: (e) {
            focusPass.unfocus();
          },
          onChanged: (text) {
            setState(() {
              _isPassEmpty = text.characters.isEmpty ? true : false;
            });
          },
          obscureText: obscureText,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderSide:
                  const BorderSide(color: GlobalVariables.secondaryColor),
              borderRadius: BorderRadius.circular(20.0),
            ),
            hintText: 'Mật khẩu',
            suffixIcon: _isPassEmpty
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

  Widget _buildCfPasswordField(TextEditingController controller) {
    return Material(
        color: Colors.transparent,
        child: TextFormField(
          focusNode: focusCfPass,
          controller: controller,
          onTap: () {
            setState(() {
              _isSame = true;
            });
          },
          onTapOutside: (e) {
            focusCfPass.unfocus();
          },
          onChanged: (text) {
            setState(() {
              _isCfPassEmpty = text.characters.isEmpty ? true : false;
            });
          },
          obscureText: obscureCfText,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderSide:
                  const BorderSide(color: GlobalVariables.secondaryColor),
              borderRadius: BorderRadius.circular(20.0),
            ),
            hintText: 'Nhập lại mật khẩu',
            suffixIcon: _isCfPassEmpty
                ? null
                : IconButton(
                    icon: obscureCfText
                        ? const Icon(Icons.visibility_off)
                        : const Icon(Icons.visibility),
                    onPressed: () {
                      setState(() {
                        obscureCfText = !obscureCfText;
                      });
                    },
                  ),
            errorText: _isSame ? null : 'Mật khẩu nhập lại không khớp',
          ),
        ));
  }
}

class VerifyEmailPage extends StatefulWidget {
  final String email;
  final String password;
  const VerifyEmailPage(
      {super.key, required this.email, required this.password});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  TextEditingController codeController = TextEditingController();
  bool _isLoading = false;
  bool _isCodeValid = true;
  final focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    String email = widget.email;
    String password = widget.password;
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
                  'Xác nhận Email',
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
                child: Text('Chúng tôi đã gửi mã tới email của bạn',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        decoration: TextDecoration.none,
                        fontSize: 18,
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
                  child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                          onTap: () async {
                            setState(() {
                              _isLoading = true;
                            });
                            var body = {
                              'email': email,
                              "code_verify": codeController.text
                            };
                            var response = await http.post(
                                Uri.parse('$root/check_verify_code'),
                                headers: <String, String>{
                                  'Content-Type': 'application/json',
                                },
                                body: jsonEncode(body));
                            var responseBody = jsonDecode(response.body);
                            if (int.parse(responseBody['code']) == 1000) {
                              print(responseBody['data']);
                              _isLoading = false;
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        ChangeInfoAfterSignupPage(
                                            email: email, password: password)),
                              );
                            } else {
                              setState(() {
                                _isCodeValid = false;
                                _isLoading = false;
                              });
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
                                      "Xác thực",
                                      style: TextStyle(
                                          decoration: TextDecoration.none,
                                          letterSpacing: 0.5,
                                          color: Colors.white,
                                          fontSize: 20,
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
}

class ChangeInfoAfterSignupPage extends StatefulWidget {
  final String email;
  final String password;
  const ChangeInfoAfterSignupPage(
      {super.key, required this.email, required this.password});

  @override
  State<ChangeInfoAfterSignupPage> createState() =>
      _ChangeInfoAfterSignupPageState();
}

class _ChangeInfoAfterSignupPageState extends State<ChangeInfoAfterSignupPage> {
  late String token;
  late int coins;
  bool _isLoading = false;
  File? image;
  late String filename;
  late Image avt;
  bool _isImage = true;

  @override
  Widget build(BuildContext context) {
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
                  'Hoàn tất thông tin',
                  style: TextStyle(
                      fontSize: 24,
                      color: GlobalVariables.darkGreyColor,
                      decoration: TextDecoration.none,
                      fontFamily: 'Tahoma',
                      fontWeight: FontWeight.w600),
                ),
              ]),
              const Padding(
                padding: EdgeInsets.only(top: 30),
                child: Text('Hãy thêm ảnh đại diện!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        decoration: TextDecoration.none,
                        fontSize: 18,
                        fontFamily: "Tahoma",
                        fontWeight: FontWeight.w500,
                        color: GlobalVariables.darkGreyColor)),
              ),
              Padding(
                  padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: GlobalVariables.endGradientColor,
                                  width: 2.5,
                                  style: BorderStyle.solid,
                                ),
                              ),
                              child: (image != null)
                                  ? CircleAvatar(
                                      backgroundImage: avt.image,
                                      radius: 75,
                                    )
                                  : const CircleAvatar(
                                      backgroundImage: AssetImage(
                                          'assets/images/user/default-avt.jpg'),
                                      radius: 75,
                                    ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    border: Border.all(
                                        width: 0.5,
                                        color: GlobalVariables.iconColor),
                                    shape: BoxShape.circle,
                                  ),
                                  child: GestureDetector(
                                    onTap: () async {
                                      image = await uploadFile();
                                      if (image != null) {
                                        avt = await convertFileToImage(image!);
                                      }
                                      setState(() {});
                                    },
                                    child: const Icon(
                                      Icons.camera_alt_rounded,
                                      color: Colors.black,
                                      size: 22,
                                    ),
                                  )),
                            ),
                          ],
                        ),
                        _isImage
                            ? Container()
                            : const Padding(
                                padding: EdgeInsets.fromLTRB(15, 10, 15, 0),
                                child: Text(
                                  "File không hợp lệ.\nVui lòng chọn file ảnh!",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      decoration: TextDecoration.none,
                                      color: GlobalVariables.redColor,
                                      fontSize: 16,
                                      fontFamily: 'Tahoma',
                                      fontWeight: FontWeight.w500),
                                )),
                        Padding(
                          padding: const EdgeInsets.only(top: 25.0, bottom: 10),
                          child: Text(StaticVariable.name,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  decoration: TextDecoration.none,
                                  fontSize: 25,
                                  fontFamily: "Tahoma",
                                  fontWeight: FontWeight.w500,
                                  color: GlobalVariables.darkGreyColor)),
                        )
                      ])),
              Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                          onTap: () async {
                            await login();
                            Map<String, String> headers = {
                              "Content-Type": "multipart/form-data",
                              "Authorization": 'Bearer $token'
                            };
                            var request = http.MultipartRequest('POST',
                                Uri.parse('$root/change_profile_after_signup'));

                            if (image != null) {
                              var subType = getSubType(filename);
                              var avtFile = await http.MultipartFile.fromPath(
                                  'avatar', image!.path,
                                  contentType: MediaType('image', subType));
                              request.files.add(avtFile);
                            }

                            request.fields['username'] = StaticVariable.name;
                            request.headers.addAll(headers);
                            print(request.fields);

                            request.send().then((response) {
                              response.stream
                                  .transform(utf8.decoder)
                                  .listen((value) {
                                print("Value: $value");
                                var valueBody = jsonDecode(value);
                                if (int.parse(valueBody['code']) == 1000) {
                                  var data = json.decode(value)['data'];
                                  print("Data: $data");
                                  var avt = data['avatar'] as String;
                                  StaticVariable.currentUser = User(
                                      userId: int.parse(data['id']),
                                      email: data['email'],
                                      name:
                                          data['username'] ?? "Tên người dùng",
                                      avatar: (avt.isEmpty)
                                          ? "https://it4788.catan.io.vn/files/avatar-1701332613133-239789843.jpg"
                                          : avt,
                                      coins: coins);
                                  StaticVariable.currentSession = Session(
                                      StaticVariable.currentUser.name,
                                      token,
                                      StaticVariable.deviceId);

                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const HomePage()),
                                  );
                                }
                              });
                            });
                          },
                          child: Container(
                              decoration: BoxDecoration(
                                color: GlobalVariables.secondaryColor,
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              margin: const EdgeInsets.only(top: 20),
                              height: 40,
                              alignment: Alignment.center,
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                      color: GlobalVariables.backgroundColor,
                                    )
                                  : const Text(
                                      "Hoàn tất",
                                      style: TextStyle(
                                          decoration: TextDecoration.none,
                                          letterSpacing: 0.5,
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontFamily: "Tahoma",
                                          fontWeight: FontWeight.w600),
                                    )))))
            ],
          )),
    );
  }

  login() async {
    String email = widget.email;
    String password = widget.password;
    var body = {'email': email, 'password': password, 'uuid': 'string'};
    var response = await http.post(Uri.parse('$root/login'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body));
    var responseBody = jsonDecode(response.body);
    if (int.parse(responseBody['code']) == 1000) {
      var data = responseBody['data'];
      token = data['token'];
      coins = int.parse(data['coins']);
      print(data);
    }
  }

  Future<File?> uploadFile() async {
    final picker = ImagePicker();
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    List<String> imageFormat = ['.png', '.jpg', '.svg', 'jpeg'];

    if (pickedFile != null) {
      File result = File(pickedFile.path ?? " ");
      filename = result.path.split('/').last;
      if (imageFormat.contains(filename.lastChars(4).toLowerCase())) {
        _isImage = true;
        return result;
      } else {
        setState(() {
          setState(() {
            _isImage = false;
          });
        });
        return null;
      }
    } else {
      return null;
    }
  }

  Future<Image> convertFileToImage(File picture) async {
    List<int> imageBase64 = picture.readAsBytesSync();
    String imageAsString = base64Encode(imageBase64);
    Uint8List uint8list = base64.decode(imageAsString);
    Image image = Image.memory(uint8list);
    return image;
  }

  String getSubType(String filename) {
    var subType = filename.lastChars(4).toLowerCase();
    switch (subType) {
      case '.jpg':
        return 'jpg';
      case '.png':
        return 'png';
      case '.svg':
        return 'svg';
      case 'jpeg':
        return 'jpeg';
      default:
        return 'Not an image';
    }
  }
}
