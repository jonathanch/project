

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartkit_pro/ui/fullApps/hotelBooking/helper/constants.dart';
import 'package:smartkit_pro/ui/fullApps/hotelBooking/helper/route.dart';
import 'package:smartkit_pro/ui/fullApps/hotelBooking/theme/colors.dart';
import 'package:smartkit_pro/ui/fullApps/hotelBooking/ui/homeScreen.dart';
import 'package:smartkit_pro/ui/fullApps/hotelBooking/widget/appBar.dart';
import 'package:smartkit_pro/ui/fullApps/hotelBooking/widget/appButton.dart';
import 'package:smartkit_pro/ui/fullApps/hotelBooking/widget/appTextField.dart';
import 'package:smartkit_pro/ui/fullApps/hotelBooking/widget/imageAsset.dart';

import 'package:firebase_storage/firebase_storage.dart' as fStorage;
import '../global/global.dart';
import '../widget/error_dialog.dart';
import '../widget/loading_dialog.dart';

List<FocusNode> focusNodes = [
  FocusNode(),
  FocusNode(),
  FocusNode(),
  FocusNode(),
  FocusNode(),
  FocusNode(),
  FocusNode(),
];

var selectedValue = "Male";

class SignUpManuallyScreen extends StatefulWidget {
  const SignUpManuallyScreen({Key? key}) : super(key: key);

  @override
  State<SignUpManuallyScreen> createState() => _SignUpManuallyScreenState();
}

