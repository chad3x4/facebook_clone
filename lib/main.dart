import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter_application_2/constant/static_variables.dart';
import 'package:flutter_application_2/constant/global_variables.dart';
import 'package:flutter_application_2/model/User.dart';
import 'package:flutter_application_2/screen/auth/ForgotPasswordPage.dart';
import 'dart:io' show Platform;

import 'package:flutter_application_2/screen/auth/RegisterPage.dart';
import 'package:flutter_application_2/screen/home/HomePage.dart';

// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';
import 'package:http/http.dart' as http;

import 'model/Session.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  StaticVariable.deviceId = await getDeviceId();
  print(StaticVariable.deviceId);
  runApp(const MyApp());
}

Future<String> getDeviceId() async {
  String deviceId = '1';
  // try {
  //   DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  //   if (Platform.isAndroid) {
  //     AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  //     deviceId = androidInfo.androidId; // Android device ID
  //   } else if (Platform.isIOS) {
  //     IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
  //     deviceId = iosInfo.identifierForVendor; // iOS device ID
  //   }
  // } catch (e) {
  //   print('Error getting device ID: $e');
  // }
  return deviceId;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Anti-Facebook',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _isInputValid = true;
  bool _isPasswordValid = true;
  bool _isDuplicatePassword = false;
  bool _isEmpty = true;
  List<String> _errorPasswordMessages = [];
  bool obscureText = true;
  bool _isLoading = false;
  final _focusInputNode = FocusNode();
  final _focusPasswordNode = FocusNode();

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
      _isLoading = _isInputValid && _isPasswordValid;
    });
  }

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
      _isLoading = _isPasswordValid && _isInputValid;
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
              SizedBox(
                  height: screenHeight * 0.35,
                  width: screenWidth,
                  child: Icon(
                    Icons.facebook_outlined,
                    size: screenWidth * 0.2,
                    color: GlobalVariables.secondaryColor,
                  )),
              Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Column(children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInputEmailField(emailController),
                        const SizedBox(height: 15),
                        _buildInputPasswordField(passwordController,
                            isPassword: true),
                        MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                                onTap: () async {
                                  _isLoading = true;
                                  validateInput(emailController.text);
                                  passwordInput(passwordController.text,
                                      emailController.text);
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
                                      !_isDuplicatePassword) {
                                    var body = {
                                      'email': emailController.text,
                                      'password': passwordController.text,
                                      'uuid': StaticVariable.deviceId.isEmpty
                                          ? '1'
                                          : StaticVariable.deviceId
                                    };
                                    var response = await http.post(
                                        Uri.parse('$root/login'),
                                        headers: <String, String>{
                                          'Content-Type': 'application/json',
                                        },
                                        body: jsonEncode(body));
                                    var responseBody =
                                        jsonDecode(response.body);
                                    print(responseBody);
                                    _isLoading = false;
                                    if (int.parse(responseBody['code']) ==
                                        1000) {
                                      var data = responseBody['data'];
                                      var token = data['token'];
                                      var avt = data['avatar'] as String;
                                      StaticVariable.currentUser = User(
                                          userId: int.parse(data['id']),
                                          email: emailController.text,
                                          name: data['username'] ??
                                              "Tên người dùng",
                                          avatar:
                                              (avt.isEmpty) ? defaultavt : avt,
                                          coins: int.parse(data['coins']));
                                      StaticVariable.currentSession = Session(
                                          StaticVariable.currentUser.name,
                                          token,
                                          StaticVariable.deviceId ?? '1');
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const HomePage()),
                                      );
                                    } else {
                                      setState(() {
                                        _errorPasswordMessages.clear();
                                        _errorPasswordMessages.add(
                                            'Mật khẩu sai hoặc tài khoản không tồn tại');
                                      });
                                    }
                                  }
                                },
                                child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20.0),
                                      color: GlobalVariables.secondaryColor,
                                    ),
                                    margin: const EdgeInsets.only(top: 20),
                                    height: screenHeight * 0.06,
                                    width: screenWidth,
                                    alignment: Alignment.center,
                                    child: !_isLoading
                                        ? const Text(
                                            "Đăng nhập",
                                            style: TextStyle(
                                                color: Colors.white,
                                                decoration: TextDecoration.none,
                                                fontSize: 16,
                                                fontFamily: 'Tahoma',
                                                fontWeight: FontWeight.bold),
                                          )
                                        : const CircularProgressIndicator(
                                            color:
                                                GlobalVariables.backgroundColor,
                                          )))),
                        !_isLoading
                            ? Column(
                                children: [
                                  MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const ForgotPasswordPage()),
                                            );
                                          },
                                          child: Container(
                                            margin:
                                                const EdgeInsets.only(top: 15),
                                            alignment: Alignment.center,
                                            child: const Text(
                                              "Bạn quên mật khẩu ư?",
                                              style: TextStyle(
                                                  color: GlobalVariables
                                                      .darkGreyColor,
                                                  decoration:
                                                      TextDecoration.none,
                                                  fontSize: 15,
                                                  fontFamily: 'Tahoma',
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ))),
                                ],
                              )
                            : Container(),
                      ],
                    ),
                  ])),
              Container(
                height: 0.2 * screenHeight,
                alignment: Alignment.bottomCenter,
                child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const WelcomeRegisterPage()),
                          );
                        },
                        child: Container(
                          height: 40,
                          margin: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: GlobalVariables.secondaryColor,
                                width: 1.5),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            "Tạo tài khoản mới",
                            style: TextStyle(
                                color: GlobalVariables.secondaryColor,
                                decoration: TextDecoration.none,
                                fontSize: 16,
                                fontFamily: 'Tahoma',
                                fontWeight: FontWeight.w500),
                          ),
                        ))),
              )
            ],
          )),
    );
  }

  Widget _buildInputEmailField(TextEditingController controller) {
    return Material(
        color: Colors.transparent,
        child: TextFormField(
          focusNode: _focusInputNode,
          controller: controller,
          onTap: () {
            setState(() {
              _isInputValid = true;
            });
          },
          onTapOutside: (e) {
            if (_focusInputNode.hasFocus) {
              _focusInputNode.unfocus();
            }
          },
          decoration: InputDecoration(
              border: OutlineInputBorder(
                borderSide:
                    const BorderSide(color: GlobalVariables.secondaryColor),
                borderRadius: BorderRadius.circular(20.0),
              ),
              labelText: "Email",
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
              errorText: _isInputValid ? null : 'Email không hợp lệ'),
        ));
  }

  Widget _buildInputPasswordField(TextEditingController controller,
      {isPassword = false}) {
    return Material(
        color: Colors.transparent,
        child: TextFormField(
          focusNode: _focusPasswordNode,
          controller: controller,
          obscureText: obscureText,
          onTap: () {
            setState(() {
              _errorPasswordMessages.clear();
              _isDuplicatePassword = false;
            });
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
            labelText: 'Mật khẩu',
            hintText: 'Mật khẩu',
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
