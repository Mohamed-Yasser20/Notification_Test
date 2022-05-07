import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:test_notification/notification_badge.dart';
import 'model/pushnotification_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return OverlaySupport(
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const HomePage(),
      ),
    );
  }
}

//start
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // initialize some values
  late final FirebaseMessaging _messaging;
  late int totalNotificationCounter;
  // model
  PushNotification? notificationInfo;
  // register notification (normal state)
  void registerNotification() async {
    await Firebase.initializeApp();
    // instance for firebase messaging
    _messaging = FirebaseMessaging.instance;
    // three type of state in notification
    // not determined(null),granted(true)and decline(false)
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("User granted the permissioin");
      // main message
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        PushNotification notification = PushNotification(
          title: message.notification!.title,
          body: message.notification!.body,
          dataTitle: message.data['title'],
          dataBody: message.data['body'],
        );
        setState(() {
          totalNotificationCounter++; //inc the counter
          notificationInfo = notification;
        });
        if(notification != null)
        {
          showSimpleNotification(Text(notificationInfo!.title!),
          leading: NotificationBadege(totalNotification: totalNotificationCounter),
          subtitle: Text(notificationInfo!.body!),
          background: Colors.cyan.shade700,
          duration: Duration(seconds: 2));//time of the notification
        }

      });
    }
    else{
      print("user permission declined");
    }
  }

  //when nothing is there in background (app closed)
  checkForInitialMessage() async{
    await Firebase.initializeApp();
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if(initialMessage != null){
      PushNotification notification = PushNotification(
        title: initialMessage.notification!.title,
        body: initialMessage.notification!.body,
        dataTitle: initialMessage.data['title'],
        dataBody: initialMessage.data['body'],
      );
      setState(() {
        totalNotificationCounter++; //inc the counter
        notificationInfo = notification;
      });
    }
  }


  @override
  void initState() {
    //when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message){
      PushNotification notification = PushNotification(
        title: message.notification!.title,
        body: message.notification!.body,
        dataTitle: message.data['title'],
        dataBody: message.data['body'],
      );
      setState(() {
        totalNotificationCounter++; //inc the counter
        notificationInfo = notification;
      });
    });
    //when app is in use (Normal state)
    registerNotification();
    //app in terminated state
    checkForInitialMessage();
    // TODO: implement initState
    totalNotificationCounter = 0;
    super.initState();
  }
//Design
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("PushNotification")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "FlutterPushNotification",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
              ),
            ),
            SizedBox(height: 12),
            NotificationBadege(totalNotification: totalNotificationCounter),
            SizedBox(height: 30),
            //if notif is not null
            notificationInfo != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Titel : ${notificationInfo!.dataTitle ?? notificationInfo!.title}",
                         style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16)),
                        SizedBox(height: 9),
                      Text(
                          "BODY : ${notificationInfo!.dataBody ?? notificationInfo!.body}",
                          style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16)),
                    ],
                  )
                : Container()
          ],
        ),
      ),
    );
  }
}
