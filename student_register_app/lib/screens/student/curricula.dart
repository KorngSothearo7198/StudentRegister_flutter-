import 'package:flutter/material.dart';

// Major Model
class Major {
  final String id;
  final String name;
  final String code;
  final String? description;
  final int studentCount;
  final Color? color;

  Major({
    required this.id,
    required this.name,
    required this.code,
    this.description,
    this.studentCount = 0,
    this.color,
  });
}

// Main Curricula Screen
class CurriculaScreen extends StatefulWidget {
  const CurriculaScreen({super.key});

  @override
  State<CurriculaScreen> createState() => _CurriculaScreenState();
}

class _CurriculaScreenState extends State<CurriculaScreen> {
  final List<Major> majors = [
    Major(
      id: 'cs',
      name: 'Computer Science',
      code: 'CS',
      description:
      'Programming, algorithms, software development, AI, and web technologies',
      studentCount: 156,
      color: const Color(0xFF2196F3), // Blue
    ),
    Major(
      id: 'marketing',
      name: 'Marketing',
      code: 'MKT',
      description:
      'Market research, advertising, brand management, consumer behavior',
      studentCount: 89,
      color: const Color(0xFFFF9800), // Orange
    ),
    Major(
      id: 'cse',
      name: 'Computer Science Engineering',
      code: 'CSE',
      description:
      'Software engineering, hardware systems, embedded systems, networking',
      studentCount: 134,
      color: const Color(0xFFF44336), // Red
    ),
    Major(
      id: 'finance',
      name: 'Finance',
      code: 'FIN',
      description:
      'Investment analysis, corporate finance, banking, financial markets',
      studentCount: 112,
      color: const Color(0xFF4CAF50), // Green
    ),
    Major(
      id: 'digital_marketing',
      name: 'Digital Marketing',
      code: 'DMA',
      description:
      'SEO, social media marketing, content strategy, digital analytics',
      studentCount: 76,
      color: const Color(0xFF9C27B0), // Purple
    ),
    Major(
      id: 'english',
      name: 'English',
      code: 'ENG',
      description:
      'Literature, linguistics, creative writing, communication studies',
      studentCount: 65,
      color: const Color(0xFF795548), // Brown
    ),
    Major(
      id: 'data_science',
      name: 'Data Science',
      code: 'DSC',
      description:
      'Statistics, machine learning, data visualization, big data analytics',
      studentCount: 143,
      color: const Color(0xFF00BCD4), // Cyan
    ),
    Major(
      id: 'cyber_security',
      name: 'Cyber Security',
      code: 'CYS',
      description:
      'Network security, cryptography, ethical hacking, digital forensics',
      studentCount: 98,
      color: const Color(0xFF673AB7), // Deep Purple
    ),
    Major(
      id: 'business',
      name: 'Business Administration',
      code: 'BUS',
      description:
      'Management, entrepreneurship, operations, strategic planning',
      studentCount: 121,
      color: const Color(0xFFFF5722), // Deep Orange
    ),
    Major(
      id: 'ai',
      name: 'Artificial Intelligence',
      code: 'AIM',
      description:
      'Machine learning, neural networks, robotics, natural language processing',
      studentCount: 108,
      color: const Color(0xFFE91E63), // Pink
    ),
    Major(
      id: 'graphic',
      name: 'Graphic Design',
      code: 'GRD',
      description:
      'Visual communication, typography, digital art, UI/UX design',
      studentCount: 72,
      color: const Color(0xFF8BC34A), // Light Green
    ),
    Major(
      id: 'accounting',
      name: 'Accounting',
      code: 'ACC',
      description:
      'Financial accounting, auditing, taxation, managerial accounting',
      studentCount: 95,
      color: const Color(0xFF009688), // Teal
    ),
  ];

