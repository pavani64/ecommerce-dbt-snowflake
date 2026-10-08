select
    review_id,
    order_id,
    review_score,
    review_comment_title,
    review_comment_message,
    review_creation_date,
    review_answer_timestamp,

    case
        when review_score <= 2 then 'negative'
        when review_score = 3 then 'neutral'
        when review_score >= 4 then 'positive'
    end as review_score_category

from {{ ref('stg_order_reviews') }}