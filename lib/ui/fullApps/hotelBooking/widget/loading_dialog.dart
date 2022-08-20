import 'package:flutter/material.dart';
import 'package:smartkit_pro/ui/fullApps/hotelBooking/widget/progess_bar.dart';

class LoadingDialog extends StatelessWidget {

  final String? message;
  LoadingDialog ({this.message});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        key: key,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            circularProgress(), // rappel de la progress_bar
            SizedBox(height: 10,),
            Text(message! + "Veuillez patienter..."),
          ],
        ),
    );
  }
}
