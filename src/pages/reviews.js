// =====================================================
// reviews.js
// Static (non-AI) SEO-friendly review text, split into two
// buckets by rating: low (1-3 stars) and high (4-5 stars).
//
// Used by ReviewScreen as a fallback when the AI call fails.
//
// SEO NOTES:
// - Each review uses a {business_name} placeholder, filled in
//   dynamically per business via fillBusinessName().
// - Reviews work for ANY business type (restaurant, salon,
//   clinic, shop, service business, etc.) — they lean on
//   generic-but-strong local-SEO terms that Google weighs in
//   reviews: service quality, staff, pricing/value, location/
//   visit, recommend, professionalism, experience.
// - Sentence structure and length are varied on purpose so a
//   batch of reviews doesn't look templated/spammy to Google
//   or to readers.
// =====================================================

export const lowRatingReviews = [
  "My experience at {business_name} could have been better.",
  "Service at {business_name} needs some attention and improvement.",
  "Overall it was an average visit to {business_name}.",
  "Not quite what I expected from {business_name}, there's room to improve.",
  "{business_name} was okay but service could be a lot faster.",
  "It was a fine visit to {business_name}, nothing special though.",
  "Expected better quality for the price at {business_name}.",
  "Staff at {business_name} seemed busy and a bit unorganized.",
  "The wait time at {business_name} was longer than I expected.",
  "Decent service at {business_name}, but communication could improve.",
  "Had a few issues at {business_name} that need to be addressed.",
  "{business_name} was alright, but I think there's potential to do better.",
  "Quality at {business_name} was below my expectations this time.",
  "My visit to {business_name} felt a bit rushed.",
  "Things at {business_name} were okay but not very memorable.",
  "There were some delays at {business_name} that affected the experience.",
  "Service at {business_name} was inconsistent during my visit.",
  "I expected more attention to detail from {business_name}.",
  "It was an average visit to {business_name}, nothing stood out.",
  "{business_name} could use some improvements in customer service.",
  "What I got from {business_name} didn't fully meet my expectations.",
  "Staff at {business_name} were polite but the process was slow.",
  "{business_name} needs better coordination between staff members.",
  "My visit to {business_name} was okay, but I had some concerns.",
  "Cleanliness could be improved at {business_name} in certain areas.",
  "I faced a minor issue at {business_name} that wasn't resolved quickly.",
  "It was a so-so experience overall at {business_name}.",
  "Pricing at {business_name} felt a bit high for what was offered.",
  "Communication from {business_name} was unclear at times.",
  "There's scope for {business_name} to improve service speed.",
  "It was an okay experience at {business_name}, but not outstanding.",
  "A few things at {business_name} didn't go as smoothly as expected.",
  "Staff at {business_name} could be more attentive to customers.",
  "Quality control at {business_name} seems to need some work.",
  "I had to wait longer than I would have liked at {business_name}.",
  "My experience at {business_name} was just average.",
  "Some improvements in efficiency at {business_name} would help a lot.",
  "{business_name} wasn't bad, but it wasn't great either.",
  "Service at {business_name} felt a little impersonal.",
  "There were a couple of hiccups during my visit to {business_name}.",
  "I think the team at {business_name} could improve their response time.",
  "Overall okay at {business_name}, but I expected a bit more value.",
  "The setup at {business_name} felt slightly disorganized.",
  "Service quality at {business_name} varied throughout my visit.",
  "It was a passable experience overall at {business_name}.",
  "A bit more attention to detail would help at {business_name}.",
  "My visit to {business_name} left me with mixed feelings.",
  "Things at {business_name} were fine, but not particularly impressive.",
  "I noticed a few things at {business_name} that could be better managed.",
  "{business_name} met basic expectations but nothing more.",
];

