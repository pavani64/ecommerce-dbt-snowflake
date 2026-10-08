select
    cast(
        date_trunc('month', review_creation_date)
        as date
    ) as review_month,

    count(*) as review_count,

    avg(review_score) as average_review_score,

    count(
        case
            when review_score_category = 'positive'
            then 1
        end
    ) as positive_review_count,

    count(
        case
            when review_score_category = 'neutral'
            then 1
        end
    ) as neutral_review_count,

    count(
        case
            when review_score_category = 'negative'
            then 1
        end
    ) as negative_review_count,

    count(
        case
            when review_comment_message is not null
             and trim(review_comment_message) <> ''
            then 1
        end
    ) as reviews_with_comments

from {{ ref('int_order_reviews') }}

group by
    cast(
        date_trunc('month', review_creation_date)
        as date
    )