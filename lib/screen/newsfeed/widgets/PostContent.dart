import 'package:flutter/material.dart';

class PostContent extends StatefulWidget {
  static double offset = 0;

  final String text;
  final Color? textColor;
  final int? type;
  const PostContent({super.key, required this.text, this.textColor, this.type = 0});

  @override
  State<PostContent> createState() => _PostContentState();
}

class _PostContentState extends State<PostContent> {
  String first = '';
  bool expand = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      if (widget.text.length > 100) {
        first = widget.text.substring(0, 100);
        for (int i = 0; i < 100; i++) {
          if (widget.text[i] == '\n') {
            first = widget.text.substring(0, i);
            break;
          }
        }
      } else {
        first = widget.text;
      }
    });
    return InkWell(
      onTap: () {
        setState(() {
          expand = !expand;
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
        child: widget.text.length == first.length
            ? Text(
                first,
                style: TextStyle(
                  color: widget.textColor ?? Colors.black,
                  fontSize: 16,
                ),
              )
            : !expand
                ? RichText(
                    text: TextSpan(
                        text: "$first...",
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Tahoma',
                          color: widget.textColor ?? Colors.black,
                        ),
                        children: [
                          WidgetSpan(
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    expand = !expand;
                                  });
                                },
                                child: Text(
                                  'Xem thêm',
                                  style: TextStyle(
                                    color: widget.textColor ?? Colors.black54,
                                    fontSize: 16,
                                    fontFamily: "Tahoma"
                                  ),
                                ),
                              )
                          )
                        ]),
                  )
                : (widget.type == 0)
                  ? Text(
                      widget.text,
                      style: TextStyle(
                        color: widget.textColor ?? Colors.black,
                        fontSize: 16,
                        fontFamily: "Tahoma"
                      ),
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Container(
                        child: Text(
                              widget.text,
                              overflow: TextOverflow.fade,
                              style: TextStyle(
                                color: widget.textColor ?? Colors.black,
                                fontSize: 16,
                                fontFamily: "Tahoma"
                              ),
                          ),
                      ),
                    )
      ),
    );
  }
}
