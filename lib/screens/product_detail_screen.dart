import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/product_model.dart';

class ProductDetailsScreen extends StatelessWidget {
  final KidsProduct product;

  const ProductDetailsScreen({
    super.key,
    required this.product,
  });

  Future<void> _launchURL() async {
    final url = Uri.parse(product.buyLink);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProductName(),
                  const SizedBox(height: 16),
                  _buildDescription(),
                  const SizedBox(height: 20),
                  _buildPriceAndRating(),
                  const SizedBox(height: 24),
                  _buildBenefits(),
                  const SizedBox(height: 32),
                  _buildBuyButton(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: Colors.white,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF5D7BD5)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Hero(
          tag: 'product_${product.id}',
          child: Image.network(
            product.imageUrl,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildProductName() {
    return Text(
      product.name,
      style: GoogleFonts.quicksand(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF5D7BD5),
      ),
    );
  }

  Widget _buildDescription() {
    return Text(
      product.description,
      style: GoogleFonts.quicksand(
        fontSize: 16,
        color: Colors.grey[700],
        height: 1.5,
      ),
    );
  }

  Widget _buildPriceAndRating() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Price',
                style: GoogleFonts.quicksand(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                '₹${product.price.toStringAsFixed(2)}',
                style: GoogleFonts.quicksand(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFA873E8),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Rating',
                style: GoogleFonts.quicksand(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              Row(
                children: [
                  Text(
                    product.rating.toString(),
                    style: GoogleFonts.quicksand(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF5D7BD5),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.star_rounded,
                    color: Color(0xFFFFC107),
                    size: 24,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBenefits() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Benefits',
          style: GoogleFonts.quicksand(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF5D7BD5),
          ),
        ),
        const SizedBox(height: 16),
        ...product.benefits.map((benefit) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Color(0xFFA873E8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  benefit,
                  style: GoogleFonts.quicksand(
                    fontSize: 16,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildBuyButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: const LinearGradient(
          colors: [Color(0xFF5D7BD5), Color(0xFFA873E8)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFA873E8).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _launchURL,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shopping_cart_outlined, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              'Buy Now',
              style: GoogleFonts.quicksand(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}