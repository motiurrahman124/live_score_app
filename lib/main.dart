import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

// void main() {
//   runApp(const MyApp());
// }

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const LiveScoreApp());
}

class LiveScoreApp extends StatelessWidget {
  const LiveScoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: HomeScreen());
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<LiveScore> _listOfScore = [];
  final FirebaseFirestore db = FirebaseFirestore.instance;
  Future<void> _getLiveScoreData() async {
    _listOfScore.clear();
    final QuerySnapshot<Map<String, dynamic>> snapshots =
        await db.collection("football").get();

    for (QueryDocumentSnapshot<Map<String, dynamic>> doc in snapshots.docs) {
      LiveScore liveScore = LiveScore(
        id: doc.id,
        team1Name: doc.get("team1"),
        team2Name: doc.get("team2"),
        team1Score: doc.get("team1_score"),
        team2Score: doc.get("team2_score"),
        runningTime: doc.get("running_time"),
        totalTime: doc.get("total_time"),
      );

      _listOfScore.add(liveScore);
    }
    setState(() {});
  }

  // @override
  // void initState() {
  //   super.initState();
  //   _getLiveScoreData();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Match List",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.blue,

        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder(
        stream: db.collection('football').snapshots(),
        builder: (context,  AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshots) {

          if (snapshots.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshots.hasError) {
            return Center(child: Text(snapshots.error.toString()));
          }

          if (snapshots.hasData) {
            _listOfScore.clear();
            for (QueryDocumentSnapshot<Map<String, dynamic>> doc
            in snapshots.data!.docs) {
              LiveScore liveScore = LiveScore(
                id: doc.id,
                team1Name: doc.get("team1"),
                team2Name: doc.get("team2"),
                team1Score: doc.get("team1_score"),
                team2Score: doc.get("team2_score"),
                runningTime: doc.get("running_time"),
                totalTime: doc.get("total_time"),
              );

              _listOfScore.add(liveScore);
            }
          }

          return ListView.builder(
            itemCount: _listOfScore.length,
            itemBuilder: (context, index) {
              LiveScore liveScore = _listOfScore[index];
              return ListTile(
                title: Text(
                  "${liveScore.team1Name} vs ${liveScore.team2Name}",
                  style: TextStyle(
                    fontSize: 18,
                    // fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_rounded, size: 24),
              );
            },
          );
        }
      ),
    );
  }
}

class LiveScore {
  final String id;
  final String team1Name;
  final String team2Name;
  final int team1Score;
  final int team2Score;
  final String runningTime;
  final String totalTime;

  LiveScore({
    required this.id,
    required this.team1Name,
    required this.team2Name,
    required this.team1Score,
    required this.team2Score,
    required this.runningTime,
    required this.totalTime,
  });
}
