import 'package:flutter/material.dart';

class PeriodEssentialsPage extends StatelessWidget {
  const PeriodEssentialsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    int crossAxisCount = 1;
    if (width > 700) crossAxisCount = 2;
    if (width > 1100) crossAxisCount = 3;

    return Scaffold(
      backgroundColor: const Color(0xffF7F5F2),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: width > 700 ? 32 : 16,
            vertical: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Row(
                    children: [
                      Icon(Icons.menu),
                      SizedBox(width: 12),
                      Text(
                        "Fiora Shop",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Icon(Icons.shopping_cart_outlined),
                ],
              ),

              const SizedBox(height: 24),

              /// Title
              const Text(
                "CURATED ESSENTIALS",
                style: TextStyle(
                  letterSpacing: 1.5,
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Your Cycle,\nHonored.",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 20),

              /// Search
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.search),
                    SizedBox(width: 8),
                    Text("Search rituals..."),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// Filters
              const Row(
                children: [
                  FilterChipWidget("All", true),
                  SizedBox(width: 10),
                  FilterChipWidget("Cycles", false),
                  SizedBox(width: 10),
                  FilterChipWidget("Tea & Ritual", false),
                ],
              ),

              const SizedBox(height: 24),

              /// Products
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: demoProducts.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.78,
                ),
                itemBuilder: (context, index) {
                  return ProductCard(product: demoProducts[index]);
                },
              ),

              const SizedBox(height: 20),

              /// Subscribe card
              const SubscribeCard(),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class FilterChipWidget extends StatelessWidget {
  final String text;
  final bool active;

  const FilterChipWidget(this.text, this.active, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: active ? const Color(0xff4E6B52) : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Text(
        text,
        style: TextStyle(color: active ? Colors.white : Colors.black),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Image.network(
            product.image,
            height: 220,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          product.title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          product.subtitle,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              product.price,
              style: const TextStyle(
                color: Colors.deepOrange,
                fontWeight: FontWeight.w600,
              ),
            ),
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xff4E6B52),
              child: const Icon(
                Icons.shopping_cart_outlined,
                size: 18,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class SubscribeCard extends StatelessWidget {
  const SubscribeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Text(
            "Join the Fiora",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            "Receive monthly rituals, cycle-syncing tips, and early access.",
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            height: 45,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Row(children: [Text("email@example.com")]),
          ),
          const SizedBox(height: 12),
          Container(
            height: 45,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xff4E6B52),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Text(
              "Subscribe",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class Product {
  final String title;
  final String subtitle;
  final String price;
  final String image;

  Product(this.title, this.subtitle, this.price, this.image);
}

final demoProducts = [
  Product(
    "Organic Cotton Pads",
    "Biodegradable, ultra-soft",
    "\$14.00",
    "assets/pad.jpg",
  ),
  Product(
    "Moon Cycle Tea Blend",
    "Raspberry leaf & hibiscus",
    "\$22.00",
    "assets/tea.png",
  ),
  Product(
    "Aromatherapy Heat Patch",
    "8-hour relief",
    "\$18.00",
    "assets/heating.png",
  ),
  Product(
    "Sustainable Menstrual Cup",
    "Medical grade silicone",
    "\$35.00",
    "assets/cup.png",
  ),
];
