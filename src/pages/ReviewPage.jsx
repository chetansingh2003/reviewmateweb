import { useEffect, useState } from "react";
import { createClient } from "@supabase/supabase-js";
import { useSearchParams } from "react-router-dom";

const supabase = createClient(
  "https://pwaaldsnrjhexahaoqzs.supabase.co",

  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB3YWFsZHNucmpoZXhhaGFvcXpzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzkwMzIzNTksImV4cCI6MjA5NDYwODM1OX0.KdIyjjl3rfNFAuTLxlfhZDKwXvlDRPfAHYi1plSQ1Wk"
);

export default function ReviewScreen() {

  const [searchParams] =
      useSearchParams();

  const businessId =
      searchParams.get("id");

  const [business, setBusiness] =
      useState(null);

  const [rating, setRating] =
      useState(0);

  const [text, setText] =
      useState("");

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

    const { data, error } =
        await supabase

            .from("business_profiles")

            .select()

            .eq("id", businessId)

            .single();

    if (error) {

      console.log(error);

      return;
    }

    setBusiness(data);
  }

  // =====================================
  // AI REVIEW
  // =====================================

  function generateAIReview(
      mood = "professional"
  ) {

    const category =
        business?.category || "";

    if (category === "restaurant") {

      const reviews = {

        professional:
            "Amazing food quality and excellent customer service. The restaurant atmosphere was clean, cozy, and highly professional.",

        friendly:
            "Loved the food and staff behaviour. Definitely coming again with friends and family!",

        emotional:
            "One of the best restaurant experiences I’ve ever had. Everything felt perfect and memorable.",
      };

      setText(reviews[mood]);
    }

    else {

      const reviews = {

        professional:
            "Excellent experience and professional service. Highly recommended!",

        friendly:
            "Amazing experience and very friendly staff!",

        emotional:
            "I genuinely loved the experience and felt valued as a customer.",
      };

      setText(reviews[mood]);
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
                businessId,

                customer_name:
                "Anonymous User",

                review:
                text,

                rating:
                rating,
              });

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

  return (

    <div className="min-h-screen bg-gradient-to-br from-[#021B3A] via-[#003D9B] to-[#005BEA] pb-32">

      {/* HEADER */}

      <div className="relative bg-gradient-to-r from-[#005BEA] via-[#003D9B] to-[#021B3A] text-white px-6 pt-14 pb-24 rounded-b-[50px]">

        <div className="flex flex-col items-center">

          <img
            src={business.logo}
            alt=""

            className="w-24 h-24 sm:w-28 sm:h-28 rounded-full border-4 border-white shadow-2xl object-cover"
          />

          <h1 className="text-3xl md:text-4xl font-black mt-5 text-center">

            {business.business_name}

          </h1>

          <p className="mt-2 text-blue-100">
            Verified Business
          </p>
        </div>
      </div>

      {/* BODY */}

      <div className="max-w-xl mx-auto px-5 -mt-14">

        <div className="bg-white/10 backdrop-blur-2xl border border-white/10 rounded-[35px] shadow-2xl p-6 sm:p-8">

          {/* TITLE */}

          <h2 className="text-2xl font-black text-white text-center">

            Rate Your Experience

          </h2>

          {/* STARS */}

          <div className="flex justify-center gap-3 mt-8">

            {[1,2,3,4,5].map((star) => (

              <button
                key={star}

                onClick={() =>
                    setRating(star)
                }

                className={`text-5xl transition-all duration-200 hover:scale-125 ${
                  rating >= star
                      ? "text-yellow-400 scale-110"
                      : "text-blue-100"
                }`}
              >
                ★
              </button>
            ))}
          </div>

          {/* AI BUTTONS */}

          <div className="grid grid-cols-3 gap-3 mt-8">

            <button

              onClick={() =>
                  generateAIReview(
                      "professional"
                  )
              }

              className="bg-[#005BEA] hover:bg-[#0048BA] text-white py-3 rounded-2xl font-bold"
            >
              Professional
            </button>

            <button

              onClick={() =>
                  generateAIReview(
                      "friendly"
                  )
              }

              className="bg-[#00A3FF] hover:bg-[#008AE0] text-white py-3 rounded-2xl font-bold"
            >
              Friendly
            </button>

            <button

              onClick={() =>
                  generateAIReview(
                      "emotional"
                  )
              }

              className="bg-[#4F7CFF] hover:bg-[#3A63D8] text-white py-3 rounded-2xl font-bold"
            >
              Emotional
            </button>
          </div>

          {/* TEXTAREA */}

          <textarea

            value={text}

            onChange={(e) =>
                setText(
                    e.target.value
                )
            }

            placeholder="Write your review..."

            className="w-full h-44 border border-white/10 bg-white/10 text-white placeholder:text-blue-100 rounded-3xl p-5 mt-8 outline-none focus:border-blue-400 resize-none text-lg"
          />

          {/* CHARACTER */}

          <div className="flex justify-between mt-3 text-sm text-blue-100">

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

                      ? "Copy & Open Google Review"

                      : "Submit Private Feedback"
            }

          </button>
        </div>
      </div>
    </div>
  );
}