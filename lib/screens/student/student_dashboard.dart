import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({Key? key}) : super(key: key);

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = true;
  List<Map<String, dynamic>> _enrolledCourses = [];
  List<Map<String, dynamic>> _availableCourses = [];
  String _selectedFilter = 'All';
  List<String> _filters = ['All'];

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      // Load enrolled courses
      final enrollmentSnapshot = await _databaseRef
          .child('userEnrollments/$userId/courses')
          .get();

      Set<String> enrolledCourseIds = {};
      if (enrollmentSnapshot.exists) {
        final enrollments = enrollmentSnapshot.value as Map<dynamic, dynamic>;
        enrolledCourseIds = enrollments.keys.cast<String>().toSet();
      }

      // Load all available courses
      final coursesSnapshot = await _databaseRef.child('courses').get();
      if (coursesSnapshot.exists) {
        final coursesData = coursesSnapshot.value as Map<dynamic, dynamic>;
        List<Map<String, dynamic>> enrolled = [];
        List<Map<String, dynamic>> available = [];
        Set<String> uniqueTags = {'All'};

        coursesData.forEach((key, value) {
          final course = value as Map<dynamic, dynamic>;
          final courseMap = {
            'id': key,
            'title': course['title'] ?? 'Untitled Course',
            'description': course['description'] ?? '',
            'coverImageUrl': course['coverImageUrl'] ?? '',
            'tutorName': course['tutorName'] ?? 'Unknown Tutor',
            'tags': (course['tags'] as List<dynamic>?)?.cast<String>() ?? [],
            'enrollmentCount': course['enrollmentCount'] ?? 0,
          };

          // Add tags to filter options
          if (course['tags'] != null) {
            for (var tag in (course['tags'] as List<dynamic>)) {
              uniqueTags.add(tag.toString());
            }
          }

          if (enrolledCourseIds.contains(key)) {
            enrolled.add(courseMap);
          } else {
            available.add(courseMap);
          }
        });

        setState(() {
          _enrolledCourses = enrolled;
          _availableCourses = available;
          _filters = uniqueTags.toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading courses: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load courses'))
      );
    }
  }

  Future<void> _enrollInCourse(String courseId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You need to be signed in to enroll'))
      );
      return;
    }

    try {
      // Mark as enrolled
      await _databaseRef
          .child('userEnrollments/$userId/courses/$courseId')
          .set(true);

      // Increment enrollment count
      final courseRef = _databaseRef.child('courses/$courseId/enrollmentCount');
      await courseRef.runTransaction((currentCount) {
        int newCount = 1;
        if (currentCount != null) {
          newCount = (currentCount as int) + 1;
        }
        return Transaction.success(newCount);
      });


      // Refresh course lists
      await _loadCourses();

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully enrolled in course!'))
      );
    } catch (e) {
      print('Error enrolling in course: $e');
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to enroll in course'))
      );
    }
  }

  List<Map<String, dynamic>> _getFilteredCourses() {
    if (_selectedFilter == 'All') {
      return _availableCourses;
    }
    return _availableCourses.where((course) {
      return (course['tags'] as List<String>).contains(_selectedFilter);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              // Navigate to profile screen
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadCourses,
        child: CustomScrollView(
          slivers: [
            if (_enrolledCourses.isNotEmpty) ...[
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    'My Enrolled Courses',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 220,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    scrollDirection: Axis.horizontal,
                    itemCount: _enrolledCourses.length,
                    itemBuilder: (context, index) {
                      final course = _enrolledCourses[index];
                      return _buildEnrolledCourseCard(course);
                    },
                  ),
                ),
              ),
            ],

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Explore Courses',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _filters.length,
                        itemBuilder: (context, index) {
                          final filter = _filters[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(filter),
                              selected: _selectedFilter == filter,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedFilter = filter;
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final filteredCourses = _getFilteredCourses();
                  if (filteredCourses.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(
                        child: Text('No courses available for this filter'),
                      ),
                    );
                  }
                  final course = filteredCourses[index];
                  return _buildAvailableCourseCard(course);
                },
                childCount: _getFilteredCourses().isEmpty ? 1 : _getFilteredCourses().length,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnrolledCourseCard(Map<String, dynamic> course) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/courseDetail',
          arguments: {'courseId': course['id']},
        );
      },
      child: Container(
        width: 280,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: course['coverImageUrl'] != null && course['coverImageUrl'].toString().isNotEmpty
                  ? Image.network(
                course['coverImageUrl'],
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(
                      height: 120,
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image, size: 40),
                    ),
              )
                  : Container(
                height: 120,
                color: Colors.grey[300],
                child: const Icon(Icons.book, size: 40),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course['title'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'By ${course['tutorName']}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: 0.3, // Replace with actual progress
                    backgroundColor: Colors.grey[200],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '30% Complete', // Replace with actual progress
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
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

  Widget _buildAvailableCourseCard(Map<String, dynamic> course) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/courseDetail',
            arguments: {'courseId': course['id']},
          );
        },
        child: Column(
          children: [
            if (course['coverImageUrl'] != null && course['coverImageUrl'].toString().isNotEmpty)
              Image.network(
                course['coverImageUrl'],
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(
                      height: 150,
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image, size: 40),
                    ),
              )
            else
              Container(
                height: 150,
                color: Colors.grey[300],
                child: const Icon(Icons.book, size: 40),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course['title'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('By ${course['tutorName']}'),
                  const SizedBox(height: 8),
                  Text(
                    course['description'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if ((course['tags'] as List).isNotEmpty)
                        Expanded(
                          child: Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: (course['tags'] as List).map((tag) {
                              return Chip(
                                label: Text(
                                  tag,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                padding: EdgeInsets.zero,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              );
                            }).toList(),
                          ),
                        ),
                      TextButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Enroll'),
                        onPressed: () => _enrollInCourse(course['id']),
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
}