export const highRatingReviews = [
  "Really loved my experience at {business_name}, everything was perfect.",
  "Excellent service and amazing staff at {business_name}.",
  "Highly recommend {business_name}, I'll definitely come back.",
  "{business_name} has friendly staff and excellent service, highly recommended.",
  "Great experience from start to finish at {business_name}, will visit again.",
  "Professional service at {business_name} with amazing support and quality work.",
  "Outstanding experience at {business_name}, exceeded all my expectations.",
  "Fantastic service at {business_name}, the staff went above and beyond.",
  "Couldn't be happier with the quality and attention to detail at {business_name}.",
  "Top-notch service every time at {business_name}, highly recommend.",
  "The team at {business_name} was incredibly professional and friendly.",
  "Amazing experience at {business_name}, I'll definitely be a repeat customer.",
  "Everything at {business_name} was handled perfectly from start to finish.",
  "Wonderful service at {business_name}, truly exceeded my expectations.",
  "Five stars for {business_name}, absolutely fantastic all around.",
  "Staff at {business_name} made the entire process smooth and enjoyable.",
  "Best experience I've had in a long time, highly recommend {business_name}.",
  "Quick, efficient, and extremely friendly service at {business_name}.",
  "Impressed by the level of professionalism and care at {business_name}.",
  "A truly wonderful visit to {business_name} from beginning to end.",
  "The quality of service at {business_name} is simply outstanding.",
  "Everyone at {business_name} was so welcoming and helpful throughout.",
  "Exceptional service at {business_name}, will be telling all my friends.",
  "Loved every part of my visit to {business_name}, truly first class.",
  "The attention to detail at {business_name} really made a difference.",
  "Such a pleasant and smooth experience overall at {business_name}.",
  "I'm extremely satisfied with the service provided at {business_name}.",
  "Staff at {business_name} were knowledgeable and very accommodating.",
  "A fantastic experience at {business_name} that I would highly recommend.",
  "Everything at {business_name} exceeded my expectations, truly impressive.",
  "Great communication and excellent customer care from {business_name}.",
  "The whole team at {business_name} was friendly, fast, and professional.",
  "I had an absolutely delightful experience at {business_name}.",
  "Superb service at {business_name}, definitely worth the visit.",
  "My experience at {business_name} was seamless and very enjoyable.",
  "I appreciated the warm welcome and great service at {business_name}.",
  "Highly professional staff with a great attitude at {business_name}.",
  "Everything at {business_name} was top quality, very impressed overall.",
  "A great experience at {business_name} that I would gladly repeat.",
  "The staff at {business_name} truly cared about making my visit special.",
  "Excellent attention to detail and great hospitality at {business_name}.",
  "I felt valued as a customer throughout my visit to {business_name}.",
  "A wonderful experience at {business_name} with friendly, helpful staff.",
  "Service quality at {business_name} is consistently excellent.",
  "Everything went smoothly at {business_name} and the staff were lovely.",
  "Such a great experience at {business_name}, I'll definitely be back.",
  "The team at {business_name} really knows how to take care of customers.",
  "Impressive service from start to finish at {business_name}, well done.",
  "A truly satisfying visit to {business_name}, highly recommended.",
  "Couldn't have asked for a better experience overall at {business_name}.",
];

export const allStaticReviews = [...lowRatingReviews, ...highRatingReviews];

// Returns a list of static reviews matching the given star rating
// (1-3 -> low bucket, 4-5 -> high bucket).
export function getStaticReviewsForRating(rating) {
  return rating >= 4 ? highRatingReviews : lowRatingReviews;
}

// Replaces the {business_name} placeholder with the actual name.
// Falls back to "this business" if no name is provided, so the
// sentence still reads naturally instead of showing "{business_name}".
export function fillBusinessName(reviewText, businessName) {
  const name = businessName?.trim() || "this business";
  return reviewText.replaceAll("{business_name}", name);
}

// Returns `count` random reviews from the bucket matching the rating,
// without repeats, with {business_name} already filled in. Used as
// the AI-failure fallback so the suggestions still read as natural,
// SEO-friendly, business-specific reviews.
export function getRandomStaticReviews(rating, count = 3, businessName = "") {
  const pool = [...getStaticReviewsForRating(rating)];
  const result = [];

  while (result.length < count && pool.length > 0) {
    const randomIndex = Math.floor(Math.random() * pool.length);
    const review = pool.splice(randomIndex, 1)[0];
    result.push(fillBusinessName(review, businessName));
  }

  return result;
}