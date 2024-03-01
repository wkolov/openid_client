import 'package:flutter/material.dart';
import 'package:openid_client/openid_client.dart';
import 'openid_browser.dart';

// const keycloakUri = 'https://vpp-app.bop-dev.de/auth/realms/vms';
const keycloakUri = 'http://localhost:8080/auth/realms/vms';
const clientId = 'vms-services';
const scopes = <String>[];

Credential? credential;

late final Client client;

Future<Client> getClient() async {
  var uri = Uri.parse(keycloakUri);
  // if (!kIsWeb && Platform.isAndroid) uri = uri.replace(host: '10.0.2.2');
  var issuer = await Issuer.discover(uri);
  return Client(issuer, clientId);
}

Future<void> main() async {
  client = await getClient();
  credential = await getRedirectResult(client, scopes: scopes);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'openid_client demo',
      home: MyHomePage(title: 'openid_client Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  UserInfo? userInfo;
  TokenResponse? tokenResponse;

  @override
  void initState() {
    if (credential != null) {
      credential!
          .getUserInfo()
          .then((userInfo) {
        setState(() {
          this.userInfo = userInfo;
        });
      })
          .then((value) => credential!.getTokenResponse())
          .then((tokenResponse) {
        this.tokenResponse = tokenResponse;
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (userInfo != null) ...[
              Text('Hello ${userInfo!.name}'),
              Text(userInfo!.email ?? ''),
              Text('refresh_token: ${tokenResponse?.refreshToken}', maxLines: 1,),
              Text('access_token: ${tokenResponse?.accessToken}', maxLines: 1,),
              OutlinedButton(
                  child: const Text('Logout'),
                  onPressed: () async {
                    await logout();
                    setState(() {
                      userInfo = null;
                    });
                  })
            ],
            if (userInfo == null)
              OutlinedButton(
                  child: const Text('Login'),
                  onPressed: () async {
                    var credential = await authenticate(client, scopes: scopes);
                    var userInfo = await credential.getUserInfo();
                    setState(() {
                      this.userInfo = userInfo;
                    });
                  }),
          ],
        ),
      ),
    );
  }
}
