import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:plantcare/constant/colors.dart';
import 'package:plantcare/modelView/news_controllers.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsScreen extends StatelessWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize NewsController
    final NewsController newsController = Get.put(NewsController());
    
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 12.h),
              
              // Header with back button
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        size: 20.sp,
                        color: blackColor,
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Trending News',
                          style: GoogleFonts.poppins(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.w600,
                            color: blackColor,
                          ),
                        ),
                        Text(
                          'Latest Updates',
                          style: GoogleFonts.poppins(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: greyColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 20.h),

              // Search Bar
              Container(
                height: 50.h,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(25.r),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: TextField(
                  onChanged: (value) {
                    newsController.searchNews(value);
                  },
                  decoration: InputDecoration(
                    hintText: 'Search news...',
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      color: greyColor,
                      fontWeight: FontWeight.w400,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: greyColor,
                      size: 20.sp,
                    ),
                    suffixIcon: GestureDetector(
                      onTap: () {
                        newsController.refreshNews();
                      },
                      child: Icon(
                        Icons.refresh,
                        color: greyColor,
                        size: 20.sp,
                      ),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 15.h,
                    ),
                  ),
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: blackColor,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              // News List with real API data
              Expanded(
                child: Obx(() {
                  // Loading state
                  if (newsController.isLoading.value) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: greenColor,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'Loading news...',
                            style: GoogleFonts.poppins(
                              fontSize: 16.sp,
                              color: greyColor,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Error state
                  if (newsController.hasError.value) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64.sp,
                            color: greyColor,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'Failed to load news',
                            style: GoogleFonts.poppins(
                              fontSize: 18.sp,
                              color: blackColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            newsController.errorMessage.value,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 14.sp,
                              color: greyColor,
                            ),
                          ),
                          SizedBox(height: 24.h),
                          ElevatedButton(
                            onPressed: () => newsController.refreshNews(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: greenColor,
                              padding: EdgeInsets.symmetric(
                                horizontal: 32.w,
                                vertical: 12.h,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25.r),
                              ),
                            ),
                            child: Text(
                              'Retry',
                              style: GoogleFonts.poppins(
                                fontSize: 16.sp,
                                color: whiteColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Empty state
                  if (newsController.filteredNewsList.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.article_outlined,
                            size: 64.sp,
                            color: greyColor,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'No news found',
                            style: GoogleFonts.poppins(
                              fontSize: 18.sp,
                              color: blackColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Try searching with different keywords',
                            style: GoogleFonts.poppins(
                              fontSize: 14.sp,
                              color: greyColor,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // News List
                  return RefreshIndicator(
                    onRefresh: () => newsController.refreshNews(),
                    color: greenColor,
                    child: ListView.separated(
                      physics: AlwaysScrollableScrollPhysics(),
                      itemCount: newsController.filteredNewsList.length,
                      itemBuilder: (context, index) {
                        final article = newsController.filteredNewsList[index];
                        
                        return GestureDetector(
                          onTap: () async {
                            // Open article URL in browser
                            if (article.url.isNotEmpty && await canLaunch(article.url)) {
                              await launch(article.url);
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Article Image
                                Container(
                                  width: 118.w,
                                  height: 114.h,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(15.r),
                                    child: article.imageUrl.isNotEmpty
                                        ? Image.network(
                                            article.imageUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Container(
                                                color: Colors.grey[200],
                                                child: Icon(
                                                  Icons.image_not_supported,
                                                  color: greyColor,
                                                  size: 40.sp,
                                                ),
                                              );
                                            },
                                            loadingBuilder: (context, child, loadingProgress) {
                                              if (loadingProgress == null) return child;
                                              return Container(
                                                color: Colors.grey[200],
                                                child: Center(
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    color: greenColor,
                                                  ),
                                                ),
                                              );
                                            },
                                          )
                                        : Container(
                                            color: Colors.grey[200],
                                            child: Icon(
                                              Icons.image_not_supported,
                                              color: greyColor,
                                              size: 40.sp,
                                            ),
                                          ),
                                  ),
                                ),

                                SizedBox(width: 12.w),

                                // Article Content
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Article Title
                                      Text(
                                        article.title,
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.poppins(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w600,
                                          color: blackColor,
                                          height: 1.3,
                                        ),
                                      ),

                                      SizedBox(height: 8.h),

                                      // Article Description
                                      Text(
                                        article.description,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.poppins(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w400,
                                          color: greyColor,
                                          height: 1.2,
                                        ),
                                      ),

                                      SizedBox(height: 12.h),

                                      // Source and Date
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              article.source,
                                              style: GoogleFonts.poppins(
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.w500,
                                                color: greyColor,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          SizedBox(width: 8.w),
                                          Text(
                                            newsController.formatDate(article.publishedAt),
                                            style: GoogleFonts.poppins(
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w500,
                                              color: greyColor,
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
                      },
                      separatorBuilder: (context, index) {
                        return SizedBox(height: 16.h);
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}