import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const ACCESS_TOKEN_KEY = 'ACCESS_TOKEN';
const REFRESH_TOKEN_KEY = 'REFRESH_TOKEN';

//localhost
const emulateIp = '10.0.0.2:3000';
const simulatorIp = '127.0.0.1:3000';
// const realIp = '192.168.0.24:3000';
// const realIp = '192.168.0.19:3000';
const realIp = '192.168.0.18:3000';

final ip = Platform.isIOS == true ? simulatorIp : emulateIp;