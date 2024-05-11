import 'package:flutter/material.dart';
import 'package:wallet_app_workshop/core/data.dart';
import 'package:wallet_app_workshop/core/styles.dart';
import 'package:wallet_app_workshop/core/widgets/wallet.dart';
import 'package:wallet_app_workshop/home_page.dart';

class OnBoardingPage extends StatefulWidget {
  const OnBoardingPage({super.key});

  @override
  State<OnBoardingPage> createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {
  late final PageController pageController;
  static const viewportFraction = 0.7;
  int activeIndex = 0;

  @override
  void initState() {
    pageController = PageController(viewportFraction: viewportFraction);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    final itemWidth = screenSize.width * viewportFraction;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            const Center(
              child: Text(
                'My Wallet',
                style: TextStyle(fontSize: 35),
              ),
            ),
            const SizedBox(height: 40),
            Expanded(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Positioned(
                    left: -250 + 40,
                    width: 250,
                    top: -32,
                    bottom: -32,
                    child: WalletSide(),
                  ),
                  Positioned.fill(
                    child: PageView.builder(
                      controller: pageController,
                      itemCount: onBoardingItems.length,
                      onPageChanged: (int index) {
                        setState(() {
                          activeIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return AnimatedScale(
                          duration: const Duration(milliseconds: 300),
                          scale: index == activeIndex ? 1 : 0.8,
                          curve: Curves.easeOut,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.onBlack,
                              borderRadius: BorderRadius.circular(25),
                              image: DecorationImage(
                                image: AssetImage(onBoardingItems[index].image),
                                fit: BoxFit.fitWidth,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const Positioned(
                    left: -250 + 35,
                    width: 250,
                    top: -30,
                    bottom: -30,
                    child: WalletSide(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                left: (screenSize.width - itemWidth) / 2,
                right: (screenSize.width - itemWidth) / 2,
                top: 40,
                bottom: 50,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ..._buildItemInfo(activeIndex: activeIndex),
                  PageIndicator(
                    activeIndex: activeIndex,
                    length: onBoardingItems.length,
                  ),
                  FilledButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const HomePage(),
                        ),
                      );
                    },
                    child: const Text(
                      'Get Started!',
                      style: TextStyle(color: AppColors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildItemInfo({int activeIndex = 0}) {
    return [
      Center(
        child: Text(
          onBoardingItems[activeIndex].title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      const SizedBox(height: 10),
      Center(
        child: Text(
          onBoardingItems[activeIndex].subtitle,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    ];
  }
}

class PageIndicator extends StatelessWidget {
  const PageIndicator({
    super.key,
    this.length = 1,
    this.activeIndex = 0,
    this.activeColor = AppColors.primary,
  });

  final int length;
  final int activeIndex;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: SizedBox.fromSize(
        size: const Size.fromHeight(8),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = constraints.smallest;
            final activeWidth = size.width * 0.5;
            final inActiveWidth =
                (size.width - activeWidth - (2 * length * 2)) / (length - 1);

            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                length,
                (index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    height: index == activeIndex ? 8 : 5,
                    width: index == activeIndex ? activeWidth : inActiveWidth,
                    decoration: BoxDecoration(
                      color: index == activeIndex
                          ? activeColor
                          : AppColors.onBlack,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
