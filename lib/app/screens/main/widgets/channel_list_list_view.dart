import 'package:flutter/cupertino.dart';
import 'package:flutter_iptv/app/screens/main/widgets/media_content_button.dart';

class ChannelListListView extends StatelessWidget {
  const ChannelListListView({
    super.key,
    required this.channels,
  });

  static const double _minSpacing = 16.0;

  final List<Widget> channels;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double sumWidth = -_minSpacing;
        int countButtonsInRow = 0;
        do {
          countButtonsInRow++;
          sumWidth += MediaContentButton.defaultWidth + _minSpacing;
        } while (sumWidth < constraints.maxWidth);
        countButtonsInRow--;

        int rowsN = channels.length ~/ countButtonsInRow;
        int unfinishedRowsNumber = 0;
        if (channels.length % countButtonsInRow != 0) unfinishedRowsNumber++;

        return ListView(
          children: List.generate(
            rowsN + unfinishedRowsNumber,
            (rowIndex) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    countButtonsInRow,
                    (channelIndex) {
                      int i = rowIndex * countButtonsInRow + channelIndex;

                      return Padding(
                        padding: EdgeInsets.only(
                          left: (channelIndex == 0) ? 0 : 16.0,
                        ),
                        child: i >= channels.length
                            ? Container(
                                width: MediaContentButton.defaultWidth,
                              )
                            : channels[i],
                      );
                    },
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
