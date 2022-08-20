import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smartkit_pro/ui/fullApps/hotelBooking/global/global.dart';
import 'package:smartkit_pro/ui/fullApps/hotelBooking/helper/constants.dart';
import 'package:smartkit_pro/ui/fullApps/hotelBooking/helper/route.dart';
import 'package:smartkit_pro/ui/fullApps/hotelBooking/theme/colors.dart';
import 'package:smartkit_pro/ui/fullApps/hotelBooking/ui/homeScreen.dart';
import 'package:smartkit_pro/ui/fullApps/hotelBooking/widget/appBar.dart';
import 'package:smartkit_pro/ui/fullApps/hotelBooking/widget/appButton.dart';
import 'package:smartkit_pro/ui/fullApps/hotelBooking/widget/appTextField.dart';
import 'package:smartkit_pro/ui/fullApps/hotelBooking/widget/error_dialog.dart';
import 'package:smartkit_pro/ui/fullApps/hotelBooking/widget/linkText.dart';
import 'package:smartkit_pro/ui/fullApps/hotelBooking/widget/socialMediaButton.dart';

List<FocusNode> focusNodes = [
  FocusNode(),
  FocusNode(),
];

bool _isRememberChecked = false;

class LoginWithPassword extends StatefulWidget {
  const LoginWithPassword({Key? key}) : super(key: key);

  @override
  State<LoginWithPassword> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<LoginWithPassword> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  formValidation() {
    if (emailController.text.isNotEmpty && passwordController.text.isNotEmpty)
    {
      //login
      loginNow();

    }
    else {
      showDialog(
          context: context,
          builder: (c) {
            return ErrorDialog(
              message: "Svp ecrivez votre email/password",
            );
          }
      );
    }
  }

  loginNow() async
  {
    showDialog(
        context: context,
        builder: (c) {
          return ErrorDialog(
            message: "Checking credentials",
          );
        }
    );

    User? currentUser;
    await firebaseAuth.signInWithEmailAndPassword(
      email: emailController.text.trim() ,
      password: passwordController.text.trim(),
    ).then((auth){
      currentUser = auth.user!;
    }).catchError((error){
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (c)
          {
            return ErrorDialog(
              message: error.message.toString(),
            );
          }
      );
    });
    if (currentUser != null)
    {
      readDataAndSetDataLocally(currentUser!).then((value){
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (c)=> HomeScreen()));
      });

    }
  }

  Future readDataAndSetDataLocally(User currentUser) async
  {
    await FirebaseFirestore.instance.collection("sellers")
        .doc(currentUser.uid)
        .get().then((snapshot) async {
      await sharedPreferences!.setString("uid", currentUser.uid);
      await sharedPreferences!.setString("email", snapshot.data()!["sellerEmail"]); // voir sur la console (dernier cours de la section (20)
      await sharedPreferences!.setString("name", snapshot.data()!["sellerName"]); // voir sur la console
      await sharedPreferences!.setString("photoUrl", snapshot.data()!["sellerAvatarUrl"]);


    });
  }





  onFocusChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context, ""),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        scrollDirection: Axis.vertical,
        child: Container(
            margin: EdgeInsetsDirectional.only(
                top: 20, start: 20, end: 20, bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Text(
                    'Login to your account!',
                    style: appTextTheme(context).titleLarge,
                  ),
                ),
                getSizedBox(height: 30),
                AppTextField(
                    textFieldCallBack: onFocusChanged,
                    controller: emailController,
                    hintText: 'Email',
                    prefixIcon: Icons.mail_rounded,
                    focusNode: focusNodes[0]),
                AppTextField(
                  textFieldCallBack: onFocusChanged,
                  controller: passwordController,
                  hintText: 'Password',
                  prefixIcon: Icons.lock,
                  focusNode: focusNodes[1],
                  isPasswordField: true,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Transform.scale(
                      scale: 1.2,
                      child: Checkbox(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5)),
                          activeColor: AppColors.primaryColor,
                          value: _isRememberChecked,
                          side: BorderSide(
                              color: AppColors.primaryColor, width: 2),
                          onChanged: onCheckChange),
                    ),
                    Text(
                      'Remember me',
                      style: appTextTheme(context).labelSmall,
                    )
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                AppButton(
                  btnText: 'Sign in',
                  textSize: 18,
                  voidCallBack: () {
                    formValidation(); /* CONTROLE DE SAISIE*/
                    // Navigator.pushReplacementNamed(context, homeScreen);

                  },
                ),
                SizedBox(
                  height: 30,
                ),
                linkText('Forgot the password?', context, () {
                  Navigator.pushNamed(context, forgotPasswordScreen);
                }),
                SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Divider(
                        height: 2,
                        thickness: 2,
                      ),
                    ),
                    Container(
                      margin: EdgeInsetsDirectional.only(start: 5, end: 5),
                      child: Text(
                        'or continue with',
                        style: appTextTheme(context).labelSmall?.copyWith(
                              color: AppColors.textColorLight,
                            ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        height: 2,
                        thickness: 2,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SocialMediaButton(fileName: 'google.png'),
                    SocialMediaButton(fileName: 'facebook.png'),
                    SocialMediaButton(fileName: 'apple.png'),
                  ],
                ),
                SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already have an account?',
                        style: appTextTheme(context).labelSmall),
                    linkText(' Sign in', context, () {
                      Navigator.pushNamed(context, signInScreen);
                    }),
                  ],
                )
              ],
            )),
      ),
    );
  }

  void onCheckChange(bool? value) {
    setState(() {
      _isRememberChecked = _isRememberChecked == true ? false : true;
    });
  }
}
