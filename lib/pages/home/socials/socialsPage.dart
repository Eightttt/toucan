import 'package:flutter/material.dart';
import 'package:toucan/models/socialsPageDummyModel.dart';

class SocialsPage extends StatefulWidget {
  const SocialsPage({Key? key}) : super(key: key);

  @override
  State<SocialsPage> createState() => _SocialsPageState();
}

class _SocialsPageState extends State<SocialsPage> {
  List<String> pictures = ["assets/1.jpg", "assets/2.jpg", "assets/3.jpg", "assets/4.jpg", "assets/5.jpg"];
  List<DummyModel> posts = [
    DummyModel(assetPath: "assets/1.jpg", caption: "Hello, this is my first post, hi!"),
    DummyModel(assetPath: "assets/2.jpg", caption: "Ok"),
    DummyModel(assetPath: "assets/3.jpg", caption: "Alright"),
    DummyModel(assetPath: "assets/4.jpg", caption: "Yes"),
    DummyModel(assetPath: "assets/5.jpg", caption: "Hi"),
  ];
  Color toucanOrange = Color(0xfff28705);
  Color toucanWhite = Color(0xFFFDFDF5);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image(
              image: AssetImage("assets/toucan-title-logo.png"),
              height: kToolbarHeight,
              fit: BoxFit.fitHeight,
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.person_add_rounded),
              color: toucanWhite,
              iconSize: 35,
            ),
          ],
        ),
        backgroundColor: toucanOrange,
      ),
      body: Column(
        children: [
          Container(
            height: 100,
            width: 500,
            color: toucanOrange,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: pictures.length,
                itemBuilder: (context, index){
                  return Container(
                      width: 100,
                      height: 100,
                      child:Card(
                        color: toucanOrange,
                        elevation: 0,
                        child: ListTile(
                            onTap: () {},
                            title: Center(
                              child: CircleAvatar(
                                radius: 40, // Image radius
                                backgroundImage: AssetImage(pictures[index]),
                              ),
                            )
                        ),
                      )
                  );
                }
            ),
          ),
          Container(
            height: 550,
            width: 500,
            child: ListView.builder(
              itemCount: pictures.length,
              itemBuilder: (context, index){
                return Container(
                  padding:EdgeInsets.fromLTRB(50, 25, 50, 25),
                  child:Card(
                    color: toucanWhite,
                    elevation: 0.5,
                    child: Padding(
                      padding: const EdgeInsets.all(25),
                      child: ListTile(
                        onTap: () {},
                        title: Center(
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10), // set the desired border radius
                                child: Image.asset(posts[index].assetPath),
                              ),
                              SizedBox(height: 30),
                              Container(
                                padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
                                decoration: BoxDecoration(
                                  color: toucanWhite,
                                  borderRadius: BorderRadius.circular(10), // set the desired border radius
                                ),
                                child: Text(posts[index].caption),
                              ),
                              Divider(
                                color: Colors.grey[300],
                                height: 1,
                                thickness: 1,
                              ),
                            ],
                          )
                        ),
                      ),
                    )
                  ),
                );
              }
            )
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        items:[
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_rounded),
            label: 'Calendar'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups_rounded),
            label: 'Socials'
          )
        ],
      ),
    );
  }
}
