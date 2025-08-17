module MyModule::InstructorReputation {
    use aptos_framework::signer;
    use std::vector;

    /// Struct representing an instructor's reputation profile
    struct InstructorProfile has store, key {
        total_ratings: u64,      // Total number of ratings received
        rating_sum: u64,         // Sum of all ratings (for average calculation)
        course_count: u64,       // Number of courses taught
        student_reviews: vector<u64>, // Vector storing individual ratings (1-5 scale)
    }

    /// Error codes
    const E_INVALID_RATING: u64 = 1;
    const E_INSTRUCTOR_NOT_FOUND: u64 = 2;

    /// Function to initialize an instructor's reputation profile
    public fun create_instructor_profile(instructor: &signer) {
        let profile = InstructorProfile {
            total_ratings: 0,
            rating_sum: 0,
            course_count: 0,
            student_reviews: vector::empty<u64>(),
        };
        move_to(instructor, profile);
    }

    /// Function for students to rate an instructor (rating scale: 1-5)
    public fun rate_instructor(
        student: &signer, 
        instructor_address: address, 
        rating: u64
    ) acquires InstructorProfile {
        // Validate rating is between 1-5
        assert!(rating >= 1 && rating <= 5, E_INVALID_RATING);
        
        // Get instructor's profile
        assert!(exists<InstructorProfile>(instructor_address), E_INSTRUCTOR_NOT_FOUND);
        let profile = borrow_global_mut<InstructorProfile>(instructor_address);
        
        // Update reputation metrics
        profile.total_ratings = profile.total_ratings + 1;
        profile.rating_sum = profile.rating_sum + rating;
        vector::push_back(&mut profile.student_reviews, rating);
        
        // Increment course count for every 10 ratings (simplified logic)
        if (profile.total_ratings % 10 == 0) {
            profile.course_count = profile.course_count + 1;
        };
    }

    /// View function to get instructor's average rating
    #[view]
    public fun get_average_rating(instructor_address: address): u64 acquires InstructorProfile {
        let profile = borrow_global<InstructorProfile>(instructor_address);
        if (profile.total_ratings == 0) {
            return 0
        };
        profile.rating_sum / profile.total_ratings
    }
}