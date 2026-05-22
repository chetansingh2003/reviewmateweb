import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/review_model.dart';

class ReviewCard extends StatelessWidget {

  final ReviewModel review;

  const ReviewCard({
    super.key,
    required this.review,
  });

  @override
  Widget build(BuildContext context) {

    return Container(

      margin:
      const EdgeInsets.only(
        bottom: 18,
      ),

      padding:
      const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
        BorderRadius.circular(28),

        boxShadow: [
          BoxShadow(
            blurRadius: 15,
            color:
            Colors.black.withOpacity(
              0.04,
            ),
          )
        ],
      ),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [

          Row(
            children: [

              CircleAvatar(
                radius: 26,

                backgroundColor:
                const Color(
                  0xff0052CC,
                ),

                child: Text(
                  review.customerName[0],

                  style:
                  GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

                  children: [

                    Text(
                      review.customerName,

                      style:
                      GoogleFonts.inter(
                        fontWeight:
                        FontWeight.w700,

                        fontSize: 18,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Row(
                      children: List.generate(
                        5,
                            (index) {

                          return Icon(
                            Icons.star,

                            size: 18,

                            color:
                            index <
                                review.rating
                                ? Colors.orange
                                : Colors.grey
                                .shade300,
                          );
                        },
                      ),
                    )
                  ],
                ),
              ),

              Container(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),

                decoration: BoxDecoration(
                  color: const Color(
                    0xffEEF2FF,
                  ),

                  borderRadius:
                  BorderRadius.circular(
                    30,
                  ),
                ),

                child: Text(
                  review.platform,

                  style:
                  GoogleFonts.inter(
                    color:
                    const Color(
                      0xff0052CC,
                    ),

                    fontWeight:
                    FontWeight.w600,
                  ),
                ),
              )
            ],
          ),

          const SizedBox(height: 18),

          Text(
            review.review,

            style: GoogleFonts.inter(
              color: Colors.grey.shade700,
              height: 1.6,
            ),
          ),

          const SizedBox(height: 18),

          ElevatedButton.icon(

            style:
            ElevatedButton.styleFrom(
              backgroundColor:
              const Color(
                0xff0052CC,
              ),

              shape:
              RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(
                  16,
                ),
              ),
            ),

            onPressed: () {},

            icon: const Icon(
              Icons.reply,
              color: Colors.white,
            ),

            label: Text(
              "Reply",

              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight:
                FontWeight.w700,
              ),
            ),
          ),

          if (review.replied)

            Container(

              margin:
              const EdgeInsets.only(
                top: 18,
              ),

              padding:
              const EdgeInsets.all(
                16,
              ),

              decoration: BoxDecoration(
                color: const Color(
                  0xffF5F7FF,
                ),

                borderRadius:
                BorderRadius.circular(
                  18,
                ),
              ),

              child: Text(
                review.reply,

                style: GoogleFonts.inter(
                  color:
                  Colors.grey.shade700,

                  fontStyle:
                  FontStyle.italic,
                ),
              ),
            )
        ],
      ),
    );
  }
}