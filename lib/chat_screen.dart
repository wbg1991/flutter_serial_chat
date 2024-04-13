import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  var textController = TextEditingController();
  var availablePorts = [];
  SerialPort? selectedPort;
  SerialPortReader? reader;
  var isOpen = false;
  var messages = [];

  @override
  void initState() {
    super.initState();
    initPorts();
  }

  void initPorts() {
    setState(() {
      availablePorts = SerialPort.availablePorts;
      selectPort(availablePorts.firstOrNull);
    });

    debugPrint('_availablePorts length: ${availablePorts.length}');
    for(final port in availablePorts) {
      debugPrint(port);
    }
  }

  void selectPort(String? portName) {
    if (portName != null) selectedPort = SerialPort(portName);
  }

  List<DropdownMenuItem<String>> createItems() {
    return List.generate(
        availablePorts.length,
        (index) => DropdownMenuItem(
              value: '${availablePorts[index]}',
              child: Text(
                '${availablePorts[index]}',
                style: const TextStyle(color: Colors.white),
              ),
            ));
  }

  void onChanged(String? portName) {
    setState(() => selectPort(portName));
    FocusScope.of(context).requestFocus(FocusNode());
  }

  void onConnect() {
    if (selectedPort == null) return;

    final portConfig = SerialPortConfig();
    portConfig.baudRate = 9600;
    selectedPort!.config = portConfig;

    if (!selectedPort!.openReadWrite()) {
      debugPrint('${SerialPort.lastError}');
      return;
    }

    reader = SerialPortReader(selectedPort!);
    reader!.stream.listen((data) {
      final message = String.fromCharCodes(data);
      setState(() {
        messages.add("[RECV] $message");
      });
    });

    setState(() => isOpen = true);
  }

  void onDisconnect() {
    if (selectedPort == null) return;

    reader!.close();
    selectedPort!.close();

    setState(() => isOpen = false);
  }

  void onRefresh() {
    if(isOpen) return;
    initPorts();
  }

  void send(String message) {
    if(message.isEmpty || !isOpen) return;

    final bytes = Uint8List.fromList("$message\n".codeUnits);
    final ret = selectedPort?.write(bytes);
    debugPrint('written: $ret');

    setState(() {
      messages.add("[SEND] $message");
    });

    textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
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
                    const Text('Port', style: TextStyle(color: Colors.white)),
                    const SizedBox(width: 8,),
                    DropdownButton(
                      value: selectedPort?.name,
                      items: createItems(),
                      onChanged: onChanged
                    ),
                    const SizedBox(width: 8,),

                    isOpen
                    ? ElevatedButton(onPressed: onDisconnect, child: const Text('Disconnect'))
                    : ElevatedButton(onPressed: onConnect, child: const Text('Connect'))
                  ],
                ),

                IconButton(onPressed: onRefresh, icon: const Icon(Icons.refresh, color: Colors.white,))
              ],
            ),

            // 채팅 기록
            Expanded(
              child: Container(
                color: const Color(0xCC222222),
                padding: const EdgeInsets.all(8.0),
                child: ListView(
                  itemExtent: 32,
                  children: List.generate(messages.length, (index) {
                    return ListTile(
                      title: Text(
                          messages[index],
                          style: const TextStyle(color: Colors.white)
                      ),
                    );
                  }),
                ),
              )
            ),

            // 메시지 입력
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: textController,
                    style: const TextStyle(color: Colors.white),
                    onSubmitted: (msg)=>send(msg),
                  )
                ),
                ElevatedButton(onPressed: ()=>send(textController.text), child: Text('SEND'))
              ],
            )
          ],
        ),
      ),
    );
  }
}
