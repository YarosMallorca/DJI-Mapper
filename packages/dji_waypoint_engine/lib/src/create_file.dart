import 'dart:io';

import 'template_kml.dart';
import 'waylines_wpml.dart';
import 'package:archive/archive_io.dart';

Future<File> createDJIFile(
    {required TemplateKml template,
    required WaylinesWpml waylines,
    required File filePath}) async {
  var templateString = template.toXmlString(pretty: true);
  var waylinesString = waylines.toXmlString(pretty: true);
  var encoder = ZipFileEncoder();
  var temp = Directory.systemTemp;

  Directory("${temp.path}/wpmz").createSync(recursive: true);

  var templateFile = File("${temp.path}/wpmz/template.kml");
  var waylinesFile = File("${temp.path}/wpmz/waylines.wpml");

  await templateFile.writeAsString(templateString);
  await waylinesFile.writeAsString(waylinesString);

  encoder.create(filePath.path);
  encoder.addDirectory(Directory("${temp.path}/wpmz"));
  encoder.close();

  await templateFile.delete();
  await waylinesFile.delete();

  return File(filePath.path);
}
