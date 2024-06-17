import { Decoder, Stream, Profile, Utils } from '@garmin/fitsdk';
import fs from 'node:fs';

const buf = fs.readFileSync('./15920387501_ACTIVITY.fit');
const stream = Stream.fromBuffer(buf);
// console.log("isFIT (static method): " + Decoder.isFIT(stream));

const decoder = new Decoder(stream);
// console.log("isFIT (instance method): " + decoder.isFIT());
// console.log("checkIntegrity: " + decoder.checkIntegrity());

const { messages, errors } = decoder.read();

// console.log(errors);
// console.log(Object.getOwnPropertyNames(messages))
// console.dir(messages.fileIdMesgs)
// console.dir(messages.fileCreatorMesgs)
// console.dir(messages.activityMesgs)
console.dir(messages.sessionMesgs)
// console.dir(messages.timeInZoneMesgs)
// console.dir(messages.lapMesgs)
// console.dir(messages.eventMesgs)
// console.dir(messages.deviceInfoMesgs)
// console.dir(messages.deviceSettingsMesgs)
// console.dir(messages.userProfileMesgs)
// console.dir(messages.sportMesgs)
// console.dir(messages.zonesTargetMesgs)
// console.dir(messages.recordMesgs)
// console.dir(messages.gpsMetadataMesgs)