class _SignUpManuallyScreenState extends State<SignUpManuallyScreen> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController nicknameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController sexController = TextEditingController();
  TextEditingController locationController = TextEditingController();

  //declaration
  XFile? imageXFile;
  final ImagePicker _picker = ImagePicker();

  String sellerImageUrl = ""; // pour initialiser upload image dans firebase

  // pour appeler la galery
  Future<void> _getImage() async
  {
    imageXFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      imageXFile;
    });
  }


  /* CONTROLE DE SAISIE */
  Future<void> formValidation() async
  {
    if (imageXFile == null) {
      showDialog(
          context: context,
          builder: (c) {
            return ErrorDialog(
              message: "Selectioner une image",
            );
          }
      );
    }
    else {
      if (passwordController.text == confirmPasswordController.text) {
        if (confirmPasswordController.text.isNotEmpty &&
            emailController.text.isNotEmpty && nameController.text.isNotEmpty &&
            phoneController.text.isNotEmpty &&
            nicknameController.text.isNotEmpty) {
          // start uploading image
          showDialog(
              context: context,
              builder: (c) {
                return LoadingDialog(
                  message: "Inscription",
                );
              }
          );
          String fileName = DateTime
              .now()
              .microsecondsSinceEpoch
              .toString();
          fStorage.Reference reference = fStorage.FirebaseStorage.instance.ref()
              .child("sellers")
              .child(fileName);
          fStorage.UploadTask uploadTask = reference.putFile(
              File(imageXFile!.path));
          fStorage.TaskSnapshot taskSnapshot = await uploadTask
              .whenComplete(() {});
          await taskSnapshot.ref.getDownloadURL().then((url) {
            sellerImageUrl = url;

            // save info to firestore cf.la fonction en bas
            signUpAndAuthenticateSeller();


          });
        }
        else {
          showDialog(
              context: context,
              builder: (c) {
                return ErrorDialog(
                  message: "Veuillez entrer l'ensemble des informations obligatoires",
                );
              }
          );
        }
      }
      else {
        showDialog(
            context: context,
            builder: (c) {
              return ErrorDialog(
                message: "Le mot de passe est diffèrent",
              );
            }
        );
      }
    }
  }

  // pour plusieurs users
  void signUpAndAuthenticateSeller() async
  {
    User? currentUser;

    await firebaseAuth.createUserWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    ).then((auth) {
      currentUser = auth.user;
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

    if(currentUser != null)
    {
      saveDataToFirestore(currentUser!).then((value) {
        Navigator.pop(context);
        // send user to homePage
        Route newRoute = MaterialPageRoute(builder: (c) => HomeScreen());
        Navigator.pushReplacement(context, newRoute);
      });
    }
  }

  // pour un seul user donc on crée la fonction ci-dessus
  Future saveDataToFirestore(User currentUser) async
  {
    FirebaseFirestore.instance.collection("sellers").doc(currentUser.uid).set({
      "sellerUID": currentUser.uid,
      "sellerEmail": currentUser.email,
      "sellerName": nameController.text.trim(),
      "sellerAvatarUrl": sellerImageUrl,
      "phone": phoneController.text.trim(),
      "nickname": nicknameController.text.trim(),
      "status": "approved",
      "earnings": 0.0,
    //  "lat": position!.latitude,
      // "lng": position!.longitude,
    });

    // save data to locally
    sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences!.setString("uid", currentUser.uid);
    await sharedPreferences!.setString("email", currentUser.email.toString());
    await sharedPreferences!.setString("name", nameController.text.trim());
    await sharedPreferences!.setString("nickname", nicknameController.text.trim());
    await sharedPreferences!.setString("photoUrl", sellerImageUrl);


  }


  List<DropdownMenuItem<String>> get dropdownItems {
    List<DropdownMenuItem<String>> menuItems = [
      DropdownMenuItem(
          value: "Male",
          child: Text(
            "Male",
            style: appTextTheme(context).labelSmall,
          )),
      DropdownMenuItem(
          value: "Female",
          child: Text(
            "Female",
            style: appTextTheme(context).labelSmall,
          )),
    ];
    return menuItems;
  }

  void onFocusChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context, "Fill your profile"),
      body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsetsDirectional.all(20),

            child: Column(

              children: [

                Stack(

                  children: [
            const SizedBox(height: 10,),
            InkWell(
              onTap: ()
              {
                _getImage();
              },
                    child:CircleAvatar(

                      radius: 60,
                      backgroundColor: AppColors.primaryLightColor,
                      // Attention à bien prendre dart.io
                      backgroundImage: imageXFile == null ? null : FileImage(
                        File(imageXFile!.path)  ),
                      child: imageXFile == null
                          ?
                       imageAsset(
                        isNormalImage: true,
                        fileName: 'avatar.png',
                        imgHeight: 70,
                        imgWidth: 70,
                      ) : null ,
                    ),
            ),
                    PositionedDirectional(
                      bottom: 0,
                      end: 0,
                      child: CircleAvatar(
                        radius: 15,
                        child: imageAsset(

                          isNormalImage: false,
                          fileName: 'ic_edit.svg',
                          imgHeight: 15,
                          imgWidth: 15,
                        ),
                      ),
                    )
                  ],
                ),
                getSizedBox(height: 20),
                AppTextField(
                    textFieldCallBack: onFocusChanged,
                    controller: nameController,
                    hintText: 'Full name',
                    prefixIcon: Icons.person,
                    focusNode: focusNodes[0]),
                AppTextField(
                    textFieldCallBack: onFocusChanged,
                    controller: nicknameController,
                    hintText: 'Nickname',
                    prefixIcon: Icons.person,
                    focusNode: focusNodes[1]),
                AppTextField(
                  textFieldCallBack: onFocusChanged,
                  hintText: 'Date of birth',
                  prefixIcon: Icons.calendar_month,
                  focusNode: focusNodes[2],
                  keyboardType: TextInputType.datetime,
                ),
                AppTextField(
                  textFieldCallBack: onFocusChanged,
                  controller: emailController,
                  hintText: 'Email',
                  prefixIcon: Icons.mail_rounded,
                  focusNode: focusNodes[3],
                  keyboardType: TextInputType.emailAddress,
                ),
                AppTextField(
                  textFieldCallBack: onFocusChanged,
                  controller: passwordController,
                  hintText: 'Password',
                  prefixIcon: Icons.lock,
                  focusNode: focusNodes[5],
                  isPasswordField: true,

                ),
                AppTextField(
                  textFieldCallBack: onFocusChanged,
                  controller: confirmPasswordController,
                  hintText: 'confirm Password',
                  prefixIcon: Icons.lock,
                  focusNode: focusNodes[6],
                  isPasswordField: true,

                ),
                AppTextField(
                  textFieldCallBack: onFocusChanged,
                  controller: phoneController,
                  hintText: 'Phone number',
                  prefixIcon: Icons.phone_android,
                  focusNode: focusNodes[4],
                  keyboardType: TextInputType.phone,
                ),
                DropdownButtonFormField(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                  decoration: InputDecoration(
                    prefixIcon: selectedValue == "Male"
                        ? Icon(Icons.male, color: AppColors.textColorLight)
                        : Icon(Icons.female, color: AppColors.textColorLight),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    filled: true,
                    fillColor: AppColors.grey,
                  ),
                  dropdownColor: AppColors.grey,
                  value: selectedValue,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedValue = newValue!;
                    });
                  },
                  items: dropdownItems,
                ),
                getSizedBox(height: 20),
                AppButton(
                  btnText: 'Create Account',
                  textSize: 15,
                  voidCallBack: (){
                    formValidation(); /* CONTROLE DE SAISIE*/
                   // Navigator.pushReplacementNamed(context, homeScreen);
                  },
                )
              ],
            ),
          )),
    );
  }
}
