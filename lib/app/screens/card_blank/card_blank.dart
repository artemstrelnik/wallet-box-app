import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:wallet_box/app/core/generals_widgets/button.dart';
import 'package:wallet_box/app/screens/app_auth/html_shim.dart';
import '../../core/generals_widgets/scaffold_app_bar.dart';
import '../../core/styles/style_color_custom.dart';

class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({
    Key? key,
    required this.camera,
    required this.constraints,
    required this.callBack,
    this.isFinal = false,
  }) : super(key: key);

  final CameraDescription camera;
  final BoxConstraints constraints;
  final Function callBack;
  final bool isFinal;

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.high,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // If the Future is complete, display the preview.
          return Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                child: CameraPreview(_controller),
                left: 20,
                right: 20,
              ),
              Positioned.fill(
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(Colors.black,
                      BlendMode.srcOut), // This one will create the magic
                  child: Stack(
                    fit: StackFit.expand,
                    alignment: AlignmentDirectional.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.1),
                            backgroundBlendMode: BlendMode
                                .dstOut), // This one will handle background + difference out
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          width: widget.constraints.maxWidth,
                          height: widget.constraints.maxWidth * .62,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(17),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                child: SafeArea(
                  child: Scaffold(
                    appBar: AppBar(
                      leading: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: StyleColorCustom().setStyleByEnum(
                              context, StyleColorEnum.colorIcon),
                        ),
                      ),
                      bottom: PreferredSize(
                        preferredSize: Size(
                          MediaQuery.of(context).size.width,
                          30,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 20.0),
                              child: Text("123"),
                            ),
                          ],
                        ),
                      ),
                      centerTitle: true,
                      automaticallyImplyLeading: false,
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                    ),
                    backgroundColor: Colors.transparent,
                    body: Container(),
                    floatingActionButton: FloatingActionButton(
                      onPressed: () async {
                        try {
                          await _initializeControllerFuture;
                          final image = await _controller.takePicture();

                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => DisplayPictureScreen(
                                imagePath: image.path,
                                constraints: widget.constraints,
                                callBack: widget.callBack,
                                isFinal: widget.isFinal,
                              ),
                            ),
                          );
                        } catch (e) {
                          print(e);
                        }
                      },
                      child: const Icon(Icons.camera_alt),
                    ),
                  ),
                ),
              ),
            ],
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatelessWidget {
  const DisplayPictureScreen({
    Key? key,
    required this.imagePath,
    required this.constraints,
    required this.callBack,
    this.isFinal = false,
  }) : super(key: key);

  final String imagePath;
  final BoxConstraints constraints;
  final Function? callBack;
  final bool isFinal;

  Future<String> _resizePhoto(String filePath) async {
    ImageProperties properties =
        await FlutterNativeImage.getImageProperties(filePath);

    int width = properties.width!;

    var t = width / constraints.maxWidth;
    var h = constraints.maxWidth * .62;

    var offset = properties.height! / 2 - h * t / 2;

    File croppedFile = await FlutterNativeImage.cropImage(
      filePath,
      0,
      offset.round(),
      width,
      (h * t).round(),
    );

    return croppedFile.path;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: SafeArea(
        child: ScaffoldAppBarCustom(
          title: "Обложка вашей карты",
          leading: true,
          body: FutureBuilder<String>(
            future: _resizePhoto(imagePath),
            builder: (
              BuildContext context,
              AsyncSnapshot<String> snapshot,
            ) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  return const Text('Error');
                } else if (snapshot.hasData) {
                  return Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(14)),
                        ),
                        child: Image.file(File(snapshot.data!)),
                        clipBehavior: Clip.hardEdge,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ButtonCancel(
                            text: "Отменить",
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          SizedBox(width: 18),
                          ButtonPink(
                            text: isFinal ? "Сохранить" : "Продолжить",
                            onPressed: isFinal
                                ? (() =>
                                    callBack?.call(snapshot.data!) ?? () => {})
                                : () async {
                                    Future.delayed(Duration(microseconds: 500),
                                        () {
                                      Navigator.of(context).pop();
                                    }).then((value) =>
                                        Navigator.pop(context, snapshot.data!));
                                  },
                          ),
                        ],
                      ),
                    ],
                  );
                } else {
                  return const Text('Empty data');
                }
              } else {
                return Text('State: ${snapshot.connectionState}');
              }
            },
          ),
        ),
      ),
    );
  }
}
