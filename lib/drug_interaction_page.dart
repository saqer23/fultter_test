import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DrugInteractionPage extends StatelessWidget {
  const DrugInteractionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('التداخلات الدوائية'),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDrugInteractionSection(),
            const SizedBox(height: 20),
            _buildFeaturedDoctorsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildDrugInteractionSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.teal,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(16),
      child: const Text(
        'التداخلات الدوائية:\n'
        'التداخلات الدوائية قد تكون ذات تأثير سلبي على الصحة، ويجب توخي الحذر عند استخدام أكثر من دواء في نفس الوقت، حيث يمكن أن يتداخل تأثير أحد الأدوية مع الأدوية الأخرى.\n\n'
        '1. تداخل الأدوية مع الأدوية الأخرى (Drug-Drug Interactions):\n'
        'قد تحدث تفاعلات دوائية عندما تتداخل الأدوية التي يتم تناولها مع بعضها البعض.\n\n'
        '2. تداخل الأدوية مع الطعام (Drug-Food Interactions):\n'
        'يمكن أن تتفاعل الأدوية مع بعض الأطعمة وتؤثر على فعاليتها.\n\n'
        '3. تداخل الأدوية مع المكملات الغذائية (Drug-Supplement Interactions):\n'
        'قد تتداخل بعض المكملات الغذائية مع الأدوية وتؤثر على فعاليتها.\n\n'
        '4. تداخل الأدوية مع المشروبات (Drug-Beverage Interactions):\n'
        'بعض المشروبات مثل الكحول يمكن أن تؤثر على فعالية الأدوية.\n\n'
        'يجب دائمًا استشارة الطبيب أو الصيدلي قبل تناول أي أدوية مع بعضها البعض أو مع أي مكملات غذائية أو طعام.',
        textAlign: TextAlign.start,
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildFeaturedDoctorsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'أبرز الدكاترة',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 220, // Adjust height as per requirement
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildDoctorCard(
                doctorName: 'د/ منى سعيد',
                specialty: 'أخصائية أذن وحنجرة',
                imageUrl: 'https://via.placeholder.com/150',
                phoneNumber: '+201234567890', // Example phone number
              ),
              _buildDoctorCard(
                doctorName: 'د/ فاطمة احمد',
                specialty: 'أخصائية باطنية',
                imageUrl: 'https://via.placeholder.com/150',
                phoneNumber: '+201234567891', // Example phone number
              ),
              _buildDoctorCard(
                doctorName: 'د/ خالد محمد',
                specialty: 'أخصائي عيون',
                imageUrl: 'https://via.placeholder.com/150',
                phoneNumber: '+201234567892', // Example phone number
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDoctorCard({
    required String doctorName,
    required String specialty,
    required String imageUrl,
    required String phoneNumber,
  }) {
    return GestureDetector(
      onTap: () async {
        final whatsappUrl =
            "https://wa.me/$phoneNumber?text=مرحبا دكتور $doctorName، أحتاج إلى استشارة.";
        if (await canLaunch(whatsappUrl)) {
          await launch(whatsappUrl);
        } else {
          throw 'Could not launch $whatsappUrl';
        }
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Container(
          width: 150,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(imageUrl),
              ),
              const SizedBox(height: 16),
              Text(
                doctorName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                specialty,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
