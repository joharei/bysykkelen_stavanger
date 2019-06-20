import 'package:flutter/material.dart';

class BookingsListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _BookingsListPageState();

  static Future show(BuildContext context) => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => BookingsListPage(),
        ),
      );
}

class _BookingsListPageState extends State<BookingsListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text('Bookings'),
            floating: true,
            pinned: true,
          ),
          SliverFixedExtentList(
            itemExtent: 100,
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return ListTile(
                  title: Text('Station name $index'),
                  subtitle: Text('Time'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => {},
                  ),
                );
              },
              childCount: 50,
            ),
          ),
        ],
      ),
    );
  }
}
