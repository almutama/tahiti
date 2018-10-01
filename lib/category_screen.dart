import 'package:flutter/material.dart';
import 'package:tahiti/activity_model.dart';
import 'package:tahiti/color_picker.dart';
import 'package:tahiti/display_sticker.dart';
import 'package:tahiti/popup_grid_view.dart';
import 'package:tuple/tuple.dart';

class CategoryScreen extends StatefulWidget {
  final int itemCrossAxisCount;
  final ActivityModel model;
  final Map<String, List<Iconf>> items;
  CategoryScreen({this.itemCrossAxisCount, this.items, this.model}) : super();
  @override
  CategoryScreenState createState() {
    return new CategoryScreenState();
  }
}

class CategoryScreenState extends State<CategoryScreen> {
  ScrollController _scrollController;
  int _itemCount = 0;
  List<Tuple3<String, int, int>> _itemRange = List<Tuple3<String, int, int>>();
  String highlightedItem;
  @override
  void initState() {
    super.initState();
    widget.items.forEach((e, l) {
      _itemRange.add(Tuple3(e, _itemCount,
          _itemCount + (l.length / widget.itemCrossAxisCount).ceil()));
      _itemCount += (l.length / widget.itemCrossAxisCount).ceil();
    });
    highlightedItem = _itemRange.first.item1;
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      final offset = _itemCount *
          _scrollController.offset /
          (_scrollController.position.maxScrollExtent +
              _scrollController.position.viewportDimension -
              8.0);
      final highlight = _itemRange.firstWhere((e) => e.item3 >= offset);
      setState(() {
        highlightedItem = highlight.item1;
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Widget _divider = Divider(
    color: Colors.white,
    height: 6.0,
  );
  ScreenMode screenMode = ScreenMode.portrait;
  Color color;
  BlendMode blendMode = BlendMode.dst;
  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    if (orientation == Orientation.portrait) {
      screenMode = ScreenMode.portrait;
    } else {
      screenMode = ScreenMode.landScape;
    }
    Size size = MediaQuery.of(context).size;
    return Material(
      color: Colors.black54,
      child: SizedBox(
        height: size.height,
        width: size.width,
        child: Stack(
          overflow: Overflow.visible,
          fit: StackFit.loose,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding:
                        EdgeInsets.only(top: 10.0, left: 15.0, right: 15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(''),
                        Text('Sticker',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold)),
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(
                            Icons.done,
                            color: Colors.white,
                            size: 40.0,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                _divider,
                Expanded(
                    flex: 1,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: _itemRange
                          .map((e) => Container(
                                color: e.item1 == highlightedItem
                                    ? Color(0XFFF4F4F4)
                                    : Colors.transparent,
                                child: InkWell(
                                    onTap: () {
                                      final offset = (_scrollController
                                                  .position.maxScrollExtent +
                                              _scrollController
                                                  .position.viewportDimension) *
                                          e.item2 /
                                          _itemCount;
                                      _scrollController.jumpTo(offset);
                                    },
                                    child: buildIndexItem(context, e.item1,
                                        e.item1 == highlightedItem)),
                              ))
                          .toList(growable: false),
                    )),
                _divider,
                Expanded(
                    flex: 7,
                    child: Container(
                      child: CustomScrollView(
                          controller: _scrollController,
                          scrollDirection: Axis.vertical,
                          slivers: widget.items.keys
                              .map((e) => SliverGrid(
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount:
                                                widget.itemCrossAxisCount),
                                    delegate: SliverChildBuilderDelegate(
                                        (BuildContext context, int index) {
                                      return InkWell(
                                          onTap: () {
                                            widget.model.addSticker(
                                                widget.items[e][index].data,
                                                color,
                                                blendMode);

                                            Navigator.pop(context);
                                          },
                                          child: Padding(
                                            padding: EdgeInsets.all(10.0),
                                            child: buildItem(context,
                                                widget.items[e][index], true),
                                          ));
                                    }, childCount: widget.items[e].length),
                                  ))
                              .toList(growable: false)),
                    )),
                Expanded(
                  child: ColorPicker(
                    screenMode: screenMode,
                    model: widget.model,
                    getColor: (color) => setColor(color),
                  ),
                  flex: 2,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void setColor(Color c) {
    setState(() {
      color = c;
      if (c == Colors.white) {
        blendMode = BlendMode.dst;
      } else {
        blendMode = BlendMode.srcOver;
      }
    });
  }

  Widget buildItem(BuildContext context, Iconf conf, bool enabled) {
    if (conf.type == ItemType.sticker) {
      return DisplaySticker(
        primary: conf.data,
        color: color,
        blendmode: blendMode,
      );
    } else
      return Image.asset(
        conf.data,
        package: 'tahiti',
      );
  }

  Widget buildIndexItem(BuildContext context, String text, bool enabled) {
    return Image.asset(
      text,
      package: 'tahiti',
    );
  }

  // addSticker(Iconf text) {
  //   print('stickers: $text');
  //   if (text.data.startsWith('assets/stickers') ||
  //       text.data.startsWith('assets/svgimage') &&
  //           text.type == ItemType.sticker) {
  //     widget.model.addSticker(text.data);
  //   }
  // }
}

enum ScreenMode { landScape, portrait }