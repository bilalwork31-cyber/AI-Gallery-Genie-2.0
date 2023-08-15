import 'package:cts/Model/CoinUpdaterFirebaseProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';

import '../Model/coins_provider.dart';
import '../Model/payment_provider.dart';


class PaymentScreen extends StatelessWidget {
  const PaymentScreen({Key? key}) : super(key: key);

  Future<void> makePayment(BuildContext context) async {
    final coinProvider = Provider.of<CoinProvider>(context, listen: false);
    final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);

    try {
      await paymentProvider.createPaymentIntent(coinProvider.selectedAmount, 'USD');

      await paymentProvider.initializePaymentSheet(context);

      await paymentProvider.displayPaymentSheet(context);




    } catch (e) {
      print('Payment Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final coinProvider = Provider.of<CoinProvider>(context);

    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Coin Payment'),
      //   centerTitle: true,
      // ),
      body: Container(
        padding: const EdgeInsets.all(40),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [ Colors.orange, Colors.lightGreenAccent,],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [


            Container(
                height: 60, width: 60, child: Image.asset("images/logo.png")),
            SizedBox(
              height: 50,
            ),
            const Text(
              "Buy Credits to Unlock Premium AI Editing Features!",
              textAlign: TextAlign.center,  // You can use left, right, or center based on your layout
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(
              height: 150,
            ),
            const Text(
              textAlign: TextAlign.start,
              "Choose Your Coin Package",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.blueGrey),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    offset: const Offset(0, 4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: coinProvider.selectedPackage,
                  dropdownColor: Colors.white,
                  isExpanded: true,  // Make the dropdown full-width
                  icon: const Icon(Icons.arrow_drop_down_sharp, color: Colors.green, size: 24),
                  items: coinProvider.coinToAmount.keys.map((String package) {
                    return DropdownMenuItem<String>(
                      value: package,
                      child: Row(
                        children: [
                          const Icon(Icons.stars, color: Colors.yellow, size: 20),
                          const SizedBox(width: 10),
                          // Use Expanded to ensure the text has enough space
                          Expanded(
                            child: Text(
                              package,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 16, // You can adjust this size if needed
                                fontWeight: FontWeight.w600,
                                overflow: TextOverflow.ellipsis, // Handles overflow by truncating
                              ),
                              maxLines: 1, // Prevents multiline overflow
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    if (value != null) {
                      coinProvider.updatePackage(value);
                    }
                  },
                ),
              ),
            )


            ,
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(

                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              onPressed: () async {
                await makePayment(context);
              },
              child: const Text("Pay Now"),
            ),
          ],
        ),
      ),
    );
  }
}
