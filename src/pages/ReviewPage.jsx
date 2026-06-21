import { useEffect, useState } from "react";
import { createClient } from "@supabase/supabase-js";
import { useSearchParams } from "react-router-dom";
import { getRandomStaticReviews } from "./reviews";

const supabase = createClient(
  "https://pwaaldsnrjhexahaoqzs.supabase.co",

  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB3YWFsZHNucmpoZXhhaGFvcXpzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzkwMzIzNTksImV4cCI6MjA5NDYwODM1OX0.KdIyjjl3rfNFAuTLxlfhZDKwXvlDRPfAHYi1plSQ1Wk"
);
const API_URL =
  "https://backkk-production-4f6d.up.railway.app";

export default function ReviewScreen() {

  const [searchParams] =
      useSearchParams();

 const token =
    searchParams.get("token");

  const [business, setBusiness] =
      useState(null);

  const [rating, setRating] =
      useState(0);

  const [text, setText] =
      useState("");

  const [suggestions, setSuggestions] = useState([]);    
  const [loading, setLoading] =
      useState(false);

  const [successPopup, setSuccessPopup] =
      useState(false);

  const isPositive =
      rating >= 4;

  // =====================================
  // FETCH BUSINESS
  // =====================================

  useEffect(() => {

    fetchBusiness();
    

  }, []);



async function fetchBusiness() {


  console.log("TOKEN:", token);
  console.log("URL:", window.location.href);
  const { data: linkData, error: linkError } =
    await supabase
      .from("review_links")
      .select("*")
      .eq("token", token)
      .single();

  if (linkError || !linkData) {
    alert("Invalid Review Link");
    return;
  }
  if (linkData.used) {
  alert("Review Already Submitted");
  return;
}

  const { data, error } =
    await supabase
      .from("business_profiles")
      .select("*")
      .eq("id", linkData.business_id)
      .single();

  if (error) {
    console.log(error);
    return;
  }

const { count } = await supabase
  .from("reviews")
  .select("*", {
    count: "exact",
    head: true,
  })
  .eq("business_id", linkData.business_id);

setBusiness({
  ...data,
  total_reviews: count || 0,
});
}

  // =====================================
  // AI REVIEW
  // =====================================


async function generateAIReview(
  mood = "professional"
) {
  try {
    if (!rating) {
      alert("Please select rating first");
      return;
    }

    setLoading(true);

    console.log("Calling Backend...");

    const response = await fetch(
      `${API_URL}/generate-review`,
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          mood,
          rating,
          category:
            business?.category || "Business",
        }),
      }
    );

    console.log(
      "Response Status:",
      response.status
    );

    const data = await response.json();

    console.log(
      "AI Response:",
      data
    );

    if (!response.ok) {
      throw new Error(
        data.error ||
        "Failed to generate review"
      );
    }

    const aiReview = data.review || "";

    setText(aiReview);

    // AI succeeded — suggestions are just the AI review.
    // Static reviews.js reviews are reserved for when AI fails.
    setSuggestions([aiReview]);

  } 
 catch (error) {

  console.log("OpenAI Failed");

  // AI failed — fall back entirely to the static reviews.js
  // data for this rating, with the business name filled in so
  // the suggestions read naturally and stay SEO-friendly.
  const fallbackReviews = getRandomStaticReviews(
    rating,
    3,
    business?.business_name
  );

  setSuggestions(fallbackReviews);
  setText(fallbackReviews[0] || "");


  } finally {

    setLoading(false);
  }
}

  // =====================================
  // COPY REVIEW
  // =====================================

  async function copyReviewText(
      reviewText
  ) {

    try {

      await navigator.clipboard.writeText(
          reviewText
      );

      return true;

    } catch {

      return false;
    }
  }

  // =====================================
  // SUBMIT
  // =====================================

  async function handleSubmit() {

    if (
  business?.total_reviews >=
  business?.review_limit
) {
  alert(
    "Review limit reached. Please upgrade plan."
  );
  return;
}
    if (!rating) {

      alert(
        "Please select rating."
      );

      return;
    }

    if (!text.trim()) {

      alert(
        "Please write review."
      );

      return;
    }

    try {

      setLoading(true);

      const { error } =
          await supabase

              .from("reviews")

              .insert({

                business_id:
business.id,

                customer_name:
                "Anonymous User",

                review:
                text,

                rating:
                rating,
              });

              await supabase
  .from("review_links")
  .update({
    used: true
  })
  .eq("token", token);

      if (error) {

        alert(error.message);

        setLoading(false);

        return;
      }

      await copyReviewText(text);

      setSuccessPopup(true);

      setTimeout(() => {

        setSuccessPopup(false);

      }, 2500);

      if (
          isPositive &&
          business?.google_review_link
      ) {

        setTimeout(() => {

          window.location.href =
              business.google_review_link;

        }, 1800);
      }

    } catch (e) {

      console.log(e);

      alert(
        "Something went wrong."
      );
    }

    setLoading(false);
  }

  // =====================================
  // LOADING
  // =====================================

  if (!business) {

    return (

      <div className="h-screen flex items-center justify-center bg-slate-950">

        <h1 className="text-white text-3xl font-black">
          Loading...
        </h1>
      </div>
    );
  }

  // =====================================
  // MAIN UI
  // =====================================
  {/* REVIEW SUGGESTIONS */}


  return (

    <div className="min-h-screen bg-[#f5f7fb] pb-20">

      {/* HEADER */}

      <div className="bg-white py-10 rounded-b-[40px] shadow-lg">

        <div className="flex flex-col items-center">

          <img
            src={business.logo}
            alt=""

            className="w-24 h-24 sm:w-28 sm:h-28 rounded-full border-4 border-white shadow-2xl object-cover"
          />

         <h1 className="text-3xl font-black mt-5 text-center text-gray-900">

            {business.business_name}

          </h1>

          <p className="mt-2 text-blue-100">
            Verified Business
          </p>
        </div>
      </div>

      {/* BODY */}

      <div className="max-w-xl mx-auto px-5 -mt-14">

        <div className="bg-white rounded-[35px] shadow-2xl p-6 sm:p-8">

          {/* TITLE */}

          <h2 className="text-2xl font-black text-gray-900 text-center">

            Rate Your Experience

          </h2>

          {/* STARS */}

          <div className="flex justify-center gap-3 mt-8">

            {[1,2,3,4,5].map((star) => (

              <button
                key={star}

               onClick={() => {
  setRating(star);

 if (
  business?.total_reviews <
  business?.review_limit
) {
  setTimeout(() => {
    generateAIReview("professional");
  }, 100);
}
}}

                className={`text-6xl transition-all duration-200 hover:scale-125 ${
                  rating >= star
                      ? "text-yellow-400 scale-110"
                      : "text-blue-100"
                }`}
              >
                ★
              </button>
            ))}
          </div>
          {
  loading && (
    <div className="mt-4 text-center">
     <p className="text-blue-600 animate-pulse">
        🤖 Generating SEO Review...
      </p>
    </div>
  )
}
{
  loading && (
    <div className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center">
      <div className="bg-white rounded-3xl p-6 text-center">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto"></div>

        <p className="mt-4 font-bold">
          Generating AI Review...
        </p>

        <p className="text-gray-500 text-sm mt-2">
          Please wait 2-5 seconds
        </p>
      </div>
    </div>
  )
}

          {/* AI BUTTONS */}

     
<div className="mt-6 flex justify-center">
 {business?.total_reviews < business?.review_limit && (
  <button
    onClick={() => generateAIReview("professional")}
    disabled={loading || !rating}
    className="bg-blue-600 text-white px-6 py-3 rounded-xl font-bold"
  >
    Generate AI Review
  </button>
)}
</div>
{business?.total_reviews >=
 business?.review_limit && (
  <div className="mt-6 text-center">
    <p className="text-red-600 font-bold">
      Review limit reached.
      Please upgrade your plan.
    </p>
  </div>
)}
          {/* REVIEW SUGGESTIONS */}

{business?.total_reviews < business?.review_limit &&
 suggestions.length > 0 && (
  <div className="mt-8">

    <h3 className="text-gray-800 text-lg font-bold mb-4">
      Suggested Reviews
    </h3>

   <div className="flex gap-3 overflow-x-auto mt-8 pb-2">
  {suggestions.map((review, index) => (
    <div
      key={index}
      onClick={() => setText(review)}
      className="
        min-w-[260px]
        bg-white
        border
        rounded-[24px]
        p-5
        cursor-pointer
        shadow-sm
      "
    >
      <p className="text-gray-800 text-lg leading-8">
        {review}
      </p>
    </div>
  ))}
</div>

  </div>
)}

          {/* TEXTAREA */}

          <textarea

            value={text}

            onChange={(e) =>
                setText(
                    e.target.value
                )
            }

            placeholder="Rate your experience to see suggestions..."

            className="
w-full
h-44
bg-white
text-gray-800
rounded-3xl
p-5
mt-6
outline-none
border-2
border-gray-200
focus:border-blue-500
resize-none
"
          />

          {/* CHARACTER */}

          <div className="flex justify-between mt-3 text-sm text-gray-500">

            <span>
              AI-powered smart review
            </span>

            <span>
              {text.length}/500
            </span>
          </div>

          {/* POPUP */}

          {
            successPopup && (

              <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 backdrop-blur-sm px-5">

                <div className="bg-[#021B3A] border border-blue-400/20 rounded-[35px] p-8 w-full max-w-sm shadow-2xl text-center">

                  <div className="w-20 h-20 bg-green-100 rounded-full flex items-center justify-center mx-auto">

                    <span className="text-5xl">
                      ✅
                    </span>
                  </div>

                  <h2 className="text-2xl font-black text-white mt-6">

                    Review Copied!

                  </h2>

                  <p className="text-blue-100 mt-3 leading-7">

                    Opening Google review page...

                  </p>
                </div>
              </div>
            )
          }

          {/* BUTTON */}

          <button

            onClick={handleSubmit}

            disabled={
              loading ||
              !text.trim()
            }

            className={`w-full py-5 rounded-3xl mt-8 text-lg sm:text-xl font-black text-white transition-all duration-300 hover:scale-[1.02] active:scale-95 ${
              isPositive

                  ? "bg-gradient-to-r from-[#005BEA] to-[#003D9B]"

                  : "bg-gradient-to-r from-red-500 to-pink-600"
            }`}
          >

            {
              loading

                  ? "Please Wait..."

                  : isPositive

                      ? "Ready to Review"
                      : "Submit Review"
            }

          </button>
        </div>
      </div>
    </div>
  );
}