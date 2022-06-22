import 'package:flutter/material.dart';
import 'package:navigator2/provider.dart';

Widget bottomDetailCard(
    BuildContext context, ref,String distance, String dropOffTime) {
  String curradd = ref.read(CurrentAdressProvider);
  String destiadd = ref.read(DestinationAdressProvider);

  return Positioned(
    bottom: 0,
    child: SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('$curradd ➡ $destiadd',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: Colors.indigo)),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: ListTile(
                    tileColor: Colors.grey[200],
                    leading: const Image(
                        image: AssetImage('img_1.png'),
                        height: 50,
                        width: 50),
                    title: const Text('Happy Journey',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    subtitle: Text('$distance km'),
                    // trailing: const Text('\$384.22',
                    //     style: TextStyle(
                    //         fontWeight: FontWeight.bold, fontSize: 18)),
                  ),
                ),
                ElevatedButton(
                    onPressed: () {},
                        // Navigator.push(context,
                        // MaterialPageRoute(builder: (_) => const TurnByTurn())),
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(20)),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text('Start the journey'),
                        ])),
              ]),
        ),
      ),
    ),
  );
}