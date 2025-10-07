import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:camera/camera.dart';

class AddTransactionView extends StatefulWidget {
  const AddTransactionView({super.key});

  @override
  State<AddTransactionView> createState() => _AddTransactionViewState();
}

class _AddTransactionViewState extends State<AddTransactionView> {
  bool _isImageTaken = false;
  bool _showPastUploads = false;
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _cameraController = CameraController(
          _cameras![0], // Use back camera (index 0)
          ResolutionPreset.medium, // Use medium resolution for better performance
          enableAudio: false, // Disable audio for better performance
        );
        
        await _cameraController!.initialize();
        
        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }
      }
    } catch (e) {
      print('Error initializing camera: $e');
      if (mounted) {
        setState(() {
          _isCameraInitialized = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera view background
          Container(
            width: double.infinity,
            height: double.infinity,
            child: _isImageTaken
                ? _buildImagePreview()
                : _buildCameraView(),
          ),
          
          // Bottom navigation (footer only)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomNavigation(),
          ),
          
          // Image picker button (faint, above plus button)
          if (!_isImageTaken)
            Positioned(
              bottom: 120.h, // Position above the plus button
              left: 0,
              right: 0,
              child: Center(
                child: _buildImagePickerButton(),
              ),
            ),
          
          // Upload options (when image is taken)
          if (_isImageTaken)
            Positioned(
              bottom: 100.h,
              left: 0,
              right: 0,
              child: _buildUploadOptions(),
            ),
          
          // Past uploads overlay
          if (_showPastUploads)
            _buildPastUploadsOverlay(),
        ],
      ),
    );
  }

  Widget _buildCameraView() {
    // Show loading state
    if (!_isCameraInitialized) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: Colors.white,
              ),
              SizedBox(height: 16.h),
              Text(
                'Initializing camera...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Show error state if camera failed to initialize
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 64.w,
              ),
              SizedBox(height: 16.h),
              Text(
                'Camera not available',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Tap the circle to simulate taking a picture',
                style: TextStyle(
                  color: Colors.grey.shade300,
                  fontSize: 14.sp,
                ),
              ),
              SizedBox(height: 24.h),
              // Fallback camera circle for when camera is not available
              GestureDetector(
                onTap: _takePicture,
                child: Container(
                  width: 80.w,
                  height: 80.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 4.w,
                    ),
                    color: Colors.transparent,
                  ),
                  child: Center(
                    child: Container(
                      width: 60.w,
                      height: 60.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        // Camera preview with proper aspect ratio
        Positioned.fill(
          child: AspectRatio(
            aspectRatio: _cameraController!.value.aspectRatio,
            child: CameraPreview(_cameraController!),
          ),
        ),
        
        // Camera circle overlay
        Center(
          child: GestureDetector(
            onTap: _takePicture,
            child: Container(
              width: 80.w,
              height: 80.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 4.w,
                ),
                color: Colors.transparent,
              ),
              child: Center(
                child: Container(
                  width: 60.w,
                  height: 60.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePreview() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey.shade800,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long,
              size: 120.w,
              color: Colors.white,
            ),
            SizedBox(height: 20.h),
            Text(
              'Receipt captured!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'AI will analyze your transaction',
              style: TextStyle(
                color: Colors.grey.shade300,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePickerButton() {
    return GestureDetector(
      onTap: _showImagePicker,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3), // Faint background
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt,
              color: Colors.white.withOpacity(0.7), // Faint icon
              size: 24.w,
            ),
            SizedBox(height: 4.h),
            Text(
              'Images',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7), // Faint text
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadOptions() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Retake button
          GestureDetector(
            onTap: _retakePicture,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: Colors.white, width: 1),
              ),
              child: Text(
                'Retake',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          
          // Upload button
          GestureDetector(
            onTap: _uploadTransaction,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: const Color(0xFFEAB308),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                'Upload',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white, // Keep white theme
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade300,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavItem(Icons.home, 'Home', false, () => Navigator.of(context).pop()),
          _buildNavItem(Icons.attach_money, 'Track', false, () => Navigator.of(context).pop()),
          _buildNavItem(Icons.add, '', true, () {}, isCenter: true),
          _buildNavItem(Icons.account_balance_wallet, 'Split', false, () => Navigator.of(context).pop()),
          _buildNavItem(Icons.people, 'Social', false, () => Navigator.of(context).pop()),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, VoidCallback onTap, {bool isCenter = false}) {
    if (isCenter) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          width: 48.w,
          height: 48.h,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFF5E68A), Color(0xFFEAB308), Color(0xFFD69E2E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24.w,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? const Color(0xFFEAB308) : Colors.grey.shade600,
            size: 24.w,
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              color: isActive ? const Color(0xFFEAB308) : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPastUploadsOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.9),
      child: Column(
        children: [
          // Drag handle
          Container(
            width: 40.w,
            height: 4.h,
            margin: EdgeInsets.only(top: 8.h, bottom: 16.h),
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          
          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Past Uploads',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _showPastUploads = false),
                  child: Container(
                    width: 32.w,
                    height: 32.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade700,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20.w,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 20.h),
          
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Current Cycle
                  _buildCycleSection('Current Cycle', 'September 1st - September 30th', [
                    _buildUploadItem('Starbucks Coffee', '\$5.50', 'Today', Icons.local_cafe),
                    _buildUploadItem('Grocery Store', '\$45.20', 'Yesterday', Icons.shopping_cart),
                    _buildUploadItem('Gas Station', '\$35.00', '2 days ago', Icons.local_gas_station),
                  ]),
                  
                  SizedBox(height: 24.h),
                  
                  // Last Cycle
                  _buildCycleSection('Last Cycle', 'August 1st - August 31st', [
                    _buildUploadItem('Restaurant', '\$28.50', 'August 30th', Icons.restaurant),
                    _buildUploadItem('Amazon', '\$67.99', 'August 28th', Icons.shopping_bag),
                    _buildUploadItem('Pharmacy', '\$12.30', 'August 25th', Icons.local_pharmacy),
                  ]),
                  
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCycleSection(String title, String dateRange, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          dateRange,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey.shade400,
          ),
        ),
        SizedBox(height: 16.h),
        ...items,
      ],
    );
  }

  Widget _buildUploadItem(String title, String amount, String date, IconData icon) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFFEAB308),
            size: 24.w,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _takePicture() async {
    // If camera is not available, just simulate taking a picture
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      setState(() {
        _isImageTaken = true;
      });
      return;
    }

    try {
      final XFile image = await _cameraController!.takePicture();
      // For now, just simulate taking a picture
      setState(() {
        _isImageTaken = true;
      });
    } catch (e) {
      print('Error taking picture: $e');
      // Fallback to simulation if camera fails
      setState(() {
        _isImageTaken = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Camera error, using simulation mode'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _retakePicture() {
    setState(() {
      _isImageTaken = false;
    });
  }

  void _uploadTransaction() {
    // TODO: Implement upload functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Transaction uploaded successfully!'),
        backgroundColor: Color(0xFFEAB308),
      ),
    );
    setState(() {
      _isImageTaken = false;
    });
  }

  void _showImagePicker() {
    // TODO: Implement image picker functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Image picker coming soon!'),
        backgroundColor: Color(0xFFEAB308),
      ),
    );
  }
}