  Major? _selectedMajor;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallPhone = screenWidth < 360;
    final isLargePhone = screenWidth > 400;
    final isPortrait = screenHeight > screenWidth;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Academic Majors'),
        backgroundColor: const Color(0xFF4CAF50),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Icons.search,
              size: screenWidth * 0.06,
            ),
            onPressed: _searchMajors,
            tooltip: 'Search majors',
          ),
          IconButton(
            icon: Icon(
              Icons.filter_list,
              size: screenWidth * 0.06,
            ),
            onPressed: _showFilters,
            tooltip: 'Filter',
          ),
          IconButton(
            icon: Icon(
              Icons.sort,
              size: screenWidth * 0.06,
            ),
            onPressed: _showSortOptions,
            tooltip: 'Sort',
          ),
        ],
      ),
      body: Column(
        children: [
          // Header with stats
          Container(
            padding: EdgeInsets.all(screenWidth * 0.04),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Academic Majors',
                      style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.03,
                        vertical: screenHeight * 0.008,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.people,
                            size: screenWidth * 0.04,
                            color: const Color(0xFF4CAF50),
                          ),
                          SizedBox(width: screenWidth * 0.015),
                          Text(
                            '${_getTotalStudents()} Students',
                            style: TextStyle(
                              color: const Color(0xFF4CAF50),
                              fontWeight: FontWeight.w600,
                              fontSize: screenWidth * 0.03,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.01),
                Text(
                  '${majors.length} programs available • Tap to view details',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: screenWidth * 0.035,
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                // Quick stats - Horizontal scroll for small screens
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _statCard(
                        'Most Popular',
                        'CS',
                        '156 students',
                        const Color(0xFF2196F3),
                        context,
                      ),
                      SizedBox(width: screenWidth * 0.03),
                      _statCard(
                        'Newest',
                        'AIM',
                        'AI Major',
                        const Color(0xFFE91E63),
                        context,
                      ),
                      SizedBox(width: screenWidth * 0.03),
                      _statCard(
                        'Fast Growing',
                        'CYS',
                        '+24% growth',
                        const Color(0xFF673AB7),
                        context,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: screenHeight * 0.01),

          // Majors Grid - Responsive grid based on screen width
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isPortrait
                      ? (isSmallPhone ? 2 : 2)
                      : (screenWidth < 600 ? 3 : 4),
                  crossAxisSpacing: screenWidth * 0.04,
                  mainAxisSpacing: screenWidth * 0.04,
                  childAspectRatio: isPortrait ? 1.1 : 1.3,
                ),
                itemCount: majors.length,
                itemBuilder: (context, index) {
                  final major = majors[index];
                  return _majorCard(major, context);
                },
              ),
            ),
          ),

          // Selected Major Details
          if (_selectedMajor != null) _buildMajorDetails(context),
        ],
      ),
      floatingActionButton: _selectedMajor != null
          ? FloatingActionButton.extended(
        onPressed: () => _enrollInMajor(_selectedMajor!),
        backgroundColor: _selectedMajor!.color,
        icon: Icon(Icons.add, size: screenWidth * 0.05),
        label: Text(
          'Enroll Now',
          style: TextStyle(fontSize: screenWidth * 0.035),
        ),
      )
          : null,
    );
  }

  Widget _majorCard(Major major, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSelected = _selectedMajor?.id == major.id;

    return GestureDetector(
      onTap: () => setState(() {
        _selectedMajor = isSelected ? null : major;
      }),
      onLongPress: () => _showMajorQuickActions(major, context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isSelected ? major.color?.withOpacity(0.15) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? major.color! : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(isSelected ? 0.2 : 0.1),
              blurRadius: isSelected ? 12 : 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background decoration
            Positioned(
              right: -screenWidth * 0.05,
              top: -screenWidth * 0.05,
              child: Container(
                width: screenWidth * 0.2,
                height: screenWidth * 0.2,
                decoration: BoxDecoration(
                  color: major.color?.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Selection indicator
            if (isSelected)
              Positioned(
                top: screenHeight * 0.01,
                right: screenWidth * 0.03,
                child: Container(
                  padding: EdgeInsets.all(screenWidth * 0.01),
                  decoration: BoxDecoration(
                    color: major.color,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: screenWidth * 0.04,
                  ),
                ),
              ),

            Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Icon and Code
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.all(screenWidth * 0.02),
                        decoration: BoxDecoration(
                          color: major.color?.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getMajorIcon(major.code),
                          color: major.color,
                          size: screenWidth * 0.055,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.02,
                          vertical: screenHeight * 0.005,
                        ),
                        decoration: BoxDecoration(
                          color: major.color,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          major.code,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: screenWidth * 0.028,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Major Name
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        major.name,
                        style: TextStyle(
                          fontSize: screenWidth * 0.038,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: screenHeight * 0.005),
                      Text(
                        '${major.studentCount} students',
                        style: TextStyle(
                          fontSize: screenWidth * 0.028,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMajorDetails(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallPhone = screenWidth < 360;

    return Container(
      margin: EdgeInsets.all(screenWidth * 0.04),
      padding: EdgeInsets.all(screenWidth * 0.05),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _selectedMajor!.color!.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _selectedMajor!.name,
                style: TextStyle(
                  fontSize: screenWidth * 0.055,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: screenHeight * 0.005),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedMajor!.code,
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      color: _selectedMajor!.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.04,
                      vertical: screenHeight * 0.01,
                    ),
                    decoration: BoxDecoration(
                      color: _selectedMajor!.color,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.people,
                          size: screenWidth * 0.04,
                          color: Colors.white,
                        ),
                        SizedBox(width: screenWidth * 0.015),
                        Text(
                          '${_selectedMajor!.studentCount}',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: screenWidth * 0.035,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: screenHeight * 0.02),

          // Description
          Text(
            _selectedMajor!.description ?? 'No description available',
            style: TextStyle(
              fontSize: screenWidth * 0.037,
              color: Colors.grey[700],
              height: 1.6,
            ),
          ),

          SizedBox(height: screenHeight * 0.025),

          // Quick Info - Wrap for small screens
          Wrap(
            spacing: screenWidth * 0.03,
            runSpacing: screenHeight * 0.01,
            children: [
              _infoChip(Icons.schedule, '4 Years', _selectedMajor!.color!,
                  context),
              _infoChip(Icons.school, 'Bachelor\'s', _selectedMajor!.color!,
                  context),
              _infoChip(Icons.attach_money, 'Scholarship', _selectedMajor!.color!,
                  context),
            ],
          ),

          SizedBox(height: screenHeight * 0.03),

          // Action Buttons - Column for small screens
          isSmallPhone
              ? Column(
            children: [
              _actionButton(
                icon: Icons.library_books,
                label: 'Curriculum',
                color: _selectedMajor!.color!,
                onPressed: () => _viewCurriculum(_selectedMajor!, context),
                context: context,
              ),
              SizedBox(height: screenHeight * 0.01),
              Row(
                children: [
                  Expanded(
                    child: _actionButton(
                      icon: Icons.download,
                      label: 'Brochure',
                      color: Colors.grey[700]!,
                      onPressed: () =>
                          _downloadBrochure(_selectedMajor!, context),
                      context: context,
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.03),
                  SizedBox(
                    width: screenWidth * 0.15,
                    child: IconButton(
                      onPressed: () => _shareMajor(_selectedMajor!, context),
                      icon: Icon(
                        Icons.share,
                        size: screenWidth * 0.05,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey[100],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          )
              : Row(
            children: [
              Expanded(
                child: _actionButton(
                  icon: Icons.library_books,
                  label: 'Curriculum',
                  color: _selectedMajor!.color!,
                  onPressed: () => _viewCurriculum(_selectedMajor!, context),
                  context: context,
                ),
              ),
              SizedBox(width: screenWidth * 0.03),
              Expanded(
                child: _actionButton(
                  icon: Icons.download,
                  label: 'Brochure',
                  color: Colors.grey[700]!,
                  onPressed: () => _downloadBrochure(_selectedMajor!, context),
                  context: context,
                ),
              ),
              SizedBox(width: screenWidth * 0.03),
              SizedBox(
                width: screenWidth * 0.15,
                child: IconButton(
                  onPressed: () => _shareMajor(_selectedMajor!, context),
                  icon: Icon(
                    Icons.share,
                    size: screenWidth * 0.05,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey[100],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statCard(
      String title, String value, String subtitle, Color color, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth * 0.28,
      padding: EdgeInsets.all(screenWidth * 0.025),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: screenWidth * 0.028,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: screenWidth * 0.01),
          Text(
            value,
            style: TextStyle(
              fontSize: screenWidth * 0.035,
              color: Colors.grey[800],
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: screenWidth * 0.025,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String text, Color color, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.03,
        vertical: screenWidth * 0.015,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: screenWidth * 0.035, color: color),
          SizedBox(width: screenWidth * 0.015),
          Text(
            text,
            style: TextStyle(
              fontSize: screenWidth * 0.03,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
    required BuildContext context,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: screenWidth * 0.035),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: screenWidth * 0.045),
          SizedBox(width: screenWidth * 0.02),
          Text(
            label,
            style: TextStyle(fontSize: screenWidth * 0.035),
          ),
        ],
      ),
    );
  }

  IconData _getMajorIcon(String code) {
    switch (code) {
      case 'CS':
      case 'CSE':
        return Icons.computer;
      case 'MKT':
      case 'DMA':
        return Icons.trending_up;
      case 'FIN':
      case 'ACC':
        return Icons.attach_money;
      case 'ENG':
        return Icons.menu_book;
      case 'DSC':
      case 'AIM':
        return Icons.analytics;
      case 'CYS':
        return Icons.security;
      case 'BUS':
        return Icons.business;
      case 'GRD':
        return Icons.design_services;
      default:
        return Icons.school;
    }
  }

  int _getTotalStudents() {
    return majors.fold(0, (sum, major) => sum + major.studentCount);
  }

  void _viewCurriculum(Major major, BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _buildCurriculumScreen(major, context)),
    );
  }

  void _downloadBrochure(Major major, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading ${major.name} brochure...'),
        backgroundColor: major.color,
        action: SnackBarAction(
          label: 'VIEW',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  void _shareMajor(Major major, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share Major'),
        content: Text('Share ${major.name} program with others'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Share'),
          ),
        ],
      ),
    );
  }

  void _enrollInMajor(Major major) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enrollment'),
        content: Text('Are you sure you want to enroll in ${major.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Successfully enrolled in ${major.name}!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Enroll'),
          ),
        ],
      ),
    );
  }

  void _searchMajors() {
    showDialog(
      context: context,
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;

        return AlertDialog(
          title: const Text('Search Majors'),
          content: SizedBox(
            width: screenWidth * 0.8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search by name or code...',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) {},
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Chip(label: const Text('Popular'), onDeleted: () {}),
                    Chip(label: const Text('STEM'), onDeleted: () {}),
                    Chip(label: const Text('Business'), onDeleted: () {}),
                    Chip(label: const Text('Arts'), onDeleted: () {}),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Search'),
            ),
          ],
        );
      },
    );
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        final screenHeight = MediaQuery.of(context).size.height;

        return Container(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
          constraints: BoxConstraints(maxHeight: screenHeight * 0.7),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Filter Majors',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                _filterOption('By Student Count', Icons.people),
                _filterOption('By Duration', Icons.schedule),
                _filterOption('By Career Path', Icons.work),
                _filterOption('By Location', Icons.location_on),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Apply Filters'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _filterOption(String title, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF4CAF50)),
      title: Text(title),
      trailing: Switch(value: false, onChanged: (value) {}),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        final screenHeight = MediaQuery.of(context).size.height;

        return Container(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
          constraints: BoxConstraints(maxHeight: screenHeight * 0.7),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Sort Majors',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                _sortOption('Most Popular', Icons.trending_up),
                _sortOption('Alphabetical (A-Z)', Icons.sort_by_alpha),
                _sortOption('Student Count', Icons.people),
                _sortOption('Newest First', Icons.new_releases),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                        ),
                        child: const Text('Apply'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sortOption(String title, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[700]),
      title: Text(title),
      trailing: Radio(value: false, groupValue: true, onChanged: (value) {}),
    );
  }

  void _showMajorQuickActions(Major major, BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        final screenHeight = MediaQuery.of(context).size.height;

        return Container(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
          constraints: BoxConstraints(maxHeight: screenHeight * 0.6),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  major.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4CAF50),
                  ),
                ),
                const SizedBox(height: 20),
                _quickActionTile(Icons.info, 'Program Details', () {}),
                _quickActionTile(Icons.school, 'Faculty', () {}),
                _quickActionTile(Icons.work, 'Career Opportunities', () {}),
                _quickActionTile(Icons.event, 'Upcoming Events', () {}),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _quickActionTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF4CAF50)),
      title: Text(title),
      onTap: onTap,
    );
  }

  Widget _buildCurriculumScreen(Major major, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text('${major.code} Curriculum'),
        backgroundColor: major.color,
      ),
      body: ListView(
        padding: EdgeInsets.all(screenWidth * 0.04),
        children: [
          // Header
          Card(
            color: major.color?.withOpacity(0.1),
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    major.name,
                    style: TextStyle(
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Text(
                    '4-Year Bachelor\'s Program • ${major.studentCount} Students',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: screenWidth * 0.035,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: screenHeight * 0.02),

          // Year 1
          _yearSection('Year 1: Foundation', [
            'Introduction to ${major.name.split(' ')[0]}',
            'Basic Programming & Algorithms',
            'Mathematics for Computing',
            'Communication Skills',
            'General Education Elective',
          ], major.color!, context),

          // Year 2
          _yearSection('Year 2: Core Concepts', [
            'Data Structures',
            'Database Systems',
            'Object-Oriented Design',
            '${major.code} Lab I',
            'Technical Writing',
          ], major.color!, context),

          // Year 3
          _yearSection('Year 3: Specialization', [
            'Advanced ${major.name.split(' ')[0]}',
            'Project Management',
            'Elective Track Course',
            'Internship Preparation',
            'Research Methods',
          ], major.color!, context),

          // Year 4
          _yearSection('Year 4: Capstone', [
            'Senior Project/Thesis',
            'Professional Ethics',
            'Industry Elective',
            'Career Development',
            'Final Capstone Project',
          ], major.color!, context),

          SizedBox(height: screenHeight * 0.03),

          // Career Paths
          Card(
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Career Paths',
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.015),
                  Wrap(
                    spacing: screenWidth * 0.02,
                    runSpacing: screenHeight * 0.01,
                    children: [
                      _careerChip('Software Developer', context),
                      _careerChip('${major.code} Analyst', context),
                      _careerChip('Project Manager', context),
                      _careerChip('Data Specialist', context),
                      _careerChip('Systems Engineer', context),
                      _careerChip('Consultant', context),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _yearSection(
      String title, List<String> courses, Color color, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Card(
      margin: EdgeInsets.only(bottom: screenHeight * 0.02),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(screenWidth * 0.02),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.school, color: color),
                ),
                SizedBox(width: screenWidth * 0.03),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.015),
            Column(
              children: courses
                  .map((course) => _courseItem(course, color, context))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _courseItem(String course, Color color, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenWidth * 0.015),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: screenWidth * 0.04, color: color),
          SizedBox(width: screenWidth * 0.03),
          Expanded(
            child: Text(
              course,
              style: TextStyle(fontSize: screenWidth * 0.035),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.02,
              vertical: screenWidth * 0.01,
            ),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '3 CR',
              style: TextStyle(
                fontSize: screenWidth * 0.025,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _careerChip(String career, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Chip(
      label: Text(
        career,
        style: TextStyle(fontSize: screenWidth * 0.03),
      ),
      backgroundColor: Colors.grey[100],
      side: BorderSide(color: Colors.grey[300]!),
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.02,
        vertical: screenWidth * 0.01,
      ),
    );
  }
}