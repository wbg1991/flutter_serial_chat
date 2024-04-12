import 'package:flutter/material.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  var availablePorts = [];
  String? selectedPort;
  var isOpen = false;

  @override
  void initState() {
    super.initState();
    initPorts();
  }

  void initPorts() {
    setState(() {
      availablePorts = SerialPort.availablePorts;
      selectedPort = availablePorts.firstOrNull;
    });

    debugPrint('_availablePorts length: ${availablePorts.length}');
    for(final port in availablePorts) {
      debugPrint(port);
    }
  }

  void onConnect() {
    setState(() => isOpen = true);
  }

  void onDisconnect() {
    setState(() => isOpen = false);
  }

  void onRefresh() {
    if(isOpen) return;
    initPorts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text('Serial Chat', style: TextStyle(color: Colors.white),),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 포트 선택 및 연결
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text('Port'),
                    const SizedBox(width: 8,),
                    DropdownButton(
                      value: selectedPort,
                      items: List.generate(
                        availablePorts.length,
                        (index) => DropdownMenuItem(
                          value: '${availablePorts[index]}',
                          child: Text('${availablePorts[index]}'),
                        )
                      ),
                      onChanged: (v) => setState(() => selectedPort = v)
                    ),
                    const SizedBox(width: 8,),

                    isOpen
                    ? ElevatedButton(onPressed: onDisconnect, child: const Text('Disconnect'))
                    : ElevatedButton(onPressed: onConnect, child: const Text('Connect'))
                  ],
                ),

                IconButton(onPressed: onRefresh, icon: const Icon(Icons.refresh))
              ],
            ),

            // 채팅 기록
            Expanded(
              child: Container(
                color: Colors.grey[100],
                padding: const EdgeInsets.all(8.0),
                child: ListView(

                ),
              )
            ),

            // 메시지 입력
            Row(
              children: [
                Expanded(
                  child: TextField()
                ),
                ElevatedButton(onPressed: (){}, child: Text('SEND'))
              ],
            )
          ],
        ),
      ),
    );
  }
}
