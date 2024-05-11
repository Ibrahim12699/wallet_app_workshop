import 'dart:math';

import 'package:flutter/material.dart';
import 'package:wallet_app_workshop/core/data.dart';
import 'package:wallet_app_workshop/core/utils.dart';
import 'package:wallet_app_workshop/credit-cards/credit_card.dart';
import 'package:wallet_app_workshop/credit-cards/credit_card_page.dart';

const pageTransitionDuration = Duration(milliseconds: 1000);
const dragSnapDuration = Duration(milliseconds: 200);
const dragThreshold = Offset(70, 70);
const minCardScale = 0.6;
const maxCardScale = 1.0;
const cardsOffset = 12.0;
const minThrowDistance = 300.0;

class CreditCardsPage extends StatefulWidget {
  const CreditCardsPage({
    super.key,
    this.onCardPagePush,
    this.onCardPagePop,
  });

  final VoidCallback? onCardPagePush;
  final VoidCallback? onCardPagePop;

  @override
  State<CreditCardsPage> createState() => _CreditCardsPageState();
}

class _CreditCardsPageState extends State<CreditCardsPage> {
  int activeCard = 0;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final cardHeight = screenSize.width * 0.75;
    final cardWidth = cardHeight * creditCardAspectRatio;

    return Center(
      child: SizedBox(
        width: cardHeight,
        height: cardWidth + (cardsOffset * (cards.length - 1)),
        child: CreditCardsStack(
          itemCount: cards.length,
          initialActiveCard: activeCard,
          onCardTap: (index) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => CreditCardPage(initialIndex: index),
              ),
            );
          },
          itemBuilder: (context, index) {
            return Align(
              widthFactor: cardHeight / cardWidth,
              heightFactor: cardWidth / cardHeight,
              child: Transform.rotate(
                angle: -pi / 2,
                child: CreditCard(
                  width: cardWidth,
                  data: cards[index],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class CreditCardsStack extends StatefulWidget {
  const CreditCardsStack({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.onCardTap,
    this.initialActiveCard = 0,
  });

  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final ValueChanged<int>? onCardTap;
  final int initialActiveCard;

  @override
  State<CreditCardsStack> createState() => _CreditCardsStackState();
}

class _CreditCardsStackState extends State<CreditCardsStack>
    with SingleTickerProviderStateMixin {
  late final AnimationController animationController;
  late final Animation<double> curvedAnimation;
  late final Animation<Offset> throwAnimation;
  late final Tween<Offset> throwAnimationTween;
  int activeIndex = 0;
  Offset dragOffset = Offset.zero;
  Duration dragDuration = Duration.zero;

  double get scaleDifference =>
      (maxCardScale - minCardScale) / (widget.itemCount - 1);

  Future<void> _handleRelease() async {
    throwAnimationTween.end = getThrowOffsetFromDragLocation(
      dragOffset,
      minThrowDistance,
    );
    await animationController.forward();
    setState(() {
      activeIndex++;
    });
    animationController.reset();
  }

  void _onPanStart(DragStartDetails details) {
    if (dragDuration > Duration.zero) {
      dragDuration = Duration.zero;
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      dragOffset += details.delta;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (dragOffset.dx.abs() > dragThreshold.dx ||
        dragOffset.dy.abs() > dragThreshold.dy) {
      _handleRelease().then((_) {
        setState(() {
          dragOffset = Offset.zero;
        });
      });
    } else {
      dragDuration = dragSnapDuration;
      setState(() {
        dragOffset = Offset.zero;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    curvedAnimation = CurvedAnimation(
      parent: animationController,
      curve: Curves.easeOut,
    );
    throwAnimationTween = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(minThrowDistance, minThrowDistance),
    );
    throwAnimation = throwAnimationTween.animate(curvedAnimation);
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: animationController,
        builder: (context, _) {
          return Stack(
            clipBehavior: Clip.none,
            children: List.generate(
              widget.itemCount + 1,
              (stackIndexWithPlaceholder) {
                final index = stackIndexWithPlaceholder - 1;
                final modIndex = getModIndexFromActiveIndex(
                  index,
                  activeIndex,
                  widget.itemCount,
                );

                Widget child = widget.itemBuilder(context, modIndex);

                // Build the hidden placeholder card
                if (stackIndexWithPlaceholder == 0) {
                  return Positioned(
                    top: 0,
                    left: 0,
                    child: Transform.scale(
                      scale: minCardScale,
                      alignment: Alignment.topCenter,
                      child: child,
                    ),
                  );
                }

                // Build the last, draggable card
                if (index == widget.itemCount - 1) {
                  return AnimatedPositioned(
                    duration: dragDuration,
                    left: dragOffset.dx,
                    bottom: -dragOffset.dy,
                    child: Transform.translate(
                      offset: throwAnimation.value,
                      child: GestureDetector(
                        onPanStart: _onPanStart,
                        onPanUpdate: _onPanUpdate,
                        onPanEnd: _onPanEnd,
                        onTap: () => widget.onCardTap?.call(modIndex),
                        behavior: HitTestBehavior.opaque,
                        child: Opacity(
                          opacity: 1 - curvedAnimation.value,
                          child: child,
                        ),
                      ),
                    ),
                  );
                }

                // Build the cards in between (remaining cards)
                /// To gradually scale down widgets, limited by min and max scales
                final scaleByIndex = minCardScale +
                    ((maxCardScale - minCardScale) / (widget.itemCount - 1)) *
                        index;

                // Slide cards up gradually
                final bottomOffsetByIndex =
                    -cardsOffset * (widget.itemCount - 1 - index);

                return Positioned(
                  left: 0,
                  bottom: 0,
                  child: Transform.translate(
                    offset: Offset(0, bottomOffsetByIndex),
                    child: Transform.scale(
                      scale: scaleByIndex,
                      alignment: Alignment.topCenter,
                      child: child,
                    ),
                  ),
                );
              },
            ),
          );
        });
  }
}